#!/usr/bin/bats

SCRIPT_PATH="$BATS_TEST_DIRNAME/../src/reader_santander"

# Global
TEST_FILE=test_file.ldg

execute_reader() {
  # Function argument should be the transactions to test
  echo -e "$1" > $TEST_FILE

  run "$SCRIPT_PATH" $TEST_FILE

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
  IFS='' test_exp="0001	2020/01/17	CARD PAYMENT TO SAINSBURYS PETROL,45.43 GBP, RATE 1.00/GBP ON 15-01-2020	-£45.43"

  execute_reader $test_input $test_exp

  test_expectations $test_exp
}

@test "reader_santander: two transactions with advert in the middle" {
  IFS='' test_input="\
14/01/2020 	CARD PAYMENT TO CO-OP GROUP 070478,8.04 GBP, RATE 1.00/GBP ON 12-01-2020 		£8.04 	£56,072.34
NEW! Earn 5% Cashback at Waitrose & Partners
Choose Offer
14/01/2020 	CARD PAYMENT TO BEERHUNTER LTD,28.65 GBP, RATE 1.00/GBP ON 12-01-2020 		£28.65 	£56,080.38 "
  IFS='' test_exp="\
0001	2020/01/14	CARD PAYMENT TO CO-OP GROUP 070478,8.04 GBP, RATE 1.00/GBP ON 12-01-2020	-£8.04
0004	2020/01/14	CARD PAYMENT TO BEERHUNTER LTD,28.65 GBP, RATE 1.00/GBP ON 12-01-2020	-£28.65"

  execute_reader $test_input $test_exp

  test_expectations $test_exp
}
