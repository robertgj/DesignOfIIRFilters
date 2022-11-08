% estN=rabiner(delf,del1,del2)
% Estimate the required filter order for a low-pass linear-phase FIR filter:
%   delf - the frequency transition width fs-fp (0<fp,fs<0.5)
%   del1 - the pass-band amplitude ripple (ie: 1+del1 is the maximum amplitude)
%   del2 - the stop-band amplitude ripple (ie: del2 is the maximum amplitude)
%
% See: "Approximate Design Relationships for Low-Pass FIR Digital Filters",
% Lawrence R. Rabiner, IEEE Transactions on Audio and Electroacoustics,
% Vol. AU-21, No. 5, October 1973, pp. 456-459.
%
% Note that this function returns the FIR filter order and Rabiners function
% returns the number of coefficients. Rabiner gives the following example:
% Fp=0.14, Fs=0.3182422, del1=0.01, del2=0.0001. This function returns an
% estimated filter order of 15.462 ie: a filter order of 16 or 17 coefficients.

function estN=rabiner(delf,del1,del2)

  a1=0.005309; a2=0.07114; a3=-0.4761; a4=-0.00266; a5=-0.5941; a6=-0.4278;
  b1=11.01217; b2=0.51244;
  
  D=(((a1*(log10(del1)^2)) + (a2*log10(del1)) + a3)*log10(del2)) + ...
     ((a4*(log10(del1)^2)) + (a5*log10(del1)) + a6);
  
  f=b1+(b2*log10(del1))-(b2*log10(del2));
  
  estN=ceil((D/delf)-(f*delf)) - 1;
endfunction
