#!/usr/bin/bats

TEST_FILE=test_file.ldg
SETTINGS_FILE=.ledgerimport

function empty_settingsfile() {
  rm -f $SETTINGS_FILE && touch $SETTINGS_FILE
}

function create_settingsfile() {
  rm -f $SETTINGS_FILE && touch $SETTINGS_FILE
  echo -e "$1" > $SETTINGS_FILE
}

function execute_postings() {
  # Function argument should be the ledger transactions to test
  echo -e "$1" > $TEST_FILE

  run ./src/postings.sh $TEST_FILE
  
  echo "EXPECTING:"
  echo -e "$TEST_EXP"
  echo "GOT:"
  echo -e "$output"

  # Cleanup
  rm $TEST_FILE
  rm $SETTINGS_FILE
}

function test_expectations() {
  [ "$status" -eq 0 ]
  [ "$output" = "$TEST_EXP" ]
}

@test "Single transaction, no matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP="$TEST_CASE"
  empty_settingsfile

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single transaction, matched" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£16.60
    Expenses:IKEA
EOF
  )
  create_settingsfile "IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Multiple transactions, no matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£39.52 
    @@@
EOF
  )
  TEST_EXP="$TEST_CASE"
  empty_settingsfile

  execute_postings "$TEST_CASE"

  test_expectations
}
