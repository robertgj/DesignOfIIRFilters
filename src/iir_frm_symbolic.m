% iir_frm_symbolic.m
% Use the symbolic package to generate expressions for
% the squared-amplitude and phase response and gradients
% for the FRM filter with an IIR model filter

% Copyright (C) 2017-2025 Robert G. Jenssen

clear all
pkg load symbolic

syms w a r D M real
syms A(w,a) B(w,a) R(w,r) PZ(w,r)
syms Hr(w,a,r) Hi(w,a,r)

Hr(w,a,r)=(A(w,a)*R(w,r)*cos(PZ(w,r)))+B(w,a)
Hi(w,a,r)=A(w,a)*R(w,r)*sin(PZ(w,r))
absAsq(w,a,r)=((A(w,a)^2)*(R(w,r)^2)) + (B(w,a)^2) + ...
                (2*A(w,a)*B(w,a)*R(w,r)*cos(PZ(w,r)))
argH(w,a,r)=atan(Hi(w,a,r)/Hr(w,a,r))
grdelayH(w,a,r)=-diff(argH,w)
latex(grdelayH(w,a,r))

AsqgrdelayH(w,a,r)=-((Hr(w,a,r)*diff(Hi,w))-(Hi(w,a,r)*diff(Hr,w)))
feAsqgrdelayH(w,a,r)=simplify(expand(AsqgrdelayH(w,a,r)))
latex(feAsqgrdelayH(w,a,r))

simplify(diff(absAsq,a))
simplify(diff(absAsq,r))

simplify(diff(feAsqgrdelayH,a))
simplify(diff(feAsqgrdelayH,r))

