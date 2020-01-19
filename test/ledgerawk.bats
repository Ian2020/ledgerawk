#!/usr/bin/bats

TEST_FILE=test_file.ldg
OUTPUT_FILE=test_out
# There is an assumption here about where the tests are run from
SCRIPT_PATH=src/ledgerawk

@test "ledgerawk: transactions translated" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  echo -e $test_input > $TEST_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE
  rm $TEST_FILE

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "ledgerawk: transactions translated with verbose" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  echo -e $test_input > $TEST_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE -v
  rm $TEST_FILE

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 4 ]
}

@test "ledgerawk: transactions translated to output file" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  rm -f $OUTPUT_FILE
  echo -e $test_input > $TEST_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE -o $OUTPUT_FILE
  rm $TEST_FILE

  [ "$status" -eq 0 ]
  [ -s $OUTPUT_FILE ]
  rm -f $OUTPUT_FILE
}
