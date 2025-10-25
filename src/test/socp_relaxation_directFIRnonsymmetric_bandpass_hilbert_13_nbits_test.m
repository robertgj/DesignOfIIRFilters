% socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% SOCP-relaxation search for the  13-bit 3-signed-digit coefficients of a
% direct-form non-symmetric Hilbert bandpass filter

test_common;

strf="socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;
maxiter=400
verbose=false
ftol=1e-3
ctol=ftol/10

% From directFIRnonsymmetric_socp_slb_bandpass_hilbert_test.m
directFIRnonsymmetric_socp_slb_bandpass_hilbert_test_h_coef;
N=length(h)-1; % Filter order

% Hilbert filter frequency specification

fasl=0.05;fapl=0.1;fapu=0.2;fasu=0.25;
dBap=1.2;dBas=28;Wasl=1;Watl=0.01;Wap=1;Watu=0.01;Wasu=2;
pp=3.5;ppr=0.01;fppl=fapl;fppu=fapu;Wpp=2;
tp=16;tpr=0.08;ftpl=fapl;ftpu=fapu;Wtp=1;

n=500;

% Desired squared magnitude response
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1); ...
      (10^(-dBap/10))*ones(napu-napl+1,1); ...
      zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,n];
printf(["nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,n];\n"]);
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Wt=Wtp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);


% Find the exact coefficient error
Esq=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("Esq=%g\n",Esq);

% Scale the rounded coefficients to use all the bits 
nbits=13
ndigits=3
nscale=2^(nbits-1)
h_rd=round(h*nscale)/nscale;

% Find the signed-digit approximations to h
[h_sd,h_sdu,h_sdl]=flt2SD(h(:),nbits,ndigits);
Esq_sd=directFIRnonsymmetricEsq(h_sd,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("Esq_sd=%g\n",Esq_sd);
% Find the number of signed-digits used by h_sd
h_active=find(h~=0);
[h_sd_digits,h_sd_adders]=SDadders(h_sd(h_active),nbits);
printf("h_sd uses %d signed-digits\n",h_sd_digits);
printf("h_sd uses %d %d-bit adders for coefficient multiplications\n", ...
       h_sd_adders,nbits);

% Allocate signed digits with the heuristic of Ito et al.
ndigits_alloc=directFIRnonsymmetric_allocsd_Ito(nbits,ndigits, ...
                                                h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
print_polynomial(ndigits_alloc,"ndigits_alloc","%2d");
h_allocsd_digits=int16(ndigits_alloc);
printf("h_allocsd_digits=[ ");
printf("%2d ",h_allocsd_digits);printf("]';\n");
print_polynomial(h_allocsd_digits,"h_allocsd_digits", ...
                 strcat(strf,"_h_allocsd_digits.m"),"%2d");

% Find the signed-digit coefficients
[h_Ito_sd,h_Ito_sdu,h_Ito_sdl]=flt2SD(h(:),nbits,h_allocsd_digits(:));
% Find signed-digit error
Esq_Ito_sd=directFIRnonsymmetricEsq(h_Ito_sd,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("Esq_Ito_sd=%g\n",Esq_Ito_sd);
% Find the number of signed-digits used by h_Ito_sd
[h_Ito_sd_digits,h_Ito_sd_adders]=SDadders(h_Ito_sd,nbits);
printf("h_Ito_sd uses %d signed-digits\n",h_Ito_sd_digits);
printf("h_Ito_sd uses %d %d-bit adders for coefficient multiplications\n", ...
       h_Ito_sd_adders,nbits);

% Check for consistent upper and lower bounds
if any(h_Ito_sdl>h_Ito_sdu)
  error("found h_Ito_sdl>h_Ito_sdu");
endif
if any(h_Ito_sd(h_active)>h_Ito_sdu(h_active))
  error("found h_Ito_sd(h_active)>h_Ito_sdu(h_active)");
endif
if any(h_Ito_sdl(h_active)>h_Ito_sd(h_active))
  error("found h_Ito_sdl(h_active)>h_Ito_sd(h_active)");
endif

% Fix one coefficient at each iteration 
h_active=find(ndigits_alloc~=0);
h_b=zeros(size(h));
h_b(h_active)=h(h_active);
slb_iter=0;
socp_iter=0;
func_iter=0;

while ~isempty(h_active)
  
  % Define filter coefficients 
  [h_b_sd,h_b_sdu,h_b_sdl]=flt2SD(h,nbits,ndigits_alloc);
  h_b_sdul=h_b_sdu-h_b_sdl;
  
  % Ito et al. suggest ordering the search by max(h_b_sdu-h_b_sdl)
  [h_b_max,h_b_max_n]=max(h_b_sdul(h_active));
  if h_b_max==0
    warning("h_b_max==0 with %d active coefficients. Can't continue!", ...
            length(h_active));
    break;
  endif
  coef_n=h_active(h_b_max_n);

  % Try to solve the current SOCP problem with bounds
  try
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nexth,siter,soiter,fiter,feasible]= ...
       directFIRnonsymmetric_slb(@directFIRnonsymmetric_socp_mmse, ...
                                 h_b,h_active, ...
                                 wa,Asqd,Asqdu,Asqdl,Wa, ...
                                 wt,Td,Tdu,Tdl,Wt, ...
                                 wp,Pd,Pdu,Pdl,Wp, ...
                                 maxiter,ftol,ctol,verbose);
    slb_iter=slb_iter+siter;
    socp_iter=socp_iter+soiter;
    func_iter=func_iter+fiter;
 catch
    feasible=false;
    err=lasterror();
    fprintf(stderr,"%s\n", err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch

  % If this problem was not solved then give up
  if ~feasible
    error("SOCP problem infeasible!");
  endif

  % Fix coef_n to nearest signed-digit coefficient
  alpha= ...
    (nexth(coef_n)-((h_b_sdu(coef_n)+h_b_sdl(coef_n))/2))/(h_b_sdul(coef_n)/2);
  if alpha>=0
    nexth(coef_n)=h_b_sdu(coef_n);
  else
    nexth(coef_n)=h_b_sdl(coef_n);
  endif
  h_b=nexth;
  h_active(h_b_max_n)=[];
  printf("Fixed h_b(%d)=%g/%d\n",coef_n,h_b(coef_n)*nscale,nscale);
  printf("h_active=[ ");printf("%d ",h_active);printf("];\n\n");

endwhile

% Show results
h_min=h_b;
Esq_min=directFIRnonsymmetricEsq(h_min,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
% Find the number of signed-digits and adders used
[h_min_digits,h_min_adders]=SDadders(h_min,nbits);
printf("%d signed-digits used\n",h_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       h_min_adders,nbits);
fname=strcat(strf,"_h_min_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",h_min_adders);
fclose(fid);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.2e & & \\\\\n",Esq);
fprintf(fid,"%d-bit %d-signed-digit & %10.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_sd,h_sd_digits,h_sd_adders);  
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_Ito_sd,h_Ito_sd_digits,h_Ito_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP)&%10.2e&%d&%d\\\\\n", ...
        nbits,ndigits,Esq_min,h_min_digits,h_min_adders);
fclose(fid);

% Amplitude at local peaks
Asq=directFIRnonsymmetricAsq(wa,h_min);
vAsql=local_max(-Asq);
vAsqu=local_max(Asq);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([nasl,napl])]);
AsqS=directFIRnonsymmetricAsq(wAsqS,h_min);
wAsqS=wAsqS(find(abs(AsqS)>0));
AsqS=AsqS(find(abs(AsqS)>0));
printf("h_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h_min:AsqS=[ ");printf("%f ",10*log10(abs(AsqS)'));printf(" ] (dB)\n");

% Phase at local peaks
P=directFIRnonsymmetricP(wp,h_min);
vPl=local_max(-P);
vPu=local_max(P);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=directFIRnonsymmetricP(wPS,h_min);
wPS=wPS(find(abs(PS)>0));
PS=PS(find(abs(PS)>0));
printf("h_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h_min:PS=[ ");printf("%f ",(unwrap(PS)+(wPS*tp))'/pi);printf(" ] (rad./pi)\n");

% Delay at local peaks
T=directFIRnonsymmetricT(wt,h_min);
vTl=local_max(-T);
vTu=local_max(T);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=directFIRnonsymmetricT(wTS,h_min);
wTS=wTS(find(abs(TS)>0));
TS=TS(find(abs(TS)>0));
printf("h_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("h_min:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
Asq_h=directFIRnonsymmetricAsq(wplot,h);
Asq_h_sd=directFIRnonsymmetricAsq(wplot,h_sd);
Asq_h_Ito_sd=directFIRnonsymmetricAsq(wplot,h_Ito_sd);
Asq_h_min=directFIRnonsymmetricAsq(wplot,h_min);
P_h=directFIRnonsymmetricP(wplot,h);
P_h_sd=directFIRnonsymmetricP(wplot,h_sd);
P_h_Ito_sd=directFIRnonsymmetricP(wplot,h_Ito_sd);
P_h_min=directFIRnonsymmetricP(wplot,h_min);
T_h=directFIRnonsymmetricT(wplot,h);
T_h_sd=directFIRnonsymmetricT(wplot,h_sd);
T_h_Ito_sd=directFIRnonsymmetricT(wplot,h_Ito_sd);
T_h_min=directFIRnonsymmetricT(wplot,h_min);

% Plot amplitude response
Asq_all=[Asq_h,Asq_h_sd,Asq_h_Ito_sd,Asq_h_min];
[ax,ha,hs] = plotyy(wplot*0.5/pi,10*log10(Asq_all), ...
                    wplot*0.5/pi,10*log10(Asq_all));
% Copy line colour and set line style
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4,
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -1 0.2]);
axis(ax(2),[0 0.5 -36 -24]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Exact","s-d","s-d(Ito)","s-d(SOCP)");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf("Direct-form non-symmetric FIR : N=%d,fapl=%4.2f,fapu=%4.2f", ...
             N,fapl,fapu);
title(strt);
zticks([]);
print(strcat(strf,"_amplitude"),"-dpdflatex");
close

% Plot phase response
P_all=[P_h,P_h_sd,P_h_Ito_sd,P_h_min];
ha=plot(wplot*0.5/pi,(unwrap(P_all)+(4*pi)+(wplot*tp))/pi);
% Copy line colour and set line style
hls={"-",":","--","-."};
for c=1:4,
  set(ha(c),"linestyle",hls{c});
endfor
axis([fppl fppu 1.5+0.002*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$");
legend("Exact","s-d","s-d(Ito)","s-d(SOCP)");
legend("location","northeast");
legend("boxoff");
legend("left");
title(strt);
zticks([]);
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay response
T_all=[T_h,T_h_sd,T_h_Ito_sd,T_h_min];
ha=plot(wplot*0.5/pi,T_all);
% Copy line colour and set line style
hls={"-",":","--","-."};
for c=1:4,
  set(ha(c),"linestyle",hls{c});
endfor
axis([ftpl ftpu tp+0.04*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("Exact","s-d","s-d(Ito)","s-d(SOCP)");
legend("location","southwest");
legend("boxoff");
legend("right");
title(strt);
zticks([]);
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",length(h));
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% iteration limit\n",maxiter);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple(dB)\n",dBas);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band delay(samples)\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fppl=%g %% Phase pass band lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Phase pass band upper edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fclose(fid);

print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%12.8f");
print_polynomial(h_sd,"h_sd",nscale);
print_polynomial(h_sd,"h_sd",strcat(strf,"_h_sd_coef.m"),nscale);
print_polynomial(h_Ito_sd,"h_Ito_sd",nscale);
print_polynomial(h_Ito_sd,"h_Ito_sd",strcat(strf,"_h_Ito_sd_coef.m"),nscale);
print_polynomial(h_min,"h_min",nscale);
print_polynomial(h_min,"h_min",strcat(strf,"_h_min_coef.m"),nscale);

% Save results
eval(sprintf(["save %s.mat h h_sd h_Ito_sd h_min ftol ctol nbits ndigits ", ...
              "fapl fapu dBap dBas Wasl Watl Wap Watu Wasu ", ...
              "ftpl ftpu tp tpr Wtp fppl fppu pp ppr Wpp"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
