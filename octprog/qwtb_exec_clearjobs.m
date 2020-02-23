function [jobs_list] = qwtb_exec_clearjobs(multicoreDir)
% This function must be called before qwtb_exec_makejob() to cleanup previous job files.
% 
% Parameters:
%   multicoreDir - jobs sharing folder with slave processes (see startmulticoreslave() from
%                  Multicore package) 
%
% Returns:
%   jobs_list - initial list of jobs in progress (empty)
%               store it to some permament variable outside.
%               It is used by qwtb_exec_checkjobs() to retrieve results.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2020, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%  
           
    % make jobs folder if not exist
    if ~exist(multicoreDir,'file')
        mkdir(multicoreDir);
    end
    
    % remove old files
    existingMulticoreFiles = [...
        mc_findfiles(multicoreDir, 'parameters_*.mat', 'nonrecursive'), ...
        mc_findfiles(multicoreDir, 'parameters_*.tmp', 'nonrecursive'), ...
        mc_findfiles(multicoreDir, 'result_*.mat',     'nonrecursive'), ...
        mc_findfiles(multicoreDir, 'result_*.tmp', 'nonrecursive')];
    cellfun(@unlink,existingMulticoreFiles);
      
    % empty list of job files
    jobs_list = {};
        
end

function fileCell = mc_findfiles(varargin)
  %MC_FINDFILES  Recursively search directory for files.
  %   MC_FINDFILES returns a cell array with the file names of all files
  %   in the current directory and all subdirectories.
  %
  %   MC_FINDFILES(DIRNAME) returns the file names of all files in the given
  %   directory and its subdirectories.
  %
  %   MC_FINDFILES(DIRNAME, FILESPEC) only returns the file names matching the
  %   given file specification (like '*.c' or '*.m').
  %
  %   MC_FINDFILES(DIRNAME, FILESPEC, 'nonrecursive') searches only in the top
  %   directory.
  %
  %   MC_FINDFILES(DIRNAME, FILESPEC, EXLUDEDIR1, ...) excludes the additional
  %   directories from the search.
  %
  %		Example:
  %		fileList = mc_findfiles('.', '*.m');
  %
  %		Markus Buehren
  %		Last modified 21.04.2008 
  %		Stanislav MaĹˇlĂˇĹ
  %		Last modified 27.11.2015
  %
  %   See also DIR.
  
  % disable warnings
  %warning('off',[],'local');
    
  if nargin == 0
  	searchPath = '.';
  	fileSpec   = '*';
  elseif nargin == 1
  	searchPath = varargin{1};
  	fileSpec   = '*';
  else
  	searchPath = varargin{1};
  	fileSpec   = varargin{2};
  end
  
  excludeCell = {};
  searchrecursive = true;
  for n=3:nargin
  	if isequal(varargin{n}, 'nonrecursive')
  		searchrecursive = false;
  	elseif iscell(varargin{n})
   		excludeCell = [excludeCell, varargin{n}]; %#ok
  	elseif ischar(varargin{n}) && isdir(varargin{n})
  		excludeCell(n+1) = varargin(n); %#ok
  	else
  		error('Directory not existing or unknown command: %s', varargin{n});
  	end
  end
  
  searchPath = mc_chompsep(searchPath);
  if strcmp(searchPath, '.')
   	searchPath = '';
  elseif ~exist(searchPath, 'dir')
  	error('Directory %s not existing.', searchPath);
  end
  
  % initialize cell
  fileCell = {};
  
  % search for files in current directory
  dirStruct = mc_dir(mc_concatpath(searchPath, fileSpec));
  for n=1:length(dirStruct)
  	if ~dirStruct(n).isdir
  		fileCell(end+1) = {mc_concatpath(searchPath, dirStruct(n).name)}; %#ok
  	end
  end
  
  % search in subdirectories
  if searchrecursive
  	excludeCell = [excludeCell, {'.', '..', '.svn'}];
  	if isempty(searchPath)
  		dirStruct = mc_dir('.');
  	else
  		dirStruct = mc_dir(searchPath);
  	end
  	
  	for n=1:length(dirStruct)
  		if dirStruct(n).isdir
  			name = dirStruct(n).name;
  			if ~any(strcmp(name, excludeCell))
  				fileCell = [fileCell, mc_findfiles(mc_concatpath(searchPath, name), fileSpec)]; %#ok
  			end
  		end
  	end
  end
end

function str = mc_chompsep(str)
  %MC_CHOMPSEP  Remove file separator at end of string.
  %		STR = MC_CHOMPSEP(STR) returns the string STR with the file separator at
  %		the end of the string removed (if existing). 
  %
  %		Example:
  %		str1 = mc_chompseq('/usr/local/');
  %		str2 = mc_chompseq('C:\Program Files\');
  %
  %		Markus Buehren
  %		Last modified 05.04.2009
  %		Stanislav MaĹˇlĂˇĹ
  %		Last modified 27.11.2015
  %
  %		See also MC_CONCATPATH.
  
  if ~isempty(str) && str(end) == filesep
    str(end) = '';
  end
endfunction

function str = mc_concatpath(varargin)
  %MC_CONCATPATH  Concatenate file parts with correct file separator.
  %		STR = MC_CONCATPATH(STR1, STR2, ...) concatenates file/path parts with the
  %		system file separator.
  %
  %		Example:
  %		drive = 'C:';
  %		fileName = 'test.txt';
  %		fullFileName = mc_concatpath(drive, 'My documents', fileName);
  %	
  %		Markus Buehren
  %		Last modified 05.04.2009
  %             Stanislav MaĹˇlĂˇĹ
  %		Last modified 27.11.2015
  %             
  %
  %		See also FULLFILE, FILESEP, MC_CHOMPSEP.
  
  str = '';
  for n=1:nargin
  	curStr = varargin{n};
  	str = fullfile(str, mc_chompsep(curStr));
  end
  
  if ispc
    str = strrep(str, '/', '\');
  else
    str = strrep(str, '\', '/');
  end  

endfunction

## Copyright (C) 2004-2017 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {} {} dir
## @deftypefnx {} {} dir (@var{directory})
## @deftypefnx {} {[@var{list}] =} dir (@var{directory})
## Display file listing for directory @var{directory}.
##
## If @var{directory} is not specified then list the present working directory.
##
## If a return value is requested, return a structure array with the fields
##
## @table @asis
## @item name
## File or directory name.
##
## @item date
## Timestamp of file modification (string value).
##
## @item bytes
## File size in bytes.
##
## @item isdir
## True if name is a directory.
##
## @item datenum
## Timestamp of file modification as serial date number (double).
##
## @item statinfo
## Information structure returned from @code{stat}.
## @end table
##
## If @var{directory} is a filename, rather than a directory, then return
## information about the named file.  @var{directory} may also be a list rather
## than a single directory or file.
##
## @var{directory} is subject to shell expansion if it contains any wildcard
## characters @samp{*}, @samp{?}, @samp{[]}.  To find a literal example of a
## wildcard character the wildcard must be escaped using the backslash operator
## @samp{\}.
##
## Note that for symbolic links, @code{dir} returns information about the
## file that the symbolic link points to rather than the link itself.
## However, if the link points to a nonexistent file, @code{dir} returns
## information about the link.
## @seealso{ls, readdir, glob, what, stat, lstat}
## 
## This file was forked from octave because original version do not set ids in warnings.
## In this fork warnings can be switched off. This is the only change. (Martin Ĺ Ă­ra).
##
## @end deftypefn

## Author: jwe

## FIXME: This is quite slow for large directories.
##        Perhaps it should be converted to C++?

function retval = mc_dir (directory)

  if (nargin == 0)
    directory = ".";
  elseif (nargin > 1)
    print_usage ();
  endif

  if (! ischar (directory))
    error ("dir: DIRECTORY argument must be a string");
  endif

  ## Prep the retval.
  info = struct (zeros (0, 1),
                 {"name", "date", "bytes", "isdir", "datenum", "statinfo"});


  if (strcmp (directory, "*"))
    directory = ".";
  endif
  if (strcmp (directory, "."))
    flst = {"."};
    nf = 1;
  else
    flst = __wglob__ (directory);
    nf = numel (flst);
  endif

  ## Determine the file list for the case where a single directory is specified.
  if (nf == 1)
    fn = flst{1};
    [st, err, msg] = stat (fn);
    if (err < 0)
      warning ("multicore:dir-stat", "dir: 'stat (%s)' failed: %s", fn, msg);
      nf = 0;
    elseif (S_ISDIR (st.mode))
      flst = readdir (flst{1});
      nf = numel (flst);
      for i = 1:nf
        flst{i} = fullfile (fn, flst{i});
      endfor
    endif
  endif

  if (numel (flst) > 0)
    ## Collect results.
    for i = nf:-1:1
      fn = flst{i};
      [st, err, msg] = lstat (fn);
      if (err < 0)
        warning ("multicore:dir-lstat", "dir: 'lstat (%s)' failed: %s", fn, msg);
      else
        ## If we are looking at a link that points to something,
        ## return info about the target of the link, otherwise, return
        ## info about the link itself.
        if (S_ISLNK (st.mode))
          [xst, err, msg] = stat (fn);
          if (! err)
            st = xst;
          endif
        endif
        [dummy, fn, ext] = fileparts (fn);
        fn = [fn ext];
        info(i,1).name = fn;
        lt = localtime (st.mtime);
        info(i,1).date = strftime ("%d-%b-%Y %T", lt);
        info(i,1).bytes = st.size;
        info(i,1).isdir = S_ISDIR (st.mode);
        info(i,1).datenum = datenum (lt.year + 1900, lt.mon + 1, lt.mday,
                                     lt.hour, lt.min, lt.sec);
        info(i,1).statinfo = st;
      endif
    endfor
  endif

  ## Return the output arguments.
  if (nargout > 0)
    ## Return the requested structure.
    retval = info;
  elseif (numel (info) > 0)
    ## Print the structure to the screen.
    printf ("%s", list_in_columns ({info.name}));
  else
    warning ("multicore:dir-nodir", "dir: nonexistent directory '%s'", directory);
  endif

endfunction

