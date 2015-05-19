PROJECT=ffiler
PREFIX=/usr/local

all: install

install:
	install -D -m 0755 $(PROJECT).sh $(DESTDIR)$(PREFIX)/bin/$(PROJECT)
