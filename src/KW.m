function [K,W]=KW(A,B,C,D,algo_str)
% [K,W]=KW(A,B,C,D,algo_str="dlyap|recursive|levinson")

% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Sanity checks
if ((nargin ~= 4) && (nargin ~= 5))
  print_usage("[K,W]=KW(A,B,C,D,algo_str=\"dlyap|recursive|levinson\")");
endif
if rows(A) ~= columns(A)
  error("Expect A square");
endif
if columns(B) ~= 1 || rows(A) ~= rows(B) 
  error("Expect B rows(A)x1 column vector");
endif
if columns(C) ~= columns(A) || rows(C) ~= 1 
  error("Expect C 1xcolumns(A) row vector");
endif
if columns(D) ~= 1 || rows(D) ~= 1 
  error("Expect D a scalar");
endif

% Decide algorithm type
if nargin == 5
  algo_str=algo_str(1:5);
  if algo_str == "dlyap"
    if ~(exist("dlyap","builtin") || exist("dlyap","file"))
      error("dlyap not found!");
    endif
    algo_type=1;
  elseif algo_str == "levin"
    algo_type=2;
  elseif algo_str == "recur"
    algo_type=3;
  else
    error("Unknown algorithm type!");
  endif
elseif nargin == 4
  if exist("dlyap","builtin") || exist("dlyap","file")
    algo_type = 1;
  else
    algo_type = 2;
  endif
endif

if algo_type == 1
  K=dlyap(A,B*B');
  W=dlyap(A',C'*C);
elseif algo_type == 2
  K=dlyap_levinson(A,B);
  W=dlyap_levinson(A',C');
elseif algo_type == 3 
  % Find recursively. Fails for high filter order
  tol=10*eps;
  K=dlyap_recursive(A,B,tol);
  W=dlyap_recursive(A',C',tol);
endif

endfunction
