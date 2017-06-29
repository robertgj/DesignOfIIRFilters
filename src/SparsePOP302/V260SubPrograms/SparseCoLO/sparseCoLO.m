function [x,y,infoCoLO,cliqueDomain,cliqueRange,LOP] = sparseCoLO(A,b,c,K,J,parCoLO); 
% ======================================================================
%
%   a conversion method for SPARSE COnic-form Linear Optimization problems
% 
%   Version 1.11. September 2009 
% 
%   K. Fujisawa, S. Kim, M. Kojima, Y. Okamoto and M. Yamashita
%
% ======================================================================
% Acknowledgment
% 
% The authors of this software package are grateful to Dr. Hayato Waki
% who provided some subprograms this package. 
% 
% ======================================================================
% Input 
% ======================================================================
%   LOP (Conic form Linear Optimization Problem)
%       minimize   c^T x 
%       subject to A x - b \in J,  x \in K
%   Here 
%       x : a column vector variable. 
%       K.f --- the number of free variables, e.g., K.f = [], 0 or 10
%       K.l --- the number of LP variables,e.g., K.l = [], 0 or 12 
%       K.q --- the structure of SOCP variables, e.g., K.q = [], 3 or [3,5] 
%       K.s --- the structure of SDP variables, e.g., K.s = [], 4 or [2,4]
%       J.f --- the number of equality constraints, e.g., J.f = [], 0 or 6
%       J.l --- the number of LP inequality constraints, e.g., J.l = [], 0 or 7
%       J.q --- the structure of SOCP constraints, e.g., J.q = [], 8 or [2,3] 
%       J.s --- the structure of SDP constraints, e.g., J.s = [], 2 or [3,6]
%
%   <parameters>
%
%   parCoLO.SDPsolver 
%       = [] --- do not apply any method
%       = 'sdpa'   --- sdpa
%       = 'sedumi' --- sedumi
%       = 'sdpt3'  --- sdpt3
%       = ....
%
%   parCoLO.sdpaOPTION   --- OPTION parameters for sdpa
%   parCoLO.sedumipar    --- parameters for sedumi
%   parCoLO.sdpt3OPTIONS --- OPTION parameters for sdpt3
%
%   parCoLO.domain
%       = 0 --- exploiting no sparsity in the domain space
%       = 1 --- applying dConvCliqueTree 
%       = 2 --- applying dConvBasisRep
%   This switch is irrevant if no psd matrix variable is involved, 
%   i.e, if K does not have the field 's'. 
%
%   parCoLO.range
%       = 0 --- exploiting no sparsity in the range space 
%       = 1 --- applying rConvCliqueTree 
%       = 2 --- applying rConvMatDecomp
%   This switch is irrevant if no matrix inequality constraint is involved,
%   i.e, if J does not have the field 's'. 
%
%   parCoLO.EQorLMI
%       = 1 --- applying CoLOtoEQform to obtain an equality standard from, 
%               which can be solved by many existing software packages. 
%       = 2 --- applying CoLOtoLMIform to obtain an LMI standard form, 
%               which can be solved by many existing software packages. 
%
%   One recommended choice of parameters: 
%       parCoLO.domain = 1;  % dConvCliqueTree  ---> equalities 
%       parCoLO.range = 2;   % rConvMatDecomp   ---> equalities 
%       parCoLO.EQorLMI = 1; % CoLOtoEQform     ---> equality standard form
%   The other recommended choice of parameters: 
%       parCoLO.domain = 2;  % dConvBasisRep    ---> matrix inequalities 
%       parCoLO.range = 1;   % rConvCliqueTree  ---> matrix inequalities 
%       parCoLO.EQorLMI = 2; % CoLOtoLMIform    ---> LMI standard form
%
% ======================================================================
% Output 
%
%   When parCoLO.SDPsolver ~= []: 
%       x --- a primal approximate solution
%       y --- a dual approximate solution 
%       infoCoLO
%           infoCoLO.SDPsolver  --- information from sdpa, sedumi orsdpt3 execution
%           infoCoLO.CPUdomain  --- cpu time in second for the d-space conversion used 
%           infoCoLO.CPUrange   --- cpu time in second for the r-space conversion used 
%           infoCoLO.CPUEQorLMI --- cpu time in second for the conversion
%                                   into an equality form or an LMI form
%           infoCoLO.CPUtotal   --- total cpu time
%       cliqueDomain    --- clique information for the d-space conversion; 
%                           if this set is nonempty, only components of sdp  
%                           variables in x with indices contained in some
%                           cliques are output, others are set zero. 
%       cliqueRange     --- clique information for the r-space conversion
%       LOP --- LOP.A, LOP.b, LOP.c, LOP.K, LOP.J to
%               described the final conic form linear optimization problem. 
% 
%   When parCoLO.SDPsolver == [], the given problem is not solved, but the
%   conversion specified by parCoLO.domain, parCoLO.range and parCoLO.EQorLMI 
%   is done. In this case
%       x = [];
%       y = seqLOPs --- the sequence of LOPs converted
%       infoCoLO
%           infoCoLO.CPUdomain  --- cpu time in second for the d-space conversion used 
%           infoCoLO.CPUrange   --- cpu time in second for the r-space conversion used 
%           infoCoLO.CPUEQorLMI --- cpu time in second for the conversion
%                                   into an equality form or an LMI form
%           infoCoLO.CPUtotal   --- total cpu time
%       cliqueDomain    --- clique information for the d-space conversion; 
%                           if this set is nonempty, only components of sdp  
%                           variables in x with indices contained in some
%                           cliques are output, others are set zero. 
%       cliqueRange     --- clique information for the r-space conversion
%       LOP --- LOP.A, LOP.b, LOP.c, LOP.K, LOP.J to
%               described the final conic form linear optimization problem. 
% ======================================================================

% <Sample excecution>
% >> [A,b,c,K,J] = maxCutSDP(1,50,4,2009); 
% >> parCoLO.domain = 1;
% >> parCoLO.range = 0;
% >> parCoLO.EQorLMI = 1;
% >> parCoLO.SDPsolver = 'sedumi'; 
% >> [x,y,infoCoLO,cliqueDomain,cliqueRange] = sparseCoLO(A,b,c,K,J,parCoLO); 
% 
% SparseCoLO 1.10
% by K.Fujisawa, S.Kim, M.Kojima, Y.Okamoto and M. Yamashita,
% September 2009
% 
% parCoLO.domain = 1; parCoLO.range = 0; parCoLO.EQorLMI = 1
% Apply the d-space conversion method using clique trees.
% LOP to be converted into equality standard form is already equality standard form.
% SeDuMi 1.1R3 by AdvOL, 2006 and Jos F. Sturm, 1998-2003.
% Alg = 2: xz-corrector, Adaptive Step-Differentiation, theta = 0.250, beta = 0.500
% eqs m = 87, order n = 64, dim = 1122, blocks = 5
% nnz(A) = 124 + 0, nnz(ADA) = 3821, nnz(L) = 1954
%  it :     b*y       gap    delta  rate   t/tP*  t/tD*   feas cg cg  prec
%   0 :            2.25E-01 0.000
%   1 :  -3.14E+01 6.75E-02 0.000 0.3000 0.9000 0.9000  -0.17  1  1  1.2E+00
%   2 :  -2.93E+01 2.45E-02 0.000 0.3632 0.9000 0.9000   1.65  1  1  3.5E-01
%   3 :  -3.12E+01 5.91E-03 0.000 0.2410 0.9000 0.9000   1.08  1  1  8.3E-02
%   4 :  -3.17E+01 1.33E-03 0.000 0.2252 0.9000 0.9000   1.01  1  1  1.9E-02
%   5 :  -3.19E+01 2.79E-04 0.000 0.2094 0.9000 0.9000   1.00  1  1  3.9E-03
%   6 :  -3.19E+01 1.53E-05 0.000 0.0550 0.9000 0.8584   1.00  1  1  8.7E-04
%   7 :  -3.19E+01 8.26E-07 0.000 0.0538 0.9900 0.9900   1.00  1  1  4.6E-05
%   8 :  -3.19E+01 8.83E-08 0.068 0.1069 0.9450 0.9199   1.00  1  1  5.0E-06
%   9 :  -3.19E+01 1.76E-08 0.000 0.1992 0.9000 0.9000   1.00  1  1  9.9E-07
%  10 :  -3.19E+01 1.19E-09 0.298 0.0675 0.9900 0.9900   1.00  1  1  6.7E-08
%  11 :  -3.19E+01 2.27E-10 0.000 0.1916 0.9006 0.9000   1.00 11 11  1.3E-08
%  12 :  -3.19E+01 4.31E-11 0.000 0.1899 0.9002 0.9000   1.00 16 21  2.4E-09
%  13 :  -3.19E+01 8.74E-12 0.000 0.2026 0.9000 0.9000   1.00 22 26  4.8E-10
% 
% iter seconds digits       c*x               b*y
%  13      1.1   Inf -3.1901401910e+01 -3.1901401909e+01
% |Ax-b| =   8.7e-10, [Ay-c]_+ =   6.3E-10, |x|=  5.4e+00, |y|=  1.9e+01
% 
% Detailed timing (sec)
%    Pre          IPM          Post
% 3.100E-01    1.110E+00    1.600E-01    
% Max-norms: ||b||=2.500000e-01, ||c|| = 2,
% Cholesky |add|=0, |skip| = 7, ||L.L|| = 454.188.

% To compute the primal and objective values and feasibilities:  
% >> [primalObjValue, dualObjValue, primalfeasibility, dualfeasibility] ... 
%       = evaluateCoLO(x,y,A,b,c,K,J,cliqueDomain,cliqueRange)
% primalObjValue =  -31.9014
% dualObjValue =  -31.9014
% primalfeasibility =   1.2545e-10
% dualfeasibility =   2.0658e-10

% To retrieve all the elements of the primal SDP variable by applying
% the positive definite matrix completion: 
% [x] = psdCompletion(x,K,cliqueDomain);
% the minimum eigenvalue of a completed SDP variable matrix = +5.7e-13

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparseCoLO 
% Copyright (C) 2009 
% Masakazu Kojima Group
% Department of Mathematical and Computing Sciences
% Tokyo Institute of Technology
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

% fprintf('\nSparseCoLO 1.11\nby K.Fujisawa, S.Kim, M.Kojima, Y.Okamoto and M. Yamashita,\n');
% fprintf('September 2009\n\n');

debugSW0 = 1;

tStart = tic;

% initialization of output ---> 
x = [];
y = [];
infoCoLO = [];
cliqueDomain = [];
cliqueRange = [];
% <--- initialization of output

% Remove redudandant zero elements
if issparse(A)
    [itmp,jtmp,stmp] = find(A);
    [A1_tmp,A2_tmp] = size(A);
    A = sparse(itmp,jtmp,stmp,A1_tmp,A2_tmp);
    clear itmp;
    clear jtmp;
    clear stmp;
    clear A1_tmp;
    clear A2_tmp;
end
if issparse(c)
    [itmp,jtmp,stmp] = find(c);
    [c1_tmp,c2_tmp] = size(c);
    c = sparse(itmp,jtmp,stmp,c1_tmp,c2_tmp);
    clear itmp;
    clear jtmp;
    clear stmp;
    clear c1_tmp;
    clear c2_tmp;
end

% b and c are processed as column vectors in this program ---> 
if size(c,1) < size(c,2)
    c = c';
end
if size(b,1) < size(b,2)
    b = b';
end
% <--- b and c are processed as column vectors in this program

% infoCoLO.CPUtotal = cputime; 

% default parameters ---> 
if (nargin <= 4) || isempty(J)
    J.f = size(A,1);
end
if (nargin <= 5) || (isempty(parCoLO)) 
    [parameterSet] = defaultParCoLO(A,b,c,K,J); 
    parCoLO.domain = parameterSet(1,1); 
    parCoLO.range = parameterSet(1,2); 
    parCoLO.EQorLMI = parameterSet(1,3); 
    parCoLO.SDPsolver = 'sedumi'; 
else
    if ~isfield(parCoLO,'domain')
        if isfield(J,'f') && ~isempty(J.f) && J.f == size(A,1)
            % applying dConvCliqueTree 
            parCoLO.domain = 1;
        else 
            % applying dConvBasisRep
            parCoLO.domain = 2;
        end
    end
    if ~isfield(parCoLO,'range')
        if isfield(J,'f') && ~isempty(J.f) && J.f == size(A,1)
            parCoLO.range = 0;
        elseif parCoLO.domain == 1            
            % applying rConvMatDecomp
            parCoLO.range = 2;
        else
            % applying rConvCliqueTree 
            parCoLO.range = 1;
        end
    end
    if ~isfield(parCoLO,'EQorLMI')
        if isfield(J,'f') && ~isempty(J.f) && J.f == size(A,1)
            % an equality form LOP
            parCoLO.EQorLMI = 1;
        else 
            % an LMI form LOP
            parCoLO.EQorLMI = 2;
        end
    end            
    if ~isfield(parCoLO,'SDPsolver')
        parCoLO.SDPsolver = 'sedumi';
    end
%     fprintf('parCoLO.domain = %d; parCoLO.range = %d; parCoLO.EQorLMI = %d\n',... 
%         parCoLO.domain,parCoLO.range,parCoLO.EQorLMI); 
end
% <--- default parameters

if ~isfield(parCoLO,'sPatternVect')
    sPatternVect = [];
else
    sPatternVect = parCoLO.sPatternVect;
end

CoLOno = 1;
% information of the original LOP ---> 
seqLOPs{CoLOno}.J = J; 
seqLOPs{CoLOno}.K = K; 
seqLOPs{CoLOno}.clique = []; 
seqLOPs{CoLOno}.convMat = [];
seqLOPs{CoLOno}.domain = [];
seqLOPs{CoLOno}.range = [];
seqLOPs{CoLOno}.EQorLMI = [];
%%%%%
seqLOPs{CoLOno}.A = []; % A;
seqLOPs{CoLOno}.b = b;
seqLOPs{CoLOno}.c = c;
%%%%%
% <--- information of the original LOP

if (isfield(K,'s') && ~isempty(K.s)) 
    if parCoLO.domain == 0 
%        0
        LOP.A = A;
        LOP.b = b;
        LOP.c = c;
        LOP.K = K;
        LOP.J = J;
        infoCoLO.CPUdomain = 0; 
    elseif parCoLO.domain == 1
         % applying dConvCliqueTree 
        infoCoLO.CPUdomain = toc(tStart); % cputime;
        fprintf('Apply the d-space conversion method using clique trees.\n');
        [LOP,cliqueD] = dConvCliqueTree(A,sPatternVect,b,c,K,J);
        infoCoLO.CPUdomain = toc(tStart) - infoCoLO.CPUdomain;
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        seqLOPs{CoLOno} = setSeqLOPs(LOP,cliqueD,parCoLO.domain,[],[],[]);
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end        
        if ~isempty(cliqueD)
            [cliqueDomain] = reArrangeClique(cliqueD); 
        else
            cliqueDomain = [];
        end
        % <--- Information of the converted LOP
	elseif parCoLO.domain == 2
        % applying dConvBasisRep
        infoCoLO.CPUdomain = toc(tStart); 
        fprintf('Apply the d-space conversion method using basis representation.\n');
        [LOP,cliqueD] = dConvBasisRep(A,sPatternVect,b,c,K,J);
        infoCoLO.CPUdomain = toc(tStart) - infoCoLO.CPUdomain;
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        [mDim1,nDim1] = size(LOP.A); 
        rowPointer = 0;
        % primal free variables in seqLOPs{CoLOno-1}       
        if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && (LOP.J.f > 0)
            rowPointer = rowPointer+ LOP.J.f; 
        end
        % primal LP variables in seqLOPs{CoLOno-1}    
        if isfield(LOP.J,'l') && ~isempty(LOP.J.l) && (LOP.J.l > 0)
            rowPointer = rowPointer + LOP.J.l; 
        end
        % primal SOCP variables in seqLOPs{CoLOno-1}    
        if isfield(LOP.J,'q') && ~isempty(LOP.J.q)
            rowPointer = rowPointer + sum(LOP.J.q);
        end
        % primal SDP variables in seqLOPs{CoLOno-1}
        if isfield(seqLOPs{CoLOno-1}.J,'s') && ~isempty(seqLOPs{CoLOno-1}.J.s)
            rowPointer = rowPointer + sum(seqLOPs{CoLOno-1}.J.s .* seqLOPs{CoLOno-1}.J.s);
        end
        seqLOPs{CoLOno}  = setSeqLOPs(LOP,cliqueD,parCoLO.domain,[],[],LOP.A(rowPointer+1:mDim1,:));
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end
        if ~isempty(cliqueD)
           [cliqueDomain] = reArrangeClique(cliqueD); 
        else
            cliqueDomain = [];
        end
        %%%%%
        % <--- Information of the converted LOP
    end
else % ~isfield(K,'s') || isempty(K.s)
    LOP.A = A;
    LOP.b = b;
    LOP.c = c;
    LOP.K = K;
    LOP.J = J;
	infoCoLO.CPUdomain = 0; 
end
 
if isfield(LOP.J,'s') && ~isempty(LOP.J.s)
    if parCoLO.range == 0
%        0
        infoCoLO.CPUrange = 0; 
    elseif parCoLO.range == 1
        % applying rConvCliqueTree 
        infoCoLO.CPUrange = toc(tStart); 
        fprintf('Apply the r-space conversion method using clique trees.\n');
        [LOP,cliqueR] = rConvCliqueTree(LOP.A,sPatternVect,LOP.b,LOP.c,LOP.K,LOP.J);
        infoCoLO.CPUrange = toc(tStart) - infoCoLO.CPUrange;
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        seqLOPs{CoLOno}  = setSeqLOPs(LOP,cliqueR,[],parCoLO.range,[],[]);
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end
        if ~isempty(cliqueR)
            [cliqueRange] = reArrangeClique(cliqueR); 
        else
            cliqueRange = [];
        end
        % <--- Information of the converted LOP
    elseif parCoLO.range == 2
        % applying rConvMatDecomp
        [mDim0,nDim0] = size(LOP.A); 
        infoCoLO.CPUrange = toc(tStart); 
        fprintf('Apply the r-space conversion method using matrix decomposition.\n');
        [LOP,cliqueR] = rConvMatDecomp(LOP.A,sPatternVect,LOP.b,LOP.c,LOP.K,LOP.J);
        infoCoLO.CPUrange = toc(tStart) - infoCoLO.CPUrange;
        [mDim1,nDim1] = size(LOP.A); 
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        if isfield(seqLOPs{CoLOno-1}.J,'f') && ~isempty(seqLOPs{CoLOno-1}.J.f) && seqLOPs{CoLOno-1}.J.f > 0 
            rowPointer = seqLOPs{CoLOno-1}.J.f; 
        else
            rowPointer = 0;
        end
        seqLOPs{CoLOno}  = setSeqLOPs(LOP,cliqueR,[],parCoLO.range,[],-LOP.A(:,nDim0+1:nDim1));
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end
        if ~isempty(cliqueR)
            [cliqueRange] = reArrangeClique(cliqueR); 
        else
            cliqueRange = [];
        end
        %%%%%
        % <--- Information of the converted LOP 
    end
else
	infoCoLO.CPUrange = 0; 
end

if parCoLO.EQorLMI == 1
    % an Equality standard form 
    if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && LOP.J.f == size(LOP.A,1)
        fprintf('LOP to be converted into equality standard form is already equality standard form.\n');
        infoCoLO.CPUEQorLMI = 0; 
    else
        infoCoLO.CPUEQorLMI = toc(tStart);
        fprintf('Conversion into an equality standard form\n');
        [LOP] = CoLOtoEQform(LOP.A,LOP.b,LOP.c,LOP.K,LOP.J);
        infoCoLO.CPUEQorLMI = toc(tStart) - infoCoLO.CPUEQorLMI;
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        colPointer = 0; 
        % primal free variables in seqLOPs{CoLOno-1}       
        if isfield(LOP.K,'f') && ~isempty(LOP.K.f) && LOP.K.f > 0 
            colPointer = colPointer+ LOP.K.f; 
        end
        % primal LP variables in seqLOPs{CoLOno-1}
        if isfield(LOP.K,'l') && ~isempty(LOP.K.l) && LOP.K.l > 0 
            colPointer = colPointer + LOP.K.l; 
        end
        % primal SOCP variables in seqLOPs{CoLOno-1}
        if isfield(LOP.K,'q') && ~isempty(LOP.K.q)
            colPointer = colPointer + sum(LOP.K.q);
        end
        % primal SDP variables in seqLOPs{CoLOno-1}
        if isfield(seqLOPs{CoLOno-1}.K,'s') && ~isempty(seqLOPs{CoLOno-1}.K.s)
            colPointer = colPointer + sum(seqLOPs{CoLOno-1}.K.s .* seqLOPs{CoLOno-1}.K.s);
        end
        seqLOPs{CoLOno}  = setSeqLOPs(LOP,[],[],[],parCoLO.EQorLMI,-LOP.A(:,colPointer+1:size(LOP.A,2))');
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end
        % <--- Information of the converted LOP
    end    
elseif parCoLO.EQorLMI == 2
    % an LMI standard form
    if isfield(LOP.K,'f') && ~isempty(LOP.K.f) && LOP.K.f == size(LOP.A,2)
%        fprintf('LOP to be converted into LMI standard form is already LMI standard form.\n'); 
        infoCoLO.CPUEQorLMI = 0; 
    else
        infoCoLO.CPUEQorLMI = toc(tStart);
        fprintf('Conversion into an LMI standard form\n');
        [LOP] = CoLOtoLMIform(LOP.A,LOP.b,LOP.c,LOP.K,LOP.J);
        infoCoLO.CPUEQorLMI = toc(tStart) - infoCoLO.CPUEQorLMI;
        CoLOno = CoLOno + 1; 
        % Information of the converted LOP ---> 
        [mDim,nDim] = size(LOP.A); 
        rowPointer = 0;
        if isfield(LOP.J,'f') && ~isempty(LOP.J.f)
            rowPointer = rowPointer+ LOP.J.f; 
        end
        % primal LP variables in seqLOPs{CoLOno-1}
        if isfield(LOP.J,'l') && ~isempty(LOP.J.l)
            rowPointer = rowPointer + LOP.J.l; 
        end
        % primal SOCP variables in seqLOPs{CoLOno-1}
        if isfield(LOP.J,'q') && ~isempty(LOP.J.q)
            rowPointer = rowPointer + sum(LOP.J.q);
        end
        % primal SDP variables in seqLOPs{CoLOno-1}
        if isfield(seqLOPs{CoLOno-1}.J,'s') && ~isempty(seqLOPs{CoLOno-1}.J.s)
            rowPointer = rowPointer + sum(seqLOPs{CoLOno-1}.J.s .* seqLOPs{CoLOno-1}.J.s);
        end
        seqLOPs{CoLOno}  = setSeqLOPs(LOP,[],[],[],parCoLO.EQorLMI,LOP.A(rowPointer+1:mDim,:));
        if debugSW0 == 1
            %%%%%
            seqLOPs{CoLOno}.A = []; % LOP.A;
            seqLOPs{CoLOno}.b = LOP.b;
            seqLOPs{CoLOno}.c = LOP.c;
            %%%%%
        end
        % <--- Information of the converted LOP
    end
else
    infoCoLO.CPUEQorLMI = 0; 
end

infoCoLO.CPUsolver = 0;

if strcmp(parCoLO.SDPsolver,'sdpa')
%     LOP.b = sparse(LOP.b);
%     LOP.c = sparse(LOP.c); 
    if nargin <= 5 || (~isfield(parCoLO,'sdpaOPTION'))
        OPTION = param;
        % OPTION.print = []; % 'nodisplay'; 
    else
        OPTION = param(parCoLO.sdpaOPTION); 
        % OPTION0.print = 'nodisplay'; 
    end   
    if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && (LOP.J.f == ...
                                                   size(LOP.A,1))
        infoCoLO.CPUsolver = toc(tStart);
        [x,y,infoSDPA] = sedumiwrap(LOP.A,LOP.b,LOP.c,LOP.K,[],OPTION);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        infoCoLO.SDPsolver = infoSDPA;
    elseif isfield(LOP.K,'f') && ~isempty(LOP.K.f) && (LOP.K.f == size(LOP.A,2))
        % 'dual'
        infoCoLO.CPUsolver = toc(tStart);
        [y,x,infoSDPA] = sedumiwrap(-LOP.A',-LOP.c,-LOP.b,LOP.J,[],OPTION);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        % [y,x,infoSDPA] = sedumiwrap2(-LOP.A',-LOP.c,-LOP.b,LOP.J,[],OPTION);
        infoCoLO.SDPsolver = infoSDPA;
    else
        fprintf('LOP to be solved is neither equality nor LMI standard form.\n');
    end
elseif strcmp(parCoLO.SDPsolver,'sedumi')
%     LOP.b = sparse(LOP.b);
%     LOP.c = sparse(LOP.c); 
    if nargin <= 5 || (~isfield(parCoLO,'sedumipar'))
    	pars.free = 0;
    	pars.fid = 1;
    	pars.eps = 1.0e-9;
    else
        pars = parCoLO.sedumipar;
        if ~isfield(pars,'free')
            pars.free = 0;
        end
    end
%    switchWriteDats = 0
%	pars.scalingSW = 0;
%	pars.developmentSW = 3;
%	pars.matFile='genSDP.mat';
    if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && (LOP.J.f == ...
                                                   size(LOP.A,1))
        infoCoLO.CPUsolver = toc(tStart);
%	pars = saveMatFile(LOP.A, LOP.b, LOP.c, LOP.K, pars);
        [x,y,infoSeDuMi] = sedumi(LOP.A,LOP.b,LOP.c,LOP.K,pars);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        infoCoLO.SDPsolver = infoSeDuMi;
    elseif isfield(LOP.K,'f') && ~isempty(LOP.K.f) && (LOP.K.f == size(LOP.A,2))
        infoCoLO.CPUsolver = toc(tStart);
%	pars = saveMatFile(LOP.A', -LOP.c, -LOP.b, LOP.J, pars);
        [y,x,infoSeDuMi] = sedumi(-LOP.A',-LOP.c,-LOP.b,LOP.J,pars);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        infoCoLO.SDPsolver = infoSeDuMi;
    else
        fprintf('LOP to be solved is neither equality nor LMI standard form.\n');
    end
elseif strcmp(parCoLO.SDPsolver,'sdpt3')
    if nargin <= 5 || (~isfield(parCoLO,'sdpt3OPTIONS'))
        OPTIONS.printlevel = 3;
    else
        OPTIONS = parCoLO.sdpt3OPTIONS;
    end
    smallbkldim = 40; 
    if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && (LOP.J.f == size(LOP.A,1))
        [blkSdpt3,AtSdpt3,CSdpt3,bSdpt3,perm] = read_sedumi(LOP.A,LOP.b,LOP.c,LOP.K,smallbkldim);
        if OPTIONS.printlevel <= 1
            fprintf('\nSDPT3: Infeasible path-following algorithms');
        end
        infoCoLO.CPUsolver = toc(tStart);
        [objSdpt3,XSdpt3,y,ZSdpt3,runhist] = sqlp(blkSdpt3,AtSdpt3,CSdpt3,bSdpt3,OPTIONS);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        if OPTIONS.printlevel <= 1
            fprintf('\n');
        end
        infoCoLO.SDPsolver = runhist;
        clear objSdpt3 AtSdpt3 CSdpt3 bSdpt3 ZSdpt3        
        sdpPosVect = [0]; 
        sdppointer = 0; 
        xLength = 0; 
        if isfield(LOP.K,'f') && ~isempty(LOP.K.f) && LOP.K.f > 0
            xLength  = xLength + LOP.K.f; 
        end
        if isfield(LOP.K,'l') && ~isempty(LOP.K.l) && LOP.K.l > 0
            xLength  = xLength + LOP.K.l; 
        end
        if isfield(LOP.K,'q') && ~isempty(LOP.K.q) && LOP.K.q > 0
            xLength  = xLength + LOP.K.q; 
        end
        if isfield(LOP.K,'s') && ~isempty(LOP.K.s)
            for i=1:length(LOP.K.s)
                xLength  = xLength + LOP.K.s(i)*LOP.K.s(i); 
                sdppointer = sdppointer+LOP.K.s(i)*LOP.K.s(i); 
                sdpPosVect = [sdpPosVect, sdppointer]; 
            end
        end
        x = zeros(xLength,1);        
        noBlockSDPT3 = size(XSdpt3,1);
        nonSDPpointer = 0;
        for i=1:noBlockSDPT3
            sizeSDPT3 = size(XSdpt3{i},2);
            if sizeSDPT3 == 1
                x(nonSDPpointer+1:nonSDPpointer+size(XSdpt3{i},1),1) = XSdpt3{i};
                nonSDPpointer = nonSDPpointer+size(XSdpt3{i},1); 
            else
                lenPerm = length(perm{i}); 
                if lenPerm == 1
                    p = perm{i};
                    x(nonSDPpointer+sdpPosVect(p)+1:nonSDPpointer+sdpPosVect(p+1),1) = reshape(XSdpt3{i},sizeSDPT3*sizeSDPT3,1); 
                else
                    blockPointer = 0;
                    for j=1:lenPerm
                        p = perm{i}(j);
                        oneBlock = XSdpt3{i}(blockPointer+1:blockPointer+LOP.K.s(p),blockPointer+1:blockPointer+LOP.K.s(p));
                        x(nonSDPpointer+sdpPosVect(p)+1:nonSDPpointer+sdpPosVect(p+1),1) = reshape(oneBlock,LOP.K.s(p)*LOP.K.s(p),1); 
                        blockPointer = blockPointer + LOP.K.s(p); 
                    end
                end
            end
        end
        clear XSdpt3        
    elseif isfield(LOP.K,'f') && ~isempty(LOP.K.f) && (LOP.K.f == size(LOP.A,2))
        % 'dual'
        [blkSdpt3,AtSdpt3,CSdpt3,bSdpt3,perm] = read_sedumi(-LOP.A',-LOP.c,-LOP.b,LOP.J,smallbkldim);
        if OPTIONS.printlevel <= 1
            fprintf('\nSDPT3: Infeasible path-following algorithms');
        end
        infoCoLO.CPUsolver = toc(tStart);
        [objSdpt3,YSdpt3,x,ZSdpt3,runhist] = sqlp(blkSdpt3,AtSdpt3,CSdpt3,bSdpt3,OPTIONS);
        infoCoLO.CPUsolver = toc(tStart) - infoCoLO.CPUsolver;
        if OPTIONS.printlevel <= 1
            fprintf('\n');
        end
        infoCoLO.SDPsolver = runhist;
        clear objSdpt3 AtSdpt3 CSdpt3 bSdpt3 ZSdpt3       
        sdpPosVect = [0]; 
        sdppointer = 0; 
        yLength = 0; 
        if isfield(LOP.J,'f') && ~isempty(LOP.J.f) && LOP.J.f > 0
            yLength  = yLength + LOP.J.f; 
        end
        if isfield(LOP.J,'l') && ~isempty(LOP.J.l) && LOP.J.l > 0
            yLength  = yLength + LOP.J.l; 
        end
        if isfield(LOP.J,'q') && ~isempty(LOP.J.q) && LOP.J.q > 0
            yLength  = yLength + LOP.J.q; 
        end
        if isfield(LOP.J,'s') && ~isempty(LOP.J.s)
            for i=1:length(LOP.J.s)
                yLength  = yLength + LOP.J.s(i)*LOP.J.s(i); 
                sdppointer = sdppointer+LOP.J.s(i)*LOP.J.s(i); 
                sdpPosVect = [sdpPosVect, sdppointer]; 
            end
        end
        y = zeros(yLength,1);        
        noBlockSDPT3 = size(YSdpt3,1);
        nonSDPpointer = 0;
        for i=1:noBlockSDPT3
            sizeSDPT3 = size(YSdpt3{i},2);
            if sizeSDPT3 == 1
                y(nonSDPpointer+1:nonSDPpointer+size(YSdpt3{i},1),1) = YSdpt3{i};
                nonSDPpointer = nonSDPpointer+size(YSdpt3{i},1); 
            else
                lenPerm = length(perm{i}); 
                if lenPerm == 1
                    p = perm{i};
                    y(nonSDPpointer+sdpPosVect(p)+1:nonSDPpointer+sdpPosVect(p+1),1) = reshape(YSdpt3{i},sizeSDPT3*sizeSDPT3,1); 
                else
                    blockPointer = 0;
                    for j=1:lenPerm
                        p = perm{i}(j);
                        oneBlock = YSdpt3{i}(blockPointer+1:blockPointer+LOP.J.s(p),blockPointer+1:blockPointer+LOP.J.s(p));
                        y(nonSDPpointer+sdpPosVect(p)+1:nonSDPpointer+sdpPosVect(p+1),1) = reshape(oneBlock,LOP.J.s(p)*LOP.J.s(p),1); 
                        blockPointer = blockPointer + LOP.J.s(p); 
                    end
                end
            end
        end
        clear YSdpt3 
    else
        fprintf('LOP to be solved is neither equality nor LMI standard form.\n');
    end    
end

if strcmp(parCoLO.SDPsolver,'sedumi') || strcmp(parCoLO.SDPsolver,'sdpa') || strcmp(parCoLO.SDPsolver,'sdpt3')
    % Retrieve an optimal solution of the original problem --->
    CoLOno0 = CoLOno;
    while CoLOno > 1
        %        CoLOno
        if ~isempty(seqLOPs{CoLOno}.EQorLMI)
            if seqLOPs{CoLOno}.EQorLMI == 1
                [x,y] = EQformToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('equality form',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            elseif seqLOPs{CoLOno}.EQorLMI == 2
                [x,y] = LMIformToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('LMI form',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            end
        elseif ~isempty(seqLOPs{CoLOno}.range)
            if seqLOPs{CoLOno}.range == 1
                [x,y] = rConvClToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('range = 1',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            elseif seqLOPs{CoLOno}.range == 2
                %           'range = 2'
                [x,y] = rConvMatDToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('range = 2',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            end
        elseif ~isempty(seqLOPs{CoLOno}.domain)
            if seqLOPs{CoLOno}.domain == 1
                [x,y] = dConvClToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('domain = 1',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            elseif seqLOPs{CoLOno}.domain == 2
                %             CoLOno
                %             4
                [x,y] = dConvBrToCoLOsol(x,y,CoLOno,seqLOPs);
                if debugSW0 == 1
                    printObjFunction('domain = 2',seqLOPs{CoLOno-1}.b,seqLOPs{CoLOno-1}.c,x,y);
                end
            end
        end
        CoLOno = CoLOno - 1;
    end
    % <--- Retrieve an optimal solution of the original problem
else
    % LOP is not solved
    x = [];
    y = seqLOPs;  % --- the sequence of LOPs converted
end

infoCoLO.ElapsedTime =  toc(tStart); % cputime - infoCoLO.CPUtotal; 

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [clique] = reArrangeClique(clique0)
for i=1:size(clique0,2)
    clique{i}.NoC = clique0{i}.NoC;
    clique{i}.NoElem = clique0{i}.NoElem;
    clique{i}.maxC = clique0{i}.maxC;
    clique{i}.minC = clique0{i}.minC;
    if isfield( clique0{i},'NoCliqueInForest') 
        clique{i}.NoCliqueInForest = clique0{i}.NoCliqueInForest;
    end
    pointer = 0;
    for j=1:size(clique0{i}.Set,2)
        if ~isempty(clique0{i}.Set{j})
            pointer = pointer + 1;
            clique{i}.Set{pointer} = clique0{i}.Set{j};
        end
    end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [currentLOPinfo] = setSeqLOPs(LOP,clique,dd,rr,EQorLMI,convMat);
currentLOPinfo.J = LOP.J;
currentLOPinfo.K = LOP.K;
currentLOPinfo.clique = clique;
currentLOPinfo.convMat = convMat; % convMat;
currentLOPinfo.domain = dd;
currentLOPinfo.range = rr;
currentLOPinfo.EQorLMI = EQorLMI;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function printObjFunction(s,b,c,x,y)
fprintf('\n%s: c x = %+15.8e, b y = %+15.8e\n\n',s,full(c'*x),full(b'*y));
return
