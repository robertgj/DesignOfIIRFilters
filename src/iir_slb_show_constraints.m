function iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P)

if nargin ~= 9
  print_usage("iir_slb_show_constraints(vS,wa,A,ws,S,wt,T,wp,P)");
endif
  
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

printf("Current constraints:\n");

if !isempty(vS.al)
  printf("al = [ ");printf("%d ",vS.al');printf("]\n");
  printf("al = [ ");printf("%f ",wa(vS.al)'*0.5/pi);printf("] (fs=1)\n");
  printf("Al = [ ");printf("%f ",20*log10(abs(A(vS.al))));printf("] (dB)\n");
endif

if !isempty(vS.au)
  printf("au = [ ");printf("%d ",vS.au');printf("]\n");
  printf("au = [ ");printf("%f ",wa(vS.au)'*0.5/pi);printf("] (fs=1)\n");
  printf("Au = [ ");printf("%f ",20*log10(abs(A(vS.au))));printf("] (dB)\n");
endif

if !isempty(vS.sl)
  printf("sl = [ ");printf("%d ",vS.sl');printf("]\n");
  printf("sl = [ ");printf("%f ",ws(vS.sl)'*0.5/pi);printf("] (fs=1)\n");
  printf("Sl = [ ");printf("%f ",20*log10(abs(S(vS.sl))));printf("] (dB)\n");
endif

if !isempty(vS.su)
  printf("su = [ ");printf("%d ",vS.su');printf("]\n");
  printf("su = [ ");printf("%f ",ws(vS.su)'*0.5/pi);printf("] (fs=1)\n");
  printf("Su = [ ");printf("%f ",20*log10(abs(S(vS.su))));printf("] (dB)\n");
endif

if !isempty(vS.tl)
  printf("tl = [ ");printf("%d ",vS.tl');printf("]\n");
  printf("tl = [ ");printf("%f ",wt(vS.tl)'*0.5/pi);printf("] (fs=1)\n");
  printf("Tl = [ ");printf("%f ",T(vS.tl));printf("] (Samples)\n");
endif

if !isempty(vS.tu)
  printf("tu = [ ");printf("%d ",vS.tu');printf("]\n");
  printf("tu = [ ");printf("%f ",wt(vS.tu)'*0.5/pi);printf("] (fs=1)\n");
  printf("Tu = [ ");printf("%f ",T(vS.tu));printf("] (Samples)\n");
endif

if !isempty(vS.pl)
  printf("pl = [ ");printf("%d ",vS.pl');printf("]\n");
  printf("pl = [ ");printf("%f ",wp(vS.pl)'*0.5/pi);printf("] (fs=1)\n");
  printf("Pl = [ ");printf("%f ",P(vS.pl));printf("] (Samples)\n");
endif

if !isempty(vS.pu)
  printf("pu = [ ");printf("%d ",vS.pu');printf("]\n");
  printf("pu = [ ");printf("%f ",wp(vS.pu)'*0.5/pi);printf("] (fs=1)\n");
  printf("Pu = [ ");printf("%f ",P(vS.pu));printf("] (Samples)\n");
endif

endfunction
