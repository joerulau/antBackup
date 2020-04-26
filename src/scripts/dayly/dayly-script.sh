#!/bin/sh

WORK_PATH=/home/backup/scripts/dayly/script/*.sh

for file in $WORK_PATH
do
    /bin/sh $file
done



