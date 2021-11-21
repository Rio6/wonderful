ARCAN=~/code/arcan
INCLUDES=-I$(ARCAN)/external/lua/ -I$(ARCAN)/src

.PHONY: all
all: lualib.so

.PHONY: clean
clean:
	$(RM) lualib.so

%.so: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -shared $< -o $@
