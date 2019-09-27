^#^ Frames

Prior to Stata 16, one infamous unique aspect of Stata was support for only one data set at a time. If you wanted to work with multiple data-sets, you either needed to [`merge`](https://www.stata.com/manuals/dmerge.pdf) or [`append`](https://www.stata.com/manuals/dappend.pdf) the data sets together if there was a natural connection between them, or be frequently opening and closing data or using [`preserve` and `restore`](https://www.stata.com/manuals/ppreserve.pdf) to jump between them.

Frames are Stata's approach to handling multiple data sets. You can now have multiple frames, each with their own data, which you can move between with ease, and even transfer variables between.

^#^^#^ When might you use frames?

- Interruptions - You're working on a project, and someone asks you to do something on another data set. You can open the other data set in a new frame, do whatever is needed, then swap back to your current project without any loss.
- Destructive data manipulations - If you need to do something destructive, you can copy your current data to a new frame and do the destructive operations there.
- Linked data sets - When you have data that is linked, rather than merging, you can link the two frames together. (Either at the same level - e.g. pre & post survey for individuals; or at different levels - e.g. a person data set and a city data set.)
- Collate model results - When using [`svmat`](https://www.stata.com/manuals/pmatrixmkmat.pdf) after running a model to place the model results in the data, place those results in a new frame instead.

^#^^#^ The basics

The primary command for dealing with frames is, unsurprisingly, `frame` (or `frames`, either works). By itself, it will remind you of the current frame:

~~~~
<<dd_do>>
frame
<</dd_do>>
~~~~

This tells us the name of the frame, the name of a new frame when starting Stata is "default". There is nothing special about this name, we can easily rename the frame.


~~~~
<<dd_do>>
frame rename default maindata
frame
<</dd_do>>
~~~~

We can create a second data frame as well.

~~~~
<<dd_do>>
frame create seconddata
frame
<</dd_do>>
~~~~

Notice that we're still in the "maindata" frame. We can jump between frames via `frame change`.

~~~~
<<dd_do>>
frame change seconddata
frame
frame change otherdata
<</dd_do>>
~~~~

Notice that the last command failed; we must create a frame before we can switch to it.

We can keep track of all our frames via `frame dir`.

~~~~
<<dd_do>>
frame dir
<</dd_do>>
~~~~

The `0 x 0` is telling us that in neither frame has any data loaded. Let's load some data to make this more interesting.

~~~~
<<dd_do>>
sysuse auto
frame change maindata
sysuse bplong
frame dir
<</dd_do>>
~~~~

Now we can see what size the data is in each frame. The description next to each frame is set via [`label data`](https://www.stata.com/manuals/dlabel.pdf), a previously not very useful trait that takes on new important in keeping track of which data is loaded in which frame.

~~~~
<<dd_do>>
label data "blood-pressure data"
frame dir
<</dd_do>>
~~~~

We see that the output of `frame dir` is changed. Note that most data sets which are not provided by Stata will likely not have a data label, so you can add one as desired.

Note also that `frame dir` will track which frames have data that needs to be saved.

^#^^#^ Aliases

There are two aliases to keep track of.

1. `pwf` (print working frame) is an alias for `frame`.
2. `cwf` (change working frame) is an alias for `frame change`.

These aliases mimic [`pwd` and `cd`](https://www.stata.com/manuals/dcd.pdf), Stata's way of viewing and changing the current working directory.

^#^^#^ Remember to drop frames!

When you have data loaded into a frame, it is (like all data in Stata) loaded into your memory. That means if you open multiple very large data sets in frames, you can quickly run out of memory when you never had before.

Frames can be dropped via `frame drop` as you might guess.

~~~~
<<dd_do>>
frame dir
frame drop seconddata
frame dir
<</dd_do>>
~~~~

While not a new command to Stata 16, the [`compress`](https://www.stata.com/manuals/dcompress.pdf) command can be very handy as it will attempt to shrink the size of the data as much as possible. This process is non-destructive, so there is no harm in running it.

You cannot drop the frame you are currently in.

~~~~
<<dd_do>>
frame drop mainframe
<</dd_do>>
~~~~

To drop all frames and their data, and reset Stata to a single "default" frame,

~~~~
<<dd_do>>
frame reset
frame dir
<</dd_do>>
~~~~

Note that `clear frames` is an alias for `frame reset` and functions as well.

^#^^#^ Copying into frames

The contents of the current frame can be transfered into a new (or overwrite an existing frame). This may be useful for performing destructive operations such as `collapse`.

~~~~
<<dd_do>>
sysuse auto
frame copy default newframe
frame copy default newframe
frame copy default newframe, replace
<</dd_do>>
~~~~

As you can see, the `replace` is needed if the new frame already exists, regardless of whether that frame has data or not.

We can also selectively move data over.

~~~~
<<dd_do>>
frame put mpg headroom, into(newframe2)
frame dir
<</dd_do>>
~~~~

Note that unlike `frame copy`, there is no `replace` option, meaning `frame put` *must* operate on an un-existing frame.

^#^^#^ Executing commands in a different frame

Switching between frames can become tedious if you do it often.

~~~~
<<dd_do>>
frame change newframe2
summarize
frame change default
<</dd_do>>
~~~~

Instead, you can use the `frame:` prefix to execute a command in another frame without switching frames.

~~~~
<<dd_do>>
frame newframe2: summarize
<</dd_do>>
~~~~

You can use curly braces to execute a chunk of code as well.

~~~~
<<dd_do>>
frame newframe2 {
  summarize
  describe, simple
}
<</dd_do>>
~~~~

^#^^#^ Linking data sets

In addition to allowing multiple data sets to be open at a time, we can **link** frames together such that rows of data in each frames are connected
to each-other and can inter-operate. This requires a linking variable in each data set which will connect the rows. The two data sets can be at the same levels or at different levels.

For example, we might have data sets collected from multiple waves of surveys and follow-ups during which the same people (modulo some non-responses)
are contained in each data set. Then the person ID variable in the data sets would be the linking variable.

Another example might be one file at the person level, and another file at the city level. The linking variable would be city name, which would be
unique in the city file, but could potentially be repeated in the person level file.

The command to link files is `frlink` and requires specifying both the linking variable(s) and the frame to link to.

```
frlink 1:1 linkvar, frame(otherframe)
```

Let's load some data from NHANES. Each file contains a row per subject.

~~~~
<<dd_do>>
frame reset
frame rename default demographics
frame create diet
frame create bp

import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DEMO_I.XPT", clear
frame diet: import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/DR1TOT_I.XPT", clear
frame bp: import sasxport5 "https://wwwn.cdc.gov/Nchs/Nhanes/2015-2016/BPX_I.XPT", clear
frame dir
<</dd_do>>
~~~~

So as you can see, the current frame is the "demographics" frame, and the other frames contains diet and blood pressure information. The variable `seqn` records person ID.

~~~~
<<dd_do>>
frlink 1:1 seqn, frame(bp)
frlink 1:1 seqn, frame(diet)
<</dd_do>>
~~~~

The `1:1` subcommand specifies that it is a 1-to-1 link - each person has no more than 1 row of data in each file. An alternative is `m:1` which allows multiple rows in the main file to be linked to a single row in the second frame. `1:m` is *not allowed* at this point in time.

These commands created two new variables `bp` and `diet` (the same new as the linked frames) which indicate which row of the linked from is connected with the given row.

~~~~
<<dd_do>>
list bp diet in 25/29
<</dd_do>>
~~~~

Here we see that row 27 in the demographics file was not found in either "bp" or "diet" and thus has no entry in the `bp` or `diet` variables.

Links are tracked by the variables, we can see the current status of a link via `frlink describe`:

~~~~
<<dd_do>>
frlink describe diet
<</dd_do>>
~~~~

We can see all links from the current frame via `frlink dir`:

~~~~
<<dd_do>>
frlink dir
<</dd_do>>
~~~~

To unlink frames, simply drop the variable.

~~~~
<<dd_do>>
drop diet
<</dd_do>>
~~~~

Finally, the names of the created variables can be modified via the `generate` option to `frlink`:

~~~~
<<dd_do>>
frlink 1:1 seqn, frame(diet) generate(linkdiet)
frlink dir
<</dd_do>>
~~~~

^#^^#^^#^ Working with linked frames

Once we have linked frames, we can use variables in the linked frame in analyses on the main frame.

The `frget` command can copy variables from the linked frame into the primary frame.

~~~~
<<dd_do>>
summarize bpxchr
frget bpxchr, from(bp)
summarize bpxchr
<</dd_do>>
~~~~

This merges appropriately, with a `1:1` or `m:1` link, to properly associate the values of the variable with the right observations.

Alternatively, when using `generate`, we can reference a variable in another frame.

~~~~
<<dd_do>>
gen nonsense = frval(linkdiet, dr1tcalc)/frval(bp, bpxpls) + dmdhrage
<</dd_do>>
~~~~

Note that this calculation used variables from all three frames. A less nonsensical example might be where we want the percent of a countries population located in a given state. Imagine we have the primary frame of county data, and then a separate frame "state" containing state level information.

```
gen percentpopulation = population/frval(state, population)
```
