function [K,W]=KW(dummy1,dummy2,C,D,algo_str)
% [K,W]=KW(A,B,C,D,algo_str="dlyap|recursive|levinson")
% [K,W]=KW(ABCD,algo_str="dlyap|recursive|levinson")

% Copyright (C) 2017-2026 Robert G. Jenssen
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
if ((nargin ~= 1) && (nargin ~= 2) && (nargin ~= 4) && (nargin ~= 5))
  print_usage(["[K,W]=KW(A,B,C,D,algo_str=\"dlyap|recursive|levinson\")\n", ...
               "[K,W]=KW(ABCD,algo_str=\"dlyap|recursive|levinson\")"]);
endif
if (nargin==1) || (nargin==2)
  ABCD=dummy1;
%  if rows(ABCD) ~= columns(ABCD)
%    error("Expect ABCD square");
%  endif
  if rows(ABCD) < 2
    error("Not a state variable description!");
  endif
  Nk=rows(ABCD)-1;
  A=ABCD(1:Nk,1:Nk);
  B=ABCD(1:Nk,(Nk+1):end);
  C=ABCD((Nk+1):end,1:Nk);
  D=ABCD((Nk+1):end,(Nk+1):end);
  if nargin==2
    algo_str=dummy2;
  endif
elseif (nargin==4) || (nargin==5)
  A=dummy1;
  B=dummy2;
endif
  
if rows(A) ~= columns(A)
  error("Expect A square");
endif
if rows(A) ~= rows(B) 
  error("Expect rows(B) == rows(A)");
endif
if columns(C) ~= columns(A)
  error("Expect columns(C) == columns(A)");
endif
if columns(D) ~= columns(B)
  error("Expect columns(D) == columns(B)");
endif
if rows(D) ~= rows(C)
  error("Expect rows(D) == rows(C)");
endif

% Decide algorithm type
if (nargin == 2) || (nargin == 5)
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
elseif (nargin == 1) || (nargin == 4)
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
