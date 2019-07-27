function writeParameters(fileId,param)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

fprintf(fileId,'# parameters:\n');
fprintf(fileId,'  relaxOrder         = %d\n',param.relaxOrder);
fprintf(fileId,'  sparseSW           = %d\n',param.sparseSW);
fprintf(fileId,'  multiCliquesFactor = %6.2e\n',param.multiCliquesFactor);
fprintf(fileId,'  scalingSW          = %d\n',param.scalingSW);
fprintf(fileId,'  boundSW            = %d\n',param.boundSW);
fprintf(fileId,'  eqTolerance        = %6.2e\n',param.eqTolerance);
fprintf(fileId,'  perturbation       = %6.2e\n',param.perturbation);
fprintf(fileId,'  reduceMomentMatSW  = %d\n',param.reduceMomentMatSW);
fprintf(fileId,'  complementaritySW  = %d\n',param.complementaritySW);
fprintf(fileId,'  SquareOneSW        = %d\n',param.SquareOneSW);
fprintf(fileId,'  binarySW           = %d\n',param.binarySW);
fprintf(fileId,'  reduceAMatSW       = %d\n',param.reduceAMatSW);
%{
fprintf(fileId,'  SeDuMiSW           = %d\n',param.SeDuMiSW);
fprintf(fileId,'  SeDuMiEpsilon      = %6.2e\n',param.SeDuMiEpsilon);
if ischar(param.SeDuMiOutFile)
	fprintf(fileId,'  SeDuMiOutFile      = %s\n',param.SeDuMiOutFile);
elseif isnumeric(param.SeDuMiOutFile)
	fprintf(fileId,'  SeDuMiOutFile      = %d\n',param.SeDuMiOutFile);
end
%}
fprintf(fileId,'  SDPsolverSW        = %d\n',param.SDPsolverSW);
fprintf(fileId,'  SDPsolver          = %s\n',param.SDPsolver);
fprintf(fileId,'  SDPsolverEpsilon   = %6.2e\n',param.SDPsolverEpsilon);
if ischar(param.SDPsolverOutFile)
	fprintf(fileId,'  SDPsolverOutFile   = %s\n',param.SDPsolverOutFile);
elseif isnumeric(param.SDPsolverOutFile)
	fprintf(fileId,'  SDPsolverOutFile   = %d\n',param.SDPsolverOutFile);
end
if ischar(param.sdpaDataFile)
	fprintf(fileId,'  sdpaDataFile       = %s\n',param.sdpaDataFile);
else
	fprintf(fileId,'  sdpaDataFile       = ''\n');
end
if ischar(param.detailedInfFile)
	fprintf(fileId,'  detailedInfFile    = %s\n',param.detailedInfFile);
elseif isnumeric(param.detailedInfFile)
	fprintf(fileId,'  detailedInfFile    = %d\n',param.detailedInfFile);
end
if ischar(param.printFileName)
	fprintf(fileId,'  printFileName      = %s\n',param.printFileName);
elseif isnumeric(param.printFileName)
	fprintf(fileId,'  printFileName      = %d\n',param.printFileName);
end
fprintf(fileId,'  printLevel         = [%d, %d]\n',param.printLevel(1),param.printLevel(2));
fprintf(fileId,'  symbolicMath       = %d\n',param.symbolicMath);
fprintf(fileId,'  POPsolver          = %s\n',param.POPsolver);
%{
if isfield(param, 'errorBdIdx')
	if ~isempty(param.errorBdIdx)
		if iscell(param.errorBdIdx)
			r = size(param.errorBdIdx, 2);
			for k=1:r
				if ischar(param.errorBdIdx{k})
					fprintf(fileId,'  errorBdIdx         = %s\n', param.errorBdIdx{k});
				else
					fprintf(fileId,'  errorBdIdx         = [%2d, %2d]\n', param.errorBdIdx{k}(1), param.errorBdIdx{k}(end));
				end
			end
		else
			if ischar(param.errorBdIdx)
				fprintf(fileId,'  errorBdIdx         = %s\n', param.errorBdIdx);
			else
				fprintf(fileId,'  errorBdIdx         = [%2d, %2d]\n', param.errorBdIdx(1), param.errorBdIdx(end));
			end
		end
		fprintf(fileId,'  fValueUbd          = %5.3e\n', param.fValueUbd);
	else
		fprintf(fileId,'  errorBdIdx         =\n');
		fprintf(fileId,'  fValueUbd          =\n');
	end
else
	fprintf(fileId,'  errorBdIdx         =\n');
	fprintf(fileId,'  fValueUbd          =\n');
end
%}
fprintf(fileId,'  mex                = %d\n',param.mex);
if param.aggressiveSW == 1 
	fprintf(fileId,'  aggressiveSW       = %d // for developers of SparsePOP \n',param.aggressiveSW);
end
fprintf(fileId,'\n');
return
