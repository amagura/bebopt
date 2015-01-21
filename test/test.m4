m4_divert(-1)
m4_changequote(``'', ```''')
m4_define(`'both``'', `'((r=0)); coffee -- $startdir/../example.coffee $@; ((r=$?)); node -- $startdir/../example.js $@; ((r+=$?))``'')
m4_divert(0)
#!/usr/bin/env bash
#file: tests/test.sh
startdir="$(realpath "$(dirname "$0")")"

test_Invalids () {
  both("--help-x");
  assertEquals "bad long options cause fail?" 2 "$r"
  both("-z");
  assertEquals "bad short options cause fail?" 2 "$r"
}

test_Options () {
  both("--help");
  assertEquals "supported long options" 0 "$r"
  both("--version");
  assertEquals "supported long options" 0 "$r"
}

. /usr/bin/shunit2
