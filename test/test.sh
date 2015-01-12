

#!/usr/bin/env bash
#file: tests/test.sh
test_Invalids () {
  ((r=0)); coffee -- example.coffee "--help-x"; ((r=$?)); node -- example.js "--help-x"; ((++r));
  assertEquals "bad long options cause fail?" 2 "$r"
  ((r=0)); coffee -- example.coffee "-z"; ((r=$?)); node -- example.js "-z"; ((++r));
  assertEquals "bad short options cause fail?" 2 "$r"
}
. /usr/bin/shunit2
