#!/bin/bash
#
# Copyright José Ignacio Lucas Lledó, 2016.
#
# Prints a progress bar to Deren Eaton's pyrad's step 3.
# This step uses vsearch to cluster sequenced reads within
# samples. It usually takes a long time, and I found it useful
# to estimate how long it would take.
#

if [ ! -d edits ]; then
   echo "edits folder not found."
   exit
fi

NumClustDir=`ls -1 | grep -P "^clust\.\d\d$" | wc -l`

if [ $NumClustDir -eq 0 ]; then
   echo "clust.XX folder not found."
   exit
else
   if [ $NumClustDir -gt 1 ]; then
      echo "What clust.XX folder should I use?"
      read CLUST
   else
      CLUST=`ls -1 | grep -P "^clust\.\d\d$"`
   fi
fi

for SAMPLE in `ls -1 edits/*.derep | xargs basename -s .derep`; do
   echo    "Sample: $SAMPLE"
   echo
   echo    "0%       20%       40%       60%       80%      100%"
   echo    "|----+----|----+----|----+----|----+----|----+----|"
   echo -n "|"
   SEQNUM=`grep -e "^>" edits/$SAMPLE.derep | wc -l`
   SEQDONE=`gawk '(FILENAME~/\.u$/){F[$1]=1;F[$2]=1}((FILENAME~/\._temp$/) && (/^>/)){F[substr($1,2)]=1}END{for (f in F) N++; print N}' $CLUST/$SAMPLE.u $CLUST/$SAMPLE._temp`
   PERCENTDONE=$(( $SEQDONE * 100 / $SEQNUM ))
   PRINTED=0
   while [ $PRINTED -lt $PERCENTDONE ]; do
      echo -n "|"
      PRINTED=$(( $PRINTED + 2 ))
   done
   while [ $PERCENTDONE -lt 100 ]; do
      sleep 1h
      SEQDONE=`gawk '(FILENAME~/\.u$/){F[$1]=1;F[$2]=1}((FILENAME~/\._temp$/) && (/^>/)){F[substr($1,2)]=1}END{for (f in F) N++; print N}' $CLUST/$SAMPLE.u $CLUST/$SAMPLE._temp`
      PERCENTDONE=$(( $SEQDONE * 100 / $SEQNUM ))
      while [ $PRINTED -lt $PERCENTDONE ]; do
         echo -n "|"
         PRINTED=$(( $PRINTED + 2 ))
      done
   done
   echo
   echo
done
