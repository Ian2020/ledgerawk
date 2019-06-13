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

You can teach ledgerimport to automatically fill in postings. It will look for a
file `.ledgerimport` in the current dir and then in your home directory. Format is:

```
# Comment line
# Line format: REGEX¬POSTING1¬POSTING2
# Example:
Tesco¬Assets:HSBC:Current:Food¬Expenses:Food
```

## Implementation Details

These details mostly for developers use and debugging rather than end-users.

### Intermediate Format

```
ORDER[TAB]DATE[TAB]DESCRIPTION[AMOUNT]
```

e.g.

```
0001  2020/06/20  Disneyland  -$400
```

The order field is the last line number of each transaction from the input file.
This allows us to reverse the order of transactions if needed for ledger.

## Development

Don't forget to run the tests: `make test`. They require [bats](https://github.com/sstephenson/bats).

### Desired Usage

Copy transactions from browser into clipboard. Then at the terminal:

```
ledgerimport [INSTITUTION]
```

It will read from the clipboard and parse the data for the given institution.
The results will be put back on the clipboard for pasting into your ledger files.

### To Do

* reader_santander is leaving spaces on the end of some lines
* See the todos in the script files, use red-green-refactor to fix them!
* Make clipboard work
* Make it work as above! Just one command
* Add a whole bunch of test cases
* Allow optional institution in .ledgerimport file if we want to keep regex
  scoped that way (maybe wait till we have a need for this)
