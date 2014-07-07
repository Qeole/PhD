#!/bin/bash

sed 's/[^0-9]*[0-9]\{0,2\}\s\([0-9]*\)|/ \1/g' out-n30-t31-e1-r1.txt > val-n30-t31-e1-r1.txt

for ((i=1;i<=32;i++)) ; do L=$(grepline $i val-n30-t31-e1-r1.txt) ; read -a <<<$L TEST ; SUM=$((0)) ; for ((j=3;j<=32;j++)) ; do SUM=$((SUM+${TEST[j]})) ; done ; python -c "print '%s' % ($SUM/30.)" ; done > mean-n30-t31-e1-r1.txt


#for ((i=1;i<=32;i++)) ; do L=$(grepline $i val-n30-t31-e1-r1.txt) ; MEAN=$(grepline $i mean-n30-t31-e1-r1.txt) ; read -a <<<$L TEST ; for ((j=3;j<=32;j++)) ; do VAR=$(python -c "print '%s' % ((${TEST[j]} - $MEAN)**2)") ; printf "%s " $VAR ; done ; printf '\n' ; done > var-n30-t31-e1-r1.txt

#for ((i=1;i<=32;i++)) ; do L=$(grepline $i val-n30-t31-e1-r1.txt) ; MEAN=$(grepline $i mean-n30-t31-e1-r1.txt) ; read -a <<<$L TEST ; for ((j=3;j<=32;j++)) ; do VAR=$(python -c "import math; print '%s' % math.sqrt((${TEST[j]} - $MEAN)**2)") ; printf "%s " $VAR ; done ; printf '\n' ; done > et-n30-t31-e1-r1.txt

for ((i=1;i<=32;i++)) ; do L=$(grepline $i val-n30-t31-e1-r1.txt) ; MEAN=$(grepline $i mean-n30-t31-e1-r1.txt) ; BUF=$((0)) ; read -a <<<$L TEST ; for ((j=3;j<=32;j++)) ; do BUF=$(python -c "print '%s' % ($BUF + (${TEST[j]} - $MEAN)**2)") ; VAR=$(python -c "import math; print '%s' % math.sqrt($BUF/30.)") ; done ; echo $VAR ; done > et-n30-t31-e1-r1.txt
