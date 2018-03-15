ledgerawk: test package

test: src/*
	echo "Test"
	# Use a small language to generate tests, run an awk script to generate test files and expected results
	# somehow. Then run each in a loop.
	# File of input, the file specifying exit code and expected output.
	# Or just use bats here?

package:
	if [ ! -d "out" ]; then mkdir out; fi
	# Do something to build it
	# Extract script part of awk scripts
	# Possibly as simple as taking line 2 onwards
	# Question of escaping it into a BASH script though
