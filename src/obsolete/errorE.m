function [wap Ap gradAp wtp Tp gradTp was As gradAs E gradE hessE] = ...
  errorE(x,U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol)
%% function [wap Ap gradAp wtp Tp gradTp was As gradAs E gradE hessE]
%%   = errorE(x,U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol)
%%
%% Inputs:
%%   x - coefficient vector in the form:
%%         [k; 
%%          zR(1:U); pR(1:V); ...
%%          abs(z(1:M)); angle(z(1:M)); ...
%%          abs(p(1:Q)); angle(p(1:Q))];
%%       where k is the gain coefficient, zR and pR represent real
%%       zeros and poles and z and p represent conjugate zero and
%%       pole pairs. 
%%   U - number of real zeros
%%   V - number of real poles
%%   M - number of conjugate zero pairs
%%   Q - number of conjugate pole pairs
%%   R - decimation factor, pole pairs are for z^R
%%   Apass - vector of Lap desired amplitudes in the pass band
%%   fap - amplitude pass band edge frequency (sample rate is 1)
%%   Wap - amplitude pass band weight (a single value, eg: 10)
%%   Lap - number of desired amplitude pass band values
%%   Tpass - vector of Ltp desired group delay values in the pass band
%%   ftp - group delay pass band edge frequency
%%   Wtp - group delay pass band weight
%%   Ltp - number of desired group delay pass band values
%%   fas - amplitude stop band edge frequency
%%   Was - amplitude stop band weight
%%   Las - number of desired amplitude stop band values
%%   tol - tolerance
%%   
%% Outputs:
%%   wap - pass band frequencies
%%   Ap - pass band amplitudes at wap
%%   gradAp - gradient of pass band amplitudes at wap
%%   wtp - pass band group delays
%%   Tp - pass band group delays at wtp
%%   gradTp - gradient of pass band group delays at wtp
%%   was - stop band frequencies
%%   As - stop band amplitudes at was
%%   gradAs - gradient of stop band amplitudes at was
%%   E - error value at x
%%   gradE - gradient of error at x
%%   hessE - Hessian of E at x
%%
%% References:
%%   [1] A.G.Deczky, "Synthesis of recusive digital filters using the
%%       minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
%%       Vol. AU-20, pp. 257-263, October 1972
%%   [2] M.A.Richards, "Applications of Deczkys Program for Recursive
%%       Filter Design to the Design of Recursive Decimators" IEEE 
%%       Trans. ASSP-30 No. 5, pp. 811-814, October 1982

  global fixNaN checkNaN checkInf

  if nargin<18 || nargout<11
    ustr = "\n[wap,Ap,gradAp,wtp,Tp,gradTp,was,As,gradAs,E,gradE,hessE] = ...\n";
    ustr = strcat(ustr,"  errorE(x,U,V,M,Q,R,Apass,fap,Wap,Lap,");
    ustr = strcat(ustr,"Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol)");
    usage(ustr);
  endif

  % Amplitude pass band grid frequencies
  if Lap==1
    dfap=1;
    wap=2*pi*fap;
  else
    dfap=fap/(Lap-1);
    wap=2*pi*dfap*(1:Lap);
  endif

  % Delay pass band grid frequencies
  if Ltp==1
    dftp=1;
    wtp=2*pi*ftp;
  else
    dftp=ftp/(Ltp-1);
    wtp=2*pi*dftp*(1:Ltp);
  endif

  % Amplitude stop band grid frequencies
  if Las==1
    dfas=1;
    was=2*pi*fas;
  else
    dfas=(0.5-fas)/(Las-1);
    was=2*pi*(fas+(dfas*(0:(Las-1))));
  endif

  % Number of coefficients
  N=1+U+V+M+Q;

  % Pass band amplitude response
  hessAp=zeros(Lap,N,N);
  if nargout==12
    [Ap,gradAp,hessAp]=iirA(wap,x,U,V,M,Q,R,tol);
  else
    [Ap,gradAp]=iirA(wap,x,U,V,M,Q,R,tol);
  endif

  % Pass band delay response
  hessTp=zeros(Lap,N,N);
  if nargout==12
    [Tp,gradTp,hessTp]=iirT(wtp,x,U,V,M,Q,R,tol);
  else
    [Tp,gradTp]=iirT(wtp,x,U,V,M,Q,R,tol);
  endif

  % Amplitude stop band response
  hessAs=zeros(Las,N,N);
  if nargout==12
    [As,gradAs,hessAs]=iirA(was,x,U,V,M,Q,R,tol);
  else
    [As,gradAs]=iirA(was,x,U,V,M,Q,R,tol);
  endif

  %% Fix NaN
  if fixNaN
    [Ap,gradAp,hessAp]=fixResultNaN(Ap,gradAp,hessAp);
    [Tp,gradTp,hessTp]=fixResultNaN(Tp,gradTp,hessTp);
    [As,gradAs,hessAs]=fixResultNaN(As,gradAs,hessAs);
  endif
    
  %% Check for NaN
  if checkNaN
    if any(isnan(Ap))
      error("Ap has nan!");
    endif
    if any(any(isnan(gradAp)))
      error("gradAp has nan!");
    endif
    if any(isnan(Tp))
      error("Tp has nan!");
    endif
    if any(any(isnan(gradTp)))
      error("gradTp has nan!");
    endif
    if any(isnan(As))
      error("As has nan!");
    endif
    if any(any(isnan(gradAs)))
      error("gradAs has nan!");
    endif
  endif

  %% Check for Inf
  if checkInf
    if any(isinf(Ap))
      error("Ap has inf!");
    endif
    if any(any(isinf(gradAp)))
      error("gradAp has inf!");
    endif
    if any(isinf(Tp))
      error("Tp has inf!");
    endif
    if any(any(isinf(gradTp)))
      error("gradTp has inf!");
    endif
    if any(isinf(As))
      error("As has inf!");
    endif
    if any(any(isinf(gradAs)))
      error("gradAs has inf!");
    endif
  endif

  % Pass band amplitude response error
  if Wap==0
    Eap=0;
    gradEap=zeros(1,N); 
  else
    Eap=Wap*sum((Ap-Apass).^2)*dfap;
    gradEap=2*Wap*(Ap-Apass)'*gradAp*dfap;
  endif

  %% Pass band delay response error
  if Wtp==0
    Etp=0;
    gradEtp=zeros(1,N);
  else
    Etp=Wtp*sum((Tp-Tpass).^2)*dftp;
    gradEtp=2*Wtp*(Tp-Tpass)'*gradTp*dftp;
  endif

  % Amplitude stop band response error
  if Was==0
    Eas=0;
    gradEas=zeros(1,N);
  else
    Eas=Was*sum(As.^2)*dfas;
    gradEas=2*Was*As'*gradAs*dfas;
  endif

  %% Total error
  E=Eap+Etp+Eas;

  %% Error gradient
  gradE=gradEap+gradEtp+gradEas;

  %% Check for NaN
  if checkNaN
    if isnan(E)
      error("E is nan!");
    endif
    if any(isnan(gradE))
      error("gradE has nan!");
    endif
  endif

  %% Check for Inf
  if checkInf
    if isinf(E)
      error("E is inf!");
    endif
    if any(isinf(gradE))
      error("gradE has inf!");
    endif
  endif

  if nargout<12
    return;
  endif

  %% Error Hessian

  %% Check for NaN
  if checkNaN
    if any(any(any(isnan(hessAp))))
      error("hessAp has nan!");
    endif
    if any(any(any(isnan(hessTp))))
      error("hessTp has nan!");
    endif
    if any(any(any(isnan(hessAs))))
      error("hessAs has nan!");
    endif
  endif

  %% Check for Inf
  if checkInf
    if any(any(any(isinf(hessAp))))
      error("hessAp has inf!");
    endif
    if any(any(any(isinf(hessTp))))
      error("hessTp has inf!");
    endif
    if any(any(any(isinf(hessAs))))
      error("hessAs has inf!");
    endif
  endif

  if Wap==0
    hessEap=zeros(N,N);
  else
    hAp=permute(reshape(kron((Ap-Apass)',ones(N,N)),N,N,Lap),[3 1 2]);
    hApbyRow=permute(reshape(kron(gradAp',ones(1,N)),N,N,Lap),[3 1 2]);
    hApbyCol=permute(reshape(kron(gradAp',ones(N,1)),N,N,Lap),[3 1 2]);
    hessEap=reshape(2*sum((hApbyRow.*hApbyCol)+(hAp.*hessAp)),N,N)*dfap;
  endif

  if Wtp==0
    hessEtp=zeros(N,N);
  else
    hTp=permute(reshape(kron((Tp-Tpass)',ones(N,N)),N,N,Ltp),[3 1 2]);
    hTpbyRow=permute(reshape(kron(gradTp',ones(1,N)),N,N,Ltp),[3 1 2]);
    hTpbyCol=permute(reshape(kron(gradTp',ones(N,1)),N,N,Ltp),[3 1 2]);
    hessEtp=reshape(2*sum((hTpbyRow.*hTpbyCol)+(hTp.*hessTp)),N,N)*dftp;
  endif

  if Was==0
    hessEas=zeros(N,N);
  else
    hAs=permute(reshape(kron(As',ones(N,N)),N,N,Las),[3 1 2]);
    hAsbyRow=permute(reshape(kron(gradAs',ones(1,N)),N,N,Las),[3 1 2]);
    hAsbyCol=permute(reshape(kron(gradAs',ones(N,1)),N,N,Las),[3 1 2]);
    hessEas=reshape(2*sum((hAsbyRow.*hAsbyCol)+(hAs.*hessAs)),N,N)*dfas;
  endif

  hessE=(Wap*hessEap)+(Wtp*hessEtp)+(Was*hessEas);

  %% Check for NaN
  if checkNaN
    if any(any(isnan(hessE)))
      error("hessE has nan!");
    endif
  endif

  %% Check for Inf
  if checkInf
    if any(any(isinf(hessE)))
      error("hessE has inf!");
    endif
  endif

endfunction

function [X,gradX,hessX]=fixResultNaN(X,gradX,hessX)
  if any(isnan(X))
    iw=find(isnan(X));
    X(iw)=0;
  endif
  if any(any(isnan(gradX)))
    [iw,elt]=find(isnan(gradX));
    gradX(iw,elt)=0;
  endif
  if nargin==3 && any(any(any(isnan(hessX))))
    for k=1:length(X)
      if any(any(isnan(hessX(k,:,:))))
        H=hessX(k,:,:);
        [row,col]=find(isnan(H));
        H(row,col)=0;
        hessX(k,:,:)=H;
      endif
    endfor
  endif
endfunction
