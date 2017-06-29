% Compiling Mex Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP 
% Copyright (C) 2007 SparsePOP Project
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

MexFlags = ' -O -Dlinux=1 -DMATLAB_MEX_FILE ';

LIBfiles = ' conversion.cpp spvec.cpp polynomials.cpp sup.cpp clique.cpp mysdp.cpp Parameters.cpp ';
OBJfiles = strrep(LIBfiles,'.cpp','.o');

mpwd=pwd;
mpath=mfilename("fullpath");
mpath=mpath(1:strchr(mpath,filesep,1,'last'));
cd(strcat(mpath,filesep,'subPrograms',filesep,'Mex'));
fprintf('Compiling Libraries...');
command = ['mex -c ' MexFlags LIBfiles];
eval(command);
fprintf('done\n');
fprintf('Generating mexconv1...');
command = ['mex ' MexFlags ' mexconv1.cpp'  OBJfiles ];
eval(command);
fprintf('done\n');
fprintf('Generating mexconv2...');
command = ['mex ' MexFlags ' mexconv2.cpp ' OBJfiles ];
eval(command);
fprintf('done\n');
cd(mpwd);

fprintf('Compilation finished successfully.\n');
