. $(dirname $0)/../test.sh
. $(dirname $0)/../../src/lib/shuff.sh

set -e

function test_map {
    local input="foo
bar"
    local result=$(echo "$input" | map echo mapped)
    assert_equal "$result" "mapped foo
mapped bar"
}
run_test test_map

# commenting out due to map_parallel not working
# function test_map_parallel {
#     local result=$(printf "foo\nbar\n" | map_parallel echo mapped)
#     local sorted_result=$(echo "$result" | sort)
#     assert_equal "$sorted_result" "mapped bar
# mapped foo"
# }
# run_test test_map_parallel

function not_foo {
    if [[ $1 != 'foo' ]]; then
        echo $1
    fi
}

function test_filter {
    local result=$(echo "foo
bar" | filter not_foo)
    assert_equal "$result" "bar"
}
run_test test_filter

# starting point function for functional morphing
# this is used by other functions
function greet {
    local salutation=$1
    local title=$2
    local firstName=$3
    local lastName=$4
    echo "$salutation, $title $firstName $lastName!"
}

function test_partial {
    partial greet say_hello Hello
    partial say_hello say_hello_to_ms "Ms."
    partial say_hello_to_ms say_hello_to_ms_jane_jones Jane Jones
    local greeting=$(say_hello_to_ms_jane_jones)
    assert_equal "$greeting" "Hello, Ms. Jane Jones!"
    unset say_hello_to_ms_jane_jones
    unset say_hello_to_ms
    unset say_hello
}
run_test test_partial

function test_partial_right {
    partial_right greet greet_ms_jane_jones "Ms." Jane Jones
    local greeting=$(greet_ms_jane_jones Hello)
    assert_equal "$greeting" "Hello, Ms. Jane Jones!"
    unset greet_ms_jane_jones
}
run_test test_partial_right

function test_thunk {
    thunk greet greet_ms_jane_jones "Ms." Jane Jones
    local greeting=$(greet_ms_jane_jones Hello)
    greeting=$(greet )
    assert_equal "$greeting" "Hello, Ms. Jane Jones!"
    unset greet_ms_jane_jones
}
run_test test_partial_right

function append {
    local line=$1
    local accumulator=$2
    if [[ -z $accumulator ]]; then
        local comma=""
    else
        local comma=","
    fi
    echo "${accumulator}${comma}${line}"
}

function append_sum {
    local line=$1
    local accumulator=
    if [ -z $2 ]; then
        accumulator=0
    else
        accumulator=$2
    fi
    echo `expr $line + $accumulator`
    # echo "$(( $line + $accumulator ))"
}

function test_reduce {
    local result=$(printf "foo\nbar" | reduce "oof" append)
    assert_equal "$result" "oof,foo,bar"
    local result_sum=$(printf "1\n2\n3\n4\n5" | reduce 5 append_sum)
    assert_equal "$result_sum" "20"
}
run_test test_reduce

function test_concat_arrays {
    local result=$(concat_arrays '["one","two"]' '["a","b"]')
    assert_equal "$result" '["one","two","a","b"]'
    local pojo_result=$(concat_arrays '[{"foo":"bar1"},{"foo":"bar2"}]' '[{"foo":"bar3"},{"foo":"bar4"}]')
    assert_equal "$pojo_result" '[{"foo":"bar1"},{"foo":"bar2"},{"foo":"bar3"},{"foo":"bar4"}]'
}
run_test test_concat_arrays