function[flag]= ensureDir(path)
% ENSUREDIR  Make sure a directory exists.
%  ENSUREDIR(PATH) check for the existence of the directory
%  PATH and attempt to create it otherwise.

% AUTORIGHTS
% Copyright (c) 2009 Brian Fulkerson and Andrea Vedaldi
% Blocks is distributed under the terms of the modified BSD license.
% The full license may be found in LICENSE.

if isempty(path) || exist(path, 'dir')
    flag = 0;
  return
end

[subpath, name, ext] = fileparts(path) ;
name = [name ext] ;

ensureDir(subpath) ;

if ~exist(path, 'dir')
  if ~isempty(subpath)
    mkdir(subpath, name) ;
    flag = 1;
  else
    mkdir(name) ;
    flag = 1;
  end
end