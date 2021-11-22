ARCAN=$(HOME)/code/arcan
TARGET=util.so
INCLUDES=-I$(ARCAN)/external/lua/

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	$(RM) $(TARGET)

%.so: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -shared $< -o $@
