function ndigits_alloc=schurOneMAPlattice_frm_allocsd_Ito ...
                         (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% ndigits_alloc=schurOneMAPlattice_frm_allocsd_Ito ...
%   (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
%    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
%
% A modified version of the Ito digit allocation algorithm:
%   - the total signed-digit allocation is initially set to a large
%     number and reduced to that desired
%   - a digit is removed from the allocation to the coefficient that has
%     the minimum maximum approximation error unless that digits allocation
%     is already 0 or 1.
%
% See: "A powers-of-two term allocation algorithm for designing FIR
% filters with CSD coefficients in a min-max sense", Rika Ito, Tetsuya Fujie,
% Kenji Suyama and Ryuichi Hirabayashi.
% http://www.eurasip.org/Proceedings/Eusipco/Eusipco2004/defevent/papers/cr1722.pdf

% Copyright (C) 2019-2025 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if ((nargin~=12) && (nargin~=15) && (nargin~=18)) || (nargout~=1)
    print_usage ("ndigits_alloc=schurOneMAPlattice_frm_allocsd_Ito ...\n\
      (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...\n\
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)");
  endif
  if length(k0)~=length(epsilon0) || ...
     length(k0)~=length(p0) || ...
     length(v0)~=length(u0)
    error("Input coefficient vector lengths inconsistent!");
  endif
  if (length(Asqd)~=length(wa)) || (length(Asqd)~=length(Wa)) 
    error("Input squared-amplitude vector lengths inconsistent!");
  endif
  if nargin < 15
    wt=[];Td=[];Wt=[];
  else
    if (length(Td)~=length(wt)) || (length(Td)~=length(Wt))
      error("Input delay vector lengths inconsistent!");
    endif
  endif
  if nargin < 18
    wp=[];Pd=[];Wp=[];
  else
    if (length(Pd)~=length(wp)) || (length(Pd)~=length(Wp)) 
      error("Input phase vector lengths inconsistent!");
    endif
  endif
  
  %
  % Initialise
  %
  Nk=length(k0);
  Nu=length(u0);
  Nv=length(v0);
  Rk=1:Nk;
  Ru=(Nk+1):(Nk+Nu);
  Rv=(Nk+Nu+1):(Nk+Nu+Nv);
  kuv0=[k0(:);u0(:);v0(:)];
  % Find the non-zero coefficients in k0, u0 and v0
  tol=2.^(-nbits);
  inzkuv=find(abs(kuv0(:)') >=tol);
  % Find the initial costs for the upper and lower approximation of each k,u,v
  [kuv_sd,kuv_sdU,kuv_sdL]=flt2SD(kuv0,nbits,2*ndigits);
  cost_kuv=inf*ones(size(kuv0));
  for l=inzkuv
    kuvdel=kuv0;
    kuvdel(l)=kuv_sdU(l);
    cost_kuvU=schurOneMAPlattice_frmEsq ...
                (kuvdel(Rk),epsilon0,p0,kuvdel(Ru),kuvdel(Rv),Mmodel,Dmodel,...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    kuvdel(l)=kuv_sdL(l);
    cost_kuvL=schurOneMAPlattice_frmEsq ...
                (kuvdel(Rk),epsilon0,p0,kuvdel(Ru),kuvdel(Rv),Mmodel,Dmodel,...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    if cost_kuvU>cost_kuvL
      cost_kuv(l)=cost_kuvU;
      else
        cost_kuv(l)=cost_kuvL;
    endif
  endfor
  
  %
  % Loop reducing the number of digits allocated
  % 
  % Find the desired total number of signed-digits
  ndigits_alloc=zeros(size(kuv0));
  ndigits_alloc(inzkuv)=2*ndigits;
  desired_total_digits=ndigits*length(inzkuv);
  while sum(ndigits_alloc)>desired_total_digits
    % Update the digits allocated to the coefficient with greatest cost
    [min_cost_kuv,imkuv]=min(cost_kuv);
    ndigits_alloc(imkuv)=ndigits_alloc(imkuv)-1;

    % Update the cost
    if ndigits_alloc(imkuv) <= 1
        cost_kuv(imkuv)=inf;
    else
      kuvdel=kuv0;
      [nextkuv,nextkuvU,nextkuvL]=flt2SD(kuv0(imkuv),nbits,ndigits_alloc(imkuv));
      kuvdel(imkuv)=nextkuvU;
      cost_kuvU=schurOneMAPlattice_frmEsq ...
                  (kuvdel(Rk),epsilon0,p0,kuvdel(Ru),kuvdel(Rv),Mmodel,Dmodel,...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      kuvdel(imkuv)=nextkuvL;
      cost_kuvL=schurOneMAPlattice_frmEsq ...
                  (kuvdel(Rk),epsilon0,p0,kuvdel(Ru),kuvdel(Rv),Mmodel,Dmodel,...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      if cost_kuvU>cost_kuvL
        cost_kuv(imkuv)=cost_kuvU;
      else
        cost_kuv(imkuv)=cost_kuvL;
      endif
    endif
  endwhile

endfunction
