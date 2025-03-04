function ng=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,d,n,e)
% ng=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,d,n,e)
% schurNSlatticeNoiseGain calculates the noise gain for a normalised-scaled
% lattice filter. S is the Schur othonormal basis for the filter. sxx are
% the lattice filter coefficients. d, n, e initialise the denominator, 
% numerator and all-pass denominator. 
%
% The tranpose lattice filter structure is:
%       _______          _______                _______      [ii]    
%   D ->|     |--------->|     |--------->...-->|     |---------> 
%       |     |  ______  |     |  ______        |     |  ______  |
%   N <-|  N  |<-|z^-1|--| N-1 |<-|z^-1|<-...<--|  1  |<-|z^-1|<-+
%       |     |  ------  |     |  ------        |     |  ------  |
%   E ->|     |--------->|     |--------->...-->|     |--------->
%       -------          -------                -------       [i]
%
% Each module 1,..,N in the transposed graph looks like:
%                      
%  D(m) >---------o----------------->  D(m-1)
%                 |     s11       
%              s10|
%                 V            z^1 
%  N(m) <---------+<-+<------o------<  N(m-1)
%                    ^  s00  |
%                 s20|       |s02 
%                    |  s22  V
%  E(m) >------------o------>+------>  E(m-1)
%
% The noise gain is determined from the transposed signal flow graph of 
% the filter since the the transfer functions from internal nodes to the 
% output are the same as the transfer functions from the input to the 
% internal nodes of the transposed graph.
%
% Note that in some cases the noise gain should not be included in the 
% total noise power because the node does not generate round-off noise 
% (eg: at [i] in the original flow graph corresponding to the figure above)
% or because a double-length accumulator is assumed (eg: at [ii], likewise).

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

if nargin ~= 10
  print_usage("ng=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,d,n,e)");
endif

% Reverse Octave polynomial convention to suit the Schur algorithm
d=d(:)';d=d(length(d):-1:1);
n=n(:)';n=n(length(n):-1:1);
e=e(:)';e=e(length(e):-1:1);


M=length(s10);
nd=zeros(1,M);
nn=zeros(1,M);
ne=zeros(1,M);

% Calculate the gain from each node to the output
for m=M:-1:1
  % Matrix formulation of the transposed graph
  Nd=s11(m)*d;
  Nn=(n - (s10(m)*d) - (s20(m)*e))/s00(m);
  Ne=((s02(m)*n) + (s20(m)*s10(m)*d) + e)/s00(m);
  d=Nd;
  n=[0 Nn(1:(length(n)-1))];
  e=Ne;

  % Expand each gain polynomial in the Schur basis
  cd=schurexpand(d,S);
  cn=schurexpand(n,S);
  ce=schurexpand(e,S);

  % Find the noise power from the expansion coefficients
  nd(m)=sum(cd.^2);
  nn(m)=sum(cn.^2);
  ne(m)=sum(ce.^2);
endfor

% The noise gain is the sum of the transfer functions from the input
% of the transposed graph to the internal nodes. There is no round-off
% noise associated with ne(1) and nd(1) so these are omitted. If an 
% "acc+=(acc*B)" instruction is available then the output could be 
% calculated in one pass and the nd could be ignored entirely.
ng=sum(nn)+sum(nd(2:length(nd)))+sum(ne(2:length(ne)));

endfunction
