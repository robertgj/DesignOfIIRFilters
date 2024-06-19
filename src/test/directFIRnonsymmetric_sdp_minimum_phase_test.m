% directFIRnonsymmetric_sdp_minimum_phase_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% See Section 3.2 of SeDuMi_1_3/doc/SeDuMi_Guide_105R5.pdf and
% sedumi_minphase_test as well as Section V of "Use SeDuMi to Solve LP, SDP
% and SCOP Problems: Remarks % and Examples" by W. S. Lu (available at
% http://www.ece.uvic.ca/~wslu/Talk/SeDuMi-Remarks.pdf

test_common;

delete("directFIRnonsymmetric_sdp_minimum_phase_test.diary");
delete("directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp");
diary directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp

strf="directFIRnonsymmetric_sdp_minimum_phase_test";

% Design a low-pass filter
fapl=0.1;fapu=0.2;Wap=1;
fasl=0.05;fasu=0.25;Wasl=2;Wasu=2;
M=15;N=(2*M)+1;
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
b=bbrzc(N:end);

% Set up and solve the SeDuMi problem
n=length(b);
c=-vec(diag([(n-1):-1:0]));
At=zeros(n*n,n);
At(:,1)=vec(diag(ones(n,1)));
K.s=n;
for k=2:n,
  At(:,k)=vec(diag(0.5*ones(n-k+1,1),k-1)+diag(0.5*ones(n-k+1,1),-k+1));
endfor
[x,y,info] = sedumi(At,b,c,K);
printf("info.numerr = %d\n",info.numerr);
printf("info.dinf = %d\n",info.dinf);
printf("info.pinf = %d\n",info.pinf);
if info.numerr==2
  error("info.numerr == 2");
endif
% Check x and y
tol=2e-6;
if abs((c'*x)-(y'*b))>tol
  error("abs((c'*x)-(y'*b))(%g)>tol(%g)",abs((c'*x)-(y'*b)),tol);
endif

% Calculate the complementary minimum phase filter impulse response
X=mat(x);
[U,S,V]=svd(X);
g=V(:,1);
% Sanity check
if abs(S(1)-(g'*X*g))>2*eps
  error("abs(S(1)-(g'*X*g))(%g*eps)>2*eps",abs(S(1)-(g'*X*g))/eps);
endif

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
axis([0 0.5 -0.000010 0.000002])
print(strcat(strf,"_hg_response"),"-dpdflatex");
close

% Sanity check on combined response
if max(abs((abs(G).^2)+(abs(H).^2)-1)) > 2*tol
  error("max(abs((abs(G).^2)+(abs(H).^2)-1))(%g) > 2*tol(%g)",
        max(abs((abs(G).^2)+(abs(H).^2)-1)),2*tol);
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
save directFIRnonsymmetric_sdp_minimum_phase_test.mat ...
     N fasl fapl fapu fasu Wasl Wap Wasu h g

% Done
diary off
movefile directFIRnonsymmetric_sdp_minimum_phase_test.diary.tmp ...
         directFIRnonsymmetric_sdp_minimum_phase_test.diary;
