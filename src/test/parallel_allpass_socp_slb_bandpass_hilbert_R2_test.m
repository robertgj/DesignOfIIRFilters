% parallel_allpass_socp_slb_bandpass_hilbert_R2_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% The parallel_allpassAsq() etc functions alias the response for R>1 so only
% the lower frequency part of the response is optimised. The anti-aliasing
% filter is fixed.

test_common;

strf="parallel_allpass_socp_slb_bandpass_hilbert_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-5
ctol=1e-8
verbose=false

%
% Band-pass filter specification for parallel all-pass filters
%
% fapu=0.21,dBap=0.1 works but not with socp_relaxation_schurOneMPADoubly...
polyphase=false
difference=true
fasl=0.05,fapl=0.1,fapu=0.21,fasu=0.25
dBasl=40,dBap=0.2,
Wasl=200,Watl=1e-3,Wap=1,Watu=1e-3
ftpl=0.12,ftpu=0.18,tp=16,tpr=0.016,Wtp=10
fppl=0.12,fppu=0.18,pp=1.5,ppr=0.0002,Wpp=10
% Half-band Butterworth anti-aliasing filter
maa=11;
faap=0.25;

%
% Initial coefficients 
%
tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Db0_coef;

% Convert R=2 band-pass Hilbert filter to parallel all-pass pole-zero form
[a0,Va,Qa]=tf2a(Da0);Ra=2;
[b0,Vb,Qb]=tf2a(Db0);Rb=2;
ab0=[a0(:);b0(:)];
ma=length(a0);
mb=length(b0);
K=1;
printf("Initial ab0=[");printf("%14.10f ",ab0');printf("]'\n");

% Convert R=2 anti-aliasing  filter to parallel all-pass polynomial form
[Naa,Daa]=butter(maa,faap*2);
[Aaa1,Aaa2]=tf2pa(Naa,Daa);
Aaa1(2:2:end)=0;
Aaa2(2:2:end)=0;
print_polynomial(Aaa1,"Aaa1");
print_polynomial(Aaa1,"Aaa2");

%
% Frequency vectors
%
n=1000;
w=(0:((n/2)-1))'*pi/(n);
% Anti-aliasing filter response
Haa=freqz(Naa,Daa,w);
Aaa=abs(Haa);
Paa=unwrap(arg(Haa));
Taa=delayz(Naa,Daa,w);

% Desired squared magnitude response
wa=w;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1)./Aaa(napl:napu); ...
      zeros(length(wa)-napu,1)];
Asqdu=[(10^(-dBasl/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1)./Aaa((nasl+1):(nasu-1))];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(length(wa)-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(length(wa)-napu,1)];

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp)-Paa(nppl:nppu);;
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=(tp*ones(size(wt)))-Taa(ntpl:ntpu);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Sanity checks
nchka=[nasl-1,nasl,nasl+1, ...
       napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Linear constraints
rho=0.999;
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Asq0=parallel_allpassAsq(wa,ab0,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T0=parallel_allpassT(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P0=parallel_allpassP(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
             
% Plot initial response
subplot(311);
plot(wa*0.5/pi,10*log10(Asq0.*Aaa));
axis([0 0.5 -80 5]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("Initial parallel allpass bandpass Hilbert : ma=%d,mb=%d",ma,mb);
title(strt);
zticks([]);
subplot(312);
plot(wa*0.5/pi,(P0+(wa*tp)+Paa)/pi);
axis([0 0.5 0 2]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
zticks([]);
subplot(313);
plot(wa*0.5/pi,T0+Taa);
axis([0 0.5 0 20]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% MMSE pass
%
try
  feasible=false;
  [abm,opt_iter,func_iter,feasible]= ...
    parallel_allpass_socp_mmse([],ab0,abu,abl, ...
                               K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                               wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  warning("Caught parallel_allpass_socp_mmse");
end_try_catch
if ~feasible
  error("abm infeasible");
endif

%
% PCLS pass
%
try
  feasible=false;
  [ab1,slb_iter,opt_iter,func_iter,feasible]= ...
    parallel_allpass_slb(@parallel_allpass_socp_mmse,abm,abu,abl, ...
                         K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  err=lasterror();
  fprintf(stderr,"%s\n", err.message);
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  warning("Caught parallel_allpass_slb");
end_try_catch
if ~feasible
  error("ab1 infeasible");
endif

% Find overall filter polynomials
a1=[ab1(1:ma)];
b1=[ab1((ma+1):end)];
[~,Da1R]=a2tf(a1,Va,Qa,Ra);
Da1R=Da1R(:);
Da1R(2:2:end)=0;
[~,Db1R]=a2tf(b1,Vb,Qb,Rb);
Db1R=Db1R(:);
Db1R(2:2:end)=0;
Nab1R=(conv(flipud(Da1R),Db1R)-conv(flipud(Db1R),Da1R))/2;
Dab1R=conv(Da1R,Db1R);

% Find response
w=(0:(n-1))'*pi/n;
Hab1=freqz(Nab1R,Dab1R,w);
Tab1=delayz(Nab1R,Dab1R,w);
Pab1=unwrap(arg(Hab1));
% Anti-aliasing filter response
Haa=freqz(Naa,Daa,w);
Aaa=abs(Haa);
Paa=unwrap(arg(Haa));
Taa=delayz(Naa,Daa,w);

% Plot response
subplot(311);
plot(w*0.5/pi,20*log10(abs(Hab1).*Aaa));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf(["Parallel allpass bandpass Hilbert R=2: ", ...
              "ma=%d,mb=%d,dBap=%g,dBasl=%g,tp=%d,tpr=%g,ppr=%g"], ...
             ma,mb,dBap,dBasl,tp,tpr,ppr);
title(strt);
zticks([]);
subplot(312);
plot(w*0.5/pi,mod((Pab1+Paa+(w*tp))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 2]);
grid("on");
zticks([]);
subplot(313);
plot(w*0.5/pi,Tab1+Taa);
ylabel("Delay(samples)");
axis([0 0.5 10 30]);
grid("on");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(311);
plot(w*0.5/pi,20*log10(abs(Hab1).*Aaa));
ylabel("Amplitude(dB)");
axis([0.08 0.24 -0.6 0.2]);
grid("on");
title(strt);
zticks([]);
subplot(312);
plot(w*0.5/pi,mod((Pab1+Paa+(w*tp))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0.08 0.24 pp+(0.0002*[-1,1])]);
grid("on");
zticks([]);
subplot(313);
plot(w*0.5/pi,Tab1+Taa);
ylabel("Delay(samples)");
axis([0.08 0.24 tp+(0.01*[-1,1])]);
grid("on");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
zplane(qroots(flipud(Da1R)),qroots(Da1R));
title("Allpass filter A");
zticks([]);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
zplane(qroots(flipud(Db1R)),qroots(Db1R));
title("Allpass filter B");
zticks([]);
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"maa=%d %% Allpass model filter A denominator order\n",maa);
fprintf(fid,"Va=%d %% Allpass model filter A no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass model filter A no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass model filter A decimation\n",Ra);
fprintf(fid,"mb=%d %% Allpass model filter B denominator order\n",mb);
fprintf(fid,"Vb=%d %% Allpass model filter B no. of real poles\n",Vb);
fprintf(fid,"Qb=%d %% Allpass model filter B no. of complex poles\n",Qb);
fprintf(fid,"Rb=%d %% Allpass model filter B decimation\n",Rb);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%g %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%g %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBasl=%g %% Lower stop band amplitude response ripple(dB)\n",dBasl);
fprintf(fid,"Wasl=%g %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Pass band nominal group-delay response (samples)\n",tp);
fprintf(fid,"tpr=%g %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group-delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%g %% Pass band initial phase response (rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase response ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
print_allpass_pole(b1,Vb,Qb,Rb,"b1");
print_allpass_pole(b1,Vb,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));

Da1=Da1R(1:2:end);
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
Db1=Db1R(1:2:end);
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
Nab1=Nab1R(1:2:end);
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
Dab1=Dab1R(1:2:end);
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

eval(sprintf(["save %s.mat Naa Daa Da0 ma a0 Qa Va Ra Db0 mb b0 Qb Vb Rb ", ...
              " ftol ctol polyphase difference rho n ", ...
              " fapl fapu dBap Wap Watl Watu ", ...
              " fasl fasu dBasl Wasl ", ...
              " ftpl ftpu tp tpr Wtp fppl fppu pp ppr Wpp ", ...
              " ab1 Da1 Db1 Nab1 Dab1"],strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
