-- Standard awesome library
awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
beautiful = require("beautiful")
-- Panel
local wibox = require("wibox")
-- Plugins
local vicious = require("vicious")
-- Notification library
local naughty = require('naughty')

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
local exec      = awful.util.spawn
local sexec     = awful.util.spawn_with_shell
local editor    = os.getenv("EDITOR") or "nano"
home = os.getenv("HOME")

beautiful.init(awful.util.getdir("config") .. "/zenburn/theme.lua")

modkey = "Mod4"
shift  = "Shift"
ctrl   = "Control"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,           --1
    awful.layout.suit.max,            --2
    awful.layout.suit.max.fullscreen, --3
    awful.layout.suit.floating        --4
    -- awful.layout.suit.fair           --5
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tagcount = 7
tags = {
  names   = { "term", "work", "web", 4, 5, 6, 7 },
  layout  = { layouts[1], layouts[2], layouts[2], layouts[1], layouts[1], layouts[1], layouts[4] }
}
for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wibox

--Separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)

-- Textclock
textclock = awful.widget.textclock("%d %b %H:%M")

-- Battery state
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, "$2%", 120, "BAT0")

-- Systray
systray = wibox.widget.systray()

-- Create a wibox for each screen and add it
mywibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
tasklist   = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ },         1, awful.tag.viewonly),
                    awful.button({ modkey },  1, awful.client.movetotag),
                    awful.button({ },         3, awful.tag.viewtoggle),
                    awful.button({ modkey },  3, awful.client.toggletag),
                    awful.button({ },         4, awful.tag.viewnext),
                    awful.button({ },         5, awful.tag.viewprev)
                    )

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    promptbox[s] = awful.widget.prompt()
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
                        ))
    -- Create a taglist widget
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

    tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags)

    -- Create the wibox
    -- wibox[s] = awful.wibox({ position = "top", screen = s })
    mywibox[s] = awful.wibox({  screen = s,
      height = 18, position = "top",
      fg = beautiful.fg_normal,
      bg = beautiful.bg_normal,
      border_color = beautiful.border_focus
      -- border_width = beautiful.border_width
    })
    -- Add widgets to the wibox - order matters
    local left_wibox = wibox.layout.fixed.horizontal()
    left_wibox:add(taglist[s])
    left_wibox:add(separator)
    left_wibox:add(promptbox[s])

    local right_wibox = wibox.layout.fixed.horizontal()
    if s == 1 then right_wibox:add(systray) end
    right_wibox:add(separator)
    right_wibox:add(baticon)
    right_wibox:add(batwidget)
    right_wibox:add(separator)
    right_wibox:add(textclock)
    right_wibox:add(separator)
    right_wibox:add(layoutbox[s])

    local wibox_layout = wibox.layout.align.horizontal()
    wibox_layout:set_left(left_wibox)
    wibox_layout:set_middle(tasklist[s])
    wibox_layout:set_right(right_wibox)

    mywibox[s]:set_widget(wibox_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

clientbuttons = awful.util.table.join(
    awful.button({ },         1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey },  1, awful.mouse.client.move),
    awful.button({ modkey },  3, awful.mouse.client.resize))

local function notify_status(title, text)
    naughty.notify({ title = title, text = text, timeout = 1 })
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,  ctrl         }, "Up",      function() awful.client.moveresize(0, -20, 0, 0) end),
    awful.key({ modkey,  ctrl         }, "Down",    function() awful.client.moveresize(0, 20, 0, 0) end),
    awful.key({ modkey,  ctrl         }, "Left",    function() awful.client.moveresize(-20, 0, 0, 0) end),
    awful.key({ modkey,  ctrl         }, "Right",   function() awful.client.moveresize(20, 0, 0, 0) end),

    awful.key({ modkey,  ctrl,  shift }, "Up",      function() awful.client.moveresize(0, 0, 0, -20) end),
    awful.key({ modkey,  ctrl,  shift }, "Down",    function() awful.client.moveresize(0, 0, 0, 20) end),
    awful.key({ modkey,  ctrl,  shift }, "Right",   function() awful.client.moveresize(0, 0, 20, 0) end),
    awful.key({ modkey,  ctrl,  shift }, "Left",    function() awful.client.moveresize(0, 0, -20, 0) end),

    awful.key({ modkey,               }, "Left",    awful.tag.viewprev ),
    awful.key({ modkey,               }, "Right",   awful.tag.viewnext ),
    awful.key({ modkey,         shift }, "Left",
        function()
            local curidx = awful.tag.getidx()
            if curidx == 1 then
                awful.client.movetotag(tags[client.focus.screen][tagcount])
            else
                awful.client.movetotag(tags[client.focus.screen][curidx - 1])
            end
        end),
    awful.key({ modkey,         shift }, "Right",
        function()
            local curidx = awful.tag.getidx()
            if curidx == tagcount then
                awful.client.movetotag(tags[client.focus.screen][1])
            else
                awful.client.movetotag(tags[client.focus.screen][curidx + 1])
            end
        end),

    awful.key({ modkey,               }, "Escape",  awful.tag.history.restore),

    awful.key({ modkey,         shift }, "Return",  function () exec(terminal) end),
    awful.key({ modkey,               }, "a",       function () exec("google-chrome-stable") end),
    awful.key({ modkey,         shift }, "a",       function () exec("opera") end),
    awful.key({ modkey,               }, "s",       function () exec("subl") end),

    awful.key({ modkey,         shift }, "r",       awesome.restart),
    awful.key({ modkey,         shift }, "q",       awesome.quit),

    awful.key({ modkey,               }, "z",       function () promptbox[mouse.screen]:run() end),

    awful.key({                       }, "Print",   function () exec("scrot -e 'mv $f ~/ 2>/dev/null'") end),

    awful.key({ modkey,               }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ modkey,         shift }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),

  -- Default

    awful.key({ modkey,               }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,               }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey,         shift }, "j",       function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey,         shift }, "k",       function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,  ctrl         }, "j",       function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,  ctrl         }, "k",       function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,               }, "u",       awful.client.urgent.jumpto),

    awful.key({ modkey,               }, "l",       function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,               }, "h",       function () awful.tag.incmwfact(-0.05)    end),

    awful.key({ modkey,         shift }, "h",       
        function ()
            awful.tag.incnmaster( 1)
            notify_status("Master", tostring(awful.tag.getnmaster()))
        end),
    awful.key({ modkey,         shift }, "l",     
        function ()
            awful.tag.incnmaster(-1)
            notify_status("Master", tostring(awful.tag.getnmaster()))
        end),
    awful.key({ modkey,  ctrl         }, "h",     
        function ()
            awful.tag.incncol( 1)
            notify_status("Columns", tostring(awful.tag.getncol()))
        end),
    awful.key({ modkey,  ctrl         }, "l",     
        function ()
            awful.tag.incncol(-1)
            notify_status("Columns", tostring(awful.tag.getncol()))
        end),

    awful.key({ modkey,               }, "space",   function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey,         shift }, "space",   function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey,  ctrl         }, "n",       awful.client.restore),

    -- Standard program

    awful.key({                       }, "XF86MonBrightnessDown",   function () awful.util.spawn("xbacklight -dec 15") end),
    awful.key({                       }, "XF86MonBrightnessUp",     function () awful.util.spawn("xbacklight -inc 15") end),
    awful.key({                 shift }, "XF86MonBrightnessDown",   function () awful.util.spawn("xbacklight -dec 5") end),
    awful.key({                 shift }, "XF86MonBrightnessUp",     function () awful.util.spawn("xbacklight -inc 5") end),
    awful.key({                       }, "XF86KbdBrightnessUp",     function () awful.util.spawn("asus-kbd-backlight up") end),
    awful.key({                       }, "XF86KbdBrightnessDown",   function () awful.util.spawn("asus-kbd-backlight down") end),

    awful.key({                       }, "XF86TouchpadToggle",      
        function () 
            awful.util.spawn_with_shell("synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')") 
        end),

    awful.key({ modkey,               }, "F12",     function () awful.util.spawn("xautolock -locknow", false) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,               }, "w",       function (c) c:kill()                         end),
    awful.key({ modkey,         shift }, "e",       function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,               }, "e",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),

    -- Default

    awful.key({ modkey,  ctrl         }, "space",   awful.client.floating.toggle                     ),
    awful.key({ modkey,  ctrl         }, "Return",  function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,               }, "o",       awful.client.movetoscreen                        ),
    awful.key({ modkey,  ctrl         }, "r",       function (c) c:redraw()                       end),
    awful.key({ modkey,               }, "t",       function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,               }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end),
        awful.key({ modkey,  ctrl }, "#" .. i + 9,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewtoggle(tags[screen][i])
                end
            end),
        awful.key({ modkey, shift }, "#" .. i + 9,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end),
        awful.key({ modkey, ctrl, shift }, "#" .. i + 9,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.toggletag(tags[client.focus.screen][i])
                end
            end))
end

-- {{{ Quake console
local quake = require("quake")
local quakeconsole = {}
for s = 1, screen.count() do
    quakeconsole[s] = quake({ terminal = terminal,
                              name = "QuakeConsole",
                              height = 0.4,
                              border_width = beautiful.border_width,
                              screen = s })
end

globalkeys = awful.util.table.join( globalkeys,
    awful.key({ modkey,               }, "`",       function () quakeconsole[mouse.screen]:toggle() end),
    awful.key({ modkey,         shift }, "`",       function () quakeconsole[mouse.screen]:raise()  end),
    awful.key({ modkey,  ctrl         }, "`",       function () quakeconsole[mouse.screen]:shrink() end)
)
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
local function tag_rule(class, tag, ignore_dialogs )
    ignore_dialogs = ignore_dialogs or false
    result = {}
    result.rule = { class = class }
    result.properties = { tag = tag }
    if ignore_dialogs then
        result.except = { type = "dialog" }
    end
    return result
end

local function floating_rule(class)
    result = {}
    result.rule = { class = class }
    result.properties = { floating = true }
    return result
end

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    
    floating_rule( "MPlayer"    ),
    floating_rule( "pinentry"   ),
    floating_rule( "gimp"       ),

    tag_rule( "Chromium",              tags[1][3], true ),
    tag_rule( "Google-chrome",         tags[1][3], true ),
    tag_rule( "Google-chrome-stable",  tags[1][3], true ),
    tag_rule( "Opera",                 tags[1][3], true ),
    tag_rule( "Dwb",                   tags[1][3], true ),
    tag_rule( "Skype",                 tags[1][7]       ),
    tag_rule( "Thunderbird",           tags[1][7], true ),
    tag_rule( "sublime-text",          tags[1][2], true ),
    tag_rule( "Sublime-text",          tags[1][2], true ),
    tag_rule( "Sublime_text",          tags[1][2], true ),
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

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

for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout  = awful.layout.getname(awful.layout.get(s))

    if #clients > 0 then -- Fine grained borders and floaters control
        for _, c in pairs(clients) do
            if c.maximized then
                -- No borders with only one visible client
                c.border_width = 0
            elseif awful.client.floating.get(c) or layout == "floating" then
                -- Floaters always have borders
                c.border_width = beautiful.border_width
            elseif #clients == 1 or layout == "max" then
                -- No borders with only one visible client
                c.border_width = 0
            else
                c.border_width = beautiful.border_width
            end
        end
    end
  end)
end
-- }}}