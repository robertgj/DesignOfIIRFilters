% Linpack benchmark in Octave / Matlab
%
% MJ Rutter Nov 2015

N=2000;

fprintf('Linpack %dx%d\n',N,N);

ops=2*N*N*N/3+2*N*N;
eps=2.2e-16;

%  A=rand(N*N)-0.5;
if exist("reprand") ~= 3
  mkoctfile reprand.cc
endif
A=reshape(reprand(N*N)-0.5,N,N);

norma=max(max(max(A)),-min(min(A)));

B=sum(A,2);

t0=clock();

X=A\B;

t1=clock();

tim=etime(t1,t0);

% compute residual

R=A*X-B;

normx=max(max(X),-min(X));
resid=max(max(R),-min(R));

residn=resid/(N*norma*normx*eps);

fprintf('Norma is %f\n',norma);
fprintf('Residual is %g\n',resid);
fprintf('Normalised residual is %f\n',residn);
fprintf('Machine epsilon is %g\n',eps);
fprintf('x(1)-1 is %g\n',X(1)-1);
fprintf('x(N)-1 is %g\n',X(N)-1);
fprintf('Time is %f s\n',tim);
fprintf('MFLOPS: %.0f\n',1e-6*ops/tim);
