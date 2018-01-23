% schurOneMAPlattice_frm_hilbert_allocsd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for Lims signed-digit allocation algorithm with coefficents of
% a bandpass lattice filter in one multiplier form.

test_common;

unlink("schurOneMAPlattice_frm_hilbert_allocsd_test.diary");
unlink("schurOneMAPlattice_frm_hilbert_allocsd_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbert_allocsd_test.diary.tmp

%
% Initial filters
%
if 0
  % From tarczynski_frm_hilbert_test.m
  r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
           0.0035706175,  -0.0098219303 ]';
  aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
          -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
          -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
          -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
           0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
          -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
          -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
          -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
          -0.0019232288 ]';
  % Convert to Hilbert
  rm1=ones(size(r0));
  rm1(2:2:end)=-1;
  [k0,epsilon0,p0,~]=tf2schurOneMlattice(flipud(r0).*rm1,r0.*rm1);
  dmask=(length(aa0)-1)/2;
  u0=aa0(1:2:(dmask+1));
  um1=ones(size(u0));
  um1(2:2:end)=-1;
  u0=u0.*um1;
  v0=aa0(2:2:dmask);
  vm1=ones(size(v0));
  vm1(2:2:end)=-1;
  v0=v0.*vm1;
else
  % From schurOneMAPlattice_frm_hilbert_socp_slb_test.m
  k0 = [  -0.5737912482,  -0.1357861405,  -0.0532745521,  -0.0211256540, ... 
          -0.0087697088 ];
  epsilon0 = [  -1,   1,   1,   1,  1 ];
  p0 = [   1.5423434313,   0.8026361330,   0.9201452231,   0.9705438144, ... 
           0.9912684101 ];
  u0 = [  -0.0009005864,  -0.0025457761,  -0.0071130803,  -0.0128019220, ... 
          -0.0309485917,  -0.0343335606,  -0.0517736811,  -0.0570207655, ... 
           0.4398895843 ]';
  v0 = [   0.0065311035,   0.0043827833,   0.0072166026,   0.0020996443, ... 
          -0.0078831931,  -0.0311746387,  -0.0808425030,  -0.3143749022 ]';
endif

% Make sizes consistent
k0=k0(:);u0=u0(:);v0=v0(:);
Nk=length(k0);Nu=length(u0);Nv=length(v0);

%
% Filter specification
%
n=800
tol=1e-4
maxiter=2000
verbose=false
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=4*length(v0); % Model filter order
dmask=2*length(v0); % FIR masking filter delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
Wap=1 % Pass band amplitude weight
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
Wtp=0.01 % Pass band delay weight
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
Wpp=0.1 % Pass band phase weight

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Find response of exact filter
nplot=1000;
Asq_ex=schurOneMAPlattice_frm_hilbertAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P_ex=schurOneMAPlattice_frm_hilbertP(wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T_ex=schurOneMAPlattice_frm_hilbertT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);

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
  strf=sprintf("schurOneMAPlattice_frm_hilbert_allocsd_%d_ndigits_test", ...
               ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    nbits_strf=sprintf...
    ("schurOneMAPlattice_frm_hilbert_allocsd_%d_ndigits_%d_nbits_test", ...
     ndigits,nbits);
    
    % Rounded truncation
    k_rd=round(k0.*nscale)./nscale;
    u_rd=round(u0.*nscale)./nscale;
    v_rd=round(v0.*nscale)./nscale;
    nbits_cost_rd(l)= ...
      schurOneMAPlattice_frm_hilbertEsq ...
        (k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel, ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_rd=schurOneMAPlattice_frm_hilbertAsq ...
             (wa,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    T_rd=schurOneMAPlattice_frm_hilbertT ...
             (wt,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    P_rd=schurOneMAPlattice_frm_hilbertP ...
             (wp,k_rd,epsilon0,ones(size(p0)),u_rd,v_rd,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_rd=[k_rd(:);u_rd(:);v_rd(:)];
    nbits_kuv_rd_digits(l)=SDadders(kuv_rd,nbits);
 
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k0,nbits,ndigits);
    u_sd=flt2SD(u0,nbits,ndigits);
    v_sd=flt2SD(v0,nbits,ndigits);
    nbits_cost_sd(l)= ...
    schurOneMAPlattice_frm_hilbertEsq ...
      (k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_sd=schurOneMAPlattice_frm_hilbertAsq ...
             (wa,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    T_sd=schurOneMAPlattice_frm_hilbertT ...
             (wt,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    P_sd=schurOneMAPlattice_frm_hilbertP ...
             (wp,k_sd,epsilon0,ones(size(p0)),u_sd,v_sd,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_sd=[k_sd(:);u_sd(:);v_sd(:)];
    nbits_kuv_sd_digits(l)=SDadders(kuv_sd,nbits);

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...
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
    nbits_cost_Lim(l)=schurOneMAPlattice_frm_hilbertEsq ...
      (k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_Lim=schurOneMAPlattice_frm_hilbertAsq ...
              (wa,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    T_Lim=schurOneMAPlattice_frm_hilbertT ...
              (wt,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    P_Lim=schurOneMAPlattice_frm_hilbertP ...
              (wp,k_Lim,epsilon0,ones(size(p0)),u_Lim,v_Lim,Mmodel,Dmodel);
    % Find the actual number of signed digits used
    kuv_Lim=[k_Lim(:);u_Lim(:);v_Lim(:)];
    [nbits_kuv_digits_Lim(l),kuv_adders_Lim]=SDadders(kuv_Lim,nbits);
    fid=fopen(strcat(nbits_strf,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",kuv_adders_Lim);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMAPlattice_frm_hilbert_allocsd_Ito ...
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
    nbits_cost_Ito(l)=schurOneMAPlattice_frm_hilbertEsq ...
      (k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    Asq_Ito=schurOneMAPlattice_frm_hilbertAsq ...
              (wa,k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel);
    T_Ito=schurOneMAPlattice_frm_hilbertT ...
              (wt,k_Ito,epsilon0,ones(size(p0)),u_Ito,v_Ito,Mmodel,Dmodel);
    P_Ito=schurOneMAPlattice_frm_hilbertP ...
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
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    grid("on");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    strt=sprintf("FRM Hilbert one-multiplier lattice : nbits=%d,ndigits=%d",
                 nbits,ndigits);
    title(strt);
    subplot(312)
    plot(wt*0.5/pi,T_ex+tp,"linestyle","-", ...
         wt*0.5/pi,T_rd+tp,"linestyle",":", ...
         wt*0.5/pi,T_sd+tp,"linestyle","-.", ... 
         wt*0.5/pi,T_Lim+tp,"linestyle","--",...
         wt*0.5/pi,T_Ito+tp,"linestyle","-")
    xlabel("Frequency");
    ylabel("Delay(Samples)");
    grid("on");
    subplot(313)
    plot(wp*0.5/pi,P_ex/pi,"linestyle","-", ...
         wp*0.5/pi,P_rd/pi,"linestyle",":", ...
         wp*0.5/pi,P_sd/pi,"linestyle","-.", ... 
         wp*0.5/pi,P_Lim/pi,"linestyle","--",...
         wp*0.5/pi,P_Ito/pi,"linestyle","-")
    xlabel("Frequency");
    ylabel("Phase(rad./pi)\n(Adjusted for delay)");
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
  strt=sprintf("FRM Hilbert one-multiplier lattice cost (ndigits=%d)", ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Cost");
  grid("off");
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
  strt=sprintf("FRM Hilbert one-multiplier lattice total signed-digits \
used by coefficients (ndigits=%d)",ndigits);
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
movefile schurOneMAPlattice_frm_hilbert_allocsd_test.diary.tmp ...
       schurOneMAPlattice_frm_hilbert_allocsd_test.diary;
