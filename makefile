ledgerawk: test

clean:
	@rm .test

test: .test

.test: src/* test/*
	bats ./test
	./test/reader_usbank_ccard.py
	@touch .test
