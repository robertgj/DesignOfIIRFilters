% directFIRnonsymmetric_socp_slb_bandpass_test.m
%
% Filter design is Figure 4 of: "GENERALIZING THE KYP LEMMA TO MULTIPLE
% FREQUENCY INTERVALS", GOELE PIPELEERS, TETSUYA IWASAKI, AND SHINJI HARA, 
% SIAM J. CONTROL OPTIM., Vol. 52, No. 6, pp. 3618–3638
%
% Copyright (C) 2021-2022 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetric_socp_slb_bandpass_test.diary");
delete("directFIRnonsymmetric_socp_slb_bandpass_test.diary.tmp");
diary directFIRnonsymmetric_socp_slb_bandpass_test.diary.tmp

tic;

strf="directFIRnonsymmetric_socp_slb_bandpass_test";

maxiter=5000
tol=1e-6
ctol=tol/10
verbose=false
n=500

% Band-pass filter specification 
N=30
M=round(N/2);
fasl=0.05
fapl=0.15
fapu=0.25
fasu=0.35
deltap=2e-4
deltas=5e-3
Wap=1
Watl=0
Watu=0
Wasl=1000
Wasu=1000
ftpl=0.15
ftpu=0.25
td=14
tdr=0.02
Wtp=0.1
      
% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(deltas^2)*ones(nasl,1); ...
       ((1+deltap)^2)*ones(nasu-nasl-1,1); ...
       (deltas^2)*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1);((1-deltap)^2)*ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=td*ones(length(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band phase response
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*wa(nchkt)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkt)'/pi);printf("];\n");

% Find initial coefficients
printf("Initial filter designed with hofstetterFIRsymmetric\n");
  % Place 1+deltap at fapl,fapu and -deltas at fasl,fasu
sumfbands=fasl+(fapu-fapl)+(0.5-fasu);
nMp=ceil((M+1)*(fapu-fapl)/sumfbands);
if mod(nMp,2)==1
  nMp=nMp+1;
endif
f0p=linspace(fapl,fapu,nMp+1);
a0p=1+(((-1).^(0:nMp))*deltap);
nMsl=ceil((M+1)*fasl/sumfbands);
f0sl=linspace(0,fasl,nMsl);
a0sl=fliplr(((-1).^(1:nMsl))*deltas);
nMsu=M-nMp-nMsl;
f0su=linspace(fasu,0.5,nMsu);
a0su=((-1).^(1:nMsu))*deltas;
f0=[f0sl,f0p,f0su];
a0=[a0sl,a0p,a0su];
% Filter design
[hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,a0,n,maxiter,tol);
if feasible==false
  error("hofsetterFIRsymmetric hM not feasible");
endif
% Plot initial response
A0=directFIRsymmetricA(wa,hM);
ax=plotyy(wa(napl:napu)*0.5/pi,A0(napl:napu),wa*0.5/pi,A0);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 0.9992 1.0008]);
axis(ax(2),[0 0.5 -0.01 0.01]);
grid("on");
ylabel("Amplitude");
xlabel("Frequency");
strt=sprintf("Initial non-symmetric FIR bandpass : \
fasl=%g,fapl=%g,fapu=%g,fasu=%g,td=%g",fasl,fapl,fapu,fasu,td);
title(strt);
print(strcat(strf,"_initial"),"-dpdflatex");
close

%
% SOCP MMSE optimisation
%
h0=[hM(1:end);hM((end-1):-1:1)];
h_active=find(h0~=0);
try
  [h1,opt_iter,func_iter,feasible]= ...
  directFIRnonsymmetric_socp_mmse([],h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa,...
                                  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                                  maxiter,tol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
end_try_catch
if !feasible
  error("h1 infeasible");
endif

%
% SOCP PCLS optimisation
%
try
  [h,slb_iter,opt_iter,func_iter,feasible]=directFIRnonsymmetric_slb ...
   (@directFIRnonsymmetric_socp_mmse,h1,h_active,wa,Asqd,Asqdu,Asqdl,Wa,...
    wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
end_try_catch
if !feasible
  error("h infeasible");
endif

% Find response
Asq=directFIRnonsymmetricAsq(wa,h);
T=directFIRnonsymmetricT(wa,h);

% Plot response
plot(wa*0.5/pi,10*log10(Asq));
axis([0 0.5 20*log10(deltas)-10 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("FIR non-sym. bandpass : \
N=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,deltap=%g,deltas=%g,tdr=%g", ...
             N,fasl,fapl,fapu,fasu,deltap,deltas,tdr);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot combined passband and stopband response
subplot(411);
plot(wa(1:nasl)*0.5/pi,sqrt(abs(Asq(1:nasl))));
axis([0 fasl 0 0.008]);
ylabel("Amplitude");
grid("on");
title(strt);
subplot(412);
plot(wa(napl:napu)*0.5/pi,sqrt(abs(Asq(napl:napu))));
axis([fapl fapu 1+(deltap*2*[-1 1])]);
ylabel("Amplitude");
grid("on");
subplot(413);
plot(wa(napl:napu)*0.5/pi,T(napl:napu));
axis([fapl fapu td-(tdr) td+(tdr)]);
ylabel("Delay(samples)");
grid("on");
subplot(414);
plot(wa(nasu:end)*0.5/pi,sqrt(Asq(nasu:end)));
axis([fasu 0.5 0 0.008]);
ylabel("Amplitude");
grid("on");
xlabel("Frequency");
print(strcat(strf,"_pass_stop"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(h),[]);
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

%
% Save results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"fapl=%g %% Pass band squared amplitude lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band squared amplitude upper edge\n",fapu);
fprintf(fid,"deltap=%d %% Pass band amplitude peak ripple\n",deltap);
fprintf(fid,"Wap=%d %% Pass band squared amplitude weight\n",Wap);
fprintf(fid,"fasl=%g %% Lower stop band squared amplitude lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Upper stop band squared amplitude upper edge\n",fasu);
fprintf(fid,"deltas=%d %% Stop band amplitude response peak ripple\n",deltas);
fprintf(fid,"Watl=%d %% Lower transition band squared amplitude weight\n",Watl);
fprintf(fid,"Watu=%d %% Upper transition band squared amplitude weight\n",Watu);
fprintf(fid,"Wasl=%d %% Lower stop band squared amplitude weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band squared amplitude weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group delay response upper edge\n",ftpu);
fprintf(fid,"td=%d %% Pass band nominal group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay response peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay response weight\n",Wtp);
fclose(fid);

print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

save directFIRnonsymmetric_socp_slb_bandpass_test.mat maxiter tol ctol n ...
     N fapl fapu deltap Wap Watl Watu fasl fasu deltas Wasl Wasu ...
     ftpl ftpu td tdr Wtp h0 h1 h

%
% Done
%
toc;
diary off
movefile directFIRnonsymmetric_socp_slb_bandpass_test.diary.tmp ...
         directFIRnonsymmetric_socp_slb_bandpass_test.diary;
