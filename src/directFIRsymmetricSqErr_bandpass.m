function SqErr = directFIRsymmetricSqErr_bandpass ...
                   (w,_hM,_fasl,_fapl,_fapu,_fasu,_Wasl,_Wasu)
% SqErr = directFIRsymmetricSqErr_bandpass ...
%           (w,_hM,_fasl,_fapl,_fapu,_fasu,_Wasl,_Wasu)
% Return the squared-error of an order 2M direct form symmetric FIR
% band-pass filter. This is a helper function for calculating the
% mean-squared-error of the filter with the Octave quad functions.
%
% Inputs:
%  w - angular frequencies at which to evaluate the squared error
%  hM - first M+1 coefficients of the order 2M, symmetric, bandpass FIR filter
%  fasl - lower stop-band upper edge 
%  fapl - pass-band lower edge 
%  fapu - pass-band upper edge 
%  fasl - upper stop-band lower edge 
%  Wasl - lower stop-band weight
%  Wasu - upper stop-band weight
% The edge frequencies are assumed to be in [0 0.5] where 1 corresponds to
% the sample rate. The pass band gain and weight are 1.

  persistent hM wasl wapl wapu wasu Wasl Wasu
  persistent init_done=false;

  if nargin~=1 && nargin~=8
    print_usage(["      directFIRsymmetricSqErr_bandpass(w) \n", ...
 "      directFIRsymmetricSqErr_bandpass(w,hM,fasl,fapl,fapu,fasu,Wasl,Wasu)"]);
  endif

  if nargin==8
    hM=_hM;
    if (_fasl<0) || (_fasl>0.5)
      error("(fasl<0) || (fasl>0.5)");
    endif
    if (_fapl<0) || (_fapl>0.5)
      error("(fapl<0) || (fapl>0.5)");
    endif
    if (_fapu<0) || (_fapu>0.5)
      error("(fapu<0) || (fapu>0.5)");
    endif
    if (_fasu<0) || (_fasu>0.5)
      error("(fasu<0) || (fasu>0.5)");
    endif
    wasl=_fasl*2*pi;wapl=_fapl*2*pi;wapu=_fapu*2*pi;wasu=_fasu*2*pi;
    Wasl=_Wasl;Wasu=_Wasu;
    init_done=true;
  endif

  if ~init_done
    error("directFIRsymmetricSqErr_bandpass not initialised");
  endif

  if length(w)==0
    error("length(w)==0");
  endif
  if any(w<0) || any(w>pi)
    error("any(w<0)||any(w>pi)");
  endif
  
  Ad=zeros(length(w),1);
  Ad(find((w >= wapl) && (w <= wapu)))=1;
  
  Wa=zeros(length(w),1);
  Wa(find(w <= wasl))=Wasl;
  Wa(find((w >= wapl) && (w <= wapu)))=1;
  Wa(find(w >= wasu))=Wasu;

  A=directFIRsymmetricA(w,hM);
  SqErr=Wa.*((A(:)-Ad).^2)/pi;

endfunction
