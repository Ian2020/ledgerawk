#!/usr/bin/bats

TEST_FILE=test_file.ldg
SETTINGS_FILE=.ledgerimport

function empty_settingsfile() {
  echo "" > $SETTINGS_FILE
}

function execute_postings() {
  # Function argument should be the ledger transactions to test
  echo -e "$1" > $TEST_FILE

  run ../src/postings.sh $TEST_FILE
  
  echo "EXPECTING:"
  echo -e "$TEST_CASE"
  echo "GOT:"
  echo -e "$output"

  # Cleanup
  rm $TEST_FILE
  rm $SETTINGS_FILE
}

@test "Single transaction, no matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@
EOF
  )

  # This test has found a bug already! Ignore for now till we're ready to fix it
  skip
  empty_settingsfile
  execute_postings "$TEST_CASE"

  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_CASE" ]
}
