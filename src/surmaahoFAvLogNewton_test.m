% surmaahoFAvLogNewton_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("surmaahoFAvLogNewton_test.diary");
unlink("surmaahoFAvLogNewton_test.diary.tmp");
diary surmaahoFAvLogNewton_test.diary.tmp

maxiter=5000
tol=1e-6
verbose=false

% Minimum-phase filter specification
fap=0.1,fas=0.125,dBap=0.1,dBas=50
nf=1000;
nap=ceil(fap*nf/0.5)+1;
nas=floor(fas*nf/0.5)+1;
w=(0:(nf-1))'*pi/nf;
wa=w(1:nap);
ws=w(nas:end);

% All-pass equaliser specification
fpp=0.08
tp=20
npp=ceil(nf*fpp/0.5)+1;
wp=w(1:npp);

for nmin=6:7
  for nall=4:5
    
    strf=sprintf("surmaahoFAvLogNewton_test_nmin_%d_nall_%d",nmin,nall);
    
    % Design initial equi-ripple filter
    [z0,p0,K0]=ellip(nmin,dBap,dBas,2*fap);
    [x0,U0,V0,M0,Q0]=zp2x(z0,p0,K0);
    R0=1;

    % Desired initial pass-band phase response
    P0=iirP(wp,x0,U0,V0,M0,Q0,R0);
    Pd=-(P0+(tp*wp));

    % Design initial all-pass equaliser
    [~,A0]=butter(nall,2*fpp);
    [a0,Va,Qa]=tf2a(A0);
    Ra=1;

    % Linear constraints
    rho=31/32;
    [al,au]=aConstraints(Va,Qa,rho);

    % SOCP MMSE
    [a1,socp_iter,func_iter,feasible]= ...
    allpass_phase_socp_mmse([],a0,au,al,Va,Qa,Ra, ...
                            wp,Pd,[],[],ones(size(wp)),maxiter,tol,verbose);
    if ~feasible
      error("Initial allpass_phase_socp_mmse not feasible");
    endif
    allpass_p=a2p(a1,Va,Qa); % Fixed all-pass poles

    %
    % Find filter with single fixed zeros
    %
    [min_z,min_p,K,iter]=surmaahoFAvLogNewton ...
                           (nmin,fap,fas,allpass_p,tp,dBap,dBas);
    print_polynomial(abs(min_z),"abs_min_z");
    print_polynomial(angle(min_z),"angle_min_z");
    print_polynomial(abs(min_p),"abs_min_p");
    print_polynomial(angle(min_p),"angle_min_p");

    % Calculate combined response
    [num,den]=zp2tf([min_z;1./allpass_p],min_p,K);
    [H,w]=freqz(num,den,nf);
    Ap=20*log10(abs(H(1:nap)));
    As=20*log10(abs(H(nas:end)));
    Pp=(unwrap(angle(H(1:nap)))+(tp*wa))/pi;
    Fp=wa*0.5/pi;
    Fs=ws*0.5/pi;

    % Check dBap, dBas
    max_dBap=max(Ap);
    min_dBap=min(Ap);
    max_dBas=0-max(As);
    max_P=max(Pp);
    min_P=min(Pp);
    printf("1z:nmin=%d,nall=%d,max_dBap=%8.6f,min_dBap=%8.6f,max_dBas=%6.2f,\
min_P=%6.2f,max_P=%6.2f\n",nmin,nall,max_dBap,min_dBap,max_dBas,min_P,max_P);

    % Plot response
    subplot(211);
    ax=plotyy(Fp,Ap,Fs,As);
    set(ax(1),'ycolor','black');
    set(ax(2),'ycolor','black');
    axis(ax(1),[0 0.5 -0.008 0]);
    axis(ax(2),[0 0.5 -60 -40]);
    strt="Surma-aho-and-Saram\\\"{a}ki combined filter response";
    title(strt);
    ylabel("Amplitude(dB)");
    grid("on");
    subplot(212); 
    plot(Fp,Pp);
    axis([0 0.5 -0.4 0.4]);
    grid("on");
    ylabel("Phase error(rad./$\\pi$)");
    xlabel("Frequency");
    print(strcat(strf,"_resp"),"-dpdflatex");
    close

    % Combined filter zplane plot
    subplot(111);
    zplane([min_z;1./allpass_p],min_p);
    strt="Surma-aho-and-Saram\\\"{a}ki combined filter";
    title(strt);
    print(strcat(strf,"_pz"),"-dpdflatex");
    close

    %
    % Find filter with double fixed zeros
    %
    [min_z,min_p,K,iter] = ...
      surmaahoFAvLogNewton(nmin,fap,fas,allpass_p,tp,dBap,dBas,2);
    print_polynomial(abs(min_z),"abs_min_z");
    print_polynomial(angle(min_z),"angle_min_z");
    print_polynomial(abs(min_p),"abs_min_p");
    print_polynomial(angle(min_p),"angle_min_p");

    % Calculate combined response
    [num,den]=zp2tf([min_z;1./allpass_p],min_p,K);
    [H,w]=freqz(num,den,nf);
    Ap=20*log10(abs(H(1:nap)));
    As=20*log10(abs(H(nas:end)));
    Pp=(unwrap(angle(H(1:nap)))+(tp*wa))/pi;
    Fp=wa*0.5/pi;
    Fs=ws*0.5/pi;

    % Check dBap, dBas
    max_dBap=max(Ap);
    min_dBap=min(Ap);
    max_dBas=0-max(As);
    max_P=max(Pp);
    min_P=min(Pp);
    printf("2z:nmin=%d,nall=%d,max_dBap=%8.6f,min_dBap=%8.6f,max_dBas=%6.2f,\
min_P=%6.2f,max_P=%6.2f\n",nmin,nall,max_dBap,min_dBap,max_dBas,min_P,max_P);

    % Plot response
    subplot(211);
    ax=plotyy(Fp,Ap,Fs,As);
    set(ax(1),'ycolor','black');
    set(ax(2),'ycolor','black');
    axis(ax(1),[0 0.5 -0.008 0]);
    axis(ax(2),[0 0.5 -60 -40]);
    strt= ...
      "Surma-aho-and-Saram\\\"{a}ki combined filter response with double zeros";
    title(strt);
    ylabel("Amplitude(dB)");
    grid("on");
    subplot(212);
    plot(Fp,Pp);
    axis([0 0.5 -0.4 0.4]);
    grid("on");
    ylabel("Phase error(rad./$\\pi$)");
    xlabel("Frequency");
    print(strcat(strf,"_pa_resp"),"-dpdflatex");
    close

    % Combined filter zplane plot
    subplot(111);
    zplane([min_z;1./allpass_p],min_p);
    strt="Surma-aho-and-Saram\\\"{a}ki combined filter with double zeros";
    title(strt);
    print(strcat(strf,"_pa_pz"),"-dpdflatex");
    close
  endfor
endfor

% Done
diary off
movefile surmaahoFAvLogNewton_test.diary.tmp surmaahoFAvLogNewton_test.diary;
  
