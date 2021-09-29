#!/bin/sh

scriptName=${0##*/}
ask=1
if [ $# = 0 ] ; then
    echo "Wrapper script for the dangerous 'rm -rf'"
    echo "Usage : $scriptName [folder to delete]"
    exit 0
fi

echo "$scriptName : Delete following files/folders?"
printf "$(tput setaf 6)    %s\n" "$@"
tput sgr 0

for p in "$@" ; do
    if [ "${p:0}" = '/' ] ; then
        echo "$scriptName : Too Dangerous!!! (trying to delete a root level folder)"
        echo "$scriptName : aborted..."
        exit 1
    elif [ "$p" = '..' -o "$p" = '.' ] ; then
        echo "$scriptName : Too Dangerous!!! (trying to delete \"$p\")"
        echo "$scriptName : aborted..."
        exit 1
    fi
    if [ -d "$p" ] ; then
        type='(folder)'
    elif [ -f "$p" ] ; then
        type='(file)'
    else
        type='(other)'
    fi
    if [ $ask = 1 ] ; then
        printf "$scriptName : Delete $p $type [y, n (default), c=cancel, all]? "
        #printf "$(tput setaf 6)    %s\n" "$@"
        #tput sgr 0
        ok=no
        read ok
    fi
    if [ "$ok" = 'all' ] ; then    
        ask=0
        ok='y'
    fi
    if [ "${ok:0}" = 'y' ] ; then
        if [ -f "$p" ] ; then
             rm -f "$p"
            echo "$scriptName : \"$p\" (file) deleted..."
        elif [ -d "$p" ] ; then
             rm -rf "$p"
            echo "$scriptName : \"$p\" (folder) deleted..."
        else
            echo "$scriptName : \"$p\" not found..." 
        fi
    elif [ "${ok:0}" = 'c' ] ; then
        echo "$scriptName : cancelled..."
        exit 1
    fi
done
