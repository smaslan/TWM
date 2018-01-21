## Copyright (C) 2014 Martin Šíra %<<<1
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{infostr} = infoload (@var{filename})
## @deftypefnx {Function File} @var{infostr} = infoload (@var{filename}, @var{autoextension})
## Opens file with info string `@var{filename}.info` and loads its content as text.
## Extension `.info` is added automatically if missing, this can be prevented by
## setting @var{autoextension} to zero.
##
## Example:
## @example
## infostr = infoload('test_file')
## infostr = infoload('test_file_with_other_extension.txt', 0)
## @end example
## @end deftypefn

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2014
## Version: 4.0
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Checks inputs: yes
##   Contains tests: no
##   Contains demo: no
##   Optimized: N/A

function infostr = infoload(filename, varargin) %<<<1
        % input possibilities:
        %       filename
        %       filename, autoextension

        % check inputs %<<<2
        if ~(nargin==1 || nargin==2)
                print_usage()
        endif
        if nargin == 1
                autoextension = 1;
        else
                autoextension = varargin{1};
        endif
        if (~ischar(filename))
                error('infoload: filename must be string')
        endif

        % check extension %<<<2
        if autoextension
                % automatic addition of extension required
                if length(filename) < 5
                        % too short filename, therefore extension is definitely missing:
                                filename = [filename '.info'];
                else
                        if ~strcmpi(filename(end-4:end), '.info')
                                % extension .info is missing
                                filename = [filename '.info'];
                        endif
                endif
        endif
        % check if file exist:
        if ~exist(filename, 'file')
                error(['infoload: file `' filename '` not found'])
        endif

        % read file %<<<2
        fid = fopen(filename, 'r');
        if fid == -1
                error(['infoload: error opening file `' filename '`'])
        endif
        [infostr,count] = fread(fid, [1,inf], 'uint8=>char');  % s will be a character array, count has the number of bytes
        fclose(fid);
endfunction

% --------------------------- tests: %<<<1
%!shared fn, cont, fid, is
%! fn = 'tmp.info';
%! cont = 'delete this file';
%! fid = fopen(fn, 'w');
%! fprintf(fid, cont);
%! fclose(fid);
%! is = infoload(fn);
%!assert(strcmp(is, cont));
%! is = infoload(fn, 0);
%!assert(strcmp(is, cont));
%! is = infoload(fn(1:end-5));
%!assert(strcmp(is, cont));
%! delete(fn);
%!error(infoload(fn(1:end-5), 0));
%!error(infoload(5));
