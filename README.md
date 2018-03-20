# README

## Current Usage

Everything is in src dir in anticipation of building one final script for the whole
thing. Here's the scripts in the order to run them:

* reader\_\*: first stage of converting to our intermediate format.
* At this stage you may need to sort with `sort -gr` to do a reverse numberic
  sort on the intermediate format. This gets transactions in a most-recent last
  order as ledger needs.
* ledgerimport: convert intermediate format to ledger format. You need to
  provide a filename or STDIN, though I've not worked out how to paste into
  STDIN correctly.
* postings.sh: Update the transaction postings from previous step with regex
  expressions in .ledgerimport.
* ledgerawk: My unfinished attempt at the final script that brings it all
  together.

## Intermediate Format

```
ORDER[TAB]DATE[TAB]DESCRIPTION[AMOUNT]
```

e.g.

```
0001  2020/06/20  Disneyland  -$400
```

The order field is the last line number of each transaction from the input file.
This allows us to reverse the order of transactions if needed for ledger.

## Desired Usage

Copy transactions from browser into clipboard. Then at the terminal:

```
ledgerimport [INSTITUTION]
```

It will read from the clipboard and parse the data for the given institution.
The results will be put back on the clipboard for pasting into your ledger files.

### Auto-populate Postings

You can teach ledgerimport to automatically fill in postings. It will look for a
file `.ledgerimport` in the present directory. Format is:

```
REGEX   POSTING1                  POSTING2
Tesco   Assets:HSBC:Current:Food  Expenses:Food
```

### To Do

* Put newlines between transactions
* Allow comments in .ledgerimport
* See the todos in the script files
* Make clipboard work
* Make it work as above! Just one command
* Add a whole bunch of test cases
* Allow optional institution in .ledgerimport file if we want to keep regex
  scoped that way (maybe wait till we have a need for this)
