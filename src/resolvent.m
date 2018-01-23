function res=resolvent(w,A,method_str)
% res=resolvent(w,A,method)
% "Brute force" calculation of the resolvent (e^(jw)-A)^(-1) of a matrix A
% at angular frequencies w using the given method to calculate the inverse.
%
% Inputs:
%   w : array of angular frequencies
%   A : square matrix
%   method_str : The methods implemented are:
%    'matrix_inverse' : call "inv" to calculate the inverse (the default)
%    'hessenberg_inverse' : assume A is a complex lower hessenberg matrix and
%       call "complex_lower_hessenberg_inverse" to calculate the inverse 
%    'zhong_inverse' : assume A is a hessenberg matrix and call
%       "zhong_inverse" to calculate the inverse with the recursive
%       algorithm of Xu Zhong. See Theorem 1 of "On Inverses and Generalized
%       Inverses of Hessenberg Matrices", Xu Zhong, "Linear Algebra and its
%       Applications", Vol. 101, 1988, pp. 167-180. This implementation is
%       an m-file.
%    'complex_zhong_inverse' : assume A is a hessenberg matrix and call
%       "complex_zhong_inverse" to calculate the inverse with the recursive
%       algorithm of Xu Zhong. See above the reference above. This
%       implementation is an oct-file that calls the LAPACK ZTRTRI function.
  
% Copyright (C) 2017,2018 Robert G. Jenssen
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
  if ((nargin ~= 2) && (nargin ~= 3))
    print_usage("res=resolvent(w,A,method_str)");
  endif
  if (nargin == 3) && (~ischar(method_str))
    error("method_str must be a string")
  endif
  if nargin == 2
    method_str="matrix_inverse";
  endif
  
  % Decide method type
  if strcmp(method_str,"matrix_inverse")
    method_ptr=@inv;
  elseif strcmp(method_str,"hessenberg_inverse") 
    if ~exist("complex_lower_hessenberg_inverse","file") 
      error("complex_lower_hessenberg_inverse not found");
    endif
    method_ptr=@complex_lower_hessenberg_inverse;
  elseif strcmp(method_str,"complex_zhong_inverse")
    if ~exist("complex_zhong_inverse","file") 
      error("complex_zhong_inverse not found");
    endif
    method_ptr=@complex_zhong_inverse;
  elseif strcmp(method_str,"zhong_inverse")
    if ~exist("zhong_inverse","file") 
      error("zhong_inverse not found");
    endif
    method_ptr=@zhong_inverse;
  else
    error("Unknown method type (%s)!", method_str);
  endif

  % Run
  resolvent_loop([],A,method_ptr);
  res=arrayfun(@resolvent_loop,w,"UniformOutput",false);
endfunction

function res=resolvent_loop(w,_A,_method_ptr)
  persistent A method_ptr init_done=false
  if nargin==3
    A=_A;
    method_ptr=_method_ptr;
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  if ~isscalar(w)
    error("w not a scalar");
  endif
  res=feval(method_ptr,((exp(j*w)*eye(rows(A)))-A));
endfunction
