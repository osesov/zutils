BIN_FILES=bin/zmk bin/zupload

install:
	@for i in $(BIN_FILES); do echo "$$i..."; cp $$i ~/bin/; done
