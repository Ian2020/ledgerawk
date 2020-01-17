#!/usr/bin/bats

# Global
TEST_FILE=test_file.ldg

execute_reader() {
  # Function argument should be the transactions to test
  echo -e "$1" > $TEST_FILE

  run ./src/reader_santander $TEST_FILE

  echo "EXPECTING:"
  echo -e "$2"
  echo "GOT:"
  echo -e "$output"

  # Cleanup
  rm $TEST_FILE
}

function test_expectations() {
  # Pass expectations as first arg
  [ "$status" -eq 0 ]
  [ "$output" = "$1" ]
}

@test "reader_santander: one transaction" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  IFS='' test_exp="0001	2020/01/17	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 	-£45.43 "
  execute_reader $test_input $test_exp

  test_expectations $test_exp
}
