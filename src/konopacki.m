% function AdB=konopacki(M,wt,tau)
% Estimate the stop-band attenuation a filter with equal errors in the pass-
% and stop-bands and reduced delay.
%   N - filter order
%   wt - transition width in radians (eg: (fas-fap)*2*pi for a low-pass filter)
%   tau - nominal delay
%
% See Equation 5 of "Estimation of filter order for prescribed, reduced
% group delay FIR filter design", J. KONOPACKI and K. MOSCINSKA,
% BULLETIN OF THE POLISH ACADEMY OF SCIENCES TECHNICAL SCIENCES, Vol. 63,
% No. 1, 2015, (https://journals.pan.pl/Content/84137/PDF/24_paper.pdf)

function AdB=konopacki(N,wt,tau)
  a0=1.0562; a1=4.9148; a2=5.2582; b=0.044; c0=7.3341; c1=9.8399;
  AdB=(((((a2*(tau^2)/(N^2))+(a1*tau/N)+a0)*wt)+b)*N)+(c1*wt)+c0;
endfunction
