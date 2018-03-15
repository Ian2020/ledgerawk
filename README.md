# README

## Usage

Everything is in src dir in anticipation of building one final script for the whole
thing.

* ledgerimport: convert copied transactions to ledger format. You need to
  provide a filename or STDIN, though I've not worked out how to paste into
  STDIN correctly.
* postings.sh: Update the transaction postings from previous step with regex
  expressions in .ledgerimport.
* ledgerawk: My unfinished attempt at the final script.

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

* The order is backwards!
  * I think we need an interim step where we convert whatever to a format:
    `dateSEPdescriptionSEPamount`
    ...so we can sort properly.
* We still got spaces on the end of amounts
* Allow comments in .ledgerimport
* See the todos in the script files
* Make clipboard work
* Make it work as above! Just one command instead of ledgerimport and
  postings.sh
* Add a whole bunch of test cases
* Allow optional institution in .ledgerimport file if we want to keep regex
  scoped that way (maybe wait till we have a need for this)
