INTRODUCTION:
The Spatial Tracking GUI is built to allow the user to easily run the spatial tracking program on datasets and visualize the results without requiring in-depth knowledge of the codebase. 

REQUIREMENTS: 
Matlab (The algorithm was developed on R2016a). Any external libraries used have been included in the code zip file and acknowledged in the paper. 

GUIDE TO USING THE SPATIAL TRACKING GUI: 

(i) LOADING DATA: 

	⁃	Open MATLAB
	⁃	Change the working folder to the ‘<folder where tracking code is extracted to>\fishtracker\spatialTracking’
	⁃	In MATLAB Command window, run ‘spatialTracking’
	⁃	Click ‘SelDir’ and choose dataset folder in the popup window that opens up. 
	⁃	Under ‘Dataset Type’
	⁃	Choose ‘Tracks’ to load frequency tracks (i.e. tracks.mat files in folder ‘freqtracks’)
	⁃	Choose ‘Localized’ to load datasets that have already been processed by the spatial tracking program (i.e. particle.mat files in folder ‘tracked’). 
	⁃	Click ‘Load’. The ‘Electrode Datasets’ window just below will now be populated with the specified type of files. 

(ii) PROCESSING DATA: 

	⁃	For ‘tracks.mat’ files from folder ‘freqtracks’:
	⁃	Under ‘Grid Type’, select:
	⁃	‘Wild’ if dataset was collected in the field
	⁃	‘Tank’ if the dataset was collected in the lab
         This option tells the program whether to look for video tracked files or not. 
	⁃	In the textbox just below ‘Grid Type’, enter the number of particles to be used for spatial tracking (recommended value: 250000 or higher). 
	⁃	To process one tracks.mat file, select file from ‘Electrode Datasets’ window and click ‘Track’. To process the entire folder, click the ‘Batch’ button and then click ‘Track’
	⁃	Once the dataset has been tracked, click ‘Save Tracked Data’ to save the output of the spatial tracking program as a ‘particle.mat’ file in subfolder ’tracked’ of the dataset folder.
	⁃	For ‘particle.mat’ files from folder ‘tracked’, select file from ‘Electrode Datasets’ window and click ‘Load’


(iii) VISUALIZING DATA:

Guide to Plots in GUI: 
	⁃	The plot in the middle of the GUI, titled ‘Overhead Plot’ will show the overhead view of the grid of electrodes and the estimated X-Y positions and angles of the fish at the current time step. Each fish will be plotted with a unique color.
	⁃	The top right plot, titled ‘Electrode Heatmap’ shows the heatmap of the combined electrode readings of the selected fish at the current time step. 
	⁃	The middle right plot, titled ‘Frequency Tracks’ plots the time.v.frequency traces of the selected fish. A vertical black bar indicates the current time step.
	⁃	Clicking the ‘Plot Theoretical Heatmap’ button below the plot shows the heat map of the combined theoretical electrode readings of the selected fish. The theoretical electrode readings are calculated based on the estimated position of the fish at the current time step. ‘Plot Theoretical Heatmap’ button will now read ‘Plot Frequency Tracks’. Clicking this will re-plot the frequency traces. 

Plot Settings: 
	⁃	Freq Tracked Fish: This window shows the list of fish. The user can select which fish to plot.
	⁃	Save Overhead Plot: Saves the overhead plot of the current time step as a pdf
	⁃	Show …
	⁃	Time: Overlays the time of current time step at the top right of the overhead plot. 
	⁃	All Fish: Overrides the selection in the Selects all fish
	⁃	Videotracks: For data collected in the lab, plots video tracked fish positions
	⁃	Show current estimated… 
	⁃	Angle: Shows the position and orientation of the selected fish at the current time step as an ellipse with the long axis of the fish being the same as the long axis of the ellipse. It is not known which end of the ellipse corresponds to the head/tail of the fish. 
	⁃	Position: Plots the position of selected fish at the current time step as a filled circle.
	⁃	None: Doesn’t plot a marker showing the current state of the fish.
	⁃	Overlay spatial track …
	⁃	All: Plots a dot at the estimated position of the fish for all time steps. 
	⁃	To current step: Plots a dot at the estimated position of the fish from the start of the dataset to the current time instance. 
	⁃	None: Doesn’t plot dots. 
	⁃	Set overhead plot limit …
	⁃	Default: Sets the xlim/ylim of the overhead plot to the default values specified in the code. 
	⁃	Max: Sets the xlim/ylim of the overhead plot to the max x-coordinate/y-coordinate of the estimated position of selected fish over all time steps. 
	⁃	Manual: Uses the number specified in the textbox next to this radio button as a scaling factor (centered on the grid) to specify the xlim/ylim of the overhead plot. 

Video Settings: Create a video of the tracked estimate in the overhead plot between time step s1 to time step s2
	⁃	Step: Specify the start time step s1 in the left text box and end time s2 in the right textbook
	⁃	FPS: Specify the FPS at which the video should be generated
	⁃	Save Video: Generate video. The filename can be specified in a popup window. 

Playback Control: 
	⁃	Slider: The user can use the slider to skip to a desired time step. 
	⁃	Speed: Specify speed of playback. The FPS remains the same, the number of time steps skipped between frames determines playback speed. 
	⁃	Play: Plays the progression of estimated positions of the fish by updating the three plots on the GUI every x seconds for consecutive (as determined by playback speed) time steps. 
    Upon clicking ‘Play’, the button will now be labelled as ‘Pause’. Clicking the button will pause the playback. 
	⁃	Step: Specify time step to plot.
	⁃	Prev/Next: Plots the previous/next timestep (by a timestep skip determined by the playback speed)




