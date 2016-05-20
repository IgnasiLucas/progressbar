# progressbar

A progress bar for pyrad's step 3.

Deren Eaton's pyrad (http://dereneaton.com/software/pyrad/) may run for quite long,
with large datasets. Step 3 is one of those that can take several days. I found it
useful to be able to estimate when it would finish. Maybe somebody else finds it
useful as well.

If pyrad's step 3 is already running, just call progressbar.sh from the working
directory where pyrad created the edits/ and clust.XX/ folders. In a few seconds,
it will print a progress bar like this, for each sample:

> Sample: sample_name
> 
> 0%       20%       40%       60%       80%      100%
> |----+----|----+----|----+----|----+----|----+----|
> |||||||||

