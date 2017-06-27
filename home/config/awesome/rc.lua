-- TODO - sort the taglist on alt-n
-- TODO - scratchpad for applications
-- TODO - focus when app closes


-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Third-party libraries
local assault = require("assault")      -- battery widget
local beautiful = require("beautiful")  -- theme management
local common = require("awful.widget.common")
local lain = require("lain")            -- layouts, widgets, and utilities
local menubar = require("menubar")
local naughty = require("naughty")      -- notification library
local wibox = require("wibox")          -- widget and layout library
local vicious = require("vicious")      -- system widgets

-- Library configuration
awful.rules = require("awful.rules")


if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

--------------------------------------------------------------------------------
-- Just a quick print function that relies on naughty notification boxes. E.g.:
--      debug_print(string.format("%d\n", myTag.index))
--------------------------------------------------------------------------------
local function debug_print(words)
    naughty.notify({
        preset = naughty.config.presets.normal,
        title = "Debug Message",
        text = words,
        width = 400
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
            title = "Oops, an error happened!",
            text = err })
        in_error = false
    end)
end

-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/xathereal/theme.lua")

-- This is used later as the default terminal and editor to run.
programs = {}
programs["browser"]     = "chromium"
programs["terminal"]    = "urxvt"
programs["lock"]        = "xscreensaver-command --lock"
programs["randr"]       = "arandr"

editor = os.getenv("EDITOR") or "vim"
editor_cmd = programs["terminal"] .. " -e " .. editor

-- Can also be 'alt', 'Mod4' (logo key), ...
modkey = "Mod1"

local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

local function set_wallpaper(s)
    if beautiful.wallpaper then
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end

for s = 1, screen.count() do
    set_wallpaper(s)
end
screen.connect_signal("property:geometry", set_wallpaper)

awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, 1, layouts[1])

shared_tag_list = screen[1].tags

-- Ensure every screen has a tag, and a tag that is activated
for s = 2, screen.count() do
    shared_tag_list[s].screen = s
    awful.tag.viewnone(screen[s])
    awful.tag.viewmore({shared_tag_list[s]})
end

rows = {}
curr_y = 0
curr_screen = -1
row = {}
checked = {}

-- This chunk works out where the screens are and does a logical grid of them.
-- i.e. rows[2][1] is the second row of screens, and the left most one
-- TODO order them from left to right, they can be in a weird order..
while curr_y < (1600 * 3 + 1) do
    if curr_screen > 0 then
        gg = screen[curr_screen].geometry
        if curr_y >= (gg.y + gg.height) then
            curr_screen = -1

            -- TODO sort row by x ascending

            table.insert(rows, row)
            row = {}
        end
    end

    for s = 1, screen.count() do
        if not checked[s] then
            g = screen[s].geometry

            if curr_y == g.y then
                if curr_screen == -1 then
                    curr_screen = s
                    table.insert(row, s)
                    checked[s] = true
                else
                    gg = screen[curr_screen].geometry
                    if g.y >= gg.y and g.y < (gg.y + gg.height) then
                        table.insert(row, s)
                        checked[s] = true
                    end
                end
            end
        end
    end

    curr_y = curr_y + 1

end

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", programs["terminal"] .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", programs["terminal"] }
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = programs["terminal"] -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
widget_batt0 = assault({
    battery = "BAT0",
    critical_level = 0.15,
    critical_color = "#FF0000",
    charging_color = "#00FF00",
    height = 8,
})

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

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

gapwidget = wibox.widget.textbox()
gapwidget:set_text("   ")

memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "mem $1%", 13)

-- cpuwidget = wibox.widget.textbox()
-- vicious.register(cpuwidget, vicious.widgets.cpu, "cpu $1%")

local cpu = lain.widget.cpu {
    settings = function()
        widget:set_markup("CPU " .. cpu_now.usage)
    end
}

uptwidget = wibox.widget.textbox()
vicious.register(uptwidget, vicious.widgets.uptime, "uptime $1 days")

disk_widget = wibox.widget.textbox()
vicious.register(disk_widget, vicious.widgets.fs, "root ${/ used_p}%")

--disk2_widget = wibox.widget.textbox()
--vicious.register(disk2_widget, vicious.widgets.fs, "home ${/home used_p}%")

for s = 1, screen.count() do

    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which
    -- layout we're using. We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(
        awful.util.table.join(
            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
        )
    )

    -- Create a taglist widget, this actually creates the widget
    mytaglist[s] = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.all,
        mytaglist.buttons)

    -- Create a tasklist widget
    -- These are the program names
    mytasklist[s] = awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibar({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(gapwidget)
    right_layout:add(disk_widget)
    right_layout:add(gapwidget)
    right_layout:add(uptwidget)
    right_layout:add(gapwidget)
    right_layout:add(cpu.widget)
    right_layout:add(gapwidget)
    right_layout:add(memwidget)
    right_layout:add(gapwidget)
    right_layout:add(mytextclock)
    right_layout:add(widget_batt0)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

function focus_on_screen(x, y, rows)

    if #rows == 1 and y == 2 then
        y = 1
    end

    if y <= #rows then
        local row = rows[y]
        if x <= #row then
            s = row[x]
            awful.screen.focus(s)
        end
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
    awful.button({ }, 3, function () mymainmenu:toggle() end),
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

--local scratchpad_scr = screen.fake_add(0, 0, 1920, 1080)
--local spotify_tag = awful.tag.add(
--    "spotify", {
--        screen = scratchpad_scr.index,
--        layout = awful.layout.suit.floating
--    }
--)
--
----awful.spawn("arandr", {tag=spotify_tag})
--
--debug_print(string.format("%d\n", spotify_tag.index))
--spotify_tag.selected = false

-- onkey we need to move_tag_to_screen that is focused, then select that client
-- offkey we need to move_tag_to_scratchpad, then select another client

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),

    awful.key({ modkey,           }, "w", function () focus_on_screen(1, 1, rows) end),
    awful.key({ modkey,           }, "e", function () focus_on_screen(2, 1, rows) end),
    awful.key({ modkey,           }, "r", function () focus_on_screen(3, 1, rows) end),

    awful.key({ modkey,           }, "s", function () focus_on_screen(1, 2, rows) end),
    awful.key({ modkey,           }, "d", function () focus_on_screen(2, 2, rows) end),
    awful.key({ modkey,           }, "f", function () focus_on_screen(3, 2, rows) end),

    -- Standard program
    awful.key({ "Mod4",           }, "w", function ()       spawn_program(programs["browser"]) end),
    awful.key({ modkey, "Shift"   }, "Return", function ()  spawn_program(programs["terminal"]) end),
    awful.key({ "Mod4",           }, "l", function ()       spawn_program(programs["lock"]) end),
    awful.key({ "Mod4",           }, "a", function ()       spawn_program(programs["randr"]) end),

    -- Awesome Control
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey            }, "r", function () mypromptbox[mouse.screen]:run() end),

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

    -- Audio Control
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.util.spawn("amixer -D pulse set Master 10%+")
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.util.spawn("amixer -D pulse set Master 10%-")
    end),
    awful.key({}, "XF86AudioMute", function()
        awful.util.spawn("amixer -D pulse sset Master toggle")
    end),

    -- Brightness
    awful.key({}, "XF86MonBrightnessUp", function()
        awful.util.spawn("xbacklight -inc 10")
    end),
    awful.key({}, "XF86MonBrightnessDown", function()
        awful.util.spawn("xbacklight -dec 10")
    end),

    -- Prompt
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
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
        awful.util.spawn(command)
    end)
)

function move_client_to_screen(c, x, y)
    if #rows == 1 and y == 2 then
        y = 1
    end

    if y <= #rows then
        local row = rows[y]
        if x <= #row then
            s = row[x]
            awful.client.movetoscreen(c, s)
        end
    end
end

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "t",      awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift"   }, "w", function (c) move_client_to_screen(c, 1, 1) end),
    awful.key({ modkey, "Shift"   }, "e", function (c) move_client_to_screen(c, 2, 1) end),
    awful.key({ modkey, "Shift"   }, "r", function (c) move_client_to_screen(c, 3, 1) end),
    awful.key({ modkey, "Shift"   }, "s", function (c) move_client_to_screen(c, 1, 2) end),
    awful.key({ modkey, "Shift"   }, "d", function (c) move_client_to_screen(c, 2, 2) end),
    awful.key({ modkey, "Shift"   }, "f", function (c) move_client_to_screen(c, 3, 2) end),
    awful.key({ modkey,           }, "y",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            c.minimized = true
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
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

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
                "Arandr",
                "gimp",
                "keepassx2",
                "Keepassx2"
            }
        },
        properties = { floating = true }
    },
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
