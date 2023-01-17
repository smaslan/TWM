# Issues with GNU Octave
Document describes various issues found in various versions of GNU Octave

## Windows OS
### 6.2.0 64 bit
- Fltk toolkit fails when rendering hidden image `figure('visible','off')` to a file using command `print('something.png')`

### 7.1.0 64 bit
- Fltk toolkit fails when rendering hidden image `figure('visible','off')` to a file using command `print('something.png')`
- Commands 'addpath' and 'rmpath' takes very long time. 'qwtb_load_algorithms' take 12 s on LVNTB2. For comparison, version 6.2.0 takes 2 s.

### 7.2.0 64 bit
- Fltk toolkit fails when rendering hidden image `figure('visible','off')` to a file using command `print('something.png')`
- Commands 'addpath' and 'rmpath' takes very long time. 'qwtb_load_algorithms' take 12 s on LVNTB2. For comparison, version 6.2.0 takes 2 s.

### 7.3.0 64 bit
- Fltk toolkit fails when rendering hidden image `figure('visible','off')` to a file using command `print('something.png')`
- Commands 'addpath' and 'rmpath' takes very long time  'qwtb_load_algorithms' take 16 s on LVNTB2. For comparison, version 6.2.0 takes 2 s.





# Test commands
## FLTK rendering error
Code to test:

    graphics_toolkit('fltk'), figure('visible','off'), plot(rand(5)), print('a.png'), close

## long execution time of addpath, rmpath
Code to test:

    addpath('PATH_TO_TWM\octprog\')
    addpath('PATH_TO_TWM\octprog\info')
    addpath('PATH_TO_TWM\octprog\qwtb')
    tic, qwtb_load_algorithms, toc
