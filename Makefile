BIN_FILES=bin/zmk bin/zupload bin/svn-list-commits bin/update-group-cfg bin/tn bin/svn-merge-message bin/ztelnet bin/zgetfile

install:
	@for i in $(BIN_FILES); do echo "$$i..."; ln -sf `pwd`/$$i ~/bin/; done
	ln -sf `pwd`/bin/tn ~/bin/cmd2k
