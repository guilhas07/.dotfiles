-- Hyprland Lua config (migrated from hyprland.conf, Hyprland 0.56)
-- API reference: /usr/share/hypr/stubs/hl.meta.lua, example: /usr/share/hypr/hyprland.lua


------------------
---- MONITORS ----
------------------

local LAPTOP = "eDP-1"

hl.monitor({ output = LAPTOP, mode = "preferred", position = "auto", scale = 1.25 })
-- any external monitor (any port): extend, placed left of the laptop
local EXTERNAL = { position = "auto-left", scale = 1 }
hl.monitor({ output = "", mode = "preferred", position = EXTERNAL.position, scale = EXTERNAL.scale })

-- Modes: native resolution at its highest refresh rate, on any monitor. None of the
-- built-in modes does this: "preferred" is native but usually 60 Hz (EDID preferred
-- timing), "highres" picks a fake 4K that many 1080p gaming monitors accept and
-- downscale, "highrr" can drop to a lower resolution if it refreshes faster.
-- Applied at runtime as per-connector rules (named after the port, e.g. HDMI-A-1).
local function native_max_refresh(m)
    local native
    for _, mode in ipairs(m.available_modes or {}) do
        if mode.preferred then native = mode break end
    end
    if not native then return nil end

    local best = native
    for _, mode in ipairs(m.available_modes) do
        if mode.width == native.width and mode.height == native.height
            and mode.refresh_rate > best.refresh_rate then
            best = mode
        end
    end
    return string.format("%dx%d@%.2f", best.width, best.height, best.refresh_rate)
end

local function apply_modes()
    for _, m in ipairs(hl.get_monitors()) do
        local mode = not m.is_mirror and native_max_refresh(m)
        if mode and m.name == LAPTOP then
            -- existing eDP-1 rule keeps its position/scale; only the mode changes
            hl.monitor({ output = LAPTOP, mode = mode })
        elseif mode then
            hl.monitor({ output = m.name, mode = mode, position = EXTERNAL.position, scale = EXTERNAL.scale })
        end
    end
end


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "walker"

local function app(cmd) return "uwsm app -- " .. cmd end


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(app("qs"))
    hl.exec_cmd(app("hypridle")) -- idle dim/lock/suspend, see hypridle.conf
    hl.exec_cmd(app("nm-applet"))
    hl.exec_cmd("systemctl --user start plasma-powerdevil.service")
    hl.exec_cmd(app(terminal),         { workspace = "1 silent" })
    hl.exec_cmd(app("firefox.desktop"), { workspace = "2 silent" })
    hl.exec_cmd(app("spotify"),        { workspace = "4 silent" })
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "kde")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Palette shared with kitty/waybar
local accent = "rgba(8fb573ff)" -- waybar @accent
local bg     = "rgba(2b302bcc)" -- kitty background
local dim    = "rgba(7d837dff)" -- waybar @dim
local fg     = "rgba(c2c4c2ff)" -- kitty foreground

hl.config({
    general = {
        gaps_in  = 5,
        -- screen-edge gap: same as a lone window (6) and the bar's side margin
        gaps_out = 6,

        border_size = 2,

        col = {
            active_border   = accent,
            inactive_border = bg,
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        dim_inactive = true,
        dim_strength = 0.1,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    -- Groups (all grouped windows: kitty, browsers, IDE via rules below)
    group = {
        col = {
            border_active   = accent,
            border_inactive = bg,
        },

        groupbar = {
            disable_when_only = true, -- hide tab bar for single-window groups
            font_family       = "JetBrainsMono Nerd Font",
            font_size         = 11,
            text_color        = fg,
            col = {
                active   = accent,
                inactive = dim,
            },
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- Follow apps that ask for focus (xdg-activation), e.g. Firefox opening a walker web search
        focus_on_activate       = true,
        -- If qs (lock screen) crashes while locked, a restarted qs can take the lock back
        allow_session_lock_restore = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,pt",
        kb_variant = "",
        kb_model   = "",
        kb_options = "ctrl:swapcaps,grp:win_space_toggle",
        kb_rules   = "",

        follow_mouse = 2,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Groups: N = next tab, P = previous tab
hl.bind(mainMod .. " + N", hl.dsp.group.next())
hl.bind(mainMod .. " + P", hl.dsp.group.prev())

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(app(terminal)))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(app(fileManager)))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(app(menu)))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("uwsm stop")) -- logout
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit")) -- dwindle

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Workspaces: mainMod + [0-9] switch, + SHIFT moves active window
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Screenshots (grim + slurp + satty, as on the Hyprland wiki)
-- Super+S: select region -> satty to annotate/crop -> save to ~/Pictures/Screenshots or copy
-- Super+Shift+S: select region -> straight to clipboard, no editor
-- `|| exit` stops cleanly when the selection is cancelled with Esc.
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd([[g=$(slurp) || exit; grim -g "$g" - | satty --filename - --output-filename "$HOME/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png" --copy-command wl-copy --early-exit]]))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[g=$(slurp) || exit; grim -g "$g" - | wl-copy --type image/png]]))

-- Toggle stream mode (LIVE indicator + Big Brother wallpaper) for the current screen share
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("qs ipc call screenshare toggle"))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  media)

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "intellij",
    match = { class = "^(jetbrains-idea)$" },
    maximize = true, workspace = "3 silent", group = "set",
})
hl.window_rule({
    name  = "browsers",
    match = { class = "^(firefox|google-chrome)$" },
    maximize = true, workspace = "2 silent", group = "set",
})
hl.window_rule({
    name  = "discord",
    match = { class = "^(discord)$" },
    workspace = "5 silent",
})
hl.window_rule({
    name  = "kde-settings",
    match = { class = "^(kcmshell6|org.kde.kcmshell6)$" },
    float = true, center = true, size = "900 650",
})
hl.window_rule({
    -- Toolbox places its popup off-screen (left of the external monitor)
    name  = "jetbrains-toolbox",
    match = { class = "^(jetbrains-toolbox)$" },
    float = true, center = true,
})
hl.window_rule({
    name  = "kitty-group",
    match = { class = "^(kitty)$" },
    group = "set",
})

-- Groups are per app family: auto_group drops any new window into the
-- focused group, so pull it back out unless the group is its own family,
-- then put grouped families into their family's group (or a new one).
local group_families = {
    kitty            = "kitty",
    firefox          = "browser",
    ["google-chrome"] = "browser",
    ["jetbrains-idea"] = "idea",
}

local function find_family_group(ws, fam, except)
    if not ws then return nil end
    for _, g in ipairs(ws:get_groups() or {}) do
        local cur = g.current
        if cur and cur.address ~= except.address
            and group_families[cur.class] == fam then
            return g
        end
    end
end

hl.on("window.open", function(w)
    if not w then return end
    local fam = group_families[w.class]

    if w.group then
        for _, m in ipairs(w.group.members or {}) do
            if m.address ~= w.address and group_families[m.class] ~= fam then
                w.group:remove(w)
                break
            end
        end
    end

    if fam and not w.group then
        local g = find_family_group(w.workspace, fam, w)
        if g then
            g:add(w)
        else
            hl.dispatch(hl.dsp.focus({ window = "address:" .. w.address }))
            hl.dispatch(hl.dsp.group.toggle())
        end
    end
end)

---------------------------
---- MONITOR PLACEMENT ----
---------------------------
-- Replaces the old hypr-monitor-hotplug bash script.
-- Docked: workspaces 1-9 live on the "main" monitor (external by default), 10 on the other.
-- Super+Tab swaps which screen is main. Undocked: Hyprland moves everything to the laptop.

hl.workspace_rule({ workspace = "10", monitor = LAPTOP, default = true })

local laptop_is_main = false -- toggled by Super+Tab, reset on replug

local function external_monitor()
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= LAPTOP and not m.is_mirror then return m end
    end
end

-- Returns main (1-9) and side (10) monitor names, or nil when undocked.
local function screens()
    local ext = external_monitor()
    if not ext then return nil end
    if laptop_is_main then return LAPTOP, ext.name end
    return ext.name, LAPTOP
end

local function place_workspace(ws, main, side)
    if not ws or ws.special or not ws.monitor then return end
    local target = (ws.id >= 1 and ws.id <= 9) and main or (ws.id == 10 and side) or nil
    if target and ws.monitor.name ~= target then
        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws.id), monitor = target }))
    end
end

-- Bind 1-9 to main (and 10 to side) so new ones open there even when the other screen
-- is focused (moving a monitor's only workspace away afterwards doesn't work). The
-- external's port name varies, so the rules are added at runtime instead of statically.
local function bind_workspaces(main, side)
    for i = 1, 9 do
        hl.workspace_rule({ workspace = tostring(i), monitor = main })
    end
    hl.workspace_rule({ workspace = "10", monitor = side })
end

-- Floating windows keep their absolute x/y when their workspace changes monitor. The
-- external disconnects when it sleeps (dpms off), Hyprland parks 1-9 on the laptop, and
-- after wake a floating window stayed drawn on the laptop while its workspace was back on
-- the external (2026-11-18). So tile every floating window whenever workspaces get moved.
-- Windows that float by rule (keep in sync with the window rules) and pinned ones are left alone.
local rule_floats = {
    kcmshell6 = true, ["org.kde.kcmshell6"] = true, ["jetbrains-toolbox"] = true,
}

local function tile_floats()
    for _, w in ipairs(hl.get_windows({ floating = true })) do
        if w.class ~= "" and not rule_floats[w.class] and not w.pinned
            and w.workspace and not w.workspace.special then
            hl.dispatch(hl.dsp.window.float({ action = "disable", window = "address:" .. w.address }))
        end
    end
end

local function place_all()
    local main, side = screens()
    if not main then return end
    bind_workspaces(main, side)
    for _, ws in ipairs(hl.get_workspaces()) do place_workspace(ws, main, side) end
    tile_floats()
    -- Show 10 on the side screen; otherwise Hyprland fills it with a fresh empty
    -- workspace (lowest free id, e.g. 3) after the others moved away.
    hl.dispatch(hl.dsp.focus({ monitor = side }))
    hl.dispatch(hl.dsp.focus({ workspace = "10" }))
    hl.dispatch(hl.dsp.focus({ monitor = main }))
end

-- Super+Tab: swap main screen (all of 1-9 <-> 10)
hl.bind(mainMod .. " + Tab", function()
    if not external_monitor() then return end
    laptop_is_main = not laptop_is_main
    place_all()
end)

-- Config reloads clear runtime rules and don't fire start/monitor.added: re-bind here.
-- Lua state resets too, so recover a Super+Tab swap from where workspace 10 is.
do
    local ext = external_monitor()
    for _, ws in ipairs(hl.get_workspaces()) do
        if ext and ws.id == 10 and ws.monitor and ws.monitor.name == ext.name then
            laptop_is_main = true
        end
    end
    local main, side = screens()
    if main then bind_workspaces(main, side) end
    apply_modes()
end

hl.on("hyprland.start", function()
    apply_modes()
    place_all()
end)
hl.on("monitor.added", function()
    laptop_is_main = false
    apply_modes()
    place_all()
end)

-- Workspaces created later (slow apps like firefox/spotify) go straight to their screen
hl.on("workspace.created", function(ws)
    local main, side = screens()
    if main then place_workspace(ws, main, side) end
end)
