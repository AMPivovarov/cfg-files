-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Startup error",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Runtime error",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}


-- {{{ Variable definitions
beautiful.init(awful.util.getdir("config") .. "/zenburn/theme.lua")

local terminal      = "urxvtc"
local exec          = awful.util.spawn
local sexec         = awful.util.spawn_with_shell
local editor        = os.getenv("EDITOR") or "nano"
local editor_cmd    = terminal .. " -e " .. editor
local home          = os.getenv("HOME")

local modkey = "Mod4"
local ctrl   = "Control"
local shift  = "Shift"
local alt    = "Mod1"

local LMB    = 1
local RMB    = 3
local UpMB   = 4
local DownMB = 5
-- }}}


-- {{{ Helper functions
local util = {}
util.join = awful.util.table.join
util.notify = function(title, text) naughty.notify({ title = title, text = text, timeout = 1 }) end

util.key = function(group, description, shortcut, fun)
               local info = {}
               if not shortcut and not fun then
                   shortcut = group
                   fun = description
               else
                   info = { group = group, description = description }
               end

               -- "M C S A Key"
               local m, c, s, a, key = string.match(shortcut, "([M ]) ([C ]) ([S ]) ([A ]) (.*)")
               if not key then
                   naughty.notify({ preset = naughty.config.presets.critical,
                                    title = "Shortcut error",
                                    text = "\"" .. shortcut .. "\" is not a valid shortcut" })
                   return
               end

               local modificator = {}
               if m ~= " " then table.insert(modificator, modkey) end
               if c ~= " " then table.insert(modificator, ctrl) end
               if s ~= " " then table.insert(modificator, shift) end
               if a ~= " " then table.insert(modificator, alt) end

               return awful.key(modificator, key, fun, info)
end


local function client_menu_toggle_fn()
    local instance = nil

    return function()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        if wallpaper then gears.wallpaper.maximized(wallpaper, s, true) end
    end
end
-- }}}


-- Set the terminal for applications that require it
menubar.utils.terminal = terminal

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
--    awful.layout.suit.corner.ne,
--    awful.layout.suit.corner.sw,
--    awful.layout.suit.corner.se,
}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibox
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = util.join(
    awful.button({        }, LMB   , function(t) t:view_only() end),
    awful.button({ modkey }, LMB   , function(t)
                                         if client.focus then
                                             client.focus:move_to_tag(t)
                                         end
                                     end),
    awful.button({        }, RMB   , awful.tag.viewtoggle),
    awful.button({ modkey }, RMB   , function(t)
                                         if client.focus then
                                             client.focus:toggle_tag(t)
                                         end
                                     end),
    awful.button({        }, DownMB, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({        }, UpMB  , function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = util.join(
    awful.button({       }, LMB   , function(c)
                                        if c == client.focus then
                                            c.minimized = true
                                        else
                                            -- Without this, the following :isvisible() makes no sense
                                            c.minimized = false
                                            if not c:isvisible() and c.first_tag then
                                                c.first_tag:view_only()
                                            end
                                            -- This will also un-minimize the client, if needed
                                            client.focus = c
                                            c:raise()
                                        end
                                    end),
    awful.button({       }, RMB   , client_menu_toggle_fn()),
    awful.button({       }, DownMB, function() awful.client.focus.byidx( 1) end),
    awful.button({       }, UpMB  , function() awful.client.focus.byidx(-1) end)
)


screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(util.join(
        awful.button({ }, LMB   , function() awful.layout.inc( 1) end),
        awful.button({ }, RMB   , function() awful.layout.inc(-1) end),
        awful.button({ }, DownMB, function() awful.layout.inc( 1) end),
        awful.button({ }, UpMB  , function() awful.layout.inc(-1) end)
    ))

    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    s.mywibox = awful.wibar({ position = "top", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(util.join(
    awful.button({ }, DownMB, awful.tag.viewnext),
    awful.button({ }, UpMB  , awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = util.join(
    util.key("awesome",      "show help",
             "M   S   /",
             hotkeys_popup.show_help),

    util.key("awesome",      "lua execute prompt",
             "M       x",
             function()
                 awful.prompt.run({ prompt = "Run Lua code: " },
                 awful.screen.focused().mypromptbox.widget,
                 awful.util.eval, nil,
                 awful.util.get_cache_dir() .. "/history_eval")
             end),

    util.key("awesome",      "reload awesome",
             "M   S   r",
             awesome.restart),
    util.key("awesome",      "quit awesome",
             "M   S   q",
             awesome.quit),

    util.key("launcher",     "run prompt",
             "M       z",
             function() awful.screen.focused().mypromptbox:run() end),
    util.key("launcher",     "open a terminal",
             "M       Return",
             function() awful.spawn(terminal) end),
    util.key("launcher",     "show the menubar",
             "M       p",
             function() menubar.show() end),

    util.key("tag",          "view previous",
             "M       Left",
             awful.tag.viewprev),
    util.key("tag",          "view next",
             "M       Right",
             awful.tag.viewnext),
    util.key("tag",          "view last used",
             "M       Escape",
             awful.tag.history.restore),

    util.key("client",       "focus next by index",
             "M       j",
             function() awful.client.focus.byidx( 1) end),
    util.key("client",       "focus previous by index",
             "M       k",
             function() awful.client.focus.byidx(-1) end),

    -- Layout manipulation
    util.key("screen",       "focus the next screen",
             "M C     j",
             function() awful.screen.focus_relative( 1) end),
    util.key("screen",       "focus the previous screen",
             "M C     k",
             function() awful.screen.focus_relative(-1) end),
    util.key("client",       "swap with next client by index",
             "M   S   j",
             function() awful.client.swap.byidx( 1) end),
    util.key("client",       "swap with previous client by index",
             "M   S   k",
             function() awful.client.swap.byidx(-1) end),
    util.key("client",       "jump to urgent client",
             "M       u",
             awful.client.urgent.jumpto),
    util.key("client",       "go back",
             "M       Tab",
             function()
                 awful.client.focus.history.previous()
                 if client.focus then
                     client.focus:raise()
                 end
             end),

    util.key("layout",       "increase master width factor",
             "M       l",
             function() awful.tag.incmwfact( 0.05) end),
    util.key("layout",       "decrease master width factor",
             "M       h",
             function() awful.tag.incmwfact(-0.05) end),
    util.key("layout",       "increase the number of master clients",
             "M   S   h",
             function() awful.tag.incnmaster( 1, nil, true) end),
    util.key("layout",       "decrease the number of master clients",
             "M   S   l",
             function() awful.tag.incnmaster(-1, nil, true) end),
    util.key("layout",       "increase the number of columns",
             "M C     h",
             function() awful.tag.incncol( 1, nil, true) end),
    util.key("layout",       "decrease the number of columns",
             "M C     l",
             function() awful.tag.incncol(-1, nil, true) end),
    util.key("layout",       "select next",
             "M       space",
             function() awful.layout.inc( 1) end),
    util.key("layout",       "select previous",
             "M   S   space",
             function() awful.layout.inc(-1) end),

    util.key("client",      "restore minimized",
             "M C     n",
             function()
                 local c = awful.client.restore()
                 -- Focus restored client
                 if c then
                     client.focus = c
                     c:raise()
                 end
             end)
)

clientkeys = util.join(
    util.key("client",       "toggle fullscreen",
             "M       w",
             function(c)
                 c.fullscreen = not c.fullscreen
                 c:raise()
             end),
    util.key("client",       "close",
             "M       w",
             function(c) c:kill()                         end),
    util.key("client",       "toggle floating",
             "M C     space",
             awful.client.floating.toggle                    ),
    util.key("client",       "move to master",
             "M C     Return",
             function(c) c:swap(awful.client.getmaster()) end),
    util.key("client",       "move to screen",
             "M       o",
             function(c) c:move_to_screen()               end),
    util.key("client",       "toggle keep on top",
             "M       t",
             function(c) c.ontop = not c.ontop            end),
    util.key("client",       "minimize",
             "M       n",
             function(c)
                 -- The client currently has the input focus, so it cannot be
                 -- minimized, since minimized clients can't have the focus.
                 c.minimized = true
             end),
    util.key("client",       "minimize",
             "M       m",
             function(c)
                 c.maximized = not c.maximized
                 c:raise()
             end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  local tagname = "#" .. i
  local keycode = "#" .. i + 9
  globalkeys = util.join(globalkeys,
    util.key("M       " .. keycode,
             function()
                   local screen = awful.screen.focused()
                   local tag = screen.tags[i]
                   if tag then
                      tag:view_only()
                   end
             end),
    util.key("M C     " .. keycode,
             function()
                 local screen = awful.screen.focused()
                 local tag = screen.tags[i]
                 if tag then
                    awful.tag.viewtoggle(tag)
                 end
             end),
    util.key("M   S   " .. keycode,
             function()
                 if client.focus then
                     local tag = client.focus.screen.tags[i]
                     if tag then
                         client.focus:move_to_tag(tag)
                     end
                end
             end),
    util.key("M C S   " .. keycode,
             function()
                 if client.focus then
                     local tag = client.focus.screen.tags[i]
                     if tag then
                         client.focus:toggle_tag(tag)
                     end
                 end
             end)
    )
end
hotkeys_popup.add_hotkeys({ ["tag - numbered"] = {
    {
        modifiers = { modkey },
        keys = { ['1-9']="view tag #1-9", }
    }, {
        modifiers = { modkey, ctrl },
        keys = { ['1-9']="toggle tag #1-9", }
    }, {
        modifiers = { modkey, ctrl },
        keys = { ['1-9']="move focused client to tag #1-9", }
    }, {
        modifiers = { modkey, ctrl },
        keys = { ['1-9']="toggle focused client on tag #1-9", }
    }
}})

clientbuttons = util.join(
    awful.button({        }, LMB, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, LMB, awful.mouse.client.move),
    awful.button({ modkey }, RMB, awful.mouse.client.resize)
)


root.keys(globalkeys)


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = util.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
