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

debug() { if ((DEBUG)) ; then echo "DEBUG: $*" >&2; fi }

main () 
{
    local max_tasks=6
    local -A pids=()
    local -A tasks=()
    local -A exit_status=()
    
    # Copy test file names
    for testfile in $testlist ;do
      key=`basename $testfile .sh`
      tasks+=(["$key"]="$testfile")
    done

    # Run the tests
    for key in "${!tasks[@]}"; do
        while [ $(jobs 2>&1 | grep -c Running) -ge "$max_tasks" ]; do
            sleep 1 
        done
        /bin/sh ${tasks[$key]} &
        pids+=(["$key"]="$!")
        debug "Running $key as PID ${pids[$key]}"
     done

    # Wait for each test to finish and record the exit status
    errors=0
    for key in "${!tasks[@]}"; do
        pid=${pids[$key]}
        exit_status[$key]=127
        if [ -z "$pid" ]; then
            echo "No Job ID known for the $key process" # should never happen
            exit_status[$key]=1
        else
            debug echo "Waiting for ${tasks[$key]} PID $pid"
            wait $pid
            exit_status[$key]=$?
        fi
        if [ "${exit_status[$key]}" -ne 0 ]; then
            errors=$(($errors + 1))
            debug "$key (${tasks[$key]} PID $pid ${exit_status[$key]}) failed"
        fi
    done

    # Echo results to the output file in aegis format
    echo "test_result = [ " > $outfile
    for key in "${!tasks[@]}"; do
        echo "{" >> $outfile
        echo "file_name = \""${tasks[$key]}\"";" >> $outfile
        echo "exit_status = "${exit_status[$key]}";" >> $outfile
        echo "}," >> $outfile
    done
    echo "];" >> $outfile
    return $errors
}

testlist=$1
debug "Test files: " $testlist
outfile=$2
debug "Output file: " $outfile

main
