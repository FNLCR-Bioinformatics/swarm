#!/bin/bash
# This is the swarm script we want to test

swarm=$1

[[ -z $swarm ]] && { echo "What swarm script do you want to test?" ; exit 1; }
[[ $swarm == "-h" ]] && { echo "This script runs swarm tests which are expected to fail"; exit; }
[[ ! -x $swarm ]] && { echo "$swarm is not executable" ; exit 1; }

# This is the function we will use to run the tests
source ~/.function_depot.sh
function __test_swarm {
  printYellow $1
  ec=0
# $1 = test script
  ret=$(bash $1 2>&1) || ec=1
  if [[ $ec == 1 ]] ; then
    printRed "└── $ret"
  else
     printGreen "└── OK: $ret"
  fi
}

# These are the test cases (i.e. set of options) we want to test
cat <<testcases > testcases.list
-t 4 -p 2
-g 25 -job-name FirstBP --logdir /home/giustefo/ATACseq/Mouse_73//firstbp/
--time=10-00:00:00 -b 4
testcases

# Walk through each test case
while read line ; do

# Create a new test script for each test case
  ((n++))
  cat <<eof > t$(printf %03d $n).sh
#!/bin/bash
a=2 ; while [ \$a -gt 0 ]; do echo 1 ; ((a--)); done > \$0.\$\$
$swarm -f \$0.\$\$ --devel -v 2 \\
  $line
ec=\$?
rm \$0.\$\$
exit \$ec
eof

# Run the test case
  __test_swarm t$(printf %03d $n).sh

# Throw away the test case script
  rm t$(printf %03d $n).sh
done < testcases.list

# Throw away the list
rm testcases.list

