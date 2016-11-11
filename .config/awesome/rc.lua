local awful     = require("awful")        -- Standard awesome library
require("awful.autofocus")                -- makes sure that there's always a client that will have focus
awful.rules     = require("awful.rules")

beautiful       = require("beautiful")    -- Theme handling library
local wibox     = require("wibox")        -- Panel
local vicious   = require("vicious")      -- Plugins
local naughty   = require('naughty')      -- Notification library

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
      title = "Runtime error",
      text = err })
    in_error = false
  end)
end

-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/zenburn/theme.lua")

local terminal  = "urxvtc"
local exec      = awful.util.spawn
local sexec     = awful.util.spawn_with_shell
local editor    = os.getenv("EDITOR") or "nano"
local home      = os.getenv("HOME")

local modkey = "Mod4"
local shift  = "Shift"
local ctrl   = "Control"
local alt    = "Mod1"

local LMB    = 1
local RMB    = 3
local NextMB = 4
local PrevMB = 5


local util = {}
util.join = awful.util.table.join
util.notify = function(title, text) naughty.notify({ title = title, text = text, timeout = 1 }) end
util.indexOf = function(table, item)
                  for key, value in pairs(table) do
                    if value == item then return key end
                  end
                  return nil
               end

-- {{{ Layout
local layouts = { -- order matters, see awful.layout.inc
  awful.layout.suit.tile,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.floating,
}
local layouts_names = {
  tile       = layouts[1],
  max        = layouts[2],
  fullscreen = layouts[3],
  floating   = layouts[4],
}

-- Define a tag table which hold all screen tags.
local tags = { names = {}, layout = {} }
tags.count = 9
tags.layout[1] = layouts_names.tile

for i = 1, tags.count do
  tags.names[i]  = tags.names[i]  or i
  tags.layout[i] = tags.layout[i] or layouts_names.max
end

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}


-- {{{ Wibox
local wibox_visible = true

local separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)

local textclock = awful.widget.textclock("%d %b %H:%M")

local baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_bat)
local batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat, "$2%", 120, "BAT0")

local systray = wibox.widget.systray()

local mywibox   = {}
local promptbox = {}
local layoutbox = {}
local taglist   = {}
local tasklist  = {}

taglist.buttons = util.join(
  awful.button({        },  LMB   , awful.tag.viewonly),
  awful.button({ modkey },  LMB   , awful.client.movetotag),
  awful.button({        },  RMB   , awful.tag.viewtoggle),
  awful.button({ modkey },  RMB   , awful.client.toggletag),
  awful.button({        },  PrevMB, awful.tag.viewnext),
  awful.button({        },  NextMB, awful.tag.viewprev)
)

for s = 1, screen.count() do
  promptbox[s] = awful.widget.prompt()

  layoutbox[s] = awful.widget.layoutbox(s)
  layoutbox[s]:buttons(util.join(
    awful.button({ }, LMB   , function () awful.layout.inc(layouts,  1) end),
    awful.button({ }, RMB   , function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, PrevMB, function () awful.layout.inc(layouts,  1) end),
    awful.button({ }, NextMB, function () awful.layout.inc(layouts, -1) end)
  ))

  taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)

  tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags)

  mywibox[s] = awful.wibox({
    screen = s,
    height = 32,
    position = "top",
    fg = beautiful.fg_normal,
    bg = beautiful.bg_normal,
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

local globalbuttons = util.join(
  awful.button({ }, PrevMB, awful.tag.viewnext),
  awful.button({ }, NextMB, awful.tag.viewprev)
)

local clientbuttons = util.join(
  awful.button({        },  LMB, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey },  LMB, awful.mouse.client.move),
  awful.button({ modkey },  RMB, awful.mouse.client.resize)
)

local globalkeys = util.join(
  awful.key({ modkey,  ctrl         }, "Up",      function() awful.client.moveresize(0, -20, 0, 0) end),
  awful.key({ modkey,  ctrl         }, "Down",    function() awful.client.moveresize(0, 20, 0, 0) end),
  awful.key({ modkey,  ctrl         }, "Left",    function() awful.client.moveresize(-20, 0, 0, 0) end),
  awful.key({ modkey,  ctrl         }, "Right",   function() awful.client.moveresize(20, 0, 0, 0) end),

  awful.key({ modkey,  ctrl,  shift }, "Up",      function() awful.client.moveresize(0, 0, 0, -20) end),
  awful.key({ modkey,  ctrl,  shift }, "Down",    function() awful.client.moveresize(0, 0, 0, 20) end),
  awful.key({ modkey,  ctrl,  shift }, "Right",   function() awful.client.moveresize(0, 0, 20, 0) end),
  awful.key({ modkey,  ctrl,  shift }, "Left",    function() awful.client.moveresize(0, 0, -20, 0) end),

  awful.key({ modkey, shift          }, "Return", function ()
    for s = 1, screen.count() do
      mywibox[s].visible = not wibox_visible
    end
    wibox_visible = not wibox_visible
  end),

  awful.key({ modkey,         shift }, "Left",
    function()
      local curidx = awful.tag.getidx()
      if curidx == 1 then
        awful.client.movetotag(tags[client.focus.screen][tags.count])
      else
        awful.client.movetotag(tags[client.focus.screen][curidx - 1])
      end
    end),
  awful.key({ modkey,         shift }, "Right",
    function()
      local curidx = awful.tag.getidx()
      if curidx == tags.count then
        awful.client.movetotag(tags[client.focus.screen][1])
      else
        awful.client.movetotag(tags[client.focus.screen][curidx + 1])
      end
    end),

  awful.key({ modkey,               }, "Escape",
    function ()
      awful.client.focus.history.previous()
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,         shift }, "Escape",  awful.tag.history.restore),

  awful.key({ modkey,               }, "Return",  function () exec(terminal) end),
  awful.key({ modkey,               }, "a",       function () exec("google-chrome-stable") end),
  awful.key({ modkey,         shift }, "a",       function () exec("opera") end),
  awful.key({ modkey,               }, "s",       function () exec("subl") end),

  awful.key({ modkey,         shift }, "r",       awesome.restart),
  awful.key({ modkey,         shift }, "q",       awesome.quit),

  awful.key({ modkey,               }, "z",       function () promptbox[mouse.screen]:run() end),

  awful.key({                       }, "Print",   function () exec ("scrot-wrapper        ") end),
  awful.key({                 shift }, "Print",   function () sexec("scrot-wrapper    -d 1") end),
  awful.key({ alt   ,               }, "Print",   function () exec ("scrot-wrapper -u     ") end),
  awful.key({ alt   ,         shift }, "Print",   function () sexec("scrot-wrapper -u -d 1") end),


  awful.key({ modkey,               }, "Left",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,               }, "Right",
    function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),

  awful.key({ modkey,               }, "Tab",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,         shift }, "Tab",
    function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),


  awful.key({ modkey,               }, "j",
    function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,               }, "k",
    function()
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
    function()
      awful.tag.incnmaster(1)
      util.notify("Master", tostring(awful.tag.getnmaster()))
    end),
  awful.key({ modkey,         shift }, "l",
    function()
      awful.tag.incnmaster(-1)
      util.notify("Master", tostring(awful.tag.getnmaster()))
    end),
  awful.key({ modkey,  ctrl         }, "h",
    function()
      awful.tag.incncol(1)
      util.notify("Columns", tostring(awful.tag.getncol()))
    end),
  awful.key({ modkey,  ctrl         }, "l",
    function()
      awful.tag.incncol(-1)
      util.notify("Columns", tostring(awful.tag.getncol()))
    end),

  awful.key({ modkey,               }, "space",   function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey,         shift }, "space",   function () awful.layout.inc(layouts, -1) end),

  awful.key({ modkey,  ctrl         }, "n",       awful.client.restore),

  -- Standard program

  awful.key({                       }, "XF86MonBrightnessDown",   function () exec("xbacklight -dec 15") end),
  awful.key({                       }, "XF86MonBrightnessUp",     function () exec("xbacklight -inc 15") end),
  awful.key({                 shift }, "XF86MonBrightnessDown",   function () exec("xbacklight -dec 5") end),
  awful.key({                 shift }, "XF86MonBrightnessUp",     function () exec("xbacklight -inc 5") end),
  awful.key({                       }, "XF86KbdBrightnessUp",     function () exec("asus-kbd-backlight up") end),
  awful.key({                       }, "XF86KbdBrightnessDown",   function () exec("asus-kbd-backlight down") end),

  awful.key({                       }, "XF86TouchpadToggle",
    function()
      sexec("synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")
    end),

  awful.key({ modkey,               }, "F12",     function () exec("xautolock -locknow", false) end)
)

local clientkeys = util.join(
  awful.key({ modkey,               }, "w",       function (c) c:kill()                         end),
  awful.key({ modkey,         shift }, "e",       function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey,               }, "e",
    function (c)
      local maximized = c.maximized_horizontal and c.maximized_vertical
      c.maximized_horizontal = not maximized
      c.maximized_vertical   = not maximized
    end),

  awful.key({ modkey,  ctrl         }, "space",   awful.client.floating.toggle                     ),
  awful.key({ modkey,  ctrl         }, "Return",  function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,               }, "o",       awful.client.movetoscreen                        ),
  awful.key({ modkey,  ctrl         }, "r",       function (c) c:redraw()                       end),
  awful.key({ modkey,               }, "t",       function (c) c.ontop = not c.ontop            end),
  awful.key({ modkey,               }, "n",       function (c) c.minimized = true               end)
)


-- Compute the maximum number of digit we need, limited to 9
local keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
  local keyCode = "#" .. i + 9
  globalkeys = util.join(globalkeys,
    awful.key({ modkey              }, keyCode,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, ctrl        }, keyCode,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key({ modkey,       shift }, keyCode,
      function()
        local screen = client.focus.screen
        if client.focus and tags[screen][i] then
          awful.client.movetotag(tags[screen][i])
        end
      end),
    awful.key({ modkey, ctrl, shift }, keyCode,
      function()
        local screen = client.focus.screen
        if client.focus and tags[screen][i] then
          awful.client.toggletag(tags[screen][i])
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

globalkeys = util.join( globalkeys,
  awful.key({ modkey,               }, "`",       function () quakeconsole[mouse.screen]:toggle()     end),
  awful.key({ modkey,         shift }, "`",       function () quakeconsole[mouse.screen]:resize( 0.1) end),
  awful.key({ modkey, ctrl          }, "`",       function () quakeconsole[mouse.screen]:resize(-0.1) end)
)
-- }}}


-- Set keys
root.keys(globalkeys)
root.buttons(globalbuttons)
-- }}}


-- {{{ Rules
local function tag_rule(class, tag, ignore_dialogs)
  local rule_key = type(class) == "table" and "rule_any" or "rule"

  local result = {}
  result[rule_key] = { class = class }
  result.properties = { tag = tag }
  if ignore_dialogs then
    result.except = { type = "dialog" }
  end
  return result
end

local function floating_rule(class)
  local result = {}
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

  floating_rule("gimp"),

  tag_rule(
    { "Chromium", "[Gg]oogle[-]chrome.*", "Opera", "Dwb", "[Yy]andex[-]browser.*" },
    tags[1][3], true),

  tag_rule("Skype",       tags[1][9]),
  tag_rule("Thunderbird", tags[1][4], true),
}
-- }}}


-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c, startup)
  if not startup then
    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

for s = 1, screen.count() do
  -- No borders with only one visible client
  screen[s]:connect_signal("arrange", function()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    local quakeConsole = quakeconsole[s].client
    local quakeIndex = util.indexOf(clients, quakeConsole)
    if quakeIndex then table.remove(clients, quakeIndex) end

    if #clients > 0 then
      for _, c in pairs(clients) do
        if c.maximized then
          c.border_width = 0
        elseif awful.client.floating.get(c) or layout == "floating" then
          -- Floaters always have borders
          c.border_width = beautiful.border_width
        elseif #clients == 1 or layout == "max" then
          c.border_width = 0
        else
          c.border_width = beautiful.border_width
        end
      end
    end
  end)
end
-- }}}