
/home/alexej/code/octo/bebopt/test/test.m4

/home/alexej/code/octo/bebopt/test/test.m4
#file: tests/test.sh
test_Invalids () {
  ((r=0)) ; coffee -- example.coffe "--help-x" ; ((r=$?)) ; node -- example.js "--help-x" ; ((++r));
  assertEquals "bad long options cause fail?" 2 "$r"
  ((r=0)) ; coffee -- example.coffe "-z" ; ((r=$?)) ; node -- example.js "-z" ; ((++r));
  assertEquals "bad short options cause fail?" 2 "$r"
}
