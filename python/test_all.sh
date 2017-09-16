#!/usr/bin/env bash

vim=$1

if [ -z "$vim" ] ; then
    vim=vim
fi

python -m unittest test_rbql
python3 -m unittest test_rbql
node ./unit_tests.js


#Some CLI tests:
md5sum_test=($( ./rbql.py --query "select a1,a2,a7,b2,b3,b4 left join test_datasets/countries.tsv on a2 == b1 where 'Sci-Fi' in a7.split('|') and b2!='US' and int(a4) > 2010" < test_datasets/movies.tsv | md5sum))
md5sum_canonic=($( md5sum unit_tests/canonic_result_4.tsv ))
if [ "$md5sum_canonic" != "$md5sum_test" ] ; then
    echo "CLI test FAIL!"  1>&2
fi

md5sum_test=($( ./rbql.py --query "select a1,a2,a7,b2,b3,b4 left join test_datasets/countries.tsv on a2 == b1 where a7.split('|').includes('Sci-Fi') && b2!='US' && a4 > 2010" --meta_language js < test_datasets/movies.tsv | md5sum))
md5sum_canonic=($( md5sum unit_tests/canonic_result_4.tsv ))
if [ "$md5sum_canonic" != "$md5sum_test" ] ; then
    echo "CLI test FAIL!"  1>&2
fi

#vim integration tests:
rm movies.tsv.py.rs 2> /dev/null
rm movies.tsv.js.rs 2> /dev/null
rm movies.tsv.system_py.py.rs 2> /dev/null
rm movies.tsv.system_py.js.rs 2> /dev/null
rm movies.tsv.f5_ui.py.rs 2> /dev/null

rm vim_unit_tests.log 2> /dev/null
rm vim_debug.log 2> /dev/null

$vim -s unit_tests.vim -V0vim_debug.log
errors=$( cat vim_debug.log | grep '^E[0-9][0-9]*' | wc -l )
total=$( cat vim_unit_tests.log | wc -l )
started=$( cat vim_unit_tests.log | grep 'Starting' | wc -l )
finished=$( cat vim_unit_tests.log | grep 'Finished' | wc -l )
fails=$( cat vim_unit_tests.log | grep 'FAIL' | wc -l )
if [ $total != 5 ] || [ $started != $finished ] || [ $fails != 0 ] ; then
    echo "FAIL! Integration tests failed: see vim_unit_test.log"  1>&2
    exit 1
fi

md5sum_test_1=($( md5sum movies.tsv.py.rs ))
md5sum_test_2=($( md5sum movies.tsv.js.rs ))
md5sum_test_3=($( md5sum movies.tsv.system_py.py.rs ))
md5sum_test_4=($( md5sum movies.tsv.system_py.js.rs ))
md5sum_test_5=($( md5sum movies.tsv.f5_ui.py.rs ))

md5sum_canonic=($( md5sum unit_tests/canonic_integration_1.tsv ))
sanity_len=$( printf "$md5sum_canonic" | wc -c )

if [ "$sanity_len" != 32 ] || [ "$md5sum_test_1" != $md5sum_canonic ] || [ "$md5sum_test_2" != $md5sum_canonic ] || [ "$md5sum_test_3" != $md5sum_canonic ] || [ "$md5sum_test_4" != $md5sum_canonic ] || [ "$md5sum_test_5" != $md5sum_canonic ] ; then
    echo "FAIL! Integration tests failed: md5sums"  1>&2
    exit 1
fi

rm movies.tsv.py.rs 2> /dev/null
rm movies.tsv.js.rs 2> /dev/null
rm movies.tsv.system_py.py.rs 2> /dev/null
rm movies.tsv.system_py.js.rs 2> /dev/null
rm movies.tsv.f5_ui.py.rs 2> /dev/null

rm vim_unit_tests.log 2> /dev/null

if [ $errors != 0 ] || [ ! -e vim_debug.log ] ; then
    echo "Warning: some errors were detected during vim integration testing, see vim_debug.log"  1>&2
else
    rm vim_debug.log 2> /dev/null
fi

echo "Finished vim integration tests"
