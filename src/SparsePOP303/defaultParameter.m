function param = defaultParameter(param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting default parameters
% Details of Parameters
%%%%%%%%%%%
% 1. Parameters to control the basic relaxation scheme.
%
% param.relaxOrder = \omega = the relaxation order;
%   Default value = the minimum relaxation order \omega_{\max}.
%
% param.sparseSW = 1 if you use sparse relaxation;  
%                  0 for dense relaxation; 
%                  2 for a smaller dense relaxation; 
%                  3 for a smaller sparse relaxation; 
%	Default value = 1.
%
% param.multiCliqueFactor 
%   = 0 for no expansion of cliques; 
%   = 1 for combining cliques as long as their sizes do not exceed 
%       the maximum size of all maximal cliquees; 
%   = 'objPoly.dimVar' for combining cliques as long as possible;  
%	Default value = 1.
%
%%%%%%%%%%
% 2. Switch to handle numerical difficulties. 
%
% param.scalingSW
%   = 0 for no scaling.  
%   = 1 for scaling; 
%   Default value = 1; 
%
% param.boundSW
%   = 0 for no bounds for any y_{\alpha}; 
%   = 1 for bounds for all y_{\alpha};
%   = 2 for bounds for all y_{\alpha} and eliminating redundant bounds; 
% 	Default value = 2; 
%
% param.eqTolerance
%   Convert one equality into two inequality; 
%   if 1.0e-10 \leq param.eqTolerance then f(x) = 0 ===>  f(x) \geq 0  and
%    -f(x) \geq -param.eqTolerance. 
%   Else keep one equality as it is. 
%   Default value = 0.0; 
%
% param.perturbation 
%   = 0 for no pertubation to the objective polynomial; 
%   = 1.0e-5 for a perturbation to the objective polynomial with p, 
%     |p_i| <= 1.0e-5.
%   Default value = 0; 
%
% param.reduceMomentMatSW 
%   = 0 for no reduction of moment matrices; 
%   = 1 for reduction of moment matrices by eliminating 
%       redundant elements in moment matrices;
%   = 2 for more reduction of moment matrices by eliminating
%       redundant elements in moment and localizing matrices;
%   Default value= 1.
%
% param.complementaritySW 
%   If x_ixj = 0 is invloved in equality constraits, 
%    any variable y_{\alpha} correspoinding to a monomial x^{\alpha} 
%    such that \alpha_i \geq 1 and \alpha_j \geq 1 is set to be zero 
%    and eliminaed from the relaxed problem. 
%    Set param.complementaritySW = 1 only when the complementarity condition 
%    is involved in constraints. 
%   = 0 for no reduction in moment matrices using complementarity;
%   = 1 for reduction in moment matrices using complementarity;
%   Default value = 0; 
% 
% param.SquareOneSW
%   If x_i^2 = 1 is involved in equality constraints,
%    any variable y_{\alpha} corresponding to a monomial x^{\alpha}
%    such that \alpha_i > 1 is set to be y_{\beta}, where 
%    \beta_i = (\alpha_i mod 2)  and \beta_j = \alpha_j for j \neq i.
%   = 0 for no reduction in moment matrices using equality x_i^2 = 1;
%   = 1 for reduction in moment matrices using equality x_i^2 = 1;
%   Default value = 1; 
% 
% param.binarySW
%   If x_i^2 = x_i is involved in equality constraints,
%    any variable y_{\alpha} corresponding to a monomial x^{\alpha}
%    such that \alpha_i > 1 is set to be y_{\beta}, where 
%    \beta_i = 1 and \beta_j = \alpha_j for j \neq i.
%   = 0 for no reduction in moment matrices using equality x_i^2 = x_i;
%   = 1 for reduction in moment matrices using equality x_i^2 = x_i;
%   Default value = 1; 
%
% param.reduceAMatSW
%   If param.reduceAMatSW = 1, then
%    (a) Eliminate some fixed variables from a POP before applying the 
%        sparse SDP relaxation,  
%    (b) When the equality constraints of the SeDuMi format primal SDP
%        are linearly dependent, eliminated some equalities to restore 
%        the linear independence.
%   = 0 for no (a) and (b);
%   = 1 for (a) and (b);
%   Defaulat value = 1;
%
% param.reduceEqualitiesSW and param.elimFrSW
%   These parameters may be useful in solving POP with equality 
%   constraints. But, these functions are still incomplete. 
%   In this version, these are not available. 
%
%%%%%%%%%%
% 3. Parameters for SDP solvers.
%
% param.SDPsolverSW 
%   = 1 for solving SDP by one of SDP solvers in SDPA, SeDuMi
%       SDPT3, CSDP, SDPNAL.;  
%   = 0 only for displaying information on the SDP to be solved; 
%   Default value = 1.
%
% param.SDPsolver
%   Specifies which SDP solver in SDPA, SeDuMi, SDPT3, CSDP
%    SDPNAL is used to solve the resulting SDP problem.
%   Default value = 
%
% param.SDPsolverEpsilon
%   A stopping criteria for the duality gap in SeDuMi;
%   = any nonnegative real number;
%   Default value = 1.0e-9. 
%
% param.SDPsolverOutFile 
%   Specifies where SeDuMi output goes.
%   = 1 for the standard output (screen)
%   = 0 for no output
%   = 'filename' for output file name
%   Default value = [].
%
% param.sdpaDataFile
%   Specify SDPA sparse format data such that param.sdpaDataFile =
%   'fileName.dat-s', for example, param.sdpaDataFile = 'test.dat-s'; 
%   = [] for no SDPA sparse format data output; 
%   = 'fileName.dat-s';
%   Default value = []; 
% 
%%%%%%%%%%%
% 4. Parameters for printing numerical results. 
%
% param.detailedInfFile 
%   = 0 for no output of detailed information;
%   = 1 for the screen output of detailed information;
%   = 'filename' for output file name of detailed information;
%   Default value = [];
%
% param.printFileName 
%   = 0 for no solution information; 
%   = 1 for solution informatin;
%   = 'filename' for output file name;
%   Default = 1.
%
% param.printLevel = [a,b], 
%   where a is for display out put, and b is for the file output. 
%   a = 0 for no information on the computational result. 
%       1 for some informtion without an optimal solution. 
%       2 for detailed solution information. 
%   b = 0 for no information on the computational result. 
%       1 for some informtion without an optimal solution. 
%       2 for detailed solution information. 
%   Default = [2, 2].
%
%%%%%%%%%%%
% 5. Parameters to use Symbolic Math Toolbox, 
%    Optimization Toolbox and C++ subroutines
%
% param.symbolicMath
%   = 1 to use Symbolic MathToolbox;
%   = 0 otherwise;
%   Default value 
%       = 1 if Symbolic Math Toolbox is available;
%       = 0 otherwise; 
% 
% param.POPsolver
%   To obtain more accurate value and solution, we can use
%   functions in Optimization Toolbox
%   = 'active-set' 
%   = 'trust-region-reflective'
%   = 'interior-point'
%   = 'lsqnonlin'           
%   Default value
%       = 'active-set'
%       = ''           if Optimization Toolbox is not available;  
%
% param.mex
%   = 1 to use C++ subrouties;
%   = 0 otherwise;
%   Default value
%       = 1 if mexconv1.cpp and mexconv2.cpp have been already compiled. 
%       = 0 otherwise;
%%%%%%%%%%%
% 6. Parameters of error bounds
%
% param.errorBdIdx
%   Default value 
%      []
% param.fValueUbd 
%   Default value
%      []
%   (a) If param.errorBdIdx = 'a' or 'A' then sparsePOP outputs xCenter and
%       zeta such that
%           ||x - xCenter|| <= sqrt(zeta)
%       for every feasible solution of the POP with an objective value,
%       where the objective falue is either the one given by
%       param.fValueUbd, the one computed by the param.POPsolver, or the one
%       computed by the param.SDPsolver.
%   (b) If param.errorBdIdx = indexSet then then sparsePOP outputs xCenter
%       and zeta such that
%           ||x(indexSet) - xCenter(indexSet)|| <= sqrt(zeta)
%       for every feasible solution x of the POP with an objective value,
%       where the objective falue is either the one given by
%       param.fValueUbd, the one computed by the param.POPsolver, or the one
%       computed by the param.SDPsolver.  For example,
%       param.errorBdIdx = 1, param.errorBdIdx = [1,3,5],
%       param.errorBdIdx = [2:10].
%   (c) The user can specify multiple index sets. For example,
%       param.errorBdIdx{1} = 'a';
%       param.errorBdIdx{2} = 1;
%       param.errorBdIdx{3} = [2,3];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP 
% Copyright (C) 2007-2011 SparsePOP Project
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

%%%%%%%%%%%
% 1. Parameters that control the basic relaxation scheme.
if ~isfield(param,'relaxOrder')
    param.relaxOrder = 1; 
%   param.relaxOrder will be updated to
%       max{the minimum relaxation order ?½omega_{?½max}, param.relaxOrder}.
end

if ~isfield(param,'sparseSW')
    param.sparseSW = 1; 
%   Default:
%   param.sparseSW = 1; 
end

if ~isfield(param,'multiCliquesFactor')
    param.multiCliquesFactor = 1; 
%   Default:
%   param.multiCliquesFactor = 1; 
end

%%%%%%%%%%
% 2. Switch to handle numerical difficulties. 
%
if ~isfield(param,'scalingSW') 
	param.scalingSW = 1;
%   Default:
%	param.scalingSW = 1; 
end

if ~isfield(param,'boundSW') 
	param.boundSW = 2; 
%   Default:
%	param.boundSW = 2; 
end

if ~isfield(param,'eqTolerance') 
	param.eqTolerance = 0.0; 
end

if ~isfield(param,'perturbation')
    param.perturbation = 0.0; 
%   Default
%   param.perturbation = 0.0; 
end

if ~isfield(param,'reduceMomentMatSW') 
	param.reduceMomentMatSW = 1;
%   Default:
%	param.reduceMomentMatSW = 1; 
end

if ~isfield(param,'complementaritySW') 
	param.complementaritySW = 0;
%   Default:
%	param.complementaritySW = 0;
end

if ~isfield(param,'SquareOneSW') 
	param.SquareOneSW = 1;
%   Default:
%	param.SquareOneSW = 1;
end

if ~isfield(param,'binarySW') 
	param.binarySW = 1;
%   Default:
%	param.binarySW = 1;
end

if ~isfield(param,'reduceAMatSW') 
	param.reduceAMatSW= 1;
%   Default:
%	param.reduceAMatSW = 1;
end

if ~isfield(param,'reduceEqualitiesSW') 
	param.reduceEqualitiesSW = 0;
%   Default:
%	param.reduceEqualitiesSW = 0;
end

if ~isfield(param,'elimFrSW') 
	param.elimFrSW= 0;
%   Default:
%	param.elimFrSW = 0;
end

%%%%%%%%%%
% 3. Parameters for SDP solvers
%

if ~isfield(param,'SDPsolver')% || isempty(param.SDPsolver)
    param.SDPsolver = 'sedumi';
%   Default:
%   param.SDPsolver = 'sedumi';
%   Other Choices 
%       'sdpa'
%       'sdpt3'
%       'sdpNAL' or 'sdpnal'
%       'sdpnalplus'
%       'csdp'
end
    
if ~isfield(param,'SDPsolverSW') 
     param.SDPsolverSW = 1; 
%   Default:
%   param.SDPsolverSW = 1; 
elseif param.SDPsolverSW==1
    if isempty(param.SDPsolver)
        param.SDPsolverSW = 0;
    elseif isnumeric(param.SDPsolver) && param.SDPsolver == 0
        param.SDPsolverSW = 0;
    end    
end

% Check whether param.SDPsolver is available or not.
if strcmp(param.SDPsolver,'sedumi')
    if exist('sedumi.m','file') ~= 2
        error('## Should add ''sedumi.m'' in your MATLAB path.');
    end
elseif strcmp(param.SDPsolver,'sdpa')
    if exist('sedumiwrap.m','file') ~= 2
        error('## Should add ''sedumiwrap.m'' in your MATLAB path.');
    end
elseif strcmp(param.SDPsolver,'sdpt3')
    if exist('sqlp.m','file') ~= 2
        error('## Should add ''sqlp.m'' in your MATLAB path.');
    end
elseif strcmp(param.SDPsolver,'sdpNAL') == 1 || strcmp(param.SDPsolver, 'sdpnal') == 1
    if exist('sdpNAL.m','file') ~= 2 || exist('sdpnal.m','file') ~= 2
        error('## Should add ''sdpnal.m'' in your MATLAB path.');
    end
elseif strcmp(param.SDPsolver,'sdpNALPlus') == 1 || strcmp(param.SDPsolver, 'sdpnalplus') == 1
    if exist('sdpnalplus.m','file') ~= 2
        error('## Should add ''sdpnalplus.m'' in your MATLAB path.');
    end
elseif strcmp(param.SDPsolver,'csdp') == 1
    if exist('csdp.m','file') ~= 2
        error('## Should add ''csdp.m'' in your MATLAB path.');
    else
        [status, msg] = system('which csdp');
        if status ~= 0
            error('## Should add ''csdp'' in your path.');
        end
    end
elseif param.SDPsolverSW==1
    error('## Should set ''param.SDPsolver'' to be your sdp solver.');
else
    % SDPsolver is not set, but we do not use SDP solver because SDPsolverSW == 0.
    % Then sparsePOP only generates an SDP pboelm.
end

if ~isfield(param,'SDPsolverEpsilon')
    if strcmp(param.SDPsolver,'sedumi')
        param.SDPsolverEpsilon = 1.0e-9;
        param.SeDuMiEpsilon = param.SDPsolverEpsilon;
        %   Default:
        %   param.SDPsolverEpsilon = 1.0e-9;
    elseif strcmp(param.SDPsolver,'sdpa')
        param.SDPsolverEpsilon = 1.0e-7;
        %   Default:
        %   param.SDPsolverEpsilon = 1.0e-7;
    elseif strcmp(param.SDPsolver,'sdpt3')
        param.SDPsolverEpsilon = 1.0e-8;
        %   Default:
        %   param.SDPsolverEpsilon = 1.0e-8;
    elseif strcmp(param.SDPsolver,'sdpNAL') == 1 || strcmp(param.SDPsolver,'sdpnal') == 1 || strcmp(param.SDPsolver, 'sdpnalplus') == 1 
        param.SDPsolverEpsilon = 1.0e-3;
        %   Default:
        %   param.SDPsolverEpsilon = 1.0e-3;
    elseif strcmp(param.SDPsolver,'csdp') == 1
        param.SDPsolverEpsilon = 1.0e-7;
        %   Default:
        %   param.SDPsolverEpsilon = 1.0e-7;
    end
end

if ~isfield(param,'SDPsolverOutFile')
	param.SDPsolverOutFile = 0;
	%   Default:
	%   param.SDPsolverOutFile = 0;
end

if ~isfield(param,'sdpaDataFile') 
	param.sdpaDataFile = '';
	%   Default:
	%	param.sdpaDataFile = '';
end

%%%%%%%%%%%
% 4. Parameters for printing numerical results. 

if ~isfield(param,'detailedInfFile')
	param.detailedInfFile = '';
	%   Default:
	%	param.detailedInfFile = '';
end

if ~isfield(param,'printFileName')
    param.printFileName = 1; 
	%   Default:
	%   param.printFileName = 1; 
end

if ~isfield(param,'printLevel')
    param.printLevel = [2, 2]; 
    if param.printFileName == 0
       param.printLevel(2) = 0; 
    elseif param.printFileName == 1
       param.printLevel(2) = 0; 
    end
	%   Default:
	%   param.printLevel = [2, 2]; 
end
    
%%%%%%%%%%%
% 5. Parameters to use Symbolic Math Toolbox and C++ subrouties

if ~isfield(param,'symbolicMath')
  %   Default:
  if exist('OCTAVE_VERSION','builtin')
    pkg_id = 'symbolic';
    pkg_name = pkg_id;
  else
    pkg_id = 'Symbolic';
    pkg_name = 'Symbolic Math Toolbox';
  endif
  
  A = ver(pkg_id);
  if ~isempty(A)
	x = strfind(A.Name, pkg_name);
	if ~isempty(x)
	  param.symbolicMath = 1;
	else
	  param.symbolicMath = 0;
	end
  else
	param.symbolicMath = 0;
  end
end

if ~isfield(param,'POPsolver')
	%   Default:
	A = ver('optim');
	if ~isempty(A)
		x = strfind(A.Name, 'Optimization Toolbox');
		if ~isempty(x)
            % Default: 
			param.POPsolver = [];
            % Other choices
            % 'active-set', 'trust-region-reflective', 
            % 'interior-point' and 'lsqnonlin'.
		else
			param.POPsolver = [];
		end
	else
			param.POPsolver = [];
	end
end

if ~isfield(param,'mex')
	if exist('mexconv1', 'file') == 3 && exist('mexconv2', 'file') == 3 
		% Default: 
    		param.mex = 1;
	else
		param.mex = 0;
	end
elseif param.mex == 1
	if exist('mexconv1', 'file') ~= 3 || exist('mexconv2', 'file') ~= 3
    	fprintf('## mexconv1 or mexconv2 compiled by comileSparsePOP.m can not be found. \n');
    	fprintf('## SparsePOP sets param.mex = 0. \n');
		param.mex = 0;
	end
end

%%%%%%%%%%%
% 6. Parameters of error bounds

if ~isfield(param,'errorBdIdx')
    param.errorBdIdx = '';
%elseif ~isempty(param.errorBdIdx)
%	param.binarySW = 0;
%	param.SquareOneSW = 0;
end

if ~isfield(param,'fValueUbd') || isempty(param.fValueUbd)
    param.fValueUbd = '';
elseif isempty(param.errorBdIdx)
    param.fValueUbd = '';
    error('!!! param.fValueUbd is specified but param.errorBdIdx is not !!!');
end
if isfield(param, 'errorBdIdx') && (iscell(param.errorBdIdx) || ~strcmp(param.errorBdIdx, '') || ~isempty(param.errorBdIdx))
	if strcmp(param.SDPsolver, 'csdp') || strcmp(param.SDPsolver, 'sdpNAL') || strcmp(param.SDPsolver, 'sdpnal')
		error('## You cannot use csdp and sdpNAL for computing error bounds. ##');
	end
end

%
% 2014-07-16 H.Waki
% The following parameter works for only MATLAB
% 
if param.reduceMomentMatSW == 2
	param.mex = 0;
end
if param.sparseSW == 2 || param.sparseSW == 3
	param.mex=0;
end
if param.reduceEqualitiesSW ~= 0 || param.elimFrSW ~= 0 
	param.mex = 0;
end

%
% 2011-11-20 H.Waki
% paramter for developers of SparsePOP
if ~isfield(param, 'aggressiveSW')
	param.aggressiveSW = 0;
end
return
if param.reduceEqualitiesSW ~= 0 || param.elimFrSW ~= 0 
	param.mex = 0;
end
%
% 2011-11-20 H.Waki
% paramter for developers of SparsePOP
if ~isfield(param, 'aggressiveSW')
	param.aggressiveSW = 0;
end
return
