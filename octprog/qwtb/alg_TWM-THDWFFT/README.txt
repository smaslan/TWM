THD and harmonics by windowed FFT for non-coherent sampling
-----------------------------------------------------------

This is relatively simple algorithm developed for calculation of THD
of non-coherently sampled waveform. 

It was developed at CMI around 2013 for direct measurement of THD
usign NI PXI 5922 digitizer. Validation was made in 2014:
  J. Horska, S. Maslan, J. Streit and M. Sira, 
  "A validation of a THD measurement equipment with a 24-bit digitizer,"
  29th Conference on Precision Electromagnetic Measurements (CPEM 2014),
  Rio de Janeiro, 2014, pp. 502-503.
  doi: 10.1109/CPEM.2014.6898479


In 2017 it was reworked to fit in the QWTB toolbox. 


Main features of the algorithm:

 1) Non-coherent without need for resampling or fitting.

 2) Immune to the short-term fluctuation of frequency (uses very wide window function).

 3) Capable of calculation with harmonics barely above noise level 
    (Correcting spectral leakage of noise into the harmonics for low
    Amplitudes)

 4) Integrated fast uncertainty estimator.

It may seem a little overcomplicated however that is mostly due to 3).
For higher SNR it may be much simpler. 



Notes:

It was originally developed for GNU Octave 3.6.4. However to make it
compatible with MATLAB, especially its older versions, it had to be 
'crippled' in many places. For instance MATLAB does support automatic
operator broadcasting since version 2016, so it had to be done 
explicitly using bsxfun(). It is very nasty in the code but there is no
other way. Also function cellfun() is pretty badly implemented in older
Matlab, so there are some nasty changes as well.

So keep this in mind if you want to 'optimize' it!!!

If you decide to change something, always check compatibility with 
GNU Octave and some older MATLAB, otherwise the change cannot be accepted
into QWTB toolbox!