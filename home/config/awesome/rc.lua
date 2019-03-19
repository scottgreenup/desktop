
                -- [      Power Mode for Awesome 4.1-1      ] --
                -- [          author: scottgreenup          ] --
                -- [     http://github.com/scottgreenup     ] --
                -- [                   --                   ] --
                -- [        Theme credit to barwinco        ] --
                -- [    http://github.com/barwinco/pro      ] --

-- | Author's Commentary | --

-- Barwinco's theme inspired by Luke Bonham - https://github.com/copycat-killer
-- The tiling and window management comes from my old XMonad configuration

-- | To Do List | --

-- sort the taglist on alt-n
-- scratchpad for applications
-- focus when app closes
-- create center-oriented layout, where master is in the center


-- | Libraries | --
--
local xresources = require("beautiful.xresources")

local gears = require("gears")
local awful = require("awful")
local cairo = require("lgi").cairo
local assault = require("assault")      -- battery widget
local beautiful = require("beautiful")  -- theme management
local common = require("awful.widget.common")
local lain = require("lain")            -- layouts, widgets, and utilities
local naughty = require("naughty")      -- notification library
local wibox = require("wibox")          -- widget and layout library
local vicious = require("vicious")      -- system widgets

local round = require("gears.math").round

local awfulremote = require("awful.remote")

awful.rules = require("awful.rules")

-- | Error handling | --

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "AwesomeWM: Error With Startup",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "AwesomeWM: Runtime error after startup",
            text = err })
        in_error = false
    end)
end

local function dpi(size)
    return round(size / 96 * screen[1].dpi)
end


--------------------------------------------------------------------------------
-- Just a quick print function that relies on gears
--      debug_print(string.format("%d\n", myTag.index))
--------------------------------------------------------------------------------
local function debug_print(message)
    gears.debug.print_warning(message)
end

local function debug_dump(message, thing, depth)
    if depth ~= nil then
        gears.debug.print_warning(gears.debug.dump_return(thing, message, depth))
    else
        gears.debug.print_warning(gears.debug.dump_return(thing, message))
    end
end

local rounded_rect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

naughty.config.notify_callback = function(args)

    if args.timeout == nil or args.timeout < 30 then
        args.timeout = 30
    end

    if args.icon then
        if args.icon_size == nil or args.icon_size > 50 then
            args.icon_size = 70
        end
    end

    args.font = "Roboto 7"
    args.shape = rounded_rect(5)
    args.opacity = 0.95

    local currScreen = awful.screen.focused()
    if args.screen ~= nil then
        currScreen = args.screen
    end

    -- TODO The default width can be in the theme
    --local minWidth = currScreen.geometry.width * 0.15
    --if args.width == nil then
    --    args.width = minWidth
    --elseif args.width < minWidth then
    --    args.width = minWidth
    --end

    if args.title == nil or args.title == "" then
        args.title = "Notification"
    end

    return args
end

-- Themes define colours, icons, font and wallpapers.
theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/"
beautiful.init(theme_dir .. "xathereal/theme.lua")

local home   = os.getenv("HOME")
local exec   = function (s) awful.spawn(s, false) end

local modkey = "Mod4"

-- This is used later as the default terminal and editor to run.
programs = {}
programs["audio"]       = "pavucontrol"
programs["browser"]     = "firefox"
programs["terminal"]    = "urxvt"
programs["lock"]        = "xscreensaver-command -lock"
programs["randr"]       = "arandr"
programs["editor"]      = os.getenv("EDITOR") or "vim"
programs["editor_cmd"]  = programs["terminal"] .. " -e " .. programs["editor"]

local layouts = {
    awful.layout.suit.tile,
    lain.layout.centerwork_leftright,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

-- | Tags | --

awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, 1, layouts[1])
shared_tag_list = screen[1].tags

-- Ensure every screen has a tag, and a tag that is activated
for s = 1, screen.count() do
    shared_tag_list[s].screen = s
    awful.tag.viewnone(screen[s])
    awful.tag.viewmore({shared_tag_list[s]})
    debug_dump("DPI", screen[s].dpi)
end

-- | Screen ordering | --

screen_map = {}
table.insert(screen_map, 1)

-- Work out the ordering for alt-s, alt-d, and alt-f
for i = 2, screen.count() do
    gi = screen[i].geometry
    inserted = false

    for j = 1, #screen_map do
        gj = screen[screen_map[j]].geometry

        if gj.x > gi.x then
            table.insert(screen_map, j, i)
            inserted = true
            break
        end
    end

    if inserted == false then
        table.insert(screen_map, i)
    end
end


-- | Markup | --

local markup = lain.util.markup
local space3 = markup.font("Roboto 3", "  ")
local space4 = markup.font("Roboto 4", " ")
local vspace1 = '<span font="Roboto 3"> </span>'
local vspace2 = '<span font="Roboto 3">  </span>'

local rounded_rect_top = function(radius)
    local gap = dpi(1)
    return function(cr, width, height)
        local shape = gears.shape.transform(gears.shape.rounded_rect):translate(0, gap)
        shape(cr, width, height-(gap*2), radius)
    end
end

local widget_dark = "#252525"
local widget_radius = 5
local widget_background = function(w)
    return wibox.container.background(w, widget_dark, rounded_rect_top(widget_radius))
end

-- | Widgets | --

spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- | CPU / TMP | --

cpu_widget = lain.widget.cpu({
    settings = function()
        widget:set_markup(space3 .. cpu_now.usage .. "%" .. space3)
    end
})

local function dark_label(text)
    return wibox.widget.textbox(space3 .. "<span font=\"Roboto Black\"color=\"" .. widget_dark .. "\">" .. text .. "</span>" .. space3)
end

widget_cpu = dark_label("CPU")
cpuwidget = widget_background(cpu_widget.widget)

tmp_widget = wibox.widget.textbox()
vicious.register(tmp_widget, vicious.widgets.thermal, space3 .. "$1°C" .. space3, 9, "thermal_zone0")
tmpwidget = widget_background(tmp_widget)

-- | BAT | --

battery_widget = lain.widget.bat({
    settings = function()
        widget:set_markup(space3 .. bat_now.perc .. "%" .. space3)
    end
})

widget_bat = dark_label("BAT")
batwidget = widget_background(battery_widget.widget)

-- | MEM | --

mem_widget = lain.widget.mem({
    settings = function()
        widget:set_markup(space3 .. mem_now.perc .. "%" .. space3)
    end
})

widget_mem = dark_label("MEM")
memwidget = widget_background(mem_widget.widget)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, space3 .. "${/ avail_gb}GB" .. space3, 2)

widget_fs = dark_label("HDD")
fswidget = widget_background(fs_widget)

-- | NET | --

net_widgetul = lain.widget.net({
    iface = "wlp2s0",
    settings = function()
        widget:set_markup(space3 .. net_now.sent .. space3)
    end
})

net_widgetdl = lain.widget.net({
    iface = "wlp2s0",
    settings = function()
        widget:set_markup(space3 .. net_now.received .. space3)
    end
})

widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = widget_background(net_widgetdl.widget)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = widget_background(net_widgetul.widget)

-- | Clock / Calendar | --

mytextclock = wibox.widget.textclock(
    markup(beautiful.clockgf, space3 .. "%H:%M" .. space3))
mytextcalendar = wibox.widget.textclock(
    markup(beautiful.clockgf, space3 .. "%a %d %b"))

clockwidget = widget_background(mytextclock)

datewidget = widget_background(mytextcalendar)

-- | Task List | --

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1,
        function (c)
            if c == client.focus then
                c.minimized = true
            else
                -- Without this, the following
                -- :isvisible() makes no sense
                c.minimized = false
                if not c:isvisible() then
                    awful.tag.viewonly(c:tags()[1])
                end
                -- This will also un-minimize
                -- the client, if needed
                client.focus = c
                c:raise()
            end
        end),
    awful.button({ }, 3,
        function ()
            if instance then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({
                    theme = { width = 250 }
                })
            end
        end),
    awful.button({ }, 4,
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.button({ }, 5,
        function ()
             awful.client.focus.byidx(-1)
             if client.focus then client.focus:raise() end
        end
    )
)

-- Create a wibox for each screen and add it
mywibox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)


for s = 1, screen.count() do

    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s)
    end

    mytaglist[s] = awful.widget.taglist(
        s, awful.widget.taglist.filter.all, mytaglist.buttons)

    mytasklist[s] = awful.widget.tasklist(
        s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibar({
        position = "top",
        screen = s,
        height = beautiful.menu_height
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(spr5px)
    left_layout:add(mytaglist[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then
        right_layout:add(spr)
        right_layout:add(spr5px)
        right_layout:add(wibox.widget.systray())
        right_layout:add(spr5px)
    end

    right_layout:add(spr)

    right_layout:add(widget_cpu)
    right_layout:add(cpuwidget)
    right_layout:add(spr5px)
    right_layout:add(tmpwidget)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_mem)
    right_layout:add(memwidget)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_bat)
    right_layout:add(batwidget)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_fs)
    right_layout:add(fswidget)
    right_layout:add(spr5px)

    right_layout:add(spr)

    right_layout:add(widget_netdl)
    right_layout:add(netwidgetdl)
    right_layout:add(spr5px)
    right_layout:add(netwidgetul)
    right_layout:add(widget_netul)

    right_layout:add(spr)

    right_layout:add(spr5px)
    right_layout:add(clockwidget)
    right_layout:add(spr5px)
    right_layout:add(datewidget)
    right_layout:add(spr5px)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}
--
function move_client_to_screen(c, x, screen_map)
    nextc = select_next(c)
    if x <= #screen_map then
        awful.client.movetoscreen(c, screen_map[x])
    end
    awful.screen.focus(nextc.screen)
end


function focus_on_screen(x, screen_map)
    if x <= #screen_map then
        awful.screen.focus(screen_map[x])
    end
end

function spawn_program(program)
    awful.spawn(program, {
        --tag=screen[awful.screen.focused({client=true})].selected_tag
        tag=mouse.screen.selected_tag
    })
end

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function move_tag_to_screen(_tag, _screen_index)
    awful.tag.setproperty(_tag, "hide", true)
    _tag.screen = _screen_index
    awful.tag.setproperty(_tag, "hide", false)
end

function force_focus(_screen)
    awful.screen.focus(_screen)
    if #_screen.clients > 0 then
        c = _screen.clients[1]
        client.focus = c
        c:raise()
    end
end

function reset_to_primary()
    for k, v in pairs(shared_tag_list) do
        awful.tag.setproperty(v, "hide", true)
        v.screen = 1
        awful.tag.setproperty(v, "hide", false)
    end

    awful.tag.viewnone(screen[1])
    awful.tag.viewmore({shared_tag_list[1]})
end


--+=============================================================================
--| Key Bindings
--+-----------------------------------------------------------------------------
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

    awful.key({ modkey,           }, "s", function () focus_on_screen(1, screen_map) end),
    awful.key({ modkey,           }, "d", function () focus_on_screen(2, screen_map) end),
    awful.key({ modkey,           }, "f", function () focus_on_screen(3, screen_map) end),
    awful.key({ modkey, "Control" }, "t", function () reset_to_primary() end),
    awful.key({ modkey, "Control" }, "x", function () spawn_program("fix_black_laptop_screen") end),

    -- Standard program
    awful.key({ modkey,           }, "w", function ()       spawn_program(programs["browser"]) end),

    awful.key({ modkey, "Shift"   }, "Return", function ()
        -- Make sure our X server resource database is up-to-date, that way our
        -- terminal will have the latest settings configured in ~/.Xresources
        spawn_program("xrdb /home/sgreenup/.Xresources")

        spawn_program(programs["terminal"])
    end),

    awful.key({ modkey, "Shift"   }, "l", function ()       spawn_program(programs["lock"]) end),
    awful.key({ modkey,           }, "a", function ()       spawn_program(programs["randr"]) end),
    awful.key({ modkey,           }, "u", function ()       spawn_program(programs["audio"]) end),

    awful.key({ modkey, "Mod1"     }, "4", function ()
        awful.spawn.with_shell("sleep 0.2 && scrot --quality 100 --select -e 'echo $n' | xclip -in")
    end),

    -- Awesome Control
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Stops ctrl-q from closing Firefox.
    awful.key({ "" , "Control" }, "q", function () end),

    -- Window Control
    awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.03) end),
    awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.03) end),
    awful.key({ modkey,           }, ",", function () awful.tag.incnmaster( 1) end),
    awful.key({ modkey,           }, ".", function () awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1) end),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    awful.key({ }, "XF86AudioPlay", function () debug_print("play") end),
    awful.key({ }, "XF86AudioPause", function () debug_print("pause") end),
    awful.key({ }, "XF86AudioNext", function () debug_print("next") end),
    awful.key({ }, "XF86AudioPrev", function () debug_print("prev") end),

    -- Audio Control
    awful.key({}, "XF86AudioRaiseVolume", function()
        debug_print("up")
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        debug_print("lower")
    end),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn("amixer sset Master toggle")
    end),

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.spawn("xbacklight -inc 10")
    end),
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.spawn("xbacklight -dec 10")
    end),

    -- DMenu2
    awful.key({ modkey }, "p", function()
        scr = awful.screen.focused({client=true})

        local scrgeom = screen[scr].workarea
        local command = "dmenu_custom"
        command = command .. " " .. tostring(scrgeom.x)
        command = command .. " " .. tostring(scrgeom.y)
        command = command .. " " .. tostring(scrgeom.width)
        command = command .. " " .. tostring(scrgeom.height)
        awful.spawn(command)
    end)
)

function select_next(c)
    local scr = c.screen

    if #scr.get_clients() == 1 then
        return client.focus
    end

    if c.floating then
        awful.client.focus.byidx(1)
        if client.focus then
            client.focus:raise()
        end
        return client.focus
    end

    idx = awful.client.idx(c)

    if idx == nil then
        awful.client.focus.byidx(1)
        if client.focus then
            client.focus:raise()
        end
        return client.focus
    end

    local t = c.screen.selected_tag

    -- if the index of the client is the last index of the column, go up
    if idx["col"] == t.column_count and idx["idx"] == idx["num"] then
        awful.client.focus.byidx(-1)
        if client.focus then
            client.focus:raise()
        end
    else
        awful.client.focus.byidx(1)
        if client.focus then
            client.focus:raise()
        end
    end

    return client.focus
end

function kill_select(c)
    select_next(c)
    c:kill()
end

client.connect_signal("focus", function(c)
    -- do nothing
end)

client.connect_signal("unmanage", function(c)
    if #c.screen.clients > 0 then
        client.focus = c.screen.clients[1]
    end
end)

screen.connect_signal("removed", function(s)
    -- TODO move those tags to another screen
    -- TODO keep tags sorted
end)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",       function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",       function (c) kill_select(c) end),
    awful.key({ modkey,           }, "t",       awful.client.floating.toggle ),
    awful.key({ modkey,           }, "Return",  function (c) c:swap(awful.client.getmaster()) end),

    -- This is useful if for debugging, when you want to know what Awesome is
    -- doing with a window.
    awful.key({ modkey, "Control" }, "s",       function (c)

        -- WTF IS THIS STUPID MAXAMIZED BULLSHIT

        c.maximized = false
        c.minimized = false
        c.maximized_horizontal = false
        c.maximized_vertical = false

        debug_print(
            "Printing client information" ..
            string.format("window = %s\n", c.window) ..
            string.format("name = %s\n", c.name) ..
            string.format("skip_taskbar = %s\n", tostring(c.skip_taskbar)) ..
            string.format("type = %s\n", c.type) ..
            string.format("class = %s\n", c.class) ..
            string.format("instance = %s\n", c.instance) ..
            string.format("pid = %d\n", c.pid) ..
            string.format("role = %s\n", c.role) ..
            string.format("machine = %s\n", c.machine) ..
            string.format("icon_name = %s\n", c.icon_name) ..
            string.format("hidden = %s\n", tostring(c.hidden)) ..
            string.format("minimized = %s\n", tostring(c.minimized)) ..
            string.format("size_hints_honor = %s\n", tostring(c.size_hints_honor)) ..
            string.format("urgent = %s\n", tostring(c.urgent)) ..
            string.format("ontop = %s\n", tostring(c.ontop)) ..
            string.format("above = %s\n", tostring(c.above)) ..
            string.format("below = %s\n", tostring(c.below)) ..
            string.format("fullscreen = %s\n", tostring(c.fullscreen)) ..
            string.format("maximized = %s\n", c.maximized) ..
            string.format("maximized_horizontal = %s\n", c.maximized_horizontal) ..
            string.format("maximized_vertical = %s\n", c.maximized_vertical) ..
            string.format("sticky = %s\n", tostring(c.sticky)) ..
            string.format("modal = %s\n", tostring(c.modal)) ..
            string.format("focusable = %s\n", tostring(c.focusable)) ..
            string.format("marked = %s\n", tostring(c.marked)) ..
            string.format("floating = %s\n", tostring(c.floating)) ..
            string.format("dockable = %s\n", tostring(c.dockable))
        )
    end),
    awful.key({ modkey, "Shift"   }, "s",       function (c) move_client_to_screen(c, 1, screen_map) end),
    awful.key({ modkey, "Shift"   }, "d",       function (c) move_client_to_screen(c, 2, screen_map) end),
    awful.key({ modkey, "Shift"   }, "f",       function (c) move_client_to_screen(c, 3, screen_map) end),
    awful.key({ modkey,           }, "y",       function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
            c.maximized = false
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
        function ()

            -- I want to bring new_tag to focus on target_scr
            local new_tag = shared_tag_list[i]
            local target_scr = awful.screen.focused()

            if new_tag.selected and (new_tag.screen.index == target_scr.index) then
                return

            elseif not new_tag.selected and (new_tag.screen.index == target_scr.index) then
                awful.tag.viewnone(target_scr)
                awful.tag.viewmore({new_tag})
                force_focus(target_scr)

            elseif not new_tag.selected and (new_tag.screen.index ~= target_scr.index) then
                other_scr = new_tag.screen
                other_tag = other_scr.selected_tag

                -- TODO can other_tag be nil?

                move_tag_to_screen(new_tag, target_scr.index)
                awful.tag.viewnone(target_scr)
                awful.tag.viewnone(other_scr)
                awful.tag.viewmore({new_tag, other_tag})
                force_focus(target_scr)

            elseif new_tag.selected and (new_tag.screen.index ~= target_scr.index) then

                other_scr = new_tag.screen
                curr_tag = target_scr.selected_tag

                move_tag_to_screen(new_tag, target_scr.index)
                awful.tag.viewnone(target_scr)

                -- move focused screen tag to other screen
                if curr_tag then
                    move_tag_to_screen(curr_tag, other_scr.index)
                    awful.tag.viewnone(other_scr)
                    awful.tag.viewmore({curr_tag})
                end

                awful.tag.viewmore({new_tag})
                force_focus(target_scr)
            end

            -- Sort the tag lists
            -- Very naive solution, that requires minimal understanding of LUA
            -- to code... lol
            message = ""

            -- For sorting, we need a counter array. The index of a tag
            -- determines where it is in the tag list. But the index can't be
            -- any number, it has to be between 1..len(tags on screen); so we
            -- are going to go through each tag and keep track of the index per
            -- screen
            counters = {}
            for s in screen do
                counters[s.index] = 0
            end
            for i = 1, 9 do
                local _tag = shared_tag_list[i]
                counters[_tag.screen.index] = counters[_tag.screen.index] + 1
                _tag.index = counters[_tag.screen.index]
            end

        end),

    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus then
            local tag = shared_tag_list[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end))
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        client.focus = c;
        --c:raise()
    end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)


-- moveresize is relative to the current geometry, there was no alternative...
function client_resize(c, w, h)
    c:relative_move(0, 0, w - c.width, h - c.height)
end


-- moveresize is relative to the current geometry, there was no alternative...
function client_move(c, x, y)
    c:relative_move(x - c.x, y - c.y, 0, 0)
end


-- moveresize is relative to the current geometry, there was no alternative...
function client_move_on_screen(c, x, y)
    g = awful.screen.focused({client=true}).geometry
    c:relative_move(g.x + (x - c.x), g.y + (y - c.y), 0, 0)
end


-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {

    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            size_hints_honor = false,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons
        }
    },

    {
        rule_any = {
            class = {
                "gimp",
                "Keepassx2", "keepassx2",

                -- Dialogs in GoLand
                "sun-awt-X11-XDialogPeer",
            }
        },
        properties = { floating = true }
    },

    {
        rule_any = {
            class = {
                "Arandr", "arandr",
                "Pavucontrol", "pavucontrol",
                "blueman-manager", "Blueman-manager",
                "nitrogen", "Nitrogen",
            }
        },
        properties = { floating = true },

        -- TODO make this play nice with larger or smaller resolutions
        callback = function(c)
            client_move_on_screen(c, dpi(100), dpi(100))
            client_resize(c, dpi(1280), dpi(720))
        end
    },

    {
        rule_any = {
            name = { "win.*", },
        },
        properties = {focusable = false, ontop = true}
    }
}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
