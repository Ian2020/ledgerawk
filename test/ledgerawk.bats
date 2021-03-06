#!/usr/bin/bats

TEST_FILE=test_file.ldg
OUTPUT_FILE=test_out
SCRIPT_PATH="$BATS_TEST_DIRNAME/../src/ledgerawk"

@test "ledgerawk: transactions translated" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  echo -e $test_input > $TEST_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE
  rm $TEST_FILE

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "ledgerawk: transactions translated from clipboard" {
  IFS='' test_input="17/01/2020 	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020 		£45.43 	£54,084.23 "
  echo -e $test_input | xclip -selection clipboard

  run $SCRIPT_PATH -r santander -i $TEST_FILE -c clipboard
  # xclip process above daemonizes itself as there must be a process holding
  # the selection if it is to be pasted later. We must kill this process when
  # we're finished or bats will wait forever for it to terminate.
  # TODO: Probably a nicer way to grab its process ID than this
  pkill xclip

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
  [ "${#lines[@]}" -eq 0 ]
  [ -s $OUTPUT_FILE ]
  [ $(cat $OUTPUT_FILE | wc -l) -eq 5 ]
  rm -f $OUTPUT_FILE
}

@test "ledgerawk: suppress translation, just do postings" {
  IFS='' test_input="\
2019/05/24 * CARD PAYMENT TO IKEA LTD,16.60 GBP, RATE 1.00/GBP ON 22-05-2019
    ; Let's tag this :IKEA:
    @@@    -£16.60
    @@@"
  echo -e $test_input > $TEST_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE -n
  rm $TEST_FILE

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 4 ]
  [ "${lines[0]}" = "2019/05/24 * CARD PAYMENT TO IKEA LTD,16.60 GBP, RATE 1.00/GBP ON 22-05-2019" ]
}

@test "ledgerawk: suppress translation, just do postings to an output file which is overwritten" {
  IFS='' test_input="\
2019/05/24 * CARD PAYMENT TO IKEA LTD,16.60 GBP, RATE 1.00/GBP ON 22-05-2019
    ; Let's tag this :IKEA:
    @@@    -£16.60
    @@@"
  echo -e $test_input > $TEST_FILE
  rm -f $OUTPUT_FILE

  run $SCRIPT_PATH -r santander -i $TEST_FILE -n -o $TEST_FILE

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 0 ]
  [ $(cat $TEST_FILE | wc -l) -eq 4 ]
  rm -f $TEST_FILE
}
