ledgerawk: test

clean:
	@rm .test

test: .test

.test: src/* test/*
	bats ./test
	@touch .test
