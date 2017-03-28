README for frequencyTracking GUI in fishtracker
Manu S. Madhav
25-Mar-2017

***************************************************************************
LAUNCHING 

The frequencyTracking GUI can be launched in MATLAB by changing into the
directory ‘frequencyTracking’ and running the file ‘frequencyTracking.m’ in
the MATLAB command prompt.

***************************************************************************
SYSTEM REQUIREMENTS

frequencyTracking has been tested on MATLAB versions 2014a - 2016a, on
Windows, Ubuntu and Mac OS X operating systems.

***************************************************************************
BRIEF DESCRIPTION

The frequencyTracking GUI implements and provides an interface to the
first half of the electrode-based electric fish tracking algorithm.
Specifically, given simultaneous readings from a set of electrodes, the
program computes its spectrogram using the short-term Fourier transform,
(STFT) and displays the spectrogram. The user can then set parameters to detect
frequency 'tracks': trajectories of frequency peaks with certain harmonic
properties. The user can then manually edit and refine the tracks. The GUI
also allows you to save and load electrode data, spectrogram, tracks and
parameter files.

***************************************************************************
OPERATING INSTRUCTIONS

1. Load Electrode data:
The program can load Spike2 data files with formats *.smr or *.smrx using the
'Load smr' button in the 'File handling' section. The program looks for
channels in the smr files starting with text in the 'Prefix' field. The data
is loaded into memory as the structure 'elec', which can then be saved, loaded
or cleared using the corresponding buttons in File handling.

2. Compute spectrogram:
The 'Spectrogram' section in the GUI allows the user to set parameters for
computing the spectrogram of the raw electrode data. 'nFFT' is the number of
points in the window for the STFT, and 'Overlap' is a value between 0 and 1
denoting the amount of overlap between contiguous windows. When these values
are edited, the time and frequency resolution of the resulting spectrogram are
computed and updated. The 'presets' section provides certain settings that we
used to analyze our laboratory and field recordings. The 'Compute' button uses
the current settings to compute and display the spectrogrma in the main figure
window.

3. Viewing spectrogram:
The spectrogram view can be used to parse the electrode data and determine
initial parameters for tracking frequencies. The 'Trim' section has fields to
change the frequency and time ranges that are viewed in the figure. The
'Restore' button restores these values and the plot to the whole range of
spectrogram data available. The 'Trim' button cuts the electrode data to the
current time range, and the spectrogram data to the current time and frequency
range. Please note that you need to trim to at least double the maximum
frequency of interest, since the algorithm uses the information from second
harmonics as well. The channel list selects the channel of which the
spectrogram is plotted. The user can also delete noisy or unwanted channels at
this point. Using the 'View' section, the user can also select whether to
display the spectrogram from a single channel, the mean spectrogram of all
channels, or a subplot view of all channels. The spectrogram can be saved,
    loaded or cleared using the corresponding buttons in File handling.

4. Thresholding
The 'Threshold' option in the 'View' section switches the figure to a binary
image, where the white regions are above the set threshold in both the
fundamental and second harmonics. The threshold can be edited or changed using
the slider and text box on the right of the figure which appears when the
threshold option is selected. Set the threshold to a value where the
fundamentals of the frequency tracks are above threshold, and most of the
noise is below threshold. It is generally better to set the threshold a bit
lower than higher.

5. Tracking
In the 'Tracking' section, the user can set the lower and higher bound of
frequencies that the algorithm looks for tracks. Also, the 'ratio' field sets
the threshold ratio between the fundamental and second harmonic. Once these
parameters are set, use the 'Track' button to run the main tracking algorithm.
This could take some time based on the size of the dataset.

6. Viewing and editing tracks
Once tracking is complete, the tracks list is populated and the tracks are
displayed in the spectrogram window. Either the spectrogram or the tracks
display can be switched on and off using the checkboxes in the 'View' section.
Tracks selected in the tracks list can be highlighted using the checkbox below
the tracks list. To select a track from the figure window, use the select
button below the tracks list (or press x) and click on a point in the figure
window. The track closest to the clicked point will be selected. At any point,
the tracks can be saved, loaded or cleared using the corresponding buttons
in the 'File Handling' section.

Individual points can be selected and edited independent of tracks using the
'Edit Points' section. 'Select' allows the user to click a number of points in
the figure window to define a polygon. 'Delete' deletes those points, and also
deletes any tracks if they don't have any points left. 'Assign' assigns the
selected points to the first selected track in the tracks list. If multiple
points at the same time instant are selected, the point with the highest
amplitude is assigned to the selected track, and the assignment of all other
points is unchanged.

Tracks assingnments can be edited using the 'Edit tracks' section. 'Delete'
deletes the selected tracks in the tracks list. 'Clean' deletes all tracks
with less than 10 points. 'Split' allows the user to click one point, and the
track point closest to the clicked point is used to split that track into two.
'Combine' combines the selected tracks into one track. Similar to 'Assign', if
there are multiple points in the selected tracks at the same time instances,
the combined track contains points with the highest amplitude, and other
points remain unchanged. 'Join' allows the user to click two points. The
program splits tracks at the two clicked points, and combines the track
from the earlier to the later time. 'Interp' fills in gaps less than 5
time intervals in all tracks by interpolating points.

New tracks or points can be manually added by using the 'New' section. This is
not recommended, since the clicked points are subject to user error. Create a
new track using the 'Track' button. The 'Point' button creates a point at the
clicked location and assigns it to the currently selected track. The 'Line'
button creates a set of interpolated points between the two clicked locations.

7. Miscellaneous
Track edits can be undone or redone using the 'Undo' and 'Redo' buttons in the
'Oops' section. The current plot in the figure window can be refreshed using
the 'Refresh' button, and printed to pdf using the 'Print' button in the 'Plot
Control' section. 

The 'Control' section has the log, which displays updates and errors from the
GUI. The current parameters set in the text boxes and sliders can be saved and
loaded using the 'Save' and 'Load' buttons in the 'Params' section.

***************************************************************************
SUPPORT

Please contact Manu S. Madhav (manusmad@gmail.com) if you encounter any bugs
or need further help, and ask nicely!
