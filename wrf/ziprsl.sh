#!/bin/bash
if [ -f rsl.out.0000 ] ; then
    rm -f rsl.files.zip
    zip -qm rsl.files.zip rsl.out.* rsl.error.*
fi
