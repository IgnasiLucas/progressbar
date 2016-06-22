#!/bin/bash

CLUST=$1
SAMPLE=$2

if [ ! -e .$CLUST.$SAMPLE.bar ]; then
   echo    "Sample: $SAMPLE"                                       > .$CLUST.$SAMPLE.bar
   echo                                                           >> .$CLUST.$SAMPLE.bar
   echo    "0%       20%       40%       60%       80%      100%" >> .$CLUST.$SAMPLE.bar
   echo    "|----+----|----+----|----+----|----+----|----+----| " >> .$CLUST.$SAMPLE.bar
   echo -n "|"                                                    >> .$CLUST.$SAMPLE.bar
   PRINTED=0
else
   PRINTED=$(( $(( $(tail -n 1 .$CLUST.$SAMPLE.bar | wc -c) - 1 )) * 2 ))
fi
SEQNUM=`grep -e "^>" edits/$SAMPLE.derep | wc -l`
SEQDONE=`gawk '(FILENAME~/\.u$/){F[$1]=1;F[$2]=1}((FILENAME~/\._temp$/) && (/^>/)){F[substr($1,2)]=1}END{for (f in F) N++; print N}' $CLUST/$SAMPLE.u $CLUST/$SAMPLE._temp`
PERCENTDONE=$(( $SEQDONE * 100 / $SEQNUM ))
while [ $PRINTED -lt $PERCENTDONE ]; do
   echo -n "|" >> .$CLUST.$SAMPLE.bar
   PRINTED=$(( $PRINTED + 2 ))
done
while [ $PERCENTDONE -lt 100 ]; do
   sleep 1h
   SEQDONE=`gawk '(FILENAME~/\.u$/){F[$1]=1;F[$2]=1}((FILENAME~/\._temp$/) && (/^>/)){F[substr($1,2)]=1}END{for (f in F) N++; print N}' $CLUST/$SAMPLE.u $CLUST/$SAMPLE._temp`
   PERCENTDONE=$(( $SEQDONE * 100 / $SEQNUM ))
   while [ $PRINTED -lt $PERCENTDONE ]; do
      echo -n "|" >> .$CLUST.$SAMPLE.bar
      PRINTED=$(( $PRINTED + 2 ))
   done
done
echo >> .$CLUST.$SAMPLE.bar
echo >> .$CLUST.$SAMPLE.bar
