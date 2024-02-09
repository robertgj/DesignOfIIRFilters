% tuqanFIRnonsymmetric_dare_minimum_phase_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Implement calculation of the minimum phase component, H(z), from the causal
% part of a transfer function F(z)=H(z)H(z^-1)=D(z)+D(z^-1) by solving the
% associated Riccati equation. See: "A State Space Approach to the Design of
% Globally Optimal FIR Energy Compaction Filters", J. Tuqan and P. P.
% Vaidyanathan, IEEE Trans. On Signal Processing, Vol. 48, No. 10, Oct. 2000,
% pp. 2822-2838

test_common;

delete("tuqanFIRnonsymmetric_dare_minimum_phase_test.diary");
delete("tuqanFIRnonsymmetric_dare_minimum_phase_test.diary.tmp");
diary tuqanFIRnonsymmetric_dare_minimum_phase_test.diary.tmp

pkg load control;

strf="tuqanFIRnonsymmetric_dare_minimum_phase_test";

% Design a low-pass filter
fapl=0.1;fapu=0.2;Wap=1;
fasl=0.05;fasu=0.25;Wasl=2;Wasu=2;
M=15;N=(2*M);
h=remez(2*M,2*[0 fasl fapl fapu fasu 0.5],[0 0 1 1 0 0],...
        [Wasl Wap Wasu],'bandpass');
h=h(:);

% Brute force scaling of h so that max(abs(Hbrz))==1
Nw=2^16;
[h,w,H]=direct_form_scale(h,1,Nw);

% Find the filter corresponding to |H|^2
bbrz=conv(h(:),flipud(h(:)));
% Find the filter corresponding to 1-|H|^2.
bbrzc=[zeros(2*M,1); 1; zeros(2*M,1)]-bbrz;
b=bbrzc((N+1):end);

% Set up and solve the DARE problem
Ad=[zeros(N-1,1) eye(N-1);zeros(1,N)];
Bd=[zeros(N-1,1);1];
Cd=b(2:end)';
R=b(1);
A1=Ad-(Bd*inv(R)*Cd);
Q=Cd'*inv(R)*Cd;
Pdmin=dare(A1,Bd,Q,R);

% Calculate the complementary minimum phase filter impulse response
Wd=sqrt(R-(Bd'*Pdmin*Bd));
Ld=(Cd-(Bd'*Pdmin*Ad))/Wd;
g=[Wd,Ld]';

% Brute force scaling of g so that max(abs(Gbrz))==1
Nw=2^16;
[g,w,G]=direct_form_scale(g,1,Nw);
% Sanity check on roots of complementary minimum phase filter
if max(abs(qroots(g))) >= 1
  error("max(abs(qroots(g)))(%g) >= 1",max(abs(qroots(g))));
endif

% Plot h response
plot(w*0.5/pi,20*log10(abs(H)))
title("Filter response");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -40 5])
print(strcat(strf,"_h_response"),"-dpdflatex");
close
zplane(qroots(h));
title("Initial filter zeros");
print(strcat(strf,"_h_zeros"),"-dpdflatex");
close

% Plot complementary minimum phase response
plot(w*0.5/pi,20*log10(abs(G)))
title("Complementary filter response");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -40 5])
print(strcat(strf,"_g_response"),"-dpdflatex");
close
zplane(qroots(g));
title("Complementary filter zeros");
print(strcat(strf,"_g_zeros"),"-dpdflatex");
close

% Plot combined response
plot(w*0.5/pi,10*log10((abs(G).^2)+(abs(H).^2)))
title("Combined filter response");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
axis([0 0.5 -3 3])
print(strcat(strf,"_hg_response"),"-dpdflatex");
close

% Sanity check on combined response
tol=1;
if max(abs((abs(G).^2)+(abs(H).^2)-1)) > tol
  error("max(abs((abs(G).^2)+(abs(H).^2)-1))(%g) > tol(%g)",
        max(abs((abs(G).^2)+(abs(H).^2)-1)),tol);
endif

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% tolerance on results\n",tol);
fprintf(fid,"N=%d %% filter order\n",N);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"Wasl=%g %% Stop band amplitude response lower weight\n",Wasl);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Wasu=%g %% Stop band amplitude response upper weight\n",Wasu);
fclose(fid);

% Save results
print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));
print_polynomial(g,"g");
print_polynomial(g,"g",strcat(strf,"_g_coef.m"));

save tuqanFIRnonsymmetric_dare_minimum_phase_test.mat ...
     N fasl fapl fapu fasu Wasl Wap Wasu h g

% Done
diary off
movefile tuqanFIRnonsymmetric_dare_minimum_phase_test.diary.tmp ...
         tuqanFIRnonsymmetric_dare_minimum_phase_test.diary;
