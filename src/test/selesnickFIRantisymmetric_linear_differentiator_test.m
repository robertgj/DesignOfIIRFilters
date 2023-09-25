% selesnickFIRantisymmetric_linear_differentiator_test.m
% Copyright (C) 2020-2023 Robert G. Jenssen

test_common;

delete("selesnickFIRantisymmetric_linear_differentiator_test.diary");
delete("selesnickFIRantisymmetric_linear_differentiator_test.diary.tmp");
diary selesnickFIRantisymmetric_linear_differentiator_test.diary.tmp

strf="selesnickFIRantisymmetric_linear_differentiator_test";

%  
% Initialise
%
nplot=1024;
f=((0:(nplot-1))')*0.5/nplot;
w=2*pi*f;


%
% Reproduce Table I
%
L=10;
C=zeros(L+1,4);
for K=0:3,
  N=K+(2*L)+2;
  [~,C(:,K+1)]=selesnickFIRantisymmetric_linear_differentiator(N,K);
  print_polynomial(C(:,K+1),sprintf("cL10K%d",K),"%14.11f");
  print_polynomial(C(:,K+1),sprintf("cL10K%d",K), ...
                   sprintf("%s_cL10K%d_coef.m",strf,K),"%14.11f");
endfor

%
% Filter design with length N even, order N-1 odd
%
N=30;
nheven=7;
heven=cell(nheven,1);
Heven=zeros(nplot,nheven);
for k=1:nheven,
  K=(k-1)*4;
  heven{k}.K=K;
  heven{k}.N=N;
  [heven{k}.h,heven{k}.c]=selesnickFIRantisymmetric_linear_differentiator(N,K);
  Heven(:,k)=freqz(heven{k}.h,1,w);
  print_polynomial(heven{k}.h,sprintf("hN30K%02d",K),"%14.11f");
  print_polynomial(heven{k}.h,sprintf("hN30K%02d",K), ...
                   sprintf("%s_hN30K%02d_coef.m",strf,K),"%14.11f");
endfor

% Plot
plot(w*0.5/pi,abs(Heven));
strt=sprintf("Selesnick maximally-linear FIR differentiator : \
N=%d,K=0,4,8,12,16,20 and 24",N);
title(strt);
axis([0 0.5 -0.1 3]);
xlabel("Frequency");
ylabel("Amplitude");
grid("on");
legend("K=0","K=4","K=8","K=12","K=16","K=20","K=24");
legend("boxoff");
legend("right");
legend("location","northwest");
print(strcat(strf,"_N30_response"),"-dpdflatex");
close

%
% Filter design with length N odd, order N-1 even
%
N=31;
nhodd=7;
hodd=cell(nhodd,1);
for k=1:nhodd,
  K=1+((k-1)*4);
  hodd{k}.K=K;
  hodd{k}.N=N;
  [hodd{k}.h,hodd{k}.c]=selesnickFIRantisymmetric_linear_differentiator(N,K);
  Hodd(:,k)=freqz(hodd{k}.h,1,w);
  print_polynomial(hodd{k}.h,sprintf("hN31K%02d",K),"%14.11f");
  print_polynomial(hodd{k}.h,sprintf("hN31K%02d",K), ...
                   sprintf("%s_hN31K%02d_coef.m",strf,K),"%14.11f");
endfor

% Plot
plot(w*0.5/pi,abs(Hodd));
strt=sprintf("Selesnick maximally-linear FIR differentiator : \
N=%d,K=1,5,9,13,17,21 and 25",N);
title(strt);
axis([0 0.5 -0.1 3]);
xlabel("Frequency");
ylabel("Amplitude");
grid("on");
legend("K=1","K=5","K=9","K=13","K=17","K=21","K=25");
legend("boxoff");
legend("right");
legend("location","northwest");
print(strcat(strf,"_N31_response"),"-dpdflatex");
close

save selesnickFIRantisymmetric_linear_differentiator_test.mat C hodd heven

%
% Done
%
diary off
movefile selesnickFIRantisymmetric_linear_differentiator_test.diary.tmp ...
         selesnickFIRantisymmetric_linear_differentiator_test.diary;

