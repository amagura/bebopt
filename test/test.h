/*SKIP(#!/usr/bin/env bash)*/
/*SKIP(#file: tests/test.sh)*/

#define both(...) \
  ((r=0));\
  coffee -- example.coffee __VA_ARGS__;\
  ((r=$?));\
  node -- example.js __VA_ARGS__;\
  ((++r))

test_Invalids () {
  both("--help-x");
  assertEquals "bad long options cause fail?" 2 "$r"
  both("-z");
  assertEquals "bad short options cause fail?" 2 "$r"
}

. /usr/bin/shunit2
