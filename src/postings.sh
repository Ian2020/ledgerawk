#!/bin/awk -f
BEGIN {
  # TODO: Can we use a better separator? Just picked something unlikely to appear in regex
  SAVED_FS=FS
  FS="¬"
  # Look for a local settings file otherwise try home
  if(system("test -f .ledgerimport" ) == 0) {
    SETTINGS_FILE=".ledgerimport"
  } else {
    SETTINGS_FILE=ENVIRON["HOME"] "/.ledgerimport"
}
  while(getline < SETTINGS_FILE) {
    # Allow comments
    if(!match($0,"^#")) {
      substitutions[a]=$1
      firstposting[a]=$2
      secondposting[a]=$3
      a++
    }
  }
  FS=SAVED_FS
}
/^[[:digit:]]{4}/ {
  print
  # Transaction description - match against substitutions, remember which index matched if so
  for(i in substitutions) {
    # TODO: We'd rather match against field 3 and onwards here, so we do not include
    # the date and transaction status symbol. Is there a way to say $3: to mean
    # concat field 3 and all following fields?
    # Check the substitution is not intended to match a tag, i.e. ':TAG:'
    if((!match(substitutions[i], "^:.*:$")) && match($0,substitutions[i])) {
      matched=i
      # Remember that we're now looking for @@@ the first
      find_first_posting = 1
      # TODO: break
    } 
  }
}
/^ *;/ {
  print
  # Comment - match against substitutions, remember which index matched if so
  # Check the substitution is intended to match a tag, i.e. ':TAG:'
  for(i in substitutions) {
    if(match(substitutions[i], "^:.*:$") && match($0,substitutions[i])) {
      matched=i
      # Remember that we're now looking for @@@ the first
      find_first_posting = 1
      # TODO: break
    } 
  }
}
/^    @@@/ {
  # if we're looking for the first, now look for second
  if(find_first_posting) {
    find_first_posting=0
    find_second_posting=1
    print "    " firstposting[matched] "    " $2
  } else if (find_second_posting) {
    find_second_posting=0
    print "    " secondposting[matched]
  } else {
    # We're not looking so passthrough input
    print
  }
}
# This is nasty - as "AWK Patterns" are cumulative we must here match any lines not matched by patterns above to avoid repetition
$0 !~ /(^[[:digit:]]{4}|^    @@@|^ *;)/ {
  print
}
