ARCAN=$(HOME)/code/arcan
AWESOME=$(HOME)/code/awesome
TARGET=wonderful.so
DEPS=gdk-pixbuf-2.0 cairo
INCS=$(shell pkg-config --cflags $(DEPS)) -I$(AWESOME)
LIBS=$(shell pkg-config --libs $(DEPS))

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	$(RM) $(TARGET)

%.so: %.c
	$(CC) $(CFLAGS) $(INCS) $(LIBS) -shared $< -o $@
