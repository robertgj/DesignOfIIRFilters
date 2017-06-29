function [N,D,FVEC]=xInitTF(N0,D0,R,wd,Hd,Wd)
%% function [N,D,FVEC]=xInitTF(N0,D0,R,wd,Hd,Wd)
%% Derive an IIR filter with unconstrained optimisation of the
%% transfer function polynomial coefficients sand the "WISE" 
%% barrier function. 
%% Inputs:
%%  N0 - initial numerator
%%  D0 - initial denominator
%%  R - decimation factor
%%  wd - angular frequencies of desired complex response (2*pi is sample rate)
%%  Hd - desired complex frequency response
%%  Wd - desired complex frequency response weighting function
%% Outputs:
%%  N - numerator polynomial
%%  D - denominator polynomial
%%  FVEC - minimum value from fminunc
%%
%% The derived filter is (recall that Octave vectors are 1-based):
%%   H(z) = Sum(k=0,nN){N(k+1)*z^k} / [1 + Sum(k=1,nD){D(k)*Z^(k*R)}]
%% where nN and nD are, respectively, the orders of the N0 and D0 
%% polynomials (ie: nN=length(N0)-1).
%%
%% NOTE: THE USE OF SIMPLE TRAPEZOIDAL INTEGRATION OF THE ERROR
%% FUNCTION REQUIRES THAT THE FREQUENCIES BE CONTIGUOUS. USE THE 
%% WEIGHT TO MAKE GAPS IN FREQUENCY FOR TRANSITION BANDS.
%%  
%% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
%% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

  % Sanity checks
  if (nargin != 6) 
    usage("[N,D,FVEC]=xInitTF(N0,D0,R,wd,Hd,Wd)");
  endif
  if ((length(wd) != length(Hd)) || (length(wd) != length(Wd)))
    error("Expect wd, Hd and Wd to have equal length!");
  endif

  % Initialisation
  nN=length(N0)-1;
  nD=length(D0)-1;
  WISEJ(0,nN,nD,R,wd,Hd,Wd);

  % Unconstrained minimisation
  [ND, FVEC, INFO, OUTPUT] = fminunc(@WISEJ,[N0(:);D0(2:end)/D0(1)]);
  if (INFO == 1)
     printf("Converged to a solution point.\n");
  elseif (INFO == 2)
    printf("Last relative step size was less that TolX.\n");
  elseif (INFO == 3)
    printf("Last relative decrease in function value was less than TolF.\n");
  elseif (INFO == 0)
    printf("Iteration limit exceeded.\n");
  elseif (INFO == -3)
    printf("The trust region radius became excessively small.\n");
  else
    error("Unknown INFO value.\n");
  endif
  printf("Function value=%f\n", FVEC);
  printf("fminunc iterations=%d\n", OUTPUT.iterations);
  printf("fminunc successful=%d??\n", OUTPUT.successful);
  printf("fminunc funcCount=%d\n", OUTPUT.funcCount);
  [E,intEHd,EJ] = WISEJ(ND);
  printf("E=%f,intEHd=%f,EJ=%f\n", E,intEHd,EJ);

  % Create the output polynomials
  ND=ND(:);
  N=ND(1:(nN+1));
  D=[1; ND((nN+2):end)];

endfunction

function [E,intEHd,EJ]=WISEJ(ND,_nN,_nD,_R,_wd,_Hd,_Wd)

  persistent nN nD R wd Hd Wd

  % Initialisation
  if (nargin == 7)
    nN=_nN; nD=_nD; R=_R; wd=_wd; Hd=_Hd; Wd=_Wd; E=0;
    return;
  endif

  % Sanity check
  if length(ND) != (nN+nD+1)
    error("Expected length(ND) = (nN+nD+1)");
  endif

  % Decimate the denominator
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):end), [zeros(R-1,1);1])];

  % Find the error complex frequency response 
  HNd = freqz(N, 1, wd);
  HDRd = freqz(DR, 1, wd);
  EHd = Wd.*(abs(Hd-(HNd./HDRd)).^2);

  % Trapezoidal integration of complex error
  intEHd = sum(diff(wd).*(EHd(1:(length(EHd)-1))+EHd(2:(length(EHd))))/2);

  % Heuristics for the barrier function
  lambda = 0.001;
  if (nD > 0)
    M = nD*R;
    T = 300;
    rho = 31/32;
    % Calculate barrier function
    DRrho=DR./(rho.^(0:(length(DR)-1))');
    [ADR,bDR,cDR,dDR] = tf2Abcd(1,DRrho);
    f = zeros(M,1);
    cADR_Tk = cDR*(ADR^(T-1));
    for k=1:M
      f(k) = cADR_Tk*bDR;
      cADR_Tk = cADR_Tk*ADR;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif

  % Done
  E = ((1-lambda)*intEHd) + (lambda*EJ);

endfunction
