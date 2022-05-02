#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#include <gdk-pixbuf/gdk-pixbuf.h>
#include <cairo.h>

static int luaw_setenv(lua_State *L) {
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
   } else {
      const char *value = lua_tostring(L, -1);
      setenv(name, value, true);
   }

   lua_pop(L, 2);
   return 0;
}

static int luaw_pixbuf_to_surface(lua_State *L) {
   GdkPixbuf *buf = (GdkPixbuf *) lua_touserdata(L, 1);

   int width = gdk_pixbuf_get_width(buf);
   int height = gdk_pixbuf_get_height(buf);
   int pix_stride = gdk_pixbuf_get_rowstride(buf);
   guchar *pixels = gdk_pixbuf_get_pixels(buf);
   int channels = gdk_pixbuf_get_n_channels(buf);
   cairo_surface_t *surface;
   int cairo_stride;
   unsigned char *cairo_pixels;

   cairo_format_t format = CAIRO_FORMAT_ARGB32;
   if (channels == 3)
      format = CAIRO_FORMAT_RGB24;

   surface = cairo_image_surface_create(format, width, height);
   cairo_surface_flush(surface);
   cairo_stride = cairo_image_surface_get_stride(surface);
   cairo_pixels = cairo_image_surface_get_data(surface);

   for (int y = 0; y < height; y++) {
      guchar *row = pixels;
      uint32_t *cairo = (uint32_t *) cairo_pixels;
      for (int x = 0; x < width; x++) {
         if (channels == 3) {
            uint8_t r = *row++;
            uint8_t g = *row++;
            uint8_t b = *row++;
            *cairo++ = (r << 16) | (g << 8) | b;
         } else {
            uint8_t r = *row++;
            uint8_t g = *row++;
            uint8_t b = *row++;
            uint8_t a = *row++;
            double alpha = a / 255.0;
            r = r * alpha;
            g = g * alpha;
            b = b * alpha;
            *cairo++ = (a << 24) | (r << 16) | (g << 8) | b;
         }
      }
      pixels += pix_stride;
      cairo_pixels += cairo_stride;
   }

   cairo_surface_mark_dirty(surface);
   lua_pushlightuserdata(L, surface);

   return 1;
}

static luaL_Reg lua_regs[] = {
   {"setenv", luaw_setenv},
   {"pixbuf_to_surface", luaw_pixbuf_to_surface},
   {NULL, NULL},
};

luaL_Reg* arcan_module_init(int lua_major, int lua_minor, int lua_vernum) {
   return lua_regs;
}

int main() {}
