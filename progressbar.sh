#!/bin/bash
#
# Copyright José Ignacio Lucas Lledó, 2016.
#
# Prints a progress bar to Deren Eaton's pyrad's step 3.
# This step uses vsearch to cluster sequenced reads within
# samples. It usually takes a long time, and I found it useful
# to estimate how long it will take.
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

NumSamples=`ls -1 edits/*.derep | wc -l`

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
   DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
   SOURCE="$(readlink "$SOURCE")"
   [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ $NumSamples -gt 1 ]; then
   for SAMPLE in `ls -1 edits/*.derep | xargs basename -s .derep`; do
      $DIR/SampleBar.sh $CLUST $SAMPLE &
      echo -e "To visualize progress bar of sample $SAMPLE, type 'tail -f .$CLUST.$SAMPLE.bar'"
   done
else
   if [ $NumSamples -eq 1 ]; then
      SAMPLE=`basename -s .derep edits/*.derep`
      $DIR/SampleBar.sh $CLUST $SAMPLE &
      tail -f .$CLUST.$SAMPLE.bar
   fi
fi
wait
echo "Step 3 finished."
rm .$CLUST.*.bar
