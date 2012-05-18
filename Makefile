VERSION = 1.3

pdumpfs: pdumpfs.in
	rm -f pdumpfs
	sed -e "s!@VERSION@!$(VERSION)!g" \
	    pdumpfs.in > pdumpfs
	chmod 555 pdumpfs

check: pdumpfs
	cd tests && sh pdumpfs-test

clean:
	rm -f pdumpfs pdumpfs.exe pdumpfs.exr
	rm -f tests/tmp.log

dist: clean
	rm -rf pdumpfs-$(VERSION)
	mkdir pdumpfs-$(VERSION)
	cp -p   README COPYING ChangeLog Makefile\
		pdumpfs.in pdumpfs-$(VERSION)
	cp -rp tests man doc pdumpfs-$(VERSION)
	find pdumpfs-$(VERSION) -name CVS -or -name '*~' | xargs rm -rf
	tar zcvf pdumpfs-$(VERSION).tar.gz pdumpfs-$(VERSION)
	rm -rf pdumpfs-$(VERSION)


#
# For Windows
#

CATALOGS = catalog.jpn.txt
w32_pkgname = pdumpfs-w32-$(VERSION)

pdumpfs.exe: pdumpfs
	ruby -r exerb/mkexr.rb pdumpfs dummy
	echo "set_core_by_name	gui" >> pdumpfs.exr
	exerb pdumpfs.exr

dist-w32: clean pdumpfs.exe
	rm -rf $(w32_pkgname) $(w32_pkgname).zip
	mkdir -p $(w32_pkgname)
	cp -p pdumpfs.exe pdumpfs.exe.manifest $(CATALOGS) $(w32_pkgname)
	nkf COPYING > $(w32_pkgname)/COPYING.TXT
	nkf README > $(w32_pkgname)/README.TXT
	zip -r $(w32_pkgname).zip $(w32_pkgname)
#	rm -rf $(w32_pkgname)


