function schurOneMPAlattice_socp_slb_lowpass_plot ...
           (A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference, ...
            fap,dBap,ftp,td,tdr,fas,dBas,strF)

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
  if (nargin ~= 15)
    print_usage...
("shurOneMPAlattice_socp_slb_lowpass_plot(A1k,A1epsilon,A1p, ...\n\
    A2k,A2epsilon,A2p,difference,fap,dBap,ftp,td,tdr,fas,dBas,strF)");
  endif

  % Plot overall response
  strT=sprintf("Parallel Schur one-multiplier lattice response : \
fap=%g,dBap=%g,fas=%g,dBas=%g,ftp=%g,td=%g",fap,dBap,fas,dBas,ftp,td);
  nplot=2048;
  wplot=(0:(nplot-1))'*pi/nplot;
  Asq=schurOneMPAlatticeAsq(wplot, ...
                            A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  T=schurOneMPAlatticeT(wplot,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  subplot(211);
  plot(wplot*0.5/pi,10*log10(Asq));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -(dBas+10) 5]);
  grid("on");
  title(strT);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  axis([0 0.5 0 2*td]);
  grid("on");
  print(strcat(strF,"_response"),"-dpdflatex"); 
  close
  
  % Plot passband response
  strT=sprintf("Parallel Schur one-multiplier lattice passband response : \
fap=%g,dBap=%g,ftp=%g,td=%g,tdr=%g",fap,dBap,ftp,td,tdr);
  subplot(211);
  plot(wplot*0.5/pi,10*log10(Asq));
  ylabel("Amplitude(dB)");
  axis([0 max(fap,ftp) -2*dBap dBap]);
  grid("on");
  title(strT);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  axis([0, max(fap,ftp), td-tdr td+tdr]);
  grid("on");
  print(strcat(strF,"_passband_response"),"-dpdflatex"); 
  close
  
  % Plot poles and zeros
  [n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  subplot(111);
  zplane(roots(n),roots(d));
  title(strT);
  print(strcat(strF,"_pz"),"-dpdflatex");
  close 
  
endfunction
