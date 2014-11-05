BIN_FILES=bin/zmk bin/zupload bin/svn-list-commits bin/update-group-cfg

install:
	@for i in $(BIN_FILES); do echo "$$i..."; ln -sf `pwd`/$$i ~/bin/; done
