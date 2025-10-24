% affine_mcclellanFIRsymmetric_lowpass_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen
%
% See: "Exchange Algorithms that Complement the Parks-McClellan Algorithm for
% Linear-Phase FIR Filter Design", Ivan W. Selesnick and C. Sidney Burrus,
% IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND DIGITAL SIGNAL
% PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp. 137-143
%
% Calls the faffine.m function of Ivan Selesnick

test_common;

delete("affine_mcclellanFIRsymmetric_lowpass_test.diary");
delete("affine_mcclellanFIRsymmetric_lowpass_test.diary.tmp");
diary affine_mcclellanFIRsymmetric_lowpass_test.diary.tmp

strf="affine_mcclellanFIRsymmetric_lowpass_test";

% Specification: low pass filter order is 2*M, length is 2*M+1
M=200;fap=0.1;fas=0.11;Kp=1;Ks=0;etap=0;etas=0.0001;

% Filter design
[h,rs,del_p,del_s]=faffine(M,2*pi*fap,2*pi*fas,Kp,Ks,etap,etas);

%
% Plot response
%
strt=sprintf(["Selesnick-Burrus Parks-McClellan lowpass FIR: ", ...
 "M=%d,fap=%g,fas=%g,$K\_p$=%g,$K\_s$=%g,$\\eta\_p$=%g,$\\eta\_s$=%g"], ...
             M,fap,fas,Kp,Ks,etap,etas);
nplot=4000;
wa=(0:(nplot-1))'*pi/nplot;
hM=h(1:(M+1));
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(A))
axis([0 0.5 (20*log10(abs(del_s))-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
pnap=ceil((nplot+1)*fap/0.5)+1;
pnas=floor((nplot+1)*fas/0.5)+1;
ax=plotyy(wa(1:pnap)*0.5/pi,A(1:pnap),wa(pnas:end)*0.5/pi,A(pnas:end));
axis(ax(1),[0 0.5 1-(2*10*del_s) 1+(2*10*del_s)]);
axis(ax(2),[0 0.5 -2*del_s 2*del_s]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Check response at band edges
Hbe=freqz(h,1,2*pi*[fap,fas]);
Abe=abs(Hbe);
tol=1e-14;
if abs(1-Abe(1)-del_p)>tol
  error("abs(1-Abe(1)-del_p)>tol");
endif
if abs(Abe(2)-del_s)>tol
  error("abs(Abe(2)-del_s)>tol");
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Kp=%d %% Pass band weight\n",Kp);
fprintf(fid,"Ks=%d %% Stop band weight\n",Ks);
fprintf(fid,"etap=%d %% Pass band eta\n",etap);
fprintf(fid,"etas=%d %% Stop band eta\n",etas);
fclose(fid);

print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

fid=fopen(strcat(strf,"_del_p.tab"),"wt");
fprintf(fid,"%11.8f",del_p);
fclose(fid);

save affine_mcclellanFIRsymmetric_lowpass_test.mat ...
     M fap fas Kp Ks etap etas nplot del_p del_s h 

%
% Done
%
diary off
movefile affine_mcclellanFIRsymmetric_lowpass_test.diary.tmp ...
         affine_mcclellanFIRsymmetric_lowpass_test.diary;

