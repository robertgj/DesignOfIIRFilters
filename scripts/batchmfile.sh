#!/bin/bash
#
# Run the scripts in $@. Eg:
#   /bin/bash ./batchmfile.sh `find src -name \*_test.m -printf '%p '`
# or:
#   /bin/bash ./batchmfile.sh `aelcf | grep _test | tr '\n' ' '`

main ()
{
    # Initialise
    local max_tasks=6
    
    # Run the mfiles
    for mfile in $mfilelist
    do
        while [ $(jobs 2>&1 | grep -c Running) -ge "$max_tasks" ]; do
            sleep 1 
        done
        # Run an mfile in a sub-shell and save the exit status
        {
            octave-cli -p src $mfile &
            wait $!
            status=$?
            if [ "$status" -ne 0 ]; then
                errors=$(($errors+1));
            fi
        } &
    done < "/dev/stdin"

    # Wait
    while [ $(jobs 2>&1 | grep -c Running) -gt 0 ]; do
        sleep 1 
    done

    # Done
    return $errors
}

mfilelist=$@

main
