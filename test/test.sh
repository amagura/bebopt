#!/usr/bin/env shunit2
# file: tests/test.sh

both () {
  coffee -- ../example.coffee "$@"
  ((r=$?))
  node -- ../example.js "$@"
  ((++r))
  return $r
}

test_Invalids () {
  both "--help-x"
  c=$?
  assertEquals "bad long options cause fail?" 2 "$c"
  both "-z"
  c=$?
  assertEquals "bad short options cause fail?" 2 "$c"
}
