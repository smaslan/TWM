## Copyright (C) 2011 Martin Šíra, Věra Nováková Zachovalová %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{y2}, @var{s}]} = window(@var{y1}, @var{w}, @var{t})
## The function applies window function to a sampled signal
## @var{y1}. Parameter @var{w} selects window function:
## @table @samp
##         @item 0 - no window func.
##         @item 1 - hanning
##         @item 2 - blackman
##         @item 3 - hamming
##         @item 4 - flattop
## @end table
##
## Parameter @var{t} selects type of flat top window.
## @seealso{flattop}
## @end deftypefn

## Contact: Martin Šíra <msiraATcmi.cz>
## Created: 2011
## Version: 0.9
## Contains help: yes
## Contains test: no
## Contains demo: no

function [y2,s,flat] = fft_window(y1,w,t) %<<<1
  
  % default relative flatness [-]
  flat = 0;
  
  switch w
  	case 0
  		% without window function
      w = ones(size(y1));
  	case 1
  		% Hanning window	
  		w = hanning(length(y1)+1)(1:end-1);
  	case 2
  		% Blackman window	
  		w = blackman(length(y1)+1)(1:end-1);
  	case 3
  		% Hamming window	
  		w = hamming(length(y1)+1)(1:end-1);
  	case 4
  		% Flat top window
  		[w,flat] = flattop(t,length(y1));
  	otherwise
  		% without window function
  		w = ones(size(y1));
  end
  
  % apply window
  if(size(w)~=size(y1))
    w=w';
  endif
  y2 = y1.*w;
  
  % for normalisation of y-axis of spectrum
  s = length(y2);

endfunction

% vim settings line: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
