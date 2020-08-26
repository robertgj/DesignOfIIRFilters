function iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P)

if nargin ~= 9
  print_usage("iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P)");
endif
  
% Copyright (C) 2017-2020 Robert G. Jenssen
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

printf("Current constraints:\n");

if ~isempty(vS.al)
  print_polynomial(vS.al,"al","%d");
  print_polynomial(wa(vS.al)*0.5/pi,"f(al)(fs=1)");
  print_polynomial(20*log10(abs(A(vS.al))),"Al(dB)");
endif

if ~isempty(vS.au)
  print_polynomial(vS.au,"au","%d");
  print_polynomial(wa(vS.au)*0.5/pi,"f(au)(fs=1)");
  print_polynomial(20*log10(abs(A(vS.au))),"Au(dB)");
endif

if ~isempty(vS.sl)
  print_polynomial(vS.sl,"sl","%d");
  print_polynomial(ws(vS.sl)*0.5/pi,"f(sl)(fs=1)");
  print_polynomial(20*log10(abs(S(vS.sl))),"Sl(dB)");
endif

if ~isempty(vS.su)
  print_polynomial(vS.su,"su","%d");
  print_polynomial(ws(vS.su)*0.5/pi,"f(su)(fs=1)");
  print_polynomial(20*log10(abs(S(vS.su))),"Su(dB)");
endif

if ~isempty(vS.tl)
  print_polynomial(vS.tl,"tl","%d");
  print_polynomial(wt(vS.tl)*0.5/pi,"f(tl)(fs=1)");
  print_polynomial(T(vS.tl),"Tl(samples)");
endif

if ~isempty(vS.tu)
  print_polynomial(vS.tu,"tu","%d");
  print_polynomial(wt(vS.tu)*0.5/pi,"f(tu)(fs=1)");
  print_polynomial(T(vS.tu),"Tu(samples)");
endif

if ~isempty(vS.pl)
  print_polynomial(vS.pl,"pl","%d");
  print_polynomial(wp(vS.pl)*0.5/pi,"f(pl)(fs=1)");
  print_polynomial(P(vS.pl)/pi,"Pl(rad.)");
endif

if ~isempty(vS.pu)
  print_polynomial(vS.pu,"pu","%d");
  print_polynomial(wp(vS.pu)*0.5/pi,"f(pu)(fs=1)");
  print_polynomial(P(vS.pu)/pi,"Pu(rad.)");
endif

endfunction
