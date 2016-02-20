BIN_FILES=dumpview  mips-configure svn-list-commits svn-merge-list svn-merge-message svn-merge-revs svn-merge-info tn update-group-cfg zgetfile zmk ztelnet zupload mklinks zping getdump perflog svn-eol svn-clean
X32_FILES=$(addprefix x32/, dump_syms minidump_dump minidump_stackwalk core2md minidump-2-core)
X64_FILES=$(addprefix x64/, dump_syms minidump_dump minidump_stackwalk core2md minidump-2-core)

system=$(shell uname -m)

ifneq ($(filter $(system),i386 i486 i586 i686),)
    $(info x32)
    BIN_FILES+=$(X32_FILES)
endif

ifneq ($(filter $(system),x86_64),)
    $(info x64)
    BIN_FILES+=$(X64_FILES)
endif

.PHONY: install
install: $(addprefix bin/,$(BIN_FILES))
	@for i in $(BIN_FILES); do echo "$$i..."; ln -sf `pwd`/bin/$$i ~/bin/; done
	ln -sf `pwd`/bin/tn ~/bin/cmd2k
	ln -sf `pwd`/bin/tn ~/bin/zssh
	ln -sf `pwd`/emacs/init.el ~/.emacs.d/init.el
