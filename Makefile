BIN_FILES=zmk zupload svn-list-commits update-group-cfg tn svn-merge-message svn-merge-list svn-merge-revs ztelnet zgetfile mips-configure

install:
	@for i in $(BIN_FILES); do echo "$$i..."; ln -sf `pwd`/bin/$$i ~/bin/; done
	ln -sf `pwd`/bin/tn ~/bin/cmd2k
