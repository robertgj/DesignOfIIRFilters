% schurOneMAPlattice_frm_allocsd_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen
%
% Test the Ito and Lim signed-digit allocation algorithms with the
% coefficients of an FRM low-pass filter with a model filter implemented
% as a Schur one-multiplier lattice in parallel with a delay.

test_common;

delete("schurOneMAPlattice_frm_allocsd_test.diary");
delete("schurOneMAPlattice_frm_allocsd_test.diary.tmp");
diary schurOneMAPlattice_frm_allocsd_test.diary.tmp

%
% Initial filters from schurOneMAPlattice_frm_socp_slb_test.m
%
k0 = [   0.0106118571,   0.5990334918,  -0.0195946068,  -0.1444553701, ... 
         0.0026241480,   0.0660353838,  -0.0060674032,  -0.0286257090, ... 
         0.0019377466,   0.0190403573 ]';
epsilon0 = [  -1,   1,   1,   1,  -1,  -1,   1,   1,  -1,  -1 ];
p0 = [   1.4792258431,   1.4950073563,   0.7486323653,   0.7634480986, ... 
         0.8829937176,   0.8853138721,   0.9458404164,   0.9515967275, ... 
         0.9792381498,   0.9811375072 ];
u0 = [   0.5851784658,   0.2971899445,  -0.0631681199,  -0.0847662432, ... 
         0.0527098613,   0.0314114101,  -0.0426238250,  -0.0044257316, ... 
         0.0412954843,  -0.0234433643,  -0.0095362094,   0.0130274182, ... 
         0.0101756868,  -0.0098953348,  -0.0028549947,   0.0071650391, ... 
        -0.0008295550,  -0.0105801832,   0.0104840782,  -0.0016918877, ... 
        -0.0035215384 ]';
v0 = [  -0.6718253684,  -0.2654132425,   0.1341075166,   0.0039868022, ... 
        -0.0647577647,   0.0501026256,   0.0032293657,  -0.0340623534, ... 
         0.0343016709,  -0.0049633800,  -0.0122729626,   0.0149359392, ... 
         0.0018612907,  -0.0101406242,   0.0084461686,   0.0016885376, ... 
        -0.0066664451,   0.0091032573,  -0.0031062549,   0.0003072064, ... 
         0.0022323281 ]';
Nk=length(k0);Nu=length(u0);Nv=length(v0);

%
% Filter specification
%
n=1000;
tol=1e-4
ctol=tol/10
maxiter=2000
verbose=false
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(length(u0)-1); % FIR masking filter delay
fap=0.3 % Pass band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
Wat=0 % Transition band amplitude weight
fas=0.3105 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=100 % Stop band amplitude weight
ftp=fap % Delay pass band edge
tp=(Mmodel*Dmodel)+dmask;
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.02 % Pass band delay weight
fpp=fap % Phase pass band edge
pp=0 % Pass band zero-phase phase
ppr=0.01*pi % Peak-to-peak pass band phase ripple
Wpp=0.01 % Pass band phase weight
rho=31/32 % Stability constraint on pole radius

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Phase constraints
wp=w(1:nap);
Pd=zeros(nap,1);
Pdu=(ppr/2)*ones(nap,1);
Pdl=-Pdu;
Wp=Wpp*ones(nap,1);

% Find response of exact filter
nplot=1000;
Asq_ex=schurOneMAPlattice_frmAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P_ex=schurOneMAPlattice_frmP(wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T_ex=schurOneMAPlattice_frmT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);

% Compare
nbits_range=[6:16];
nbits_cost_rd=zeros(size(nbits_range));
nbits_kuv_rd_digits=zeros(size(nbits_range));
nbits_cost_sd=zeros(size(nbits_range));
nbits_kuv_sd_digits=zeros(size(nbits_range));
nbits_cost_Lim=zeros(size(nbits_range));
nbits_kuv_digits_Lim=zeros(size(nbits_range));
nbits_cost_Ito=zeros(size(nbits_range));
nbits_kuv_digits_Ito=zeros(size(nbits_range));
for ndigits=2:3
  strf=sprintf("schurOneMAPlattice_frm_allocsd_%d_ndigits_test", ...
               ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    nbits_strf=sprintf...
    ("schurOneMAPlattice_frm_allocsd_%d_ndigits_%d_nbits_test", ...
     ndigits,nbits);
    
    % Rounded truncation
    k_rd=round(k0.*nscale)./nscale;
    u_rd=round(u0.*nscale)./nscale;
    v_rd=round(v0.*nscale)./nscale;
    nbits_cost_rd(l)= ...
      schurOneMAPlattice_frmEsq ...
        (k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel, ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_rd=schurOneMAPlattice_frmAsq ...
             (wa,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    P_rd=schurOneMAPlattice_frmP ...
             (wp,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    T_rd=schurOneMAPlattice_frmT ...
             (wt,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_rd=[k_rd(:);u_rd(:);v_rd(:)];
    nbits_kuv_rd_digits(l)=SDadders(kuv_rd,nbits);
 
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k0,nbits,ndigits);
    u_sd=flt2SD(u0,nbits,ndigits);
    v_sd=flt2SD(v0,nbits,ndigits);
    nbits_cost_sd(l)= ...
    schurOneMAPlattice_frmEsq ...
      (k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_sd=schurOneMAPlattice_frmAsq ...
             (wa,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    P_sd=schurOneMAPlattice_frmP ...
             (wp,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    T_sd=schurOneMAPlattice_frmT ...
             (wt,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_sd=[k_sd(:);u_sd(:);v_sd(:)];
    nbits_kuv_sd_digits(l)=SDadders(kuv_sd,nbits);

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=schurOneMAPlattice_frm_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,...
                   wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)), ...
                   wp,Pd,ones(size(Wp)));
    print_polynomial(int16(ndigits_Lim(1:Nk)), ...
                     "k_allocsd_digits", ...
                     strcat(nbits_strf,"_k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim((Nk+1):(Nk+Nu))), ...
                     "u_allocsd_digits", ...
                     strcat(nbits_strf,"_u_Lim_digits.m"),"%2d"); 
    print_polynomial(int16(ndigits_Lim((Nk+Nu+1):end)), ...
                     "v_allocsd_digits", ...
                     strcat(nbits_strf,"_v_Lim_digits.m"),"%2d");
    % Signed-digits allocated by Lim
    k_Lim=flt2SD(k0,nbits,ndigits_Lim(1:Nk));
    u_Lim=flt2SD(u0,nbits,ndigits_Lim((Nk+1):(Nk+Nu)));
    v_Lim=flt2SD(v0,nbits,ndigits_Lim((Nk+Nu+1):end));
    nbits_cost_Lim(l)=schurOneMAPlattice_frmEsq ...
      (k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_Lim=schurOneMAPlattice_frmAsq ...
              (wa,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    T_Lim=schurOneMAPlattice_frmT ...
              (wt,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    P_Lim=schurOneMAPlattice_frmP ...
              (wp,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_Lim=[k_Lim(:);u_Lim(:);v_Lim(:)];
    [nbits_kuv_digits_Lim(l),kuv_adders_Lim]=SDadders(kuv_Lim,nbits);
    fid=fopen(strcat(nbits_strf,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",kuv_adders_Lim);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMAPlattice_frm_allocsd_Ito ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    print_polynomial(int16(ndigits_Ito(1:Nk)), ...
                     "k_allocsd_digits", ...
                     strcat(nbits_strf,"_k_Ito_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Ito((Nk+1):(Nk+Nu))), ...
                     "u_allocsd_digits", ...
                     strcat(nbits_strf,"_u_Ito_digits.m"),"%2d"); 
    print_polynomial(int16(ndigits_Ito((Nk+Nu+1):end)), ...
                     "v_allocsd_digits", ...
                     strcat(nbits_strf,"_v_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    k_Ito=flt2SD(k0,nbits,ndigits_Ito(1:Nk));
    u_Ito=flt2SD(u0,nbits,ndigits_Ito((Nk+1):(Nk+Nu)));
    v_Ito=flt2SD(v0,nbits,ndigits_Ito((Nk+Nu+1):end));
    nbits_cost_Ito(l)=schurOneMAPlattice_frmEsq ...
      (k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_Ito=schurOneMAPlattice_frmAsq ...
              (wa,k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel);
    T_Ito=schurOneMAPlattice_frmT ...
              (wt,k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel);
    P_Ito=schurOneMAPlattice_frmP ...
              (wp,k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel);
    % Find the actual number of signed digits and adders used
    kuv_Ito=[k_Ito(:);u_Ito(:);v_Ito(:)];
    [nbits_kuv_digits_Ito(l),kuv_adders_Ito]=SDadders(kuv_Ito,nbits);
    fid=fopen(strcat(nbits_strf,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",kuv_adders_Ito);
    fclose(fid);

    % Plot the results
    subplot(311)
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--",...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    axis([0 0.5 -0.4 1.2])
    ylabel("Amplitude(dB)");
    xlabel("Frequency");
    grid("on");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    strt=sprintf("FRM low-pass : nbits=%d,ndigits=%d", ...
                 nbits,ndigits);
    title(strt);
    subplot(312)
    plot(wp*0.5/pi,P_ex/pi,"linestyle","-", ...
         wp*0.5/pi,P_rd/pi,"linestyle",":", ...
         wp*0.5/pi,P_sd/pi,"linestyle","-.", ... 
         wp*0.5/pi,P_Lim/pi,"linestyle","--",...
         wp*0.5/pi,P_Ito/pi,"linestyle","-")
    ylabel("Phase error(rad./$\\pi$)");
    xlabel("Frequency");
    grid("on");
    subplot(313)
    plot(wt*0.5/pi,T_ex+tp,"linestyle","-", ...
         wt*0.5/pi,T_rd+tp,"linestyle",":", ...
         wt*0.5/pi,T_sd+tp,"linestyle","-.", ... 
         wt*0.5/pi,T_Lim+tp,"linestyle","--",...
         wt*0.5/pi,T_Ito+tp,"linestyle","-")
    ylabel("Delay(Samples)");
    xlabel("Frequency");
    grid("on");
    print(strcat(nbits_strf,"_response"),"-dpdflatex");
    close
    
    % Print the results
    print_polynomial(k_rd,sprintf("k_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_rd_coef.m"),nscale);
    print_polynomial(u_rd,sprintf("u_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_u_rd_coef.m"),nscale);
    print_polynomial(v_rd,sprintf("v_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_v_rd_coef.m"),nscale);
    print_polynomial(k_sd,sprintf("k_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_sd_coef.m"),nscale);
    print_polynomial(u_sd,sprintf("u_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_u_sd_coef.m"),nscale);
    print_polynomial(v_sd,sprintf("v_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_v_sd_coef.m"),nscale);
    print_polynomial(k_Lim,sprintf("k_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_Lim_coef.m"),nscale);
    print_polynomial(u_Lim,sprintf("u_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_u_Lim_coef.m"),nscale);
    print_polynomial(v_Lim,sprintf("v_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_v_Lim_coef.m"),nscale);
    print_polynomial(k_Ito,sprintf("k_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_Ito_coef.m"),nscale);
    print_polynomial(u_Ito,sprintf("u_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_u_Ito_coef.m"),nscale);
    print_polynomial(v_Ito,sprintf("v_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_v_Ito_coef.m"),nscale);
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  strt=sprintf("FRM low-pass cost (ndigits=%d)", ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Cost");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_cost"),"-dpdflatex");
  close

  % Plot comparison of total signed-digits used
  subplot(111)
  plot(nbits_range,nbits_kuv_rd_digits,"linestyle",":", ...
       nbits_range,nbits_kuv_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_kuv_digits_Lim,"linestyle","--",...
       nbits_range,nbits_kuv_digits_Ito,"linestyle","-")
  strt=sprintf(["FRM low-pass total signed-digits used by coefficients ", ...
 "(ndigits=%d)"],ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Total signed-digits used by coefficients");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northwest");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_digits"),"-dpdflatex");
  close

endfor

% Done
diary off
movefile schurOneMAPlattice_frm_allocsd_test.diary.tmp ...
         schurOneMAPlattice_frm_allocsd_test.diary;
