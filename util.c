#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include <platform/platform_types.h>

int wonderful_openlibs(lua_State *L) {
   lua_newtable(L);
   lua_setfield(L, LUA_REGISTRYINDEX, "_LOADED");
   luaL_openlibs(L);
   return 0;
}

int wonderful_setenv(lua_State *L) {
   if(lua_gettop(L) < 2) {
      lua_pushstring(L, "too few arguments");
      lua_error(L);
      return 0;
   }

   if(!lua_isstring(L, -2)) {
      lua_pushstring(L, "name must be string");
      lua_error(L);
      return 0;
   }

   const char *name = lua_tostring(L, -2);

   if(lua_isnil(L, -1)) {
      unsetenv(name);
      return 0;
   }

   const char *value = lua_tostring(L, -1);
   setenv(name, value, true);

   lua_pop(L, 2);
   return 0;
}

static luaL_Reg lua_regs[] = {
   { "openlibs", wonderful_openlibs },
   { "setenv", wonderful_setenv },
   { NULL, NULL },
};

luaL_Reg* arcan_module_init(int lua_major, int lua_minor, int lua_vernum) {
   return lua_regs;
}
