#!/usr/bin/env bash
set -e
echo 'node:'
node -- example.js $@
echo 'coffee:'
coffee -- example.coffee $@
