system_load("lualib.so").openlibs()

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

function wonderful()
   awesome.start()
end

function wonderful_clock_pulse()
   glib.MainContext.default():iteration(false)
end
