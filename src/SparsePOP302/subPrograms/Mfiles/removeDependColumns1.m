function [indepColIdx, feasibilitySW] = removeDependColumns1(DMat,bVect)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%   DMat:   an mDim \times nDim matrix
%   bVect:  a 1 \times nDim vector if nargin == 2
%           check whether y'*DMat = bVect is feasible
% Output
%   indepColIdx:    the indices of columns of DMat which forms a
%                   a basis of the column space of DMat.
%   fiesibilitySW   =  0    if nargin = 0,
%                   =  1    if y'*DMat = bVect has a solution
%                               or rank(DMat;bVect) \neq rank(DMat),
%                   = -1    if y'*DMat = bVect does not have any solutions
%                               or rank(DMat;bVect) = rank(DMat).
%
% All linearly dependent columns are removed from DMat by applying
% the LU factorization repeatedly
%
% Masakazu Kojima, 09/01/2007
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debugSW = 0;

% Regard any number to be zero if its absolute value < epsilon
epsilon = 1.0e-7;

% The size of DMat
[mDim,nDim] = size(DMat);
% Check whether y'*DMat = bVect needs to be solved
if nargin == 1
    bVect = sparse(1,nDim);
    feasibilitySW = 0;
else
    % Initialize feasibilitySW = 1 (feasible)
    feasibilitySW = 1;
end

%
% 2011-07-29 H.Waki
% Presolve for detecting linearly independency
% -->
debugSW1 = 1;
if debugSW1 == 1
	tmpDMat = spones(DMat);
	tmpDMatRowSum = sum(tmpDMat, 2);
	[OneRow, OneCol] = find(tmpDMatRowSum == 1);
	tmpDMat = tmpDMat(OneRow,:);
	tmpDMatColSum = sum(tmpDMat, 1);
	[OneRow, OneCol] = find(tmpDMatColSum > 0);
	indepColIdx0 = OneCol;
	checkIdx = setdiff(1:nDim, OneCol);
	nDim = length(checkIdx);
	DMat = DMat(:, checkIdx);
	bVect = bVect(:, checkIdx);
	%size(DMat)
	%length(checkIdx)
	%length(indepColIdx0)
end
% <--

% Sort the columns of DMat according to their number of nonzeros
colPermIdx = colperm(DMat);
% colPermIdx = [1:nDim];
% Initialization for the major iteration --->
U = DMat(:,colPermIdx);
vVect = bVect(:,colPermIdx);
indepColIdx = [];
toBecheckedColumns = colPermIdx;
%->
if debugSW == 1
    iteration = 0;
    fprintf('## Iteration = %d: Input matrix DMat\n',iteration);
    full(DMat)
    if feasibilitySW == 1
        fprintf('bVect = \n');
        full(bVect)
    end
    fprintf('Sort the columns of DMat according to their number of nonzeros\n');
    fprintf('toBecheckedColumns = colPermIdx = colperm(DMat)\n');
    %toBecheckedColumns;
    fprintf('U = \n');
    full(U)
    if feasibilitySW == 1
        fprintf('vVect\n');
        full(vVect)
    end
end
%<-
controlSW = 1;
% <--- Initialization for the major iteration
while controlSW == 1
    %->
    if debugSW == 1
        iteration = iteration + 1;
        fprintf('## Iteration = %d: U = \n',iteration);
        full(U)
        if feasibilitySW == 1
            fprintf('vVect\n');
            full(vVect)
        end
    end
    % Eliminate zero rows and zero collumns from U if they exist --->
    absU = abs(U);
    %    full(absU)
    sumAbsRowsU = sum(absU,1);
    %    full(sumAbsRowsU);
    nzColumns = find(sumAbsRowsU > epsilon);
    sumAbsColumnsU = sum(absU,2)';
    %    full(sumAbsColumnsU);
    nzRows = find(sumAbsColumnsU > epsilon);
    % <-- Eliminate zero rows and zero collumns from U if they exist
    % if U is a zero matrix then stop the iteration --->
    if isempty(nzColumns) || isempty(nzRows)
        controlSW = 0;
        if feasibilitySW == 1
            if ~isempty(find(abs(vVect) >= epsilon))
                feasibilitySW = -1;
    		indepColIdx = nzColumns;
                controlSW = 0;
            end
        end
        % <--- if U is a zero matrix then stop the iteration
        % Otherwise pick up independent columns by applying the LU
        % factorization after reducing U --->
    else
        % Reduce U by eliminating the zero rows and zero collumns --->
        if feasibilitySW == 1
            zeroColumns = find(sumAbsRowsU <= epsilon);
            if ~isempty(find(abs(vVect(1,zeroColumns)) >= epsilon))
                feasibilitySW = -1;
    		indepColIdx = nzColumns;
                %indepColIdx = 1:nDim;
                controlSW = 0;
            end
        end
        if controlSW == 1
            U = U(nzRows,nzColumns);
            vVect = vVect(1,nzColumns);
            %->
            if debugSW == 1
                fprintf('Reduce U by eliminating the zero rows and zero collumns\n');
                full(U)
                if feasibilitySW == 1
                    fprintf('vVect\n');
                    full(vVect)
                end
            end
            %<-
            % Update the candidate column indices of linearly independent
            % columns
            toBecheckedColumns = toBecheckedColumns(nzColumns);
            % Apply the LU factorization
			%
			% 2012-01-11 H.Waki
			% lu(mat, 'vector') is not implemented in 7.3 or earlier. 
			if exist('verLessThan') ~= 2
				error('Download verLessThan.m from http://www.mathworks.com/support/solutions/en/data/1-38LI61/?solution=1-38LI61');
			end
			if verLessThan('matlab', '7.3')
				mDimU = size(U, 1);
				[L, U, P] = lu(U);
				idx = (1:mDimU)';
				PVect = P*idx;
			else
				[L,U,PVect] = lu(U,'vector');
			end
            %->
            if debugSW == 1
                fprintf('Apply the LU factorization to update the candidate column indices of linearly independent columns; U = \n');
                full(U)
            end
            %<-
            [rowSize,colSize] = size(U);
            % Check whether zero exists along the diagonals --->
            diagAbsU = abs(diag(U))';
            zeroDiagIdx = find(diagAbsU < epsilon);
            % <--- Check whether zero exists along the diagonals
            % If no zeros in the diagonals, the first length(diagAbsU) columns
            % of U are linearly independent --->
            if isempty(zeroDiagIdx)
                indepColIdx = [indepColIdx, toBecheckedColumns(1:length(diagAbsU))];
                %->
                if debugSW == 1
                    fprintf('No zeros in the diagonals. Update the set of linearly independent columns of DMat\n');
                    disp(indepColIdx);
                end
                %<-
                controlSW = 0;
                % <--- If no zeros in the diagonal, the first length(diagAbsU) columns
                % of U are linearly independent
                % Otherwise, update indepColIdx and U --->
            else
                noOfl_indepColumns = zeroDiagIdx(1)-1;
                %                 if feasibilitySW == 1
                %                     vVect = vVect(1,noOfl_indepColumns+1:colSize) - vVect(1,1:noOfl_indepColumns)...
                %                     *(U(1:noOfl_indepColumns,1:noOfl_indepColumns)\U(1:noOfl_indepColumns,noOfl_indepColumns+1:colSize));
                %                 end
                indepColIdx = [indepColIdx,toBecheckedColumns(1:noOfl_indepColumns)];
                toBecheckedColumns = toBecheckedColumns(noOfl_indepColumns+1:colSize);
                % Update vVect
                if feasibilitySW == 1
                    vVect = vVect(1,noOfl_indepColumns+1:colSize) - vVect(1,1:noOfl_indepColumns)...
                        *(U(1:noOfl_indepColumns,1:noOfl_indepColumns)\U(1:noOfl_indepColumns,noOfl_indepColumns+1:colSize));
                end
                % Update U
                U = U((noOfl_indepColumns+1):rowSize,(noOfl_indepColumns+1:colSize));
                
                %->
                if debugSW == 1
                    fprintf('The first zero of the diagonals at \n');
                    disp(noOfl_indepColumns + 1);
                    fprintf('Update the set of linearly independent columns of DMat\n')
                    disp(indepColIdx);
                    fprintf('Update U\n');
                    full(U)
                    if feasibilitySW == 1
                        fprintf('Update vVect\n');
                        full(vVect)
                    end
                end
                %<-
                
                % <--- Otherwise, update indepColIdx and U
            end
        end
    end
    % <--- Otherwise pick up independent columns by applying the LU
    % factorization after reducing U
    %    XXXXX
end
%
% 2011-07-29 H.Waki
% Presolve for detecting linearly independency
% -->
if debugSW1 == 1
	%length(indepColIdx)
	%length(checkIdx)
	indepColIdx = checkIdx(indepColIdx);
	indepColIdx = [indepColIdx0, indepColIdx];
end
% <--
[indepColIdx, temp] = sort(indepColIdx);

%->
if debugSW == 1
    if feasibilitySW >= 0
        fprintf('Sort the indices of linearly independent columns\n');
        disp(indepColIdx);
    end
    disp(feasibilitySW);
end
%<-

return
