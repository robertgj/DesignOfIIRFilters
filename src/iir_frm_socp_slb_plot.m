function iir_frm_socp_slb_plot(x,na,nc,Mmodel,Dmodel, ...
                               nplot,fpass,strT,strF,strOpt)
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
  if (nargin ~= 10)
    print_usage...
("iir_frm_socp_slb_plot(x,na,nc,Mmodel,Dmodel,nplot,fpass,strT,strF,strOpt)");
  endif

  % Find the nominal group delay
  dmask=(max(na,nc)-1)/2;
  td=(Mmodel*Dmodel)+dmask;
  
  % Find overall filter transfer function polynomials
  if na>nc
    aa=x.aa;
    ac=[zeros((na-nc)/2,1);x.ac; zeros((na-nc)/2,1)];
  elseif na<nc
    aa=[zeros((nc-na)/2,1);x.aa; zeros((nc-na)/2,1)];
    ac=x.ac;
  else
    aa=x.aa;
    ac=x.ac;
  endif
  aM=[x.a(1);kron(x.a(2:end),[zeros(Mmodel-1,1);1])];
  dM=[x.d(1);kron(x.d(2:end),[zeros(Mmodel-1,1);1])];
  if length(aM)>length(dM)
    dM=[dM;zeros(length(aM)-length(dM),1)];
  elseif length(dM)>length(aM)
    aM=[aM;zeros(length(dM)-length(aM),1)];
  endif
  aM_frm=[conv(aM,aa-ac);zeros(Mmodel*Dmodel,1)] ...
         +[zeros(Mmodel*Dmodel,1);conv(ac,dM)];

  % Calculate overall response
  [Hw_frm,wplot]=freqz(aM_frm,dM,nplot);
  Tw_frm=grpdelay(aM_frm,dM,nplot);

  % Plot PCLS response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_frm)))
  axis([0, 0.5, -60, 10]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"response");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_frm)
  axis([0, 0.5, 60, 100]);
  xlabel("Frequency");
  ylabel("Group delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"response"),"-dpdflatex");
  close

  % Plot passband PCLS response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_frm)))
  axis([0, fpass, -0.2, 0.2]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"passband response");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_frm)
  axis([0, fpass, td-1, td+1]);
  xlabel("Frequency");
  ylabel("Group delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"passband_response"),"-dpdflatex");
  close

  % Calculate model filter response
  Hw_model=freqz(aM,dM,nplot);
  Tw_model=grpdelay(aM,dM,nplot);
  
  % Plot model filter response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_model)))
  axis([0, 0.5, -40, 10]);
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"model filter");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_model)
  axis([0, 0.5, 50, 100]);
  xlabel("Frequency");
  ylabel("Group delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"model_response"),"-dpdflatex");
  close

  % Calculate masking filter responses
  Hw_aa=freqz(aa,1,nplot);
  Hw_ac=freqz(ac,1,nplot);

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
