ARCAN=$(HOME)/code/arcan
TARGET=util.so
INCLUDES=-I$(ARCAN)/external/lua/ -I$(ARCAN)/src

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	$(RM) $(TARGET)

%.so: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -shared $< -o $@
