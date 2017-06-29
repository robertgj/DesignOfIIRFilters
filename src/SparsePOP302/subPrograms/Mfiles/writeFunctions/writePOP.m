function writePOP(fileId,objPoly,ineqPolySys,lbd,ubd)
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
	
% objective function
fprintf(fileId,'objPoly\n'); 
writePolynomials(fileId,objPoly); 
% inequalities 
fprintf(fileId,'ineqPolySys\n'); 
if size(ineqPolySys,2) == 1
	writePolynomials(fileId,ineqPolySys{1}); 
elseif size(ineqPolySys,2) > 1
	writePolynomials(fileId,ineqPolySys); 
end
fprintf(fileId,'\n');
nDim = length(lbd); 
% lower bounds
fprintf(fileId,'lbd = \n');
k = 1;
for i=1:nDim
	fprintf(fileId,'%3d:%+6.2e',i,lbd(i));
	if mod(k,10) == 0 
		fprintf(fileId,'\n');
	end
	k = k+1; 
end
fprintf(fileId,'\n');
% upper bounds
fprintf(fileId,'ubd = \n');
k = 1;
for i=1:nDim
	fprintf(fileId,'%3d:%+6.2e',i,ubd(i));
	if mod(k,10) == 0
		fprintf(fileId,'\n');
	end
	k = k+1; 
end
fprintf(fileId,'\n\n');

return


