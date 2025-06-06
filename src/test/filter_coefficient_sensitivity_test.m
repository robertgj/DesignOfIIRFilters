% filter_coefficient_sensitivity_test.m
%
% Plot the coefficient sensitivity of various digital filter structures.
% Write a separate tf2sensitivity function for each filter type and then
% loop over a cell array of structures with tf2sensitivity function handle
% and description string. This script tests direct-form FIR, direct-form IIR,
% Schur one-multiplier tapped lattice IIR and parallel all-pass Schur
% one-multiplier lattice IIR filters.
%
% Other filter types to look at:
%    direct-form FIR
%    second-order cascade FIR
%    second-order cascade IIR
%    gain-pole-zero FIR
%    gain-pole-zero IIR
%    globally optimised state-variable IIR
%    parallel all-pass gain-pole-zero
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="filter_coefficient_sensitivity_test";
                                           
delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

tol=1e-12;

% Filter specification
norder=5;
fpass=0.125;
dBstop=40;
fstop=0.15;
dBpass=1;
Wstop=6;

% Frequency vectors
npoints=1000;
f=(0:(npoints-1))'/(2*npoints);
w=2*pi*f;
npass=ceil(npoints*fpass/0.5)+1;
nstop=floor(npoints*fstop/0.5)+1;
Rpass=1:npass;
Rstop=nstop:length(w);

% Design an elliptic low pass direct-form IIR filter
[n0,d0]=ellip(norder,dBpass,dBstop,2*fpass);
H0_IIR_check=freqz(n0,d0,w);
T0_IIR_check=delayz(n0,d0,w);
[A0_IIR,B0_IIR,C0_IIR,D0_IIR,dA0_IIRdx,dB0_IIRdx,dC0_IIRdx,dD0_IIRdx]= ...
  tf2Abcd(n0,d0);
ng_IIR=Abcd2ng(A0_IIR,B0_IIR,C0_IIR,D0_IIR);
[H0_IIR,dH0_IIRdw,dH0_IIRdx,d2H0_IIRdwdx]= ...
  Abcd2H(w,A0_IIR,B0_IIR,C0_IIR,D0_IIR,dA0_IIRdx,dB0_IIRdx,dC0_IIRdx,dD0_IIRdx);
[Asq0_IIR,gradAsq0_IIR]=H2Asq(H0_IIR,dH0_IIRdx);
[T0_IIR,gradT0_IIR]=H2T(H0_IIR,dH0_IIRdw,dH0_IIRdx,d2H0_IIRdwdx);
% Check
if max(abs(H0_IIR-H0_IIR_check)) > tol
  error("max(abs(H0_IIR-H0_IIR_check))(%g*tol) > tol", ...
        max(abs(H0_IIR-H0_IIR_check))/tol);
endif
if max(abs(Asq0_IIR-abs(H0_IIR_check).^2)) > tol
  error("max(abs(Asq0_IIR-abs(H0_IIR_check).^2))(%g*tol) > tol", ...
        max(abs(Asq0_IIR-abs(H0_IIR_check).^2))/tol);
endif
if max(abs(T0_IIR(Rpass)-T0_IIR_check(Rpass))) > 100*tol
  error("max(abs(T0_IIR(Rpass)-T0_IIR_check(Rpass)))(%g*tol) > 100*tol", ...
        max(abs(T0_IIR(Rpass)-T0_IIR_check(Rpass)))/tol);
endif
% Plot
Rn=1:length(n0);
Rd=(length(n0)+1):(length(n0)+length(d0)-1);
% Elliptic filter frequency response
subplot(211);
plot(w*0.5/pi,20*log10(abs(H0_IIR)));
axis([0 0.5 -50 10])
grid("on")
ylabel("Amplitude(dB)");
tstr=sprintf ...
       ("Elliptic filter : norder=%d,fpass=%g,dBpass=%g,fstop=%g,dBstop=%g",...
        norder,fpass,dBpass,fstop,dBstop);
title(tstr);
subplot(212);
plot(w*0.5/pi,T0_IIR);
axis([0 0.5 0 40])
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_elliptic_response"),"-dpdflatex");
close
% Elliptic filter sensitivity
subplot(211)
[ax,hp,hs]=plotyy(w(Rpass)*0.5/pi,gradAsq0_IIR(Rpass,:), ...
                  w(Rstop)*0.5/pi,gradAsq0_IIR(Rstop,:));
% Copy line colour
hpc=get(hp,"color");
for c=1:columns(gradAsq0_IIR)
  set(hs(c),"color",hpc{c});
endfor
axis(ax(1),[0 0.5 -300 300]);
axis(ax(2),[0 0.5 -0.15 0.15]);
grid("on");
tstr=sprintf(["Elliptic filter sensitivity : ", ...
              "norder=%d, fpass=%g,dBpass=%g,fstop=%g,dBstop=%g"], ...
              norder,fpass,dBpass,fstop,dBstop);
title(tstr);
ylabel("$|A|^2$ sensitivity");
subplot(212)
plot(w(Rpass)*0.5/pi,gradT0_IIR(Rpass,:));
axis([0 0.5 -4000 4000]);
grid("on");
ylabel("Delay sensitivity");
xlabel("Frequency");
print(strcat(strf,"_elliptic_sensitivity"),"-dpdflatex");
close

% Convert direct-form to Schur one-multiplier tapped-lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);
[A0_S1M,B0_S1M,C0_S1M,D0_S1M]=schurOneMlattice2Abcd(k0,epsilon0,p0,c0);
ng_S1M=Abcd2ng(A0_S1M,B0_S1M,C0_S1M,D0_S1M);
[Asq0_S1M,gradAsq0_S1M]=schurOneMlatticeAsq(w,k0,epsilon0,p0,c0);
[T0_S1M,gradT0_S1M]=schurOneMlatticeT(w,k0,epsilon0,p0,c0);
if max(abs(Asq0_S1M-abs(H0_IIR_check).^2)) > tol
  error("max(abs(Asq0_S1M-abs(H0_IIR_check).^2))(%g*tol) > tol", ...
        max(abs(Asq0_S1M-abs(H0_IIR_check).^2))/tol);
endif
if max(abs(T0_S1M(Rpass)-T0_IIR_check(Rpass))) > 100*tol
  error("max(abs(T0_S1M(Rpass)-T0_IIR_check(Rpass)))(%g*tol) > 100*tol", ...
        max(abs(T0_S1M(Rpass)-T0_IIR_check(Rpass)))/tol);
endif
% Schur One-Multiplier elliptic filter sensitivity
subplot(211)
[ax,hp,hs]=plotyy(w(Rpass)*0.5/pi,gradAsq0_S1M(Rpass,:), ...
                  w(Rstop)*0.5/pi,gradAsq0_S1M(Rstop,:));
% Copy line colour
hpc=get(hp,"color");
for c=1:columns(gradAsq0_S1M)
  set(hs(c),"color",hpc{c});
endfor
axis(ax(1),[0 0.5 -40 80]);
axis(ax(2),[0 0.5 -0.02 0.04]);
grid("on");
tstr=sprintf(["Schur one-multiplier elliptic filter sensitivity : ", ...
              "norder=%d, fpass=%g,dBpass=%g,fstop=%g,dBstop=%g"], ...
              norder,fpass,dBpass,fstop,dBstop);
title(tstr);
ylabel("$|A|^2$ sensitivity");
subplot(212)
plot(w(Rpass)*0.5/pi,gradT0_S1M(Rpass,:));
axis([0 0.5 -1500 1500]);
grid("on");
ylabel("Delay sensitivity");
xlabel("Frequency");
print(strcat(strf,"_schur_one_multiplier_elliptic_sensitivity"),"-dpdflatex");
close

% Convert direct-form to parallel Schur one-multiplier all-pass lattice
[a0,b0]=tf2pa(n0,d0);
[A1k0,A1epsilon0,A1p0,~]=tf2schurOneMlattice(fliplr(a0),a0);
[A2k0,A2epsilon0,A2p0,~]=tf2schurOneMlattice(fliplr(b0),b0);
[A1_PA,B1_PA,C1_PA,D1_PA]=schurOneMAPlattice2Abcd(A1k0,A1epsilon0,A1p0);
[A2_PA,B2_PA,C2_PA,D2_PA]=schurOneMAPlattice2Abcd(A2k0,A2epsilon0,A2p0);
A12_PA=[A1_PA,zeros(rows(A1_PA),columns(A2_PA)); ...
        zeros(rows(A2_PA),columns(A1_PA)),A2_PA];
B12_PA=[B1_PA;B2_PA];
C12_PA=[C1_PA,C2_PA]/2;
D12_PA=(D1_PA+D2_PA)/2;
H12_PA=Abcd2H(w,A12_PA,B12_PA,C12_PA,D12_PA);
ng_PA=Abcd2ng(A12_PA,B12_PA,C12_PA,D12_PA);
[Asq0_PA,gradAsq0_PA]=schurOneMPAlatticeAsq(w,A1k0,A1epsilon0,A1p0, ...
                                            A2k0,A2epsilon0,A2p0);
[T0_PA,gradT0_PA]=schurOneMPAlatticeT(w,A1k0,A1epsilon0,A1p0, ...
                                      A2k0,A2epsilon0,A2p0);
% Sanity checks
if max(abs(abs(H12_PA)-abs(H0_IIR_check))) > tol
  error("max(abs(abs(H12_PA)-abs(H0_IIR_check)))(%g*tol) > tol", ...
        max(abs(abs(H12_PA)-abs(H0_IIR_check)))/tol);
endif
if max(abs(Asq0_PA-abs(H0_IIR_check).^2)) > tol
  error("max(abs(Asq0_PA-abs(H0_IIR_check).^2))(%g*tol) > tol", ...
        max(abs(Asq0_PA-abs(H0_IIR_check).^2))/tol);
endif
if max(abs(T0_PA(Rpass)-T0_IIR_check(Rpass))) > 100*tol
  error("max(abs(T0_PA(Rpass)-T0_IIR_check(Rpass)))(%g*tol) > 100*tol", ...
        max(abs(T0_PA(Rpass)-T0_IIR_check(Rpass)))/tol);
endif
% Plot
% Schur parallel allpass elliptic filter sensitivity
subplot(211)
[ax,hp,hs]=plotyy(w(Rpass)*0.5/pi,gradAsq0_PA(Rpass,:), ...
                  w(Rstop)*0.5/pi,gradAsq0_PA(Rstop,:));
% Copy line colour
hpc=get(hp,"color");
for c=1:columns(gradAsq0_PA)
  set(hs(c),"color",hpc{c});
endfor
axis(ax(1),[0 0.5 -30 30]);
axis(ax(2),[0 0.5 -0.06 0.06]);
grid("on");
tstr=sprintf(["Schur parallel allpass elliptic filter sensitivity : ", ...
              "norder=%d, fpass=%g,dBpass=%g,fstop=%g,dBstop=%g"], ...
              norder,fpass,dBpass,fstop,dBstop);
title(tstr);
ylabel("$|A|^2$ sensitivity");
subplot(212)
plot(w(Rpass)*0.5/pi,gradT0_PA(Rpass,:));
axis([0 0.5 -1000 1000]);
grid("on");
ylabel("Delay sensitivity");
xlabel("Frequency");
print(strcat(strf,"_schur_parallel_allpass_elliptic_sensitivity"),"-dpdflatex");
close

% Design a similar low pass direct-form FIR filter
M=29;
maxiter=100;
h0=remez(2*M,[0 fpass fstop 0.5]*2,[1 1 0 0],[1 Wstop]);
H0_FIR_check=freqz(h0,1,w);
T0_FIR_check=delayz(h0,1,w);
[A0_FIR,B0_FIR,C0_FIR,D0_FIR, ...
 dA0_FIRdx,dB0_FIRdx,dC0_FIRdx,dD0_FIRdx]=tf2Abcd(h0,1);
ng_FIR=Abcd2ng(A0_FIR,B0_FIR,C0_FIR,D0_FIR);
[H0_FIR,dH0_FIRdw,dH0_FIRdx,d2H0_FIRdwdx]=...
  Abcd2H(w,A0_FIR,B0_FIR,C0_FIR,D0_FIR,dA0_FIRdx,dB0_FIRdx,dC0_FIRdx,dD0_FIRdx);
[Asq0_FIR,gradAsq0_FIR]=H2Asq(H0_FIR,dH0_FIRdx);
[T0_FIR,gradT0_FIR]=H2T(H0_FIR,dH0_FIRdw,dH0_FIRdx,d2H0_FIRdwdx);
% Check
if max(abs(Asq0_FIR-abs(H0_FIR_check).^2)) > tol
  error("max(abs(Asq0_FIR-abs(H0_FIR_check).^2))(%g*tol) > tol", ...
        max(abs(Asq0_FIR-abs(H0_FIR_check).^2))/tol);
endif
if max(abs(T0_FIR(Rpass)-T0_FIR_check(Rpass))) > 100*tol
  error("max(abs(T0_FIR(Rpass)-T0_FIR_check(Rpass)))(%g*tol) > 100*tol", ...
        max(abs(T0_FIR(Rpass)-T0_FIR_check(Rpass)))/tol);
endif
% Further check
Rsymm=1:(M+1);
[A0_FIR_direct,gradA0_FIR_direct_symmetric]=directFIRsymmetricA(w,h0(Rsymm));
gradA0_FIR_direct=[gradA0_FIR_direct_symmetric(:,1:M)/2, ...
                   gradA0_FIR_direct_symmetric(:,M+1), ...
                   fliplr(gradA0_FIR_direct_symmetric(:,(1:M)))/2];
gradAsq0_FIR_direct=2*kron(A0_FIR_direct,ones(1,2*M+1)).*gradA0_FIR_direct;
if max(abs(abs(A0_FIR_direct)-abs(H0_FIR))) > tol/10
  error("max(abs(abs(A0_FIR_direct)-abs(H0_FIR)))(%g*tol) > tol/10", ...
        max(abs(abs(A0_FIR_direct)-abs(H0_FIR)))/tol);
endif
if max(max(abs(gradAsq0_FIR-gradAsq0_FIR_direct))) > tol/10
  error(["max(max(abs(gradAsq0_FIR-gradAsq0_FIR_direct)))(%g*tol) > tol/10"],...
        max(max(abs(gradAsq0_FIR-gradAsq0_FIR_direct)))/tol);
endif
% FIR lowpass filter frequency response
plot(w*0.5/pi,20*log10(abs(H0_FIR)));
axis([0 0.5 -50 10])
grid("on")
ylabel("Amplitude(dB)");
xlabel("Frequency");
tstr=sprintf("FIR lowpass filter : M=%d,fpass=%g,fstop=%g,Wstop=%g", ...
             M,fpass,fstop,Wstop);
title(tstr);
print(strcat(strf,"_fir_lowpass_response"),"-dpdflatex");
close
% FIR low-pass filter sensitivity
[ax,hp,hs]=plotyy(w(Rpass)*0.5/pi,gradAsq0_FIR(Rpass,Rsymm), ...
                  w(Rstop)*0.5/pi,gradAsq0_FIR(Rstop,Rsymm));
% Copy line colour
hpc=get(hp,"color");
for c=1:(M+1)
  set(hs(c),"color",hpc{c});
endfor
axis(ax(1),[0 0.5 -3 3]);
axis(ax(2),[0 0.5 -0.03 0.03]);
grid("on");
tstr=sprintf(["FIR low-pass filter sensitivity : ", ...
              "M=%d,fpass=%g,fstop=%g,Wstop=%g"], ...
              M,fpass,fstop,Wstop);
title(tstr);
ylabel("$|A|^2$ sensitivity");
xlabel("Frequency");
print(strcat(strf,"_fir_lowpass_sensitivity"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on response\n",tol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"norder=%d %% Elliptic filter order\n",norder);
fprintf(fid,"M=%d %% Even order FIR filter order is (2*M)+1\n",M);
fprintf(fid,"fpass=%g %% Amplitude pass band edge\n",fpass);
fprintf(fid,"dBpass=%g %% Amplitude pass band peak-to-peak ripple\n",dBpass);
fprintf(fid,"fstop=%g %% Amplitude stop band edge\n",fstop);
fprintf(fid,"dBstop=%g %% Amplitude stop band peak-to-peak ripple\n",dBstop);
fprintf(fid,"Wstop=%g %% FIR filter amplitude stop band weight\n",Wstop);
fclose(fid);

print_polynomial(n0,"n0");
print_polynomial(n0,"n0",strcat(strf,"_n0_coef.m"));
print_polynomial(d0,"d0");
print_polynomial(d0,"d0",strcat(strf,"_d0_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(epsilon0,"epsilon0");
print_polynomial(epsilon0,"epsilon0",strcat(strf,"_epsilon0_coef.m"));
print_polynomial(c0,"c0");
print_polynomial(c0,"c0",strcat(strf,"_c0_coef.m"));
print_polynomial(a0,"a0");
print_polynomial(a0,"a0",strcat(strf,"_a0_coef.m"));
print_polynomial(b0,"b0");
print_polynomial(b0,"b0",strcat(strf,"_b0_coef.m"));
print_polynomial(A1k0,"A1k0");
print_polynomial(A1k0,"A1k0",strcat(strf,"_A1k0_coef.m"));
print_polynomial(A2k0,"A2k0");
print_polynomial(A2k0,"A2k0",strcat(strf,"_A2k0_coef.m"));
print_polynomial(h0,"h0");
print_polynomial(h0,"h0",strcat(strf,"_h0_coef.m"));

eval(sprintf(["save %s.mat tol npoints norder M ", ...
              "fpass dBpass fstop dBstop Wstop ", ...
              "n0 d0 k0 epsilon0 p0 c0 a0 b0 A1k0 A2k0 h0"], ...
             strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
