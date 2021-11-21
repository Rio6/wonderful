//#include <stdint.h>
//#include <stdbool.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//#include <platform/platform_types.h>
//#include <platform/os_platform.h>

int openlibs(lua_State *L) {
   lua_newtable(L);
   lua_setfield(L, LUA_REGISTRYINDEX, "_LOADED");
   luaL_openlibs(L);
   return 0;
}

static luaL_Reg lua_regs[] = {
   { "openlibs", openlibs },
   { NULL, NULL },
};

luaL_Reg* arcan_module_init(int lua_major, int lua_minor, int lua_vernum) {
   //arcan_fetch_namespace(RESOURCE_APPL);
   return lua_regs;
}
