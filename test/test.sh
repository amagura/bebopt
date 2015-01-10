//SKIP()\# file: f
test_Invalids () {
  both "--help-x"
  assertEquals "bad long options cause fail?" 2 "$r"
  both "-z"
  assertEquals "bad short options cause fail?" 2 "$r"
}
