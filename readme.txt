TWM:

This is TWM - TracePQM Wattmeter - part of EMPIR project TracePQM.
Details on the project can be found on the www:

http://tracepqm.cmi.cz/




Version:

V1.7.5, 2022-01-12




Authors:

Project is composed of components prepared by members of consortium 
of the EMPIR project TracePQM.

Maintainer: Stanislav Maslan, smaslan@cmi.cz




License:

The project consist of several components:

1) LabVIEW application (GUI and HW control),
2) M-files for interfacing the QWTB toolbox to the GUI,
3) QWTB toolbox: https://qwtb.github.io/qwtb/ 

Components 1) and 2) are distributed under MIT license.

Component 3), the QWTB toolbox, is also distributed under MIT license however 
the algorithms in the QWTB have their own licenses!




What it does:

1) TWM can digitize waveforms using selected digitizer.
2) Stores the waveform data in unified format.
3) Calculates various power and PQ parameters using GNU Octave/Matlab.

For details see attached documents in 'doc' folder.