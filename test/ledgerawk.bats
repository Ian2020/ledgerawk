#!/usr/bin/bats

TEST_FILE=test_file.ldg

@test "ledgerawk: transactions translated" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  pushd src
  echo -e $test_input > $TEST_FILE

  run ./ledgerawk santander $TEST_FILE
  rm $TEST_FILE
  popd

  [ "$status" -eq 0 ]
}
