function schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
           (k,epsilon,p,u,v,Mmodel,Dmodel,nplot,strT,strF,strOpt, ...
            wa,Asqdu,Asqdl,wt,Tdu,Tdl,wp,Pdu,Pdl)

% Copyright (C) 2017 Robert G. Jenssen
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
  if (nargin ~= 11) && (nargin ~= 20)
    print_usage("schurOneMAPlattice_frm_hilbert_socp_slb_plot\
      (k,epsilon,p,u,v,...\n  Mmodel,Dmodel,nplot,strT,strF,strOpt ...\n\
       [,wa,Asqdu,Asqdl,wt,Tdl,Tdu,wp,Pdu,Pdl])") 
  endif

  dmask=2*length(v);
  td=(Mmodel*Dmodel)+dmask;
  
  wplot=(0:(nplot-1))'*pi/nplot;
  if nargin == 11
    Asq_frm=schurOneMAPlattice_frm_hilbertAsq ...
              (wplot,k,epsilon,p,u,v,Mmodel,Dmodel);
    T_frm=schurOneMAPlattice_frm_hilbertT ...
            (wplot,k,epsilon,p,u,v,Mmodel,Dmodel);
    P_frm=schurOneMAPlattice_frm_hilbertP ...
            (wplot,k,epsilon,p,u,v,Mmodel,Dmodel);
  else
    Asq_frm=schurOneMAPlattice_frm_hilbertAsq ...
              (wa,k,epsilon,p,u,v,Mmodel,Dmodel);
    T_frm=schurOneMAPlattice_frm_hilbertT ...
            (wt,k,epsilon,p,u,v,Mmodel,Dmodel);
    P_frm=schurOneMAPlattice_frm_hilbertP ...
            (wp,k,epsilon,p,u,v,Mmodel,Dmodel);
  endif
  
  % Plot response
  subplot(311);
  if nargin == 11
    plot(wplot*0.5/pi,10*log10(Asq_frm))
  else
    plot(wa*0.5/pi,10*log10(Asq_frm),"-", ...
         wa*0.5/pi,10*log10(Asqdu),"--", ...
         wa*0.5/pi,10*log10(Asqdl),"--")
  endif
  axis([0, 0.5, -0.2, 0.2]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"response");
  title(tstr);
  subplot(312);
  if nargin == 11
    plot(wplot*0.5/pi,T_frm+td)
  else
    plot(wt*0.5/pi,T_frm+td,"-", ...
         wt*0.5/pi,Tdu+td,"--", ...
         wt*0.5/pi,Tdl+td,"--")
  endif
  axis([0, 0.5, td-1, td+1]);
  ylabel("Group delay(samples)");
  grid("on");
  subplot(313);
  if nargin == 11
    plot(wplot*0.5/pi,P_frm/pi)
  else
    plot(wp*0.5/pi,P_frm/pi,"-", ...
         wp*0.5/pi,Pdu/pi,"--", ...
         wp*0.5/pi,Pdl/pi,"--")
  endif
  axis([0, 0.5, -0.504, -0.496]);
  xlabel("Frequency");
  ylabel("Phase(rad./pi)\n(Adjusted for delay)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"response"),"-dpdflatex"); 
  close

  % Plot masking filter responses
  subplot(111);
  u=u(:);
  au=zeros((2*dmask)+1,1);
  au(1:2:(dmask+1))=u;
  au((dmask+1):2:end)=flipud(u);
  Hu=freqz(au,1,wplot);
  av=zeros((2*dmask)+1,1);
  av(2:2:dmask)=v(:);
  av((dmask+2):2:end)=flipud(v);
  Hv=freqz(av,1,wplot);
  plot(wplot*0.5/pi,20*log10(abs(Hu)),'-',...
       wplot*0.5/pi,20*log10(abs(Hv)),'--');
  legend("Mask(u)","Comp(v)","location","northeast");
  legend("boxoff");
  axis([0, 0.5, -60, 10]);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"u and v masking filters");
  title(tstr);
  print(sprintf(strF,lower(strOpt),"mask_response"),"-dpdflatex");
  close

endfunction
