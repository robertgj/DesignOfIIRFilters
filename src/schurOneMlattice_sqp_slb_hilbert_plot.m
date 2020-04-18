function schurOneMlattice_sqp_slb_hilbert_plot ...
           (k,epsilon,p,c,wa,wt,wp,dBap,tp,tpr,pr, ...
            Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl,strF,strT)

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
  if (nargin ~= 19)
    print_usage("shurOneMlattice_sqp_slb_hilbert_plot(k,epsilon,p,c, ...\n\
       wa,wt,wp,dBap,tp,tpr,pr,Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl,strF,strT)");
  endif

  % Plot response
  subplot(311);
  Asq=schurOneMlatticeAsq(wa,k,epsilon,p,c);
  plot(wa*0.5/pi,10*log10([Asq Asqdu Asqdl]));
  ylabel("Amplitude(dB)");
  axis([0  0.5 -dBap*2 dBap*2]);
  grid("on");
  title(strT);
  subplot(312);
  T=schurOneMlatticeT(wt,k,epsilon,p,c);
  plot(wp*0.5/pi,[T Tdu Tdl]);
  ylabel("Group delay(samples)");
  xlabel("Frequency");
  axis([0 0.5 tp-(tpr*2) tp+(tpr*2)]);
  grid("on");
  subplot(313);
  P=schurOneMlatticeP(wp,k,epsilon,p,c);
  plot(wp*0.5/pi,([P Pdu Pdl]+(wp*tp))/pi);
  ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
  xlabel("Frequency");
  axis([0 0.5 (-0.5-(pr*2)) (-0.5+(pr*2))]);
  grid("on");
  print(strF,"-dpdflatex");
  close
  
  % Plot poles and zeros
  [n,d]=schurOneMlattice2tf(k,epsilon,p,c);
  subplot(111);
  zplane(roots(n),roots(d));
  title(strT);
  print(strcat(strF,"pz"),"-dpdflatex");
  close
  
endfunction
