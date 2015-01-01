###
Copyright 2015 Alexej Magura

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

class ConsecutiveNewline
  rule:
    name: 'consecutive_newlines'
    description: 'Validates a consecutive newline policy'
    acceptable: 0
    level: 'warn'
    message: 'Consecutive newlines'
    #allowed_in_comments: false

  lintLine: (line, lineApi) =>
    acceptable = lineApi.config[@rule.name].acceptable
    actual = 0

    { lineNumber, context } = lineApi # so confusing
    prev = lineApi.lines[lineNumber - 1]
    current = lineApi.lines[lineNumber]

    if /^[^\S]*$/.test(prev) and /^[^\S]*$/.test(current)
      ++actual

    if actual > acceptable
      return true
    else
      return false

module.exports = ConsecutiveNewline
