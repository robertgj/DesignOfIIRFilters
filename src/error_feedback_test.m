% error_feedback_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("error_feedback_test.diary");
unlink("error_feedback_test.diary.tmp");
diary error_feedback_test.diary.tmp

format short e

strf="error_feedback_test";

% 6th order narrorband lowpass filter
P=[0.9723-i*0.1989 0.9389-i*0.1623 0.9152-i*0.0646];
Z=[0.8919-i*0.3918 0.7572-i*0.6666 1.0167-i*0.0404];
q=[0.0047079 -0.0251014 0.0584417 -0.0760820 0.0584417 -0.0251014 0.0047079];
p=[1 -5.6526064 13.3817570 -16.9792460 12.1764710 -4.6789191 0.7525573];
N=length(p)-1;

% Plot response
[H,w]=freqz(q,p,1024);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -60 3]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
print(strcat(strf,"_calculated_response"),"-dpdflatex");
close

% Convert to direct form state-space filter
[A,B,C,D]=tf2Abcd(q,p);

% Noise gain of direct form state-space filter
[K,W]=KW(A,B,C,D);
ng=diag(K)'*diag(W)

% Noise gain of globally optimised state-space filter
delta=1;
[Topt,Kopt,Wopt]=optKW(K,W,delta);
ngopt=diag(Kopt)'*diag(Wopt)

% Noise gain of orthogonal state-space filter
[G0prime,Tk,Fk,Fsign]=orthogonaliseTF(q,p);
Tprime=eye(size(G0prime));
for k=1:length(Tk)
  Tprime=Tprime*Tk{k};
endfor
Fdoubleprime=Fsign;
for k=length(Fk):-1:1
  Fdoubleprime=Fdoubleprime*Fk{k}';
endfor
Gdoubleprime=G0prime*Fdoubleprime;
Aorth=Gdoubleprime(1:N,1:N);
Borth=Gdoubleprime(1:N,N+1);
Corth=Gdoubleprime(N+1,1:N);
Dorth=Gdoubleprime(N+1,N+1);
[qorth,porth]=Abcd2tf(Aorth,Borth,Corth,Dorth);
if max(abs(qorth-q)) > 2*eps
error("max(abs(qorth-q)) > 2*eps");
endif
if max(abs(porth-p)) > 50*eps
error("max(abs(porth-p)) > 50*eps");
endif
[Korth,Worth]=KW(Aorth,Borth,Corth,Dorth);
ngorth=diag(Korth)'*diag(Worth)
if max(max(abs(Aorth*Korth*Aorth'+Borth*Borth'-Korth))) > 20*eps
  error("max(max(abs(Aorth*Korth*Aorth'+Borth*Borth'-Korth))) > 20*eps");
endif
if max(max(abs(Aorth'*Worth*Aorth+Corth'*Corth-Worth))) > 20*eps
  error("max(max(abs(Aorth'*Worth*Aorth+Corth'*Corth-Worth))) > 20*eps");
endif

% Noise gain of input balanced state-space filter
[U,S,V]=svd(Korth*Worth);
Aib=U'*Aorth*U;
Bib=U'*Borth;
Cib=Corth*U;
Dib=Dorth;
[qib,pib]=Abcd2tf(Aib,Bib,Cib,Dib);
if max(abs(qib-q)) > 2*eps
error("max(abs(qib-q)) > 2*eps");
endif
if max(abs(pib-p)) > 300*eps
error("max(abs(pib-p)) > 300*eps");
endif
Kib=diag(diag(U'*Korth*U));
Wib=diag(diag(U'*Worth*U));
if max(max(abs(Aib*Kib*Aib'+Bib*Bib'-Kib))) > 60*eps
  error("max(max(abs(Aib*Kib*Aib'+Bib*Bib'-Kib))) > 60*eps");
endif
if max(max(abs(Aib'*Wib*Aib+Cib'*Cib-Wib))) > 50*eps
  error("max(max(abs(Aib'*Wib*Aib+Cib'*Cib-Wib))) > 50*eps");
endif
ngib=diag(Kib)'*diag(Wib)
est_nvib=sqrt((1+(delta*delta*ngib))/12)

% Simulate input balanced structure
rand("seed",0xdeadbeef);
u=rand(2^14,1)-0.5;
u=u/(std(u)*delta);
bits=8;
scale=2^(bits-1);
u=round(u*scale);
[yib,xxib]=svf(Aib,Bib,Cib,Dib,u,"none");
[yibf,xxibf]=svf(Aib,Bib,Cib,Dib,u,"round");
nvibf=std(yibf-yib)
nfpts=4096;
nppts=(0:((nfpts/2)-1));
Hibf=crossWelch(u,yibf,nfpts);
plot(nppts/nfpts,20*log10(abs(Hibf)));
axis([0 0.5 -60 3]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
print(strcat(strf,"_simulated_input_balanced_response"),"-dpdflatex");
close

% Estimate noise voltage with error feedback using the residue modes
Pib=((eye(N,N)-Aib)'*Wib) + (Wib*(eye(N,N)-Aib));
[Uib,Sib,Vib]=svd(Pib);
rho=sqrt(diag(Sib))
Pi=diag(sqrt(1./rho)*sqrt(sum(rho)/N));
R0=sqrt(Pi);
if max(max(abs(R0*diag(1./diag(Pi))*R0'-eye(N,N))))-eps
  error("max(max(abs(R0*diag(1./diag(Pi))*R0'-eye(N,N))))-eps");
endif
R1=Uib;
R1'*Pib*R1;
Tpi=R1*Pi*R0';
Api=inv(Tpi)*Aib*Tpi;
Bpi=inv(Tpi)*Bib;
Cpi=Cib*Tpi;
Dpi=Dib;
[qpi,ppi]=Abcd2tf(Api,Bpi,Cpi,Dpi);
if max(abs(qpi-q)) > 3*eps
error("max(abs(qpi-q)) > 3*eps");
endif
if max(abs(ppi-p)) > 300*eps
error("max(abs(ppi-p)) > 300*eps");
endif
Kpi=inv(Tpi)*Kib*inv(Tpi');
Wpi=Tpi'*Wib*Tpi;
if max(max(abs(Api*Kpi*Api'+Bpi*Bpi'-Kpi))) > 200*eps
  error("max(max(abs(Api*Kpi*Api'+Bpi*Bpi'-Kpi))) > 200*eps");
endif
if max(max(abs(Api'*Wpi*Api+Cpi'*Cpi-Wpi))) > 200*eps
  error("max(max(abs(Api'*Wpi*Api+Cpi'*Cpi-Wpi))) > 200*eps");
endif
ngpi=diag(Kpi)'*diag(Wpi)
gI=sum(rho)/sqrt(N)
est_nvgI=sqrt((1+(delta*delta*gI))/12)

% Simulate input balanced error feedback structure
[ypilpe,xxpilpe]=svf(Api,Bpi,Cpi,Dpi,u,"none");
[ypilpef,xxpilpef]=svf(Api,Bpi,Cpi,Dpi,u,"lpe",2);
nvpilpef=std(ypilpef-ypilpe)
Hpif=crossWelch(u,ypilpef,nfpts);
plot(nppts/nfpts,20*log10(abs(Hpif)));
axis([0 0.5 -60 3]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
print(strcat(strf,"_simulated_error_feedback_response"),"-dpdflatex");
close

diary off
movefile error_feedback_test.diary.tmp error_feedback_test.diary;
