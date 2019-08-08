^#^ Frames

Prior to Stata 16, one infamous unique aspect of Stata was support for only one data set at a time. If you wanted to work with multiple data-sets, you either needed to [`merge`](https://www.stata.com/manuals/dmerge.pdf) or [`append`g](https://www.stata.com/manuals/dappend.pdf) the data sets together if there was a natural connection between them, or be frequently opening and closing data or using [`preserve` and `restore`](https://www.stata.com/manuals/ppreserve.pdf) to jump between them.

Frames are Stata's approach to handling multiple data sets. You can now have multiple frames, each with their own data, which you can move between with ease, and even transfer variables between.

^#^^#^ When might you use frames?

- Interruptions.
- Destructive data manipulations.
- Linked data sets (at same or different levels).
- Collate model results.

^#^^#^ The basics

The primary command for dealing with frames is, unsurprisingly, `frames` (or `frame`, either works). By itself, it will remind you of the current frame:

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

^#^^#^ Linking data sets
