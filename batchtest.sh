#!/bin/bash
#
# Run the scripts in $1 and save the exit status in file $2 in aegis format.
# (See http://aegis.sourceforge.net). This script is intended to be used by
# the aegis aepconf batch_test_command to run max_tasks test scripts
# concurrently. For example, in aepconf format:
#   batch_test_command = 
#           "${shell} ./batchtest.sh ${quote $File_Names} ${Output}";
#
# If aegis is not installed then run the test scripts with:
#   /bin/bash ./batchtest.sh "`find test -name t0???a.sh -printf '%p '`" outfile

main ()
{
    # Initialise
    local max_tasks=6
    local errors=0
    echo "test_result = [ " > $outfile
    
    # Run the tests
    for testfile in $testlist ;do
        while [ $(jobs 2>&1 | grep -c Running) -ge "$max_tasks" ]; do
            sleep 1 
        done
        # Run a test in a sub-shell and write the exit status
        {
            /bin/sh $testfile &
            wait $!
            status=$?
            if [ "$status" -ne 0 ]; then
                errors=$(($errors+1));
            fi
            flock -x $outfile -c "echo -e '{\n  file_name = \"'$testfile'\" ;\n\
  exit_status = '$status' ;\n},' >> $outfile"
        } &
    done

    # Wait
    while [ $(jobs 2>&1 | grep -c Running) -gt 0 ]; do
        sleep 1 
    done

    # Done
    echo "];" >> $outfile
    return $errors
}

testlist=$1
outfile=$2

main
