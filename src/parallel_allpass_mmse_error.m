function [E gradE]=...
         parallel_allpass_mmse_error(abk,_K,_Va,_Qa,_Ra,_Vb,_Qb,_Rb,_poly,...
                                     _wa,_Asqd,_Wa,_wt,_Td,_Wt)
% [E gradE]= parallel_allpass_mmse_error...
%   (abk,_K,_Va,_Qa,_Ra,_Vb,_Qb,_Rb,_poly,_wa,_Asqd,_Wa,_wt,_Td,_Wt)

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

  persistent K Va Qa Ra Vb Qb Rb polyphase wa Asqd Wa wt Td Wt
  persistent init_done=false
  if nargin == 15
    K=_K;
    Va=_Va;Qa=_Qa;Ra=_Ra;
    Vb=_Vb;Qb=_Qb;Rb=_Rb;
    polyphase=_poly;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;
    wt=_wt;Td=_Td;Wt=_Wt;
    init_done=true;
  elseif nargin ~= 1
    print_usage("[E gradE]= parallel_allpass_mmse_error...\n\
    (abk,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,wa,Asqd,Wa,wt,Td,Wt)");
  endif
  if init_done==false
    error("init_done==false");
  endif
  if length(abk) ~= (Va+Qa+Vb+Qb)
    error("length(abk) ~= (Va+Qa+Vb+Qb)");
  endif

  Nab=length(abk);
  Nwa=length(wa);
  Nwt=length(wt);

  Ewa=0;
  gradEwa=zeros(1,Nab);
  if ~isempty(wa)
    [Asqwa,gradAsqwa]=parallel_allpassAsq(wa,abk,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
    AsqwaMAsqd=Asqwa-Asqd;
    NwaM1=Nwa-1;
    Ewa=sum(diff(wa).*((Wa(1:NwaM1).*(AsqwaMAsqd(1:NwaM1).^2)) + ...
                       (Wa(2:end).*(AsqwaMAsqd(2:end).^2))))/2;
    gradEwa = ...
      (diff(wa).*Wa(1:NwaM1).*AsqwaMAsqd(1:NwaM1))'*gradAsqwa(1:NwaM1,:)+...
      (diff(wa).*Wa(2:end).*AsqwaMAsqd(2:end))'*gradAsqwa(2:end,:);
  endif

  Ewt=0;
  gradEwt=zeros(1,Nab);
  if ~isempty(wt)
    [Twt,gradTwt]=parallel_allpassT(wt,abk,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
    TwtMTd=Twt-Td;
    NwtM1=Nwt-1;
    Ewt=sum(diff(wt).*((Wt(1:NwtM1).*(TwtMTd(1:NwtM1).^2)) + ...
                       (Wt(2:end).*(TwtMTd(2:end).^2))))/2;
    gradEwt=(diff(wt).*Wt(1:NwtM1).*TwtMTd(1:NwtM1))'*gradTwt(1:NwtM1,:)+...
            (diff(wt).*Wt(2:end).*TwtMTd(2:end))'*gradTwt(2:end,:);
  endif

  
  E=Ewa+Ewt;
  gradE=gradEwa+gradEwt;
  gradE=gradE(:);
  
endfunction
