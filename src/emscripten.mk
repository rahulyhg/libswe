include Makefile

EMFLAGS = -O2 --closure 1
EMFLAGS += --post-js libswe.post.js
EMFLAGS += -s EXPORTED_FUNCTIONS=@`pwd`/em-exported-functions.js

libswe.post.js: swephexp.h
	echo "var Module;" > $@
	echo "if (typeof Module === "undefined") Module = {};" > $@
	grep '#.*define' $< | grep ' SE' \
		| sed -e 's/#.*define */Module["_/' \
		| sed -e 's/[ \t]\+/"] = /' \
		| sed -e 's/\<[A-Z][A-Z0-9_]*\>/Module["_&"]/g' \
		| sed -e 's:[ \t]*\(/\*.*\)\?$$:;:' \
		>> $@

libswe.html: $(SWESRC) libswe.post.js
	$(CC) $(SWESRC) -o $@ $(EMFLAGS)

libswe.inner.js: $(SWESRC) libswe.post.js
	$(CC) $(SWESRC) -o $@ $(EMFLAGS)
	sleep 1

libswe.js: libswe.inner.js em-wrapper.js
	sed -e '/var Module;/{r libswe.inner.js' -e 'd}' em-wrapper.js > $@
