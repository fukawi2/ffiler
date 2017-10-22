PROJECT=ffiler
PREFIX=/usr/local

all: install

install:
	install -D -m 0755 $(PROJECT).sh $(DESTDIR)$(PREFIX)/bin/$(PROJECT)
	install -D -m 0644 $(PROJECT).man $(DESTDIR)$(PREFIX)/man/man7/$(PROJECT).7
	gzip -f $(DESTDIR)$(PREFIX)/man/man7/$(PROJECT).7
