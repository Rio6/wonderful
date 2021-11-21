local util = system_load("util.so")

util.openlibs()

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

local glib = require("lgi").GLib
local conn_point = "wonderful"

function wonderful()
   target_alloc(conn_point, client_event_handler)
   util.setenv("ARCAN_CONNPATH", conn_point)
   awesome.start()
end

function wonderful_clock_pulse()
   glib.MainContext.default():iteration(false)
end

function client_event_handler(source, status)
   if status.kind == "terminated" then
      delete_image(source)

   elseif status.kind == "resized" then
      resize_image(source, status.width, status.height)

   elseif status.kind == "connected" then
      target_alloc(conn_point, client_event_handler)

   elseif status.kind == "registered" then
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
