TOP=../../../..
include $(TOP)/mk/boilerplate.mk
include $(TOP)/mk/test.mk

SETUP='$(PWD)/Setup' -v0
CONFIGURE=$(SETUP) configure $(CABAL_MINIMAL_BUILD) --with-ghc='$(TEST_HC)' --with-hc-pkg='$(GHC_PKG)' --ghc-options='$(TEST_HC_OPTS)' --package-db='$(PWD)/tmp.d' --prefix='$(PWD)/inst'

# This test checks that instantiating an indefinite package
# with a wired in package works.

bkpcabal07: clean
	$(MAKE) -s --no-print-directory clean
	'$(GHC_PKG)' init tmp.d
	'$(TEST_HC)' $(TEST_HC_OPTS) -v0 --make Setup
	$(CONFIGURE)
	$(SETUP) build
ifneq "$(CLEANUP)" ""
	$(MAKE) -s --no-print-directory clean
endif

clean :
	$(RM) -rf tmp.d inst dist Setup$(exeext)
