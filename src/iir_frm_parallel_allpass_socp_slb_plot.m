function iir_frm_parallel_allpass_socp_slb_plot(x,na,nc,Mmodel,Dmodel,dmask, ...
                                                nplot,fpass,strT,strF,strOpt)
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
    print_usage("iir_frm_parallel_allpass_socp_slb_plot(x,na,nc, ...\n\
                Mmodel,Dmodel,dmask,nplot,fpass,strT,strF,strOpt)")
  endif

  % Find the nominal group delay
  td=(Mmodel*Dmodel)+dmask;
  
  % Find overall filter transfer function polynomials
  xrM=[x.r(1);kron(x.r(2:end),[zeros(Mmodel-1,1);1])];
  xsM=[x.s(1);kron(x.s(2:end),[zeros(Mmodel-1,1);1])];
  if na>nc
    xaa=x.aa;
    xac=[x.ac;zeros(na-nc,1)];
  elseif na<nc
    xaa=[x.aa;zeros(nc-na,1)];
    xac=x.ac;
  else
    xaa=x.aa;
    xac=x.ac;
  endif
  nfrm=(conv(conv(flipud(xrM),(xaa+xac)/2),xsM) + ...
        conv(conv(flipud(xsM),(xaa-xac)/2),xrM));
  dfrm=conv(xrM,xsM);

  % Calculate overall response
  [Hw_frm,wplot]=freqz(nfrm,dfrm,nplot);
  Tw_frm=delayz(nfrm,dfrm,nplot);

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
  axis([0, 0.5, 0, 200]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"response"),"-dpdflatex");
  close

  % Plot passband PCLS response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_frm)))
  axis([0, fpass, -0.05, 0.05]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"passband response");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_frm)
  axis([0, fpass, 40, 100]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"passband_response"),"-dpdflatex");
  close

  % Calculate model filter response
  num_model=(conv(flipud(xrM),xsM)+conv(flipud(xsM),xrM))/2;
  Hw_model=freqz(num_model,dfrm,nplot);
  Tw_model=delayz(num_model,dfrm,nplot);
  
  % Plot model filter response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_model)))
  axis([0, 0.5, -40, 5]);
  ylabel("Amplitude(dB)");
  grid("on");
  tstr=sprintf(strT,strOpt,"model filter");
  title(tstr);
  subplot(212);
  plot(wplot*0.5/pi,Tw_model)
  axis([0, 0.5, 0, 150]);
  xlabel("Frequency");
  ylabel("Delay(samples)");
  grid("on");
  print(sprintf(strF,lower(strOpt),"model_response"),"-dpdflatex");
  close

  % Plot masking filters
  subplot(211);
  plot(xaa);
  ylabel("aa\n(Mask)");
  s=sprintf("FRM masking filters : na=%d,nc=%d",na,nc);
  title(s);
  subplot(212);
  plot(xac);
  ylabel("ac(Comp. Mask)");
  print(sprintf(strF,lower(strOpt),"mask_filters"),"-dpdflatex");
  close
  
  % Calculate masking filter responses
  Hw_aa=freqz(xaa,1,nplot);
  Hw_ac=freqz(xac,1,nplot);
  Tw_aa=delayz(xaa,1,nplot);
  Tw_ac=delayz(xac,1,nplot);

  % Plot masking filter response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),'linestyle','-', ...
       wplot*0.5/pi,20*log10(abs(Hw_ac)),'linestyle','--');
  legend("Mask","Comp","location","northeast");
  legend("boxoff");
  axis([0 0.5 -40 5]);
  ylabel("Amplitude(dB)");
  grid("on");
  s=sprintf("FRM masking filters : na=%d,nc=%d",na,nc);
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,Tw_aa,'linestyle','-', ...
       wplot*0.5/pi,Tw_ac,'linestyle','--');
  axis([0 0.5 0 30]);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  grid("on");
  print(sprintf(strF,lower(strOpt),"mask_response"),"-dpdflatex");
  close
  
endfunction
