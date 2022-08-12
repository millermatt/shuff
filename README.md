# shuff

Functional programming utils for bash scripts

Yes, it's ridiculous.

See [test/lib/shuff.test.sh](test/lib/shuff.test.sh) for more examples.

## Install

Download [build/lib/shuff.sh](build/lib/shuff.sh) and source it in your script.

## API

### `concat`

```shell
# use: concat <string0> <string1> <string2> <...>
```

### `concat_arrays`

dependency: https://stedolan.github.io/jq/

```shell
# use: concat_arrays <array 1 as json string> <array 2 as json string>
```

### `filter`

```shell
# use: cat <file with line separated data> | filter <command to receive line data>
# ex:  printf "foo\nbar\n" | filter not_foo
#      function not_foo {
#          if [[ $1 != 'foo' ]]; then
#              echo $1
#          fi
#      }
#  result:
#         bar
```

### `map`

```shell
# use: cat <file with line separated data> | map <command to receive line data>
# ex:  printf "foo\nbar\n" | map echo mapped
#  result:
#         mapped foo
#         mapped bar
```

### `map_parallel`

```shell
# use: cat <file with line separated data> | map <command to receive line data>
# ex:  printf "foo\nbar\n" | map echo mapped
#  result:
#         mapped foo
#         mapped bar
#  or maybe:
#         mapped bar
#         mapped foo
```

### `partial`

```shell
# use: partial <original function name> <new function name> <params>
```

### `partial_right`

```shell
# use: partial_right <original function name> <new function name> <params>
```

### `reduce`

```shell
# use: cat <file with line separated data> | reduce <initial accumulator value> <command to receive line data>
# ex:  printf "foo\nbar\n" | filter oof append
#      function append {
#          local line=$1
#          local accumulator=$2
#          if [[ -z $accumulator ]]; then
#              local comma=""
#          else
#              local comma=","
#          fi
#          echo "${accumulator}${comma}${line}"
#      }
#  result:
#         oof,foo,bar
```

### `thunk`

```shell
# like `partial` but never passes in additional arguments on subsequent calls
# https://functionalprogramming.slack.com/archives/C0432GV99/p1559173581072200
# use: thunk <original function name> <new function name> <params>
```
