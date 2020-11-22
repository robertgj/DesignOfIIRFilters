% ellip20OneMPAMB_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("ellip20OneMPAMB_test.diary");
delete("ellip20OneMPAMB_test.diary.tmp");
diary ellip20OneMPAMB_test.diary.tmp

tol=4e-6;
nplot=1024;
strf="ellip20OneMPAMB_test";

% Prototype lowpass (fp=0.5 corresponds to 0.5*Fs/2)
[b,a]=ellip(5,0.5,40,2*0.25);
% Lowpass to double bandpass transformation
phi=[0.05 0.125 0.175 0.225];
print_polynomial(phi,"phi",strcat(strf,"_phi_coef.m"),"%5.3f");
p=phi2p(phi);
[B,A]=tfp2g(b,a,p,-1);
% Ensure that all zeros are on the unit circle
[x,U,V,M,Q]=tf2x(B,A);
x(1+(1:U))=x(1+(1:U))./abs(x(1+(1:U)));
x(1+U+V+(1:(M/2)))=1;
[B,A]=x2tf(x,U,V,M,Q,1);
print_polynomial(B,"B",strcat(strf,"_B_coef.m"),"%16.10f");
print_polynomial(A,"A",strcat(strf,"_A_coef.m"),"%16.10f");

% Convert to the difference of parallel allpass filters
Bp=conv(B,[1;-1]);
Ap=conv(A,[1;-1]);
Q=spectralfactor(Bp,Ap)(:);
Qp=deconv(Q,[1;-1]);
print_polynomial(Qp,"Qp",strcat(strf,"_Qp_coef.m"),"%16.10f");
f=(0:(nplot-1))'*0.5/nplot;
w=f*2*pi;
H=freqz(B,A,w);
G=freqz(Qp,A,w);
if max(abs(abs(H+G)-1))>tol
  error("max(abs(abs(H+G)-1))(%g)>tol(%g)",max(abs(abs(H+G)-1)),tol);
endif
BQp=B+Qp;
Z=qroots(BQp)
A1=[1];
A2=[1];
for m=1:length(Z)
  if abs(Z(m)) == 1
    error("All-pass pole on unit circle!");
  elseif abs(Z(m)) > 1
    A1=conv(A1, [-1/Z(m) 1]);
  else
    A2=conv(A2, [-Z(m) 1]);
  endif
endfor
print_polynomial(A1,"A1",strcat(strf,"_A1_coef.m"),"%16.10f");
print_polynomial(A2,"A2",strcat(strf,"_A2_coef.m"),"%16.10f");

% Implement the all-pass filters as Schur one-multiplier lattice filters
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(A1,fliplr(A1));
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(A2,fliplr(A2));
print_polynomial(k1,"k1");
print_polynomial(epsilon1,"epsilon1","%2d");
print_polynomial(k2,"k2");
print_polynomial(epsilon2,"epsilon2","%2d");

% Check parallel all-pass filter response
[Aap1,Bap1,~,~,Cap1,Dap1]=schurOneMlattice2Abcd(k1,epsilon1,p1,zeros(size(c1)));
Hap1=schurOneMlattice2H(w,Aap1,Bap1,Cap1,Dap1);
[Aap2,Bap2,~,~,Cap2,Dap2]=schurOneMlattice2Abcd(k2,epsilon2,p2,zeros(size(c2)));
Hap2=schurOneMlattice2H(w,Aap2,Bap2,Cap2,Dap2);
if max(abs(((Hap1-Hap2)/2)-H))>tol
  error("max(abs((Hap1-Hap2)/2)-H)(%g)>tol(%g)",max(abs(((Hap1-Hap2)/2)-H)),tol);
endif

% Quantise to 10-bit 3-signed-digits
nbits=8
scale=2^(nbits-1)
ndigits=4
k1sd=flt2SD(k1, nbits, ndigits);
k2sd=flt2SD(k2, nbits, ndigits);
print_polynomial(k1sd,"k1sd",scale);
print_polynomial(k2sd,"k2sd",scale);
% Calculate parallel all-pass filter response with signed-digit coefficients
[Aap1,Bap1,~,~,Cap1,Dap1]=schurOneMlattice2Abcd ...
                            (k1sd,epsilon1,p1,zeros(size(c1)));
Hap1sd=schurOneMlattice2H(w,Aap1,Bap1,Cap1,Dap1);
[Aap2,Bap2,~,~,Cap2,Dap2]=schurOneMlattice2Abcd ...
                            (k2sd,epsilon2,p2,zeros(size(c2)));
Hap2sd=schurOneMlattice2H(w,Aap2,Bap2,Cap2,Dap2);
Hapsd=(Hap1sd-Hap2sd)/2;

% Noise gain for the allpass filters
[~,A1ng]=schurOneMlatticeRetimedNoiseGain ...
           (k1sd,epsilon1,p1,zeros(size(c1)),"schur")
[~,A2ng]=schurOneMlatticeRetimedNoiseGain ...
           (k2sd,epsilon2,p2,zeros(size(c2)),"schur")

% Make a quantised noise signal with standard deviation 0.25*2^nbits
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter
[yap1sd,~,xx1sd]=schurOneMlatticeFilter ...
                   (k1sd,epsilon1,p1,zeros(size(c1)),u,"none");
[yap2sd,~,xx2sd]=schurOneMlatticeFilter ...
                   (k2sd,epsilon2,p2,zeros(size(c2)),u,"none");
[yap1sdf,~,xx1sdf]=schurOneMlatticeFilter ...
                     (k1sd,epsilon1,p1,zeros(size(c1)),u,"round");
[yap2sdf,~,xx2sdf]=schurOneMlatticeFilter ...
                     (k2sd,epsilon2,p2,zeros(size(c2)),u,"round");

% Round the summed outputs
yapsd=0.5*(yap1sd-yap2sd);
yapsdf=round(0.5*(yap1sdf-yap2sdf));

% Find output round-off noise variance at the output
est_varyap1sd=(1+A1ng)/12
varyap1sd=var(yap1sd-yap1sdf)
est_varyap2sd=(1+A2ng)/12
varyap2sd=var(yap2sd-yap2sdf)
est_varysd=(2 + 0.25*(A1ng+A2ng))/12
varyapsd=var(yapsd-yapsdf)

% Check state variable std. deviation
A1stdxf=std(xx1sdf)
A2stdxf=std(xx2sdf)

% Plot frequency response
Hsd=crossWelch(u,yapsdf,2*nplot);
plot(f,20*log10(abs(Hsd)),"-", ...
     f,20*log10(abs(Hapsd)),"--", ...
     f,20*log10(abs(H)),"-.");
ylabel("Amplitude (dB)")
axis([0 0.5 -50 5])
xlabel("Frequency")
grid("on");
legend("simulated(s-d)","calculated(s-d)","exact");
legend("boxoff");

print(strcat(strf,"_response"),"-dpdflatex");
close

% Save results
print_polynomial(k1,"k1");
print_polynomial(epsilon1,"epsilon1","%2d");
print_polynomial(k2,"k2");
print_polynomial(epsilon2,"epsilon2","%2d");
print_polynomial(k1sd,"k1sd",scale);
print_polynomial(k2sd,"k2sd",scale);

print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(epsilon1,"epsilon1",strcat(strf,"_epsilon1_coef.m"),"%2d");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(k1sd,"k1sd",strcat(strf,"_k1sd_coef.m"),scale);
print_polynomial(k2sd,"k2sd",strcat(strf,"_k2sd_coef.m"),scale);

% Done
diary off
movefile ellip20OneMPAMB_test.diary.tmp ellip20OneMPAMB_test.diary;
