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

@test "Single commented transaction, no matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; Here's a comment
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
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single transaction space between currency, matched" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£ 16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£ 16.60
    Expenses:IKEA
EOF
  )
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single commented transaction, matched" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; Comment
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; Comment
    Assets:IKEA    -£16.60
    Expenses:IKEA
EOF
  )
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single transaction, matched but not for this filename" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; Comment
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$TEST_CASE
  create_settingsfile "NONMATCHING_FILENAME¬IKEA¬Assets:IKEA¬Expenses:IKEA"

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

@test "Multiple transactions, one matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£39.52 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£16.60
    Expenses:IKEA

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£39.52 
    @@@
EOF
  )
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Multiple transactions, all match" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£16.60 
    @@@

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£39.52 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£16.60
    Expenses:IKEA

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:Tesco    -£39.52
    Expenses:Tesco
EOF
  )
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA\n$TEST_FILE¬TESCO¬Assets:Tesco¬Expenses:Tesco"

  execute_postings "$TEST_CASE"

  test_expectations
}

#
# TAGS
#

@test "Single tagged transaction, no matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP="$TEST_CASE"
  empty_settingsfile

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single tagged transaction, matches" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    Assets:IKEA    -£16.60
    Expenses:IKEA
EOF
  )
  create_settingsfile "$TEST_FILE¬:TAG:¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single tagged transaction, matches but not for this filename" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP="$TEST_CASE"
  create_settingsfile "NONMATCHING_FILENAME¬:TAG:¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single tagged transaction, regex for tag not matched with transaction description" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO :IKEA: LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO :IKEA: LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  create_settingsfile "$TEST_FILE¬:IKEA:¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

@test "Single tagged transaction, regex for transaction description not matched with transaction tag" {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  TEST_EXP=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    ; :TAG:
    @@@    -£16.60 
    @@@
EOF
  )
  create_settingsfile "$TEST_FILE¬TAG¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}

#
# Matched things shouldn't bleed beyond the transaction that matched
#

@test "Multiple transactions, first matches but already filled so match is cancelled." {
  TEST_CASE=$(cat << EOF
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    A    -£16.60 
    B

2019/05/24 * CARD PAYMENT TO TESCO PFS 3876,39.52 GBP, RATE 1.00/GBP ON 22-05-2019 
    @@@    -£39.52 
    @@@
EOF
  )
  TEST_EXP=$TEST_CASE
  create_settingsfile "$TEST_FILE¬IKEA¬Assets:IKEA¬Expenses:IKEA"

  execute_postings "$TEST_CASE"

  test_expectations
}
