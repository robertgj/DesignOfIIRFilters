function schurOneMAPlattice_frm_socp_slb_plot ...
           (k,epsilon,p,u,v,Mmodel,Dmodel,fap,fas,strT,strF,strOpt)
% schurOneMAPlattice_frm_socp_slb_plot ...
%  (k,epsilon,p,u,v,Mmodel,Dmodel,fap,fas,strT,strF,strOpt)

% Copyright (C) 2019-2020 Robert G. Jenssen
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
  if nargin ~= 12
    print_usage("schurOneMAPlattice_frm_socp_slb_plot\
(k,epsilon,p,u,v,Mmodel,Dmodel,fap,fas,strT,strF,strOpt)");
  endif
  if length(u)~=length(v)
    error("length(u)~=length(v)");
  endif
  
  u=u(:);
  v=v(:);
  dmask=length(u)-1;
  tp=(Mmodel*Dmodel)+dmask;
  nplot=1000;
  w=(0:(nplot-1))'*pi/nplot;
  nap=ceil(fap*nplot/0.5)+1;
  nas=floor(fas*nplot/0.5)+1;
  wap=w(1:nap);
  was=w(nas:end);
  wt=w(1:nap);
  wp=w(1:nap);
  AsqP_frm=schurOneMAPlattice_frmAsq(wap,k,epsilon,p,u,v,Mmodel,Dmodel);
  AsqS_frm=schurOneMAPlattice_frmAsq(was,k,epsilon,p,u,v,Mmodel,Dmodel);
  T_frm=schurOneMAPlattice_frmT(wt,k,epsilon,p,u,v,Mmodel,Dmodel);
  P_frm=schurOneMAPlattice_frmP(wp,k,epsilon,p,u,v,Mmodel,Dmodel);
  
  % Plot magnitude response
  subplot(311);
  ax=plotyy(wap*0.5/pi,10*log10(AsqP_frm),was*0.5/pi,10*log10(AsqS_frm));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  axis(ax(1),[0 0.5 -0.1 0.1]);
  axis(ax(2),[0 0.5 -60 -20]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"response");
  title(tstr);
  % Plot pass-band group delay response
  subplot(312);
  plot(wt*0.5/pi,T_frm+tp)
  axis([0, 0.5, tp-1, tp+1]);
  ylabel("Delay(samples)");
  grid("on");
  % Plot pass-band phase response
  subplot(313);
  plot(wp*0.5/pi,P_frm/pi)
  axis([0, 0.5, -0.01, 0.01]);
  ylabel("Phase(radians/$\\pi$)\n(Adjusted for delay)");
  xlabel("Frequency");
  grid("on");
  print(sprintf(strF,lower(strOpt),"response"),"-dpdflatex"); 
  close

  % Calculate model filter response
  Asq_model=schurOneMAPlattice_frmAsq(w,k,epsilon,p,0,1,Mmodel,Dmodel);
  T_model=schurOneMAPlattice_frmT(w,k,epsilon,p,0,1,Mmodel,Dmodel);

  % Plot model filter response
  subplot(211);
  plot(w*0.5/pi,10*log10(abs(Asq_model)))
  axis([0, 0.5, -60, 5]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"model filter");
  title(tstr);
  subplot(212);
  plot(w*0.5/pi,T_model+(Dmodel*Mmodel))
  axis([0, 0.5, 50, 150]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"model_response"),"-dpdflatex");
  close

  % Calculate masking filter responses
  Haa=freqz([u(end:-1:2);u],1,w); 
  Hac=freqz([v(end:-1:2);v],1,w);
  
  % Plot masking filter responses
  subplot(111);
  plot(w*0.5/pi,20*log10(abs(Haa)),'-',...
       w*0.5/pi,20*log10(abs(Hac)),'--');
  legend("Mask","Comp.");
  legend("location","northeast");
  legend("left");
  legend("boxoff");
  axis([0, 0.5, -60, 10]);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"masking filters");
  title(tstr);
  print(sprintf(strF,lower(strOpt),"mask_response"),"-dpdflatex");
  close

endfunction
