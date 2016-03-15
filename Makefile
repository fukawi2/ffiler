PROJECT=ffiler
PREFIX=/usr/local

all: install

install:
	install -D -m 0755 $(PROJECT).sh $(DESTDIR)$(PREFIX)/bin/$(PROJECT)
	install -D -o0 -g0 -m0644 $(PROJECT).man /usr/local/man/man7/$(PROJECT).7.man
	gzip /usr/local/man/man7/$(PROJECT).7.man
