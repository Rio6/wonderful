local util = system_load("util.so")
util.openlibs()

local glib = require("lgi").GLib

local conn_point = "wonderful"
local capi = {
    "awesome",
    "root",
    "tag",
    "screen",
    "client",
    "mouse",
    "drawin",
    "button",
    "keygrabber",
    "mousegrabber",
    "dbus",
    "key",
}

for _, name in ipairs(capi) do
   _G[name] = require(name)
end

function wonderful()
   target_alloc(conn_point, client_event_handler)
   util.setenv("ARCAN_CONNPATH", conn_point)

   screen.add_screen(0, 0, VRESW, VRESH)
   screen.primary = screen[1]

   awesome.start()
end

function wonderful_clock_pulse()
   glib.MainContext.default():iteration(false)
   awesome.emit_signal("refresh")
end

function client_event_handler(source, status)
   if status.kind == "terminated" then
      c = client.from_vid(source)
      if c ~= nil then
         c:kill()
      end
      delete_image(source)

   elseif status.kind == "resized" then
      resize_image(source, status.width, status.height)

   elseif status.kind == "connected" then
      target_alloc(conn_point, client_event_handler)

   elseif status.kind == "registered" then
      client.add_client {
         vid = source,
         screen = screen.primary,
         x = 0,
         y = 0,
         width = VRESW,
         height = VRESH,
      }
      show_image(source)

   elseif status.kind == "preroll" then
      target_displayhint(source, VRESW, VRESH, TD_HINT_IGNORE, {ppcm = VPPCM})

   elseif status.kind == "segment_request" then
      if status.segkind == "clipboard" then
         local vid = accept_target(clipboard_handler)
         if not valid_vid(vid) then
            return
         end
         link_image(vid, source)
      end
   end
end

function wonderful_input(input)
   local c = client.focus
   if c ~= nil then
      target_input(c.vid, input)
   end
end
