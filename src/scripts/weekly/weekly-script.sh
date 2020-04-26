#!/bin/sh

WORK_PATH=/home/backup/scripts/weekly/script/*.sh

for file in $WORK_PATH
do
    /bin/sh $file
done


