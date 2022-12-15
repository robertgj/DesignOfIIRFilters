% vaidyanathanFIRsymmetric_lowpass_test.m
% Design an interpolated multiplier-less FIR filter by the method of
% Vaidyanathan. See: "Efficient and Multiplierless Design of FIR Filters with
% Very Sharp Cutoff via Maximally Flat Building Blocks", P. P. Vaidyanathan,
% IEEE Trans. on Circuits and Systems, March, 1985, Vol. 32, No. 3, pp. 236-244
%
% Copyright (C) 2022 Robert G. Jenssen

test_common;

strf="vaidyanathanFIRsymmetric_lowpass_test";
delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

nplot=1000;
f=(0:nplot)'*0.5/nplot;
w=2*pi*f;

% C and S
C=cos(w/2).^2;
C2=cos(w).^2;
C4=cos(2*w).^2;
S=sin(w/2).^2;
S2=sin(w).^2;
S4=sin(2*w).^2;

% Frequency transformations
I=(C.^3).*(1+(3*S)+(6*(S.^2)));
II=(I.^6).*(1 + (3*(1-(I.^2))) + (6*((1-(I.^2)).^2)));

Iz2=(C2.^3).*(1 + (3*S2) + (6*(S2.^2)));
IIz2=(Iz2.^6).*(1 + (3*(1-(Iz2.^2))) + (6*((1-(Iz2.^2)).^2)));

Jz4=(C4.^2).*(1 + (2*S4) + (3*(S4.^2)) + (4*(S4.^3)));
JJz4=(Jz4.^4).*(1 + ...
                (2*((1-(Jz4.^2)))) + ...
                (3*((1-(Jz4.^2)).^2)) + ...
                (4*((1-(Jz4.^2)).^3)));

% Overall filter
H5=II.*IIz2.*JJz4;

% Plot response
plot(f,20*log10(abs(H5)));
axis([0 0.5 -120 20])
grid("on");
xlabel("Frequency");
ylabel("Amplitude (dB)");
title(sprintf("Vaidyanathan multiplier-less interpolated FIR filter"));
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
