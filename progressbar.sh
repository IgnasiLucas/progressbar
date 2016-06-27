#!/bin/bash
#
# Copyright José Ignacio Lucas Lledó, 2016.
#
# Prints a progress bar to Deren Eaton's pyrad's step 3.
# This step uses vsearch to cluster sequenced reads within
# samples. It usually takes a long time, and I found it useful
# to estimate how long it will take.
#
#
# This function was taken from https://gist.github.com/criccomini/3786342
# If stopped while SampleBar.sh was sleeping, 'sleep 1h' is a child process
# that becomes killed before the parent SampleBar.sh itself is. Thus, the
# subsequent gawk command gets executed before the function kill_child_processes
# knowing about it. By the time SampleBar.sh is killed, gawk keeps running.

function kill_child_processes() {
   isTopmost=$1
   curPid=$2
   childPids=`ps -o pid --no-headers --ppid ${curPid}`
   echo "The following are children of ${curPid}"
   ps --ppid ${curPid}
   for childPid in $childPids; do
      kill_child_processes 0 $childPid
   done
   echo "After killing children of ${curPid}, is there any left?"
   ps --ppid ${curPid}
   if [ $isTopmost -eq 0 ]; then
      kill -9 $curPid 2> /dev/null
   fi
}

trap "kill_child_processes 1 $$; exit 0" INT

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

# I call a second script to actually print the progress bar, because that
# way I can easily parallelize the task and generate as many bars as samples
# are being processed. This script needs to know where it is installed,
# in order to call the second one. In addition, I need to be able to kill
# SampleBar and its subprocess (sleep and gawk) if progressbar.sh gets
# interrupted with Ctrl-C.

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
      sleep 1
      tail -f .$CLUST.$SAMPLE.bar
   fi
fi
wait
echo "Step 3 finished."
rm .$CLUST.*.bar
