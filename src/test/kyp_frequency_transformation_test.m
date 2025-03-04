% kyp_frequency_transformation_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Numerical verification of Lemma 2 of "Generalization of Kalman-Yakubovic-Popov
% Lemma for Restricted Frequency Inequalities", T. Iwasaki and S. Hara,
% Proceedings of the American Control Conference, June 4-6, 2003, pp. 3828-3833
%
% The script kyp_symbolic_frequency_transformation_test.m contains a symbolic
% verification of Lemma 2 that is commented out because it takes some minutes

test_common;

strf="kyp_frequency_transformation_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

pkg load signal

fp=100;dBap=1;dBas=40;
f=0:0.1:fp*3;
w=2*pi*f;
a=1;b=2;c=3;d=4;
for n=1:16;
  [A,B,C,D]=ellip(n,dBap,dBas,2*pi*fp,"s");
  
  I=eye(n);
  G=inv((d*I)+(c*A));
  Ac=((b*I)+(a*A))*G;
  Bc=((a*d)-(b*c))*G*B;
  Cc=G;
  Dc=-c*G*B;

  s=j*w;

  T=(b-(d*s))./((c*s)-a);
  H=zeros(rows(B),columns(f));
  Hc=zeros(rows(B),columns(f));
  for k=1:length(f),
    if abs(det((s(k)*I)-Ac)) < 100*eps
      error("abs(det((s(k)*I)-Ac))(%g*eps)<100*eps",abs(det((s(k)*I)-Ac))/eps);
    endif
    H(:,k)=inv((T(k)*I)-A)*B;
    Hc(:,k)=(Cc*inv((s(k)*I)-Ac)*Bc)+Dc;
  endfor
  if max(max(abs(H-Hc)))>1000*eps
    error("max(max(abs(H-Hc)))(%g*eps)>1000*eps",max(max(abs(H-Hc)))/eps);
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
