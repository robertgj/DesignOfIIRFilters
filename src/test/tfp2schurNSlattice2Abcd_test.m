% tfp2schurNSlattice2Abcd_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Script for testing frequency transformations

test_common;

strf="tfp2schurNSlattice2Abcd_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));


function plot_response(B,A,fname)
  [h,w]=freqz(B,A,2048);
  subplot(211);
  plot(0.5*w/pi,20*log10(abs(h)))
  axis([0 0.5 -50 5]);
  grid("on");
  ylabel("Amplitude(dB)")
  subplot(212);
  plot(0.5*w/pi,20*log10(abs(h)))
  axis([0 0.5 -0.7 0.1]);
  grid("on");
  ylabel("Amplitude(dB)")
  xlabel("Frequency")
  print(fname,"-dpdflatex");
  close
endfunction

% Prototype lowpass (fp=0.25 corresponds to 0.5*Fs/2)
delta=4;
norder=5;
fpass=0.25;
dBpass=0.5;
dBstop=40;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
plot_response(n0,d0,"tfp2schurNSlattice2Abcd_test_lpproto");
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[a,b,c,d]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[k,w]=KW(a,b,c,d);
[topt,kopt,wopt]=optKW(k,w,delta);
aopt=inv(topt)*a*topt;
bopt=inv(topt)*b;
copt=c*topt;
dopt=d;
ng_opt=sum(diag(kopt).*diag(wopt))

% Low-pass to multi-band-stop specification
phi=[0.1 0.15 0.2 0.25 0.3 0.35];
s=1;
p=phi2p(phi);

% Allpass transformation
[ps10,ps11,ps20,ps00,ps02,ps22]=tf2schurNSlattice(p(length(p):-1:1),s*p);
[Alpha,Beta,dummy1,dummy2,Gamma,Delta]=...
schurNSlattice2Abcd(ps10,ps11,ps20,ps00,ps02,ps22);
[n1,d1]=Abcd2tf(Alpha,Beta,Gamma,Delta);
if norm(n1(:)-flipud(p(:)))>10*eps
  error("norm(n1-flipud(p))>10*eps")
endif
if norm(d1-p)>10*eps
  error("norm(d1-p)>10*eps")
endif
[pK,pW]=KW(Alpha,Beta,Gamma,Delta);
Q=eye(size(Alpha));
if norm(pK-Q)>100*eps
  error("norm(pk-Q)>100*eps")
endif
if norm(pK-pW)>100*eps
  error("norm(pk-pW)>100*eps")
endif

% Bandpass filter
[A,B,C,D]=tfp2schurNSlattice2Abcd(n0,d0,p,s,delta)
ABCD_nz_coefs=sum(sum(abs([A,B;C,D])>eps))
[K,W]=KW(A,B,C,D);
[N1,D1]=Abcd2tf(A,B,C,D);
plot_response(N1,D1,"tfp2schurNSlattice2Abcd_test_ABCD");
if norm(K-kron(kopt,Q))>100*eps
  error("norm(K-kron(kopt,Q))>100*eps")
endif
if norm(W-kron(wopt,Q))>5000*eps
  error("norm(W-kron(wopt,Q))>5000*eps")
endif
NG_ABCD=sum(diag(K).*diag(W))

% Globally optimised
[Topt,Kopt,Wopt]=optKW(K,W,delta);
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;
ABCDopt_nz_coefs=sum(sum(abs([Aopt,Bopt;Copt,Dopt])>eps))
NG_ABCDopt=sum(diag(Kopt).*diag(Wopt))

% Schur NS lattice
[S10,S11,S20,S00,S02,S22,CC,SS]=tf2schurNSlattice(N1,D1);
NG_schurNS=schurNSlatticeNoiseGain(SS,S10,S11,S20,S00,S02,S22, ...
                                   D1,N1,zeros(size(D1)))
% Make a noise signal with standard deviation 0.25*2^nbits
nbits=16;
scale=2^(nbits-1);
nsamples=2^12;
n60=p2n60(D1);
rand("seed",0xdeadbeef);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);
% Simulate filter
[yap,y,xx]=schurNSlatticeFilter(S10,S11,S20,S00,S02,S22,u,"none");
[yapf,yf,xxf]=schurNSlatticeFilter(S10,S11,S20,S00,S02,S22,u,"round");
% Remove initial transient
Rn60=(n60+1):length(u);
ub=u(Rn60);
yap=yap(Rn60);
y=y(Rn60);
xx=xx(Rn60,:);
yapf=yapf(Rn60);
yf=yf(Rn60);
xxf=xxf(Rn60,:);
% Variance
est_varyd=(1+NG_schurNS)/12
varyd=var(y-yf)
% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(ub,yf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print(strcat(strf,"_schurNS"),"-dpdflatex");
close

% Schur One-multiplier lattice
[KK,EE,PP,CC,SS]=tf2schurOneMlattice(N1,D1);
NG_schurOneM=schurOneMlatticeNoiseGain(SS,KK,EE,PP,CC,D1,N1,zeros(size(D1)))
% Simulate filter
[yap,y,xx]=schurOneMlatticeFilter(KK,EE,PP,CC,u,"none");
[yapf,yf,xxf]=schurOneMlatticeFilter(KK,EE,PP,CC,u,"round");
% Remove initial transient
yap=yap(Rn60);
y=y(Rn60);
xx=xx(Rn60,:);
yapf=yapf(Rn60);
yf=yf(Rn60);
xxf=xxf(Rn60,:);
% Variance
est_varyd=(1+NG_schurOneM)/12
varyd=var(y-yf)
% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(ub,yf,nfpts);
H=freqz(N1,D1,nfpts/2);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print(strcat(strf,"_schurOneM"),"-dpdflatex");
close

% Make a LaTeX table for noise performance
fname=sprintf("%s.tab",strf);
fid=fopen(fname,"wt");
fprintf(fid,"\\begin{table}[hptb]\n");
fprintf(fid,"\\centering\n");
fprintf(fid,"\\begin{threeparttable}\n");
fprintf(fid,"\\begin{tabular}{lrrr}  \\toprule\n");
fprintf(fid,"&Non-zero coefficients&Noise gain&Noise variance(bits)\\\\ \n");
fprintf(fid,"\\midrule\n");
fprintf(fid,"ABCD transformed & %d & %5.2f & %5.2f \\\\ \n",
        ABCD_nz_coefs,NG_ABCD,(1+NG_ABCD)/12);
fprintf(fid,"Globally optimised & %d & %5.2f & %5.2f \\\\ \n",
        ABCDopt_nz_coefs,NG_ABCDopt,(1+NG_ABCDopt)/12);
fprintf(fid,"Schur normalised-scaled lattice & %d & %5.2f & %5.2f \\\\ \n", ...
        6*length(S10),NG_schurNS,(1+NG_schurNS)/12);
fprintf(fid,"Schur one-multiplier lattice & %d & %5.2f & %5.2f \\\\ \n", ...
        length(KK)+length(CC),NG_schurOneM,(1+NG_schurOneM)/12);
fprintf(fid,"\\bottomrule\n");
fprintf(fid,"\\end{tabular}\n");
fprintf(fid,"\\end{threeparttable}\n");
fprintf(fid,"\\caption[Schur NS lattice frequency transformation example]");
fprintf(fid,"{Schur NS lattice frequency transformation round-off noise \
example : number of non-zero coefficients, noise gain and estimated output \
roundoff noise variances for a prototype 5th order elliptic low-pass filter \
transformed to a multiple band-stop filter.}\n");
fprintf(fid,"\\label{tab:Schur-NS-lattice-frequency-transformation-example}\n");
fprintf(fid,"\\end{table}\n");
fclose(fid);

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
