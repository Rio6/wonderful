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

function wonderful()
   wonderful = system_load("wonderful.so")

   for _, name in ipairs(capi) do
      _G[name] = require(name)
   end

   target_alloc(conn_point, client_event_handler)
   wonderful.setenv("ARCAN_CONNPATH", conn_point)

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
      client.manage {
         window = source,
         screen = screen.primary,
         x = 0,
         y = 0,
         width = VRESW,
         height = VRESH,
      }
      show_image(source)

   elseif status.kind == "preroll" then
      target_displayhint(source, VRESW, VRESH, TD_HINT_IGNORE, {ppcm = VPPCM})
   end
end

function wonderful_input(input)
   root.handle_event(input)
end
