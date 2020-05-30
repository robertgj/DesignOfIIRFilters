% chebyshevT_expand_test.m
%
% Copyright (C) 2019-2020 Robert G. Jenssen

test_common;

delete("chebyshevT_expand_test.diary");
delete("chebyshevT_expand_test.diary.tmp");
diary chebyshevT_expand_test.diary.tmp


%
% Test sanity checks
%
try
  at=chebyshevT_expand();
catch
  printf("No arguments exception caught\n");
end_try_catch

at=chebyshevT_expand([]);
if ~isempty(at)
  error("~isempty(at)");
endif

at=chebyshevT_expand(2);
if norm(at-2)~=0
  error("norm(at-2)~=0");
endif

at=chebyshevT_expand(chebyshevT(2));
if norm(at-[0 0 1])~=0
  error("norm(at-[0 0 1])~=0");
endif

at=chebyshevT_expand(chebyshevT(3));
if norm(at-[0 0 0 1])~=0
  error("norm(at-[0 0 0 1])~=0");
endif

%
% Test a low-pass filter design
%
N=10;fap=0.1;fas=0.2;
tol=4e-14;
nw=1000;
f=(0:nw)'/(2*nw);
w=2*pi*f;
cosw=cos(w);
cosNw=cos((0:N).*w);
b=remez(2*N,[0 fap fas 0.5]*2,[1 1 0 0]);
% Calculate complex frequency response
Hf=freqz(b,1,w);
Af=real(Hf.*exp(j*w*N));
if norm(abs(Af)-abs(Hf))>tol
  error("norm(abs(Af)-abs(Hf))(%g)>tol",norm(abs(Af)-abs(Hf)));
endif
bN=[b(N+1);2*b(N:-1:1)]';
% Calculate zero-phase amplitude response
Ac=sum(bN.*cosNw,2);
if norm(Af-Ac)>tol
  error("norm(Af-Ac)(%g)>tol",norm(Af-Ac));
endif
% Find Chebyshev Type 1 coefficients
aN=zeros(1,N+1);
for k=0:N,
  aN=aN+[zeros(1,N-k),bN(1+k)*chebyshevT(k)];
endfor
% Calculate zero-phase frequency response with Chebyshev Type 1 coefficients
Aa=sum(aN.*(cosw.^(N:-1:0)),2);
Ap=polyval(aN,cosw);
if norm(Aa-Ap)>tol
  error("norm(Aa-Ap)(%g)>tol",norm(Aa-Ap));
endif
if norm(Aa-Af)>tol
  error("norm(Aa-Af)(%g)>tol",norm(Aa-Af));
endif
% Check chebyshevT_expand
bN_Texpansion=chebyshevT_expand(aN);
if norm(bN_Texpansion-bN)>tol
  error("norm(bN_Texpansion-bN)>tol");
endif

%
% Test longer expansions
%
for n=1:28,
  bn=bincoeff(n,0:n);
  at=chebyshevT_expand(bn);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor

rand("seed",0xdeadbeef);
for n=1:50
  br=rand(1,n);
  at=chebyshevT_expand(br);
  print_polynomial(at,sprintf("at%02d",n),"%15.8g");
endfor
  
% Done
diary off
movefile chebyshevT_expand_test.diary.tmp chebyshevT_expand_test.diary;
