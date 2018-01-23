function SqErr = directFIRsymmetricSqErr(w,_hM,_Ad,_Wa)
% SqErr = directFIRsymmetricSqErr(w,_hM,_Ad,_Wa)
% Return the squared-error of an order 2M direct form symmetric FIR filter.
% This is a helper function for calculating the mean-squared-error of the
% filter with the Octave quad functions.
%
% Inputs:
%  w - angular frequencies in [0, pi] at which to evaluate the squared error
%  hM - first M+1 coefficients of the order 2M, symmetric, bandpass FIR filter
%  Ad - desired amplitude response
%  Wa - amplitude weight function
% The angular frequency 2*pi corresponds to the sample rate. Ad and Wa are
% assumed to be evenly spaced in angular frequency from 0 to pi inclusive.

  persistent hM Ad Wa N
  persistent init_done=false;

  if nargin~=1 && nargin~=4
    print_usage("      directFIRsymmetricSqErr(w) \n\
      directFIRsymmetricSqErr(w,hM,Ad,Wa)");
  endif

  if nargin==4
    hM=_hM;
    if isempty(hM)
      error("hM is empty");
    endif
    Ad=_Ad(:);
    Wa=_Wa(:);
    if length(Ad)~=length(Wa)
      error("length(Ad)~=length(Wa)");
    endif
    if length(Ad)<2
      error("length(Ad)<2");
    endif
    N=length(Ad);
    init_done=true;
  endif

  if ~init_done
    error("directFIRsymmetricSqErr not initialised");
  endif

  if length(w)==0
    error("length(w)==0");
  endif

  n=1+round(w*(N-1)/pi);
  if any(n<1) || any(n>N)
    error("any(n<1) || any(n>N)")
  endif
  
  A=directFIRsymmetricA(w,hM);
  SqErr=Wa(n).*((A(:)-Ad(n)).^2)/pi;

endfunction
