function schurNSlattice_sqp_slb_bandpass_plot ...
           (s10,s11,s20,s00,s02,s22, ...
            fapl,fapu,dBap,ftpl,ftpu,tp,tpr,fasl,fasu,dBas,strF,strT)

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
  if (nargin ~= 18)
    print_usage...
("shurNSlattice_sqp_slb_lowpass_plot(s10,s11,s20,s00,s02,s22, ...\n\
    fapl,fapu,dBap,ftpl,ftpu,tp,tpr,fasl,fasu,dBas,strF,strT)");
  endif

  % Plot overall response
  nplot=2048;
  wplot=(0:(nplot-1))'*pi/nplot;
  Asq=schurNSlatticeAsq(wplot,s10,s11,s20,s00,s02,s22);
  T=schurNSlatticeT(wplot,s10,s11,s20,s00,s02,s22);
  subplot(211);
  plot(wplot*0.5/pi,10*log10(Asq));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -60 5]);
  grid("on");
  title(strT);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  axis([0 0.5 0 2*tp]);
  grid("on");
  print(strcat(strF,""),"-dpdflatex");
  close

  % Plot passband response 
  subplot(211);
  plot(wplot*0.5/pi,10*log10(Asq));
  ylabel("Amplitude(dB)");
  axis([fapl fapu -dBap dBap]);
  grid("on");
  title(strT);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  axis([ftpl, ftpu, tp-tpr tp+tpr]);
  grid("on");
  print(strcat(strF,"pass"),"-dpdflatex");
  close

  % Plot poles and zeros
  [n,d]=schurNSlattice2tf(s10,s11,s20,s00,s02,s22);
  subplot(111);
  zplane(roots(n),roots(d));
  title(strT);
  print(strcat(strF,"pz"),"-dpdflatex");
  close
  
endfunction
