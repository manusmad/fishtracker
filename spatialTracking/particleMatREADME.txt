INTRODUCTION:
The frequency localization algorithm outputs tracks, each of which represents the signal trajectory of a single dipole source. This allows each dipole to be spatially localized independent of other sources. The output of the spatial localization program is saved in particle.mat files. 

REQUIREMENTS: 
Matlab (The algorithm was developed on R2016a). Any external libraries used have been included in the code zip file.  

DATA STRUCTURE: 
The particle.mat files contain one variable, a ‘particle’ structure.

	⁃	particle.tankCoord		: (x,y) coordinates of tank boundary (in cm)
	⁃	particle.gridCoord		: (x,y,z) coordinates of electrodes in grid (in cm)
	⁃	particle.wildTag		: Value 1 or 0. Value 1 denotes if the data was collected in 					      the field
	⁃	particle.fish     		: 
		⁃	fish(i).id       		: Fish identifier number
		⁃	fish(i).freq 		: Frequency trace (in Hz)
		⁃	fish(i).x    		: estimated X coordinate of fish (in cm)
		⁃	fish(i).y    		: estimated Y coordinate of fish (in cm)
		⁃	fish(i).z    		: estimated Z coordinate of fish (in cm)
		⁃	fish(i).theta		: Orientation in horizontal plane. (in radians)
		⁃	fish(i).ampAct		: Matrix of actual electrode amplitudes
		⁃	fish(i).ampTheor		: Matrix of theoretical electrode amplitudes
	⁃	particle.t          		: Time vector of dataset (in s)
	⁃	particle.nPart			: Number of particles used
	⁃	particle.varObs			: Observation noise variance
	⁃	particle.nFish 			: Number of fish
	⁃	particle.nChannels		: Number of electrodes
	⁃	particle.freqTrackFile	: File name of frequency tracking output used as input 

AUTHOR: 
Ravikrishnan Perur Jayakumar, 
Email: rperurj1@jhu.edu