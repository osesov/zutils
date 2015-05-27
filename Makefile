BIN_FILES=core2md dump_syms dumpview minidump-2-core minidump_dump minidump_stackwalk mips-configure svn-list-commits svn-merge-list svn-merge-message svn-merge-revs tn update-group-cfg zgetfile zmk ztelnet zupload

install:
	@for i in $(BIN_FILES); do echo "$$i..."; ln -sf `pwd`/bin/$$i ~/bin/; done
	ln -sf `pwd`/bin/tn ~/bin/cmd2k
