These are a series of scripts that classify different behaviors (shaking hands, punching, etc) displayed in short video clips.

The Part 1 scripts calculate a histogram of gradients/HOG and a histogram of optical flows/HOF respectively for every frame of a video. HOG is calculated by computing gradient orientation and magnitude for each pixel and using trilinear interpolation.
HOF is calculated similarly.

The Part 2 script implements a “bag of visual words.” This script uses k means clustering on the HOGs calculated in part 1. Each cluster corresponds to a visual word. Each frame of every video is assigned a visual word and a histogram of words is computed for each video. This is repeated using k means clustering on the HOFs as well.

The Part 3 script implements the video classification. A random forest classifier is used for training and testing.

Videos used found at: http://michaelryoo.com/datasets/jpl_interaction_segmented_iyuv.zip


To run:
Place all the video files in the same directory as the .m files.

Note:
Each part creates intermediate files that are accessed by the next part. I
have collected those parts in the folder ./intermediateFiles so that if
you want to run a part without running the previous part, you can. To do
so, move the intermediate files to the same directory as the .m files.

The part1 scripts take a very long time to run.

I used an external script to calculate dense optical flows. For it to work,
those files needed to be in the same directory as the scripts I wrote for
the assignment. So, to differentiate them:
Scripts I wrote: 'Part1HOG.m' 'Part1HOF.m' 'Part2.m'
                                     'Part3.m'

Scripts that are part of the optical flow: ./mex 'Coarse2FineTwoFrames.mexmaci64
                                           'computeColor.m' 'flowToColor.m'
                                           'warpFl.m' 'warpFLColor.m'


