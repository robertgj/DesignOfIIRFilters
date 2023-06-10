function schurOneMAPlattice_frm_halfband_socp_slb_plot ...
           (k,epsilon,p,u,v,Mmodel,Dmodel,nplot,strT,strF,strOpt)

% Copyright (C) 2017-2023 Robert G. Jenssen
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
  if (nargin ~= 11)
    print_usage("schurOneMAPlattice_frm_halfband_socp_slb_plot ...\n\
      (k,epsilon,p,u,v,Mmodel,Dmodel,nplot,strT,strF,strOpt)")
  endif

  % Reconstruct the FRM filters
  r=schurOneMAPlattice2tf(k,epsilon,p);
  r=r(:);
  mr=length(r)-1;
  r2M=zeros((2*Mmodel*mr)+1,1);
  r2M(1:(2*Mmodel):end)=r;
  dmask=length(v)+length(u)-1;
  au=zeros((2*dmask)+1,1);
  u=u(:);
  au(1:2:end)=[u;u((end-1):-1:1)];
  azm1v=zeros(size(au));
  v=v(:);
  azm1v(2:2:end)=[v;v(end:-1:1)];
  qn=[conv(flipud(r2M), ...
           (2*au)-[zeros(dmask,1);1;zeros(dmask,1)]);zeros(Dmodel*Mmodel,1)] ...
     + conv(r2M,[zeros(Mmodel*Dmodel,1);2*azm1v]);
  n=0.5*(qn+[zeros((Dmodel*Mmodel)+dmask,1);r2M;zeros(dmask,1)]);
  aa=au+azm1v;
  na=length(aa);
  ac=aa.*((-ones(na,1)).^((0:(na-1))'))-[zeros(dmask,1);1;zeros(dmask,1)];
  td=(Dmodel*Mmodel)+((na-1)/2);
  
  % Calculate filter responses
  [Hw_frm,wplot]=freqz(n,r2M,nplot);
  Tw_frm=delayz(n,r2M,nplot);
  Hw_aa=freqz(aa,1,nplot);
  Hw_ac=freqz(ac,1,nplot);
  n_model=([flipud(r2M);zeros(Mmodel*Dmodel,1)] + ...
           conv([zeros(Mmodel*Dmodel,1);1],r2M))/2;
  Hw_model=freqz(n_model,r2M,nplot);
  Tw_model=delayz(n_model,r2M,nplot);
  
  % Plot overall response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(Hw_frm))
  axis([0, 0.5, -60, 10]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"response");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_frm)
  axis([0, 0.5, td-10, td+10]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"response"),"-dpdflatex"); 
  close

  % Plot passband response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(Hw_frm))
  axis([0, 0.25, -0.1 0.1]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"passband response");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_frm)
  td=(Dmodel*Mmodel)+dmask;
  axis([0, 0.25, td-0.4, td+0.4]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"passband_response"),"-dpdflatex");  
  close

  % Plot model filter response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_model)))
  axis([0, 0.5, -60, 5]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"model filter");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_model)
  axis([0, 0.5, (Dmodel*Mmodel)-50, (Dmodel*Mmodel)+50]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"model_response"),"-dpdflatex");
  close

  % Plot masking filter response
  subplot(111);
  plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),'-',...
       wplot*0.5/pi,20*log10(abs(Hw_ac)),'--');
  legend("Mask","Comp","location","northeast");
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
