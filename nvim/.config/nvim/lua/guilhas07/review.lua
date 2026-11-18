-- Commit-by-commit branch review.
--
-- :Review [base]    backup branch -> `git rebase -i` with every commit set to `edit`
--                   -> diffview of the stopped commit, with a COMMIT_MSG entry on top
--                   If a :Review rebase is already in progress, reopens it at the current commit.
-- :ReviewContinue   amend file edits + edited message into the stopped commit, go to next
-- :ReviewAbort      `git rebase --abort`, back to the pre-review state
-- :ReviewFinish     like :ReviewContinue, but apply the remaining commits as-is (no more stops)
-- :ReviewTodos      reopen the TODO quickfix list (current + window), see below
-- :ReviewList       toggle the commit list (right column of the diff tab, shown at every stop)
--                   ✓ done  ▶ current  ○ queued (stops)  · queued (applied without stop)
--                   <CR> on a later commit: amend current, apply the ones between, stop there.
--                   <CR> on an earlier one (asks first): :ReviewFinish, then a new review from
--                   that commit's parent (all stop again); review-backup/<branch> is kept.
--
-- Each stop also fills a "Review TODOs" quickfix list with TODO/FIXME/HACK/XXX on lines the
-- commit adds (plus your edits), refreshed with the view.
--
-- COMMIT_MSG entry: single editable window (like added files). It is backed by an
-- untracked file at the repo root (never committed: -a only takes tracked files), removed
-- when the review finishes or is aborted.
local M = {}

local BACKUP_PREFIX = "review-backup/"
local MSG = "COMMIT_MSG"

local function git(args, env)
	local res = vim.system(vim.list_extend({ "git" }, args), { text = true, env = env }):wait()
	return res.code == 0, vim.trim(res.stdout or ""), vim.trim(res.stderr or "")
end

local function err(msg)
	vim.notify("Review: " .. msg, vim.log.levels.ERROR)
end

local function info(msg)
	vim.notify("Review: " .. msg, vim.log.levels.INFO)
end

local function toplevel()
	local _, t = git({ "rev-parse", "--show-toplevel" })
	return t
end

local function rebase_dir()
	local _, p = git({ "rev-parse", "--path-format=absolute", "--git-path", "rebase-merge" })
	return p
end

local function in_rebase()
	return vim.fn.isdirectory(rebase_dir()) == 1
end

-- git writes rebase-merge/amend only when stopped at an `edit` (not on a conflict stop)
local function at_edit_stop()
	return vim.fn.filereadable(rebase_dir() .. "/amend") == 1
end

local function progress()
	local dir = rebase_dir()
	local n = vim.fn.filereadable(dir .. "/msgnum") == 1 and vim.fn.readfile(dir .. "/msgnum")[1] or "?"
	local total = vim.fn.filereadable(dir .. "/end") == 1 and vim.fn.readfile(dir .. "/end")[1] or "?"
	local _, subject = git({ "log", "-1", "--format=%h %s", "HEAD" })
	return string.format("[%s/%s] %s", n, total, subject)
end

local function head_message()
	local _, m = git({ "log", "-1", "--format=%B", "HEAD" })
	return m
end

local function tracked_dirty()
	local _, out = git({ "status", "--porcelain", "--untracked-files=no" })
	return out ~= ""
end

local function unsaved_buffers()
	local out = {}
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].modified and vim.bo[b].buftype == "" then
			table.insert(out, vim.api.nvim_buf_get_name(b))
		end
	end
	return out
end

local function close_view()
	local ok, lib = pcall(require, "diffview.lib")
	if ok and lib.get_current_view() then
		vim.cmd("DiffviewClose")
	end
end

-- COMMIT_MSG file ----------------------------------------------------------

local function msg_path()
	return toplevel() .. "/" .. MSG
end

-- Records which commit (HEAD sha) the COMMIT_MSG file was written for. Also marks the
-- in-progress rebase as started by :Review.
local function msg_marker()
	return rebase_dir() .. "/review-msg-head"
end

local function remove_msg_file()
	local path = msg_path()
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(b) == path then
			vim.api.nvim_buf_delete(b, { force = true })
		end
	end
	vim.fn.delete(path)
end

-- TODO quickfix -----------------------------------------------------------------

local TODO_KEYWORDS = { "TODO", "FIXME", "HACK", "XXX" }
local todo_qf_id -- quickfix list owned by :Review, reused across stops

-- TODO-style words on lines added between parent and working tree (this commit + your edits).
-- Plain text match on `git diff -U0` + lines: language-agnostic, no parser needed.
-- No vim.fn calls: also runs from diffview's update_files (may be a fast context).
local function added_todos(parent)
	local root = toplevel()
	local _, out = git({ "-c", "core.quotePath=false", "diff", "-U0", "--no-color", "--no-ext-diff", parent })
	local items, file, lnum, in_header = {}, nil, 0, false
	for _, line in ipairs(vim.split(out, "\n", { plain = true })) do
		if vim.startswith(line, "diff --git ") then
			in_header, file = true, nil
		elseif in_header and vim.startswith(line, "+++ ") then
			local path = line:match("^%+%+%+ b/(.-)\t?$")
			file = path and (root .. "/" .. path) or nil -- nil: deleted file (+++ /dev/null)
		elseif vim.startswith(line, "@@") then
			in_header = false
			lnum = tonumber(line:match("^@@ %-%S+ %+(%d+)")) or 0
		elseif not in_header and file and line:sub(1, 1) == "+" then
			local text = line:sub(2)
			for _, kw in ipairs(TODO_KEYWORDS) do
				local col = text:find("%f[%w]" .. kw .. "%f[%W]")
				if col then
					table.insert(items, { filename = file, lnum = lnum, col = col, text = vim.trim(text) })
					break
				end
			end
			lnum = lnum + 1
		end
	end
	return items
end

local function todo_list_exists()
	return todo_qf_id ~= nil and vim.fn.getqflist({ id = todo_qf_id }).id ~= 0
end

-- Make the TODO list the current quickfix list again (e.g. after grr pushed references on top).
local function make_todo_list_current()
	local nr = vim.fn.getqflist({ id = todo_qf_id, nr = 0 }).nr
	vim.cmd("silent " .. nr .. "chistory")
end

-- One quickfix list for the whole review, replaced in place.
-- open=true (new stop / :ReviewTodos): make it current and show it; when empty, close the window
--   (stop) or say so (explicit = :ReviewTodos).
-- open=false (view refresh): only update the items.
local function show_todos(parent, open, explicit)
	local items = added_todos(parent)
	vim.schedule(function()
		local what = { title = "Review TODOs", items = items }
		if todo_list_exists() then
			what.id = todo_qf_id
			vim.fn.setqflist({}, "r", what)
			if open then
				make_todo_list_current()
			end
		elseif open then
			vim.fn.setqflist({}, " ", what)
			todo_qf_id = vim.fn.getqflist({ id = 0 }).id
		end
		if not open then
			return
		end
		if #items > 0 then
			vim.cmd("botright copen " .. math.min(#items, 10))
			vim.cmd("wincmd p") -- keep focus in the diff
		elseif explicit then
			info("no TODOs added by this commit")
		else
			vim.cmd("cclose")
		end
	end)
	return #items
end

-- Commit list -------------------------------------------------------------------

local start -- defined in Commands below

local list = { enabled = true, buf = nil, entries = {} }
local list_ns = vim.api.nvim_create_namespace("guilhas07.review.list")

local COMMIT_CMDS = {
	pick = true, p = true, reword = true, r = true, edit = true, e = true,
	squash = true, s = true, fixup = true, f = true, drop = true, d = true,
}
local STOP_CMDS = { edit = true, e = true }
local PLAIN_CMDS = { pick = true, p = true, edit = true, e = true } -- 1 todo line = 1 commit

-- Commit lines of a todo-format file (`edit <sha> # subject`); idx = line number in the file.
local function read_todo(file)
	local out = {}
	if vim.fn.filereadable(file) == 0 then
		return out
	end
	for idx, line in ipairs(vim.fn.readfile(file)) do
		local cmd, sha = line:match("^(%S+)%s+(%x+)")
		if cmd and COMMIT_CMDS[cmd] then
			table.insert(out, { cmd = cmd, sha = sha, idx = idx })
		end
	end
	return out
end

-- Shas of the done commits as they are now (after amends), done[i] -> i-th commit after onto.
-- nil when that isn't 1:1 (squash/fixup/drop, or a commit that became empty).
local function done_shas(done)
	for _, c in ipairs(done) do
		if not PLAIN_CMDS[c.cmd] then
			return nil
		end
	end
	local onto = vim.fn.readfile(rebase_dir() .. "/onto")[1]
	local _, out = git({ "rev-list", "--reverse", onto .. "..HEAD" })
	local revs = out == "" and {} or vim.split(out, "\n")
	return #revs == #done and revs or nil
end

-- done (last = current stop) + queued. Done entries carry their current sha (nil if unknown).
local function list_entries()
	local dir = rebase_dir()
	local done = read_todo(dir .. "/done")
	local revs = done_shas(done)
	local entries = {}
	for i, c in ipairs(done) do
		local sha = revs and revs[i]
		table.insert(entries, { state = i == #done and "current" or "done", sha = sha, show = sha or c.sha })
	end
	for _, c in ipairs(read_todo(dir .. "/git-rebase-todo")) do
		local state = STOP_CMDS[c.cmd] and "queued" or "apply" -- apply: no stop
		table.insert(entries, { state = state, idx = c.idx, show = c.sha })
	end
	local shas = vim.tbl_map(function(e)
		return e.show
	end, entries)
	local _, out = git(vim.list_extend({ "show", "-s", "--format=%h %s" }, shas))
	local subjects = vim.split(out, "\n")
	for i, e in ipairs(entries) do
		e.subject = subjects[i] or e.show:sub(1, 7)
	end
	return entries
end

local MARK = { done = "✓", current = "▶", queued = "○", apply = "·" }
local HL = { done = "Comment", current = "Title", apply = "Comment" }

local function list_win()
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(w) == list.buf then
			return w
		end
	end
end

local function check_unsaved()
	local unsaved = unsaved_buffers()
	if #unsaved > 0 then
		err("unsaved buffers:\n" .. table.concat(unsaved, "\n"))
		return false
	end
	return true
end

-- Rewrite todo lines in place: f(line, i) -> new line.
local function edit_todo(f)
	local todo = rebase_dir() .. "/git-rebase-todo"
	local lines = vim.fn.readfile(todo)
	for i, line in ipairs(lines) do
		lines[i] = f(line, i)
	end
	vim.fn.writefile(lines, todo)
end

local function to_pick(line)
	return (line:gsub("^edit ", "pick "):gsub("^e ", "pick "))
end

local function jump(entry)
	if not at_edit_stop() then
		return err("resolve the conflict first (:ReviewContinue)")
	end
	if entry.state == "current" or not check_unsaved() then
		return
	end

	if entry.state == "queued" or entry.state == "apply" then
		-- forward: amend current, apply everything before the target without stopping
		edit_todo(function(line, i)
			if i < entry.idx then
				return to_pick(line)
			elseif i == entry.idx then
				return (line:gsub("^pick ", "edit "):gsub("^p ", "edit "))
			end
			return line
		end)
		return M.continue()
	end

	-- backward: finish this rebase, then a new one from the target's parent
	if not entry.sha then
		return err("can't map done commits to their current shas (squash/fixup/drop?), go back by hand")
	end
	local n = 0
	for _, e in ipairs(list.entries) do
		n = n + ((e.state == "queued" or e.state == "apply") and 1 or 0)
	end
	local msg = string.format(
		"Go back to %s?\n\nThis amends your edits into the current commit, applies the %d remaining commit(s) "
			.. "without review, then restarts the review at that commit. Every commit from there on stops again.\n"
			.. "Backup branch is kept (original undo point).",
		entry.subject,
		n
	)
	if vim.fn.confirm(msg, "&Go back\n&Cancel", 2, "Warning") ~= 1 then
		return
	end
	-- same onto: earlier commits are picked unchanged (fast-forward, same shas), list stays whole
	local onto = vim.fn.readfile(rebase_dir() .. "/onto")[1]
	M.finish(function()
		start(onto, { keep_backup = true, from = entry.sha })
	end)
end

local function render_list()
	local entries = list_entries()
	local lines, current = {}, 1
	for i, e in ipairs(entries) do
		lines[i] = MARK[e.state] .. " " .. e.subject
		if e.state == "current" then
			current = i
		end
	end
	list.entries = entries

	local buf = list.buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].filetype = "reviewlist"
		pcall(vim.api.nvim_buf_set_name, buf, "Review commits")
		local o = { buffer = buf, nowait = true }
		vim.keymap.set("n", "<CR>", function()
			local e = list.entries[vim.api.nvim_win_get_cursor(0)[1]]
			if e then
				jump(e)
			end
		end, vim.tbl_extend("force", o, { desc = "Review: jump to commit" }))
		vim.keymap.set("n", "q", function()
			M.list(false)
		end, vim.tbl_extend("force", o, { desc = "Review: hide commit list" }))
		list.buf = buf
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.api.nvim_buf_clear_namespace(buf, list_ns, 0, -1)
	for i, e in ipairs(entries) do
		if HL[e.state] then
			vim.api.nvim_buf_set_extmark(buf, list_ns, i - 1, 0, { end_col = #lines[i], hl_group = HL[e.state] })
		end
	end
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	return math.max(30, math.min(width + 1, 60)), current
end

-- Commit list: own column at the far right of the diffview tab. Not under the file panel:
-- diffview closes/reopens the panel (`wincmd H`) on every layout switch (COMMIT_MSG <-> diff),
-- which would tear a split under it apart.
local function show_list()
	local width, current = render_list()
	local win = list_win()
	if not win then
		vim.api.nvim_win_call(0, function()
			vim.cmd("botright " .. width .. "vsplit")
			win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(win, list.buf)
		end)
	end
	local wo = vim.wo[win]
	wo.winfixwidth = true -- diffview runs `wincmd =` on layout switches
	wo.number, wo.relativenumber, wo.signcolumn, wo.wrap = false, false, "no", false
	wo.cursorline = true
	vim.api.nvim_win_set_cursor(win, { current, 0 })
end

-- Diff view of the stopped commit ---------------------------------------------

-- Files changed between parent and working tree (= this commit + your edits), COMMIT_MSG first.
local function changed_files(parent, select_msg)
	local _, out = git({ "diff", "--name-status", "-M", "-z", parent })
	local parts = vim.split(out, "\0", { plain = true })
	local files = { { path = MSG, status = "M", selected = select_msg } }
	local renames = {}
	local i = 1
	while i <= #parts and parts[i] ~= "" do
		local letter = parts[i]:sub(1, 1)
		if letter == "R" or letter == "C" then
			table.insert(files, { path = parts[i + 2], oldpath = parts[i + 1], status = letter })
			renames[parts[i + 2]] = parts[i + 1]
			i = i + 3
		else
			table.insert(files, { path = parts[i + 1], status = letter })
			i = i + 2
		end
	end
	return files, renames
end

local function open_view()
	require("diffview")
	local CDiffView = require("diffview.api.views.diff.diff_view").CDiffView
	local GitRev = require("diffview.vcs.adapters.git.rev").GitRev
	local RevType = require("diffview.vcs.rev").RevType
	local lib = require("diffview.lib")

	local root = toplevel()
	local _, parent = git({ "rev-parse", "HEAD~1" })
	local _, head = git({ "rev-parse", "HEAD" })
	local original = vim.split(head_message(), "\n")

	-- Keep an existing COMMIT_MSG (saved edits, e.g. nvim restarted mid-review) only if the
	-- marker says it was written for this commit. Marker lives in rebase-merge/: git removes it.
	local path, marker = msg_path(), msg_marker()
	local readable = vim.fn.filereadable
	local keep = readable(path) == 1 and readable(marker) == 1 and vim.fn.readfile(marker)[1] == head
	if not keep then
		if readable(path) == 1 then
			vim.notify("Review: " .. MSG .. " belonged to another commit, regenerated", vim.log.levels.WARN)
		end
		remove_msg_file()
		vim.fn.writefile(original, path)
		vim.fn.writefile({ head }, marker)
	end

	local renames = {}
	local function fetch(select_msg)
		local files
		files, renames = changed_files(parent, select_msg)
		return { working = files }
	end

	local view = CDiffView({
		git_root = root,
		left = GitRev(RevType.COMMIT, parent),
		right = GitRev(RevType.LOCAL), -- real files on disk: editable
		files = fetch(true),
		update_files = function()
			show_todos(parent, false)
			return fetch(false) -- refresh must not jump back to COMMIT_MSG
		end,
		-- only called for the left side (right is LOCAL)
		get_file_data = function(_, path, _)
			if path == MSG then
				return original
			end
			local res = vim.system({ "git", "show", parent .. ":" .. (renames[path] or path) }, {
				cwd = root,
				text = true,
			}):wait()
			if res.code ~= 0 then
				return {} -- added file: empty left side
			end
			local lines = vim.split(res.stdout, "\n")
			if lines[#lines] == "" then
				table.remove(lines)
			end
			return lines
		end,
	})
	-- diffview treats "path missing at rev" as binary (null buffer). COMMIT_MSG never exists in
	-- git, and renamed files exist under their old path at the parent. Patch this view's adapter only.
	local is_binary = view.adapter.is_binary
	view.adapter.is_binary = function(self, path, rev)
		if path == MSG then
			return false
		end
		if rev.type == RevType.COMMIT then
			path = renames[path] or path
		end
		return is_binary(self, path, rev)
	end

	-- COMMIT_MSG and added files: single editable window (diffview's diff1_plain layout)
	-- instead of side-by-side. Applied to the initial entries and to every refresh.
	local Diff1 = require("diffview.scene.layouts.diff_1").Diff1
	local function single_window(entries)
		for _, entry in ipairs(entries or {}) do
			if entry.path == MSG or entry.status == "A" then
				entry:convert_layout(Diff1)
			end
		end
	end
	single_window(view.files.working)
	local create_file_entries = view.create_file_entries
	view.create_file_entries = function(self, files)
		local entries = create_file_entries(self, files)
		single_window(entries.working)
		return entries
	end

	lib.add_view(view)
	view:open()
	if list.enabled then
		show_list()
	end
	local n = show_todos(parent, true)
	info(progress() .. (n > 0 and string.format(" · %d TODO%s", n, n == 1 and "" or "s") or ""))
end

local function show_range_diff()
	local _, branch = git({ "branch", "--show-current" })
	local backup = BACKUP_PREFIX .. branch
	local _, out = git({ "range-diff", "--no-color", backup .. "...HEAD" })
	if out == "" then
		return info("done, no changes (" .. backup .. " == HEAD)")
	end
	vim.cmd("tabnew")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(out, "\n"))
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].modified = false
	vim.bo[buf].filetype = "diff"
	info("done; range-diff vs " .. backup .. " (undo: git reset --hard " .. backup .. ")")
end

-- Commands ---------------------------------------------------------------

-- Reopen the view of a review already in progress (e.g. after restarting nvim).
local function resume()
	local dir = rebase_dir()
	local head_name = vim.fn.filereadable(dir .. "/head-name") == 1 and vim.fn.readfile(dir .. "/head-name")[1] or ""
	local branch = (head_name:gsub("^refs/heads/", ""))
	local has_backup = branch ~= ""
		and git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. BACKUP_PREFIX .. branch })
	if not has_backup or vim.fn.filereadable(msg_marker()) == 0 then
		return err("rebase in progress was not started by :Review, finish it with git first")
	end
	close_view()
	if at_edit_stop() then
		info("resuming review of " .. branch)
		return open_view()
	end
	err("resuming at a conflict stop, resolve in merge view then :ReviewContinue")
	vim.cmd("DiffviewOpen")
end

-- opts (commit jump back): keep_backup = review-backup/<branch> already holds the original
-- pre-review state and must not move; from = first commit to stop at (earlier ones: pick).
function start(base, opts)
	opts = opts or {}
	if in_rebase() then
		return resume()
	end
	local _, branch = git({ "branch", "--show-current" })
	if branch == "" then
		return err("detached HEAD, checkout a branch first")
	end
	if vim.startswith(branch, BACKUP_PREFIX) then
		return err("'" .. branch .. "' is a backup branch, checkout the real branch")
	end
	if tracked_dirty() then
		return err("uncommitted changes to tracked files, commit them first")
	end
	if git({ "ls-files", "--error-unmatch", MSG }) then
		return err("repo tracks a file named " .. MSG .. ", can't use it for the message entry")
	end
	if vim.fn.filereadable(msg_path()) == 1 then
		return err(msg_path() .. " exists (stale from a previous review?), remove it first")
	end

	if not base or base == "" then
		local ok, ref = git({ "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })
		base = (ok and ref ~= "") and ref or "origin/main"
	end
	local ok, mb, e = git({ "merge-base", base, "HEAD" })
	if not ok then
		return err("no merge-base with " .. base .. ": " .. e)
	end
	local _, count = git({ "rev-list", "--count", mb .. "..HEAD" })
	if tonumber(count) == 0 then
		return err("no commits ahead of " .. base)
	end
	local _, merges = git({ "rev-list", "--merges", mb .. "..HEAD" })
	if merges ~= "" then
		return err("branch has merge commits, rebase would flatten them")
	end

	local backup = BACKUP_PREFIX .. branch
	if opts.keep_backup then
		if not git({ "rev-parse", "--verify", "--quiet", "refs/heads/" .. backup }) then
			return err(backup .. " missing, not restarting")
		end
	else
		ok, _, e = git({ "branch", "-f", backup, "HEAD" })
		if not ok then
			return err("backup failed: " .. e)
		end
	end

	-- rebase onto the merge-base, not base itself: review only, never moves the branch onto newer base
	-- the editor sees abbreviated shas (>= 7 chars): match on a 7-char prefix
	local range = opts.from and ("/^pick " .. opts.from:sub(1, 7) .. "/,$ ") or ""
	ok, _, e = git({ "rebase", "-i", mb }, {
		GIT_SEQUENCE_EDITOR = "sed -i -e '" .. range .. "s/^pick /edit /'",
		GIT_EDITOR = "true",
	})
	if not in_rebase() then
		return err("rebase did not start: " .. e)
	end
	info((opts.keep_backup and "restarted, backup still at " or "backup at ") .. backup)
	open_view()
end

function M.start(base)
	start(base)
end

-- on_done: called instead of showing the range-diff when the rebase ends (commit jump back).
function M.continue(on_done)
	if not in_rebase() then
		return err("no review in progress")
	end
	if not check_unsaved() then
		return
	end

	if at_edit_stop() then
		local path = msg_path()
		local edited = vim.fn.filereadable(path) == 1 and table.concat(vim.fn.readfile(path), "\n") or nil
		local msg_changed = edited ~= nil and vim.trim(edited) ~= vim.trim(head_message())
		if tracked_dirty() or msg_changed then
			local args = msg_changed and { "commit", "-a", "--amend", "--cleanup=whitespace", "-F", path }
				or { "commit", "-a", "--amend", "--no-edit" }
			local ok, _, e = git(args)
			if not ok then
				return err("amend failed: " .. e)
			end
		end
	else
		-- conflict stop: the commit isn't created yet, `rebase --continue` creates it
		local _, unmerged = git({ "diff", "--name-only", "--diff-filter=U" })
		if unmerged ~= "" then
			return err("unresolved conflicts, stage resolved files (`-` in diffview panel):\n" .. unmerged)
		end
		git({ "add", "-u" })
	end

	close_view()
	remove_msg_file()
	local ok, _, e = git({ "rebase", "--continue" }, { GIT_EDITOR = "true" })
	vim.cmd("checktime")

	if not in_rebase() then
		if on_done then
			return on_done()
		end
		return show_range_diff()
	end
	if not ok then
		if on_done then
			err("jump back cancelled: rebase stopped on conflict")
		end
		err("stopped on conflict, resolve in merge view then :ReviewContinue\n" .. e)
		return vim.cmd("DiffviewOpen")
	end
	open_view()
end

function M.finish(on_done)
	if not in_rebase() then
		return err("no review in progress")
	end
	-- Checked here too so a refusal doesn't leave the todo already rewritten
	if not check_unsaved() then
		return
	end
	edit_todo(to_pick) -- remaining commits: `edit` -> `pick`
	M.continue(on_done)
end

-- Show (on=true), hide (false) or toggle (nil) the commit list; remembered for later stops.
function M.list(on)
	if on == nil then
		on = list_win() == nil
	end
	list.enabled = on
	local win = list_win()
	if not on then
		if win then
			vim.api.nvim_win_close(win, true)
		end
		return
	end
	if not in_rebase() or not at_edit_stop() then
		return err("no review stop in progress")
	end
	show_list()
end

function M.todos()
	if not in_rebase() or not at_edit_stop() then
		return err("no review stop in progress")
	end
	local _, parent = git({ "rev-parse", "HEAD~1" })
	show_todos(parent, true, true)
end

function M.abort()
	if not in_rebase() then
		return err("no review in progress")
	end
	close_view()
	remove_msg_file()
	local ok, _, e = git({ "rebase", "--abort" })
	vim.cmd("checktime")
	if not ok then
		return err("abort failed: " .. e)
	end
	info("aborted, branch back to pre-review state")
end

function M.setup()
	vim.api.nvim_create_user_command("Review", function(o)
		M.start(o.args)
	end, { nargs = "?", desc = "Review branch commit by commit" })
	-- wrapped: the command opts table must not reach the on_done parameter
	vim.api.nvim_create_user_command("ReviewContinue", function()
		M.continue()
	end, { desc = "Amend edits, next commit" })
	vim.api.nvim_create_user_command("ReviewAbort", M.abort, { desc = "Abort review rebase" })
	vim.api.nvim_create_user_command("ReviewFinish", function()
		M.finish()
	end, { desc = "Amend edits, apply remaining commits without stopping" })
	vim.api.nvim_create_user_command("ReviewList", function()
		M.list()
	end, { desc = "Toggle the review commit list" })
	vim.api.nvim_create_user_command("ReviewTodos", M.todos, { desc = "Show TODOs added by the stopped commit" })
end

return M
