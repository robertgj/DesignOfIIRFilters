%% Copyright (C) 2014, 2016-2019 Colin B. Macdonald
%%
%% The symbolic-2.9.0 package does not support the SymPy collect function.
%% This code is copied from octave/packages/symbolic-2.9.0/@sym/factor.m

%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypemethod  @@sym {@var{e} =} collect (@var{f}, @var{x})
%% Collect common powers of a term in an expression.
%%
%% An example of collecting terms in a polynomial:
%% @example
%% @group
%% syms x y z
%% e = collect([x*y + x - 3 + 2*x^2 - z*x^3 + x^3], x)
%%   @result{} (sym) x^3⋅(1 - z) + 2⋅x^2  + x⋅(y + 1) - 3
%% @end group
%% @end example
%%
%% @seealso{@@sym/expand}
%% @end deftypemethod


function e = collect(f, varargin)
  
  if (nargout > 1)
    print_usage ();
  endif

  f = sym(f);
  for i = 1:length(varargin)
    varargin{i} = sym(varargin{i});
  endfor
  
  e = pycall_sympy__ ('return collect(*_ins)', f, varargin{:});

endfunction

%!test syms x y z
%! f = [x*y + x - 3 + 2*x^2 - z*x^3 + x^3]
%! assert( logical (collect(f,x) == ((x^3)*(1 - z) + 2*(x^2)  + x*(y + 1) - 3)))

