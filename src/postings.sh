#!/bin/awk -f
BEGIN {
  # TODO: Can we use a better separator? Just picked something unlikely to appear in regex
  SAVED_FS=FS
  FS="¬"
  while(getline < ".ledgerimport") {
    substitutions[a]=$1
    firstposting[a]=$2
    secondposting[a]=$3
    a++
  }
  FS=SAVED_FS
}
{
  matched=-1
  for(i in substitutions) {
    # TODO: We'd rather match against field 3 and onwards here, so we do not include
    # the date and transaction status symbol. Is there a way to say $3: to mean
    # concat field 3 and all following fields?
    if(match($0,substitutions[i])) {
      matched=i
      # TODO: break
    } 
  }
  if(matched != -1) {
    print $0
    getline
    print "    " firstposting[matched] "    " $2
    getline
    print "    " secondposting[matched]
  } else {
    print
    getline
    print
    getline
    print
  }
}
