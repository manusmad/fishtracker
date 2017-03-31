README for fishtracker

'fishtracker' is the two-step algorithm described in Madhav et al., 2017 to
track multiple freely moving weakly electric fish using measurements from a
grid of electrodes in a known configuration.

The 'frequencyTracking' folder contains the MATLAB code for tracking frequency
parameters of fish, and must be run first. A GUI for analyzing data can be opened by running ‘frequencyTracking.m’ from the MATLAB command prompt.

The ‘spatialTracking’ folder contains the MATLAB code for tracking spatial parameters of fish from the frequency tracks. A GUI for analyzing data can be opened by running ‘spatialTracking.m’ from the MATLAB command prompt.

The ‘packages’ directory contains the third-party MATLAB code that we acquired (mostly) from the Mathworks community website and have utilized for this project. We acknowledge and credit the original authors of the packages. The packages are licensed as specified in their individual folders. We are making this code available for non-commercial use, and including the versions of the packages that have been tested to execute properly with our codebase.

The third-party packages are:
CircStat2012a
Hungarian
MagnetGInput
SONlib
addpath_recurse
datastructure
disperse
distinguishable_colors
export_fig
findjobj
ginputax
matson
ndnanfilter
parfor_progress
plot_ellipse
progressbar
savefast
serialization
subtightplot