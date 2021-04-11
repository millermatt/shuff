# use: cat <file with line separated data> | map <command to receive line data>
# ex:  printf "foo\nbar\n" | map echo mapped
#  result:
#         mapped foo
#         mapped bar
function map {
    local input=$(< /dev/stdin)
    echo "$input" | while read line ; do
        "$@" "$line"
    done
}

# use: cat <file with line separated data> | filter <command to receive line data>
# ex:  printf "foo\nbar\n" | filter not_foo
#      function not_foo {
#          if [[ $1 != 'foo' ]]; then
#              echo $1
#          fi
#      }
#  result:
#         bar
function filter {
    local input
    local test_result
    while read input; do
        test_result=$($@ $input)
        # >&2 echo $test_result
        if [[ ! -z $test_result ]]; then
            echo $input
        fi
    done
}

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
function reduce {
    local input=$(< /dev/stdin)
    local accumulator="$1"
    local reducer="$2"
    local IFS=$'
'
    for line in ${input}; do
        eval "unset IFS && accumulator=$($reducer ${line} ${accumulator})"
    done
    unset IFS
    echo $accumulator
}

# use: cat <file with line separated data> | map <command to receive line data>
# ex:  printf "foo\nbar\n" | map echo mapped
#  result:
#         mapped foo
#         mapped bar
#  or maybe:
#         mapped bar
#         mapped foo
function map_parallel {
    local input=$(< /dev/stdin)
    local pids=""
    local pid_count=0
    local max_jobs=10
    local IFS=$'
'
    for i in ${input}; do
        eval "unset IFS && $@ $i" & pids="$! ${pids}"
        pid_count=$(expr $pid_count + 1)
        # >&2 echo "pid_count $pid_count"
        if [ $pid_count -ge $max_jobs ]; then
            >&2 echo "waiting for $max_jobs procs"
            wait #${pids%?}
            pid_count=0
            pids=""
        fi
    done
    unset IFS
    wait ${pids}
}

# use: partial <original function name> <new function name> <params>
function partial {
    local params="${@:3}"
    local func="
        function $2 {
            $1 $params \$@
        }
    "
    eval "$func"
}

# use: partial_right <original function name> <new function name> <params>
function partial_right {
    local params="${@:3}"
    local func="
        function $2 {
            $1 \$@ $params
        }
    "
    eval "$func"
}

# like `partial` but never passes in additional arguments on subsequent calls
# https://functionalprogramming.slack.com/archives/C0432GV99/p1559173581072200
# use: thunk <original function name> <new function name> <params>
function thunk {
    local params="${@:3}"
    local func="
        function $2 {
            $1 $params
        }
    "
    eval "$func"
}

# use: concat <string0> <string1> <string2> <...>
function concat {
    local result=""
    local i=""
    for i in "$@"; do
        result="${result}${i}"
    done
    echo "$result"
}

# use: concat_arrays <array 1 as json string> <array 2 as json string>
function concat_arrays {
    local line="$1"
    local accumulator="$2"
    jq -c --argjson arr1 "$line" --argjson arr2 "$accumulator" -n '$arr1 + $arr2'
}


# use: curry <original function name> <new function name>
# function curry {
# TBD
# }

# BIND_PARAMS_TEMP_FILES=""
# function make_bind_params_temp {
#     local temp_file=$(mktemp)
#     BIND_PARAMS_TEMP_FILES="${BIND_PARAMS_TEMP_FILES}${temp_file}\n"
#     BIND_PARAMS_LAST_TEMP=$temp_file
# }

# function cleanup_temp_files {
#     echo $BIND_PARAMS_TEMP_FILES | xargs -n1 -I % rm % 2>/dev/null
# }
# trap cleanup_temp_files EXIT

