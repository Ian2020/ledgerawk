# README

## Current Usage

Everything is in src dir in anticipation of building one final script for the whole
thing. Below are the scripts in the order to run them. Each script can work from
STDIN or a filename as they are all awk scripts at the moment. However I would
avoid using STDIN as pasting hard tabs in here-documents [is
tricky](https://stackoverflow.com/questions/3731513/how-do-you-type-a-tab-in-a-bash-here-document)
and they are used in the file formats.

* reader\_\*: first stage of converting to our intermediate format.
* At this stage you may need to sort with `sort -gr` to do a reverse numberic
  sort on the intermediate format. This gets transactions in a most-recent last
  order as ledger needs.
* ledgerimport: convert intermediate format to ledger format.
* postings.sh: Update the transaction postings from previous step with regex
  expressions in a .ledgerimport settings file, more on this below.
* ledgerawk: My unfinished attempt at the final script that brings it all
  together.

### Auto-populate Postings

You can teach postings.sh to automatically fill in postings. It will look for a
file `.ledgerimport` first in the current dir and if not found then in your home
directory. Format is:

```text
# Comment line
# Line format: FILE¬TRANSACTION¬POSTING1¬POSTING2
# Example:
bank.ldg¬IKEA¬Assets:IKEA¬Expenses:IKEA
```

Given a transaction like so in a file bank.ldg:

```text
2019/05/24 * CARD PAYMENT TO IKEA LTD,16.60 GBP, RATE 1.00/GBP ON 22-05-2019
    @@@    -£16.60
    @@@
```

It will attempt to match the TRANSACTION regex against the transaction
description and if so replace the first and second occurences of '@@@' with
POSTING1 and POSTING2 respectively:

```text
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£16.60
    Expenses:IKEA
```

You can also search comments for tags and replace postings the same way. Just
indicate this by surrounding your TRANSACTION regex with colons. So if you have the
following in your .ledgerimport file:

```text
bank.ldg¬:IKEA:¬Assets:IKEA¬Expenses:IKEA
```

And a transaction such as:

```text
2019/05/24 * CARD PAYMENT TO IKEA LTD,16.60 GBP, RATE 1.00/GBP ON 22-05-2019
    ; Let's tag this :IKEA:
    @@@    -£16.60
    @@@
```

The output will be:

```text
2019/05/24 * CARD PAYMENT TO IKEA LTD 264 BRISTOL IKEA,16.60 GBP, RATE 1.00/GBP ON 22-05-2019 
    Assets:IKEA    -£16.60
    Expenses:IKEA
```

Tag matching takes priority over transaction description and across both the
first entry in the ledgerimport settings file to match will win.

The FILE regex is there so you can limit the application of matching to the
correct ledger file, in case you have multiple to deal with.

## Implementation Details

These details mostly for developers use and debugging rather than end-users.

### Intermediate Format

```text
ORDER[TAB]DATE[TAB]DESCRIPTION[AMOUNT]
```

e.g.

```text
0001  2020/06/20  Disneyland  -$400
```

The order field is the last line number of each transaction from the input file.
This allows us to reverse the order of transactions if needed for ledger.

## Development

Don't forget to run the tests: `make test`. They require [bats](https://github.com/sstephenson/bats).

### Desired Usage

Copy transactions from browser into clipboard. Then at the terminal:

```bash
ledgerimport [INSTITUTION]
```

It will read from the clipboard and parse the data for the given institution.
The results will be put back on the clipboard for pasting into your ledger files.

### Roadmap

* Better usage:
  * Add option to take input from clipboard (X)
* More into config, less to specify on the cmdline:
  * In a new config take labels for mappings of reader_type to ledger file:
    `label: reader_type destination_ledger_file`
  * Allow specifying label on cmdline to shortcut output file and reader options
    * When we run postings cmd default input should also be the ledger file,
      unless on cmdline
* Easier to invoke:
  * Switch to ninja for build
  * Pick a better name that would survive in actual Fedora repos
  * Identify correct path to install our subsidiary scripts to
  * Install it system-wide when we build, make sure its still testable in parts
    too

Other bits:

* See the todos in the script files, use red-green-refactor to fix them!
* Add a whole bunch of test cases
* Allow optional institution in .ledgerimport file if we want to keep regex
  scoped globally (maybe wait till we have a need for this)
