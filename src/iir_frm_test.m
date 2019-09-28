% iir_frm_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("iir_frm_test.diary");
unlink("iir_frm_test.diary.tmp");
diary iir_frm_test.diary.tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency vector
%
clear all
Mmodel=9;
Dmodel=9;
mn=14;
mr=10;
fp=0.3;
fs=0.305;
% Model filter
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
x0.a=remez(mn,2*[0 fadp fads 0.5],[1 1 0 0]);
x0.d=[1;zeros(mr,1)];
% Masking filters
na=41;
faap=((m-1)+fads)/Mmodel;
faas=(m-fadp)/Mmodel;
x0.aa=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
facp=(m-fads)/Mmodel;
facs=(m+fadp)/Mmodel;
nc=33;
x0.ac=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T,gradAsq,gradT]=iir_frm([],xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
if !isempty(Asq)
  error("Expected Asq=[]");
endif
if !isempty(T)
  error("Expected T=[]");
endif
if !isempty(gradAsq)
  error("Expected gradAsq=[]");
endif
if !isempty(gradT)
  error("Expected gradT=[]");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=10*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of 4th order Butterworth model filter (Mmodel=1)
%
clear all
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.15;
[b_4,a_4]=butter(4,2*fp);
x0.a=b_4(:);
x0.d=a_4(:);
x0.aa=1;
x0.ac=0;
Mmodel=1;
Dmodel=0;
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
H_4=freqz(b_4,a_4,n);
Asq_4=abs(H_4).^2;
tolH_4=60*eps;
if max(abs(Asq_4-Asq)) > tolH_4
  error("Expected max(abs(Asq_4-Asq)) <= tolH_4");
endif
np=ceil(fp*n/0.5);
T_4=grpdelay(b_4,a_4,n);
tolT_4=88*eps;
if max(abs(T_4(1:np)-T(1:np))) > tolT_4
  error("Expected max(abs(T_4(1:np)-T(1:np))) <= tolT_4");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=10*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of masking filter (odd length)
%
clear all
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=0;
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
faap=((m-1)+fads)/Mmodel;
faas=(m-fadp)/Mmodel;
nak=41;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.a=1;
x0.d=1;
x0.aa=aa;
x0.ac=0;
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
H_aa=freqz(x0.aa,1,w);
Asq_aa=abs(H_aa).^2;
tolAsq_aa=20*eps;
if max(abs(Asq_aa-Asq)) > tolAsq_aa
  error("Expected max(abs(Asq_aa-Asq)) <= tolAsq_aa");
endif
np=ceil(0.15*n/0.5);
tolT_aa=eps;
if max(abs(T(1:np))) > tolT_aa
  error("Expected max(abs(T(1:np))) <= tolT_aa");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=20*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of masking filter (even length)
%
clear all
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=0;
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
faap=((m-1)+fads)/Mmodel;
faas=(m-fadp)/Mmodel;
nak=40;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.a=1;
x0.d=1;
x0.aa=aa;
x0.ac=[0 0];
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
H_aa=freqz(x0.aa,1,w);
Asq_aa=abs(H_aa).^2;
tol=20*eps;
if max(abs(Asq_aa-Asq)) > tol
  error("Expected max(abs(Asq_aa-Asq)) > tol");
endif
np=ceil(0.15*n/0.5);
tolT_aa=eps;
if max(abs(T(1:np))) > tolT_aa
  error("Expected max(abs(T(1:np))) <= tolT_aa");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=20*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of complementary model masking filter (odd length)
%
clear all
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=0;
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
facp=(m-fads)/Mmodel;
facs=(m+fadp)/Mmodel;
nck=33;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.a=0;
x0.d=1;
x0.aa=0;
x0.ac=ac;
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
H_ac=freqz(x0.ac,1,w);
Asq_ac=abs(H_ac).^2;
tol=20*eps;
if max(abs(Asq_ac-Asq)) > tol
  error("Expected max(abs(Asq_ac-Asq)) <= tol");
endif
np=ceil(0.15*n/0.5);
tolT_ac=eps;
if max(abs(T(1:np))) > tolT_ac
  error("Expected max(abs(T(1:np))) <= tolT_ac");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=20*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of complementary model masking filter (even length)
%
clear all
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=0;
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
facp=(m-fads)/Mmodel;
facs=(m+fadp)/Mmodel;
nck=32;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.a=0;
x0.d=1;
x0.aa=[0 0];
x0.ac=ac;
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
H_ac=freqz(x0.ac,1,w);
Asq_ac=abs(H_ac).^2;
tol=20*eps;
if max(abs(Asq_ac-Asq)) > tol
  error("max(abs(Hw_ac-Asq)) > tol");
endif
np=ceil(0.15*n/0.5);
tolT_ac=eps;
if max(abs(T(1:np))) > tolT_ac
  error("Expected max(abs(T(1:np))) <= tolT_ac");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=20*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with 5th order Butterworth (Mmodel=4)
%
clear all
verbose=false;
n=1021;
w=((0:(n-1))*pi/n)';
fp=0.15;
[b_5,a_5]=butter(5,2*fp);
x0.a=b_5(:);
x0.d=a_5(:);
x0.aa=1;
x0.ac=0;
Mmodel=4;
Dmodel=3;
Tnominal=(Mmodel*Dmodel)+((max(length(x0.aa),length(x0.ac))-1)/2);
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch    
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
aM_5=[x0.a(1);kron(x0.a(2:end),[zeros(Mmodel-1,1);1])];
dM_5=[x0.d(1);kron(x0.d(2:end),[zeros(Mmodel-1,1);1])];
HM_5=freqz(aM_5,dM_5,w);
AsqM_5=abs(HM_5).^2;
tolAsqM_5=70*eps;
if max(abs(AsqM_5-Asq)) > tolAsqM_5
  error("Expected max(abs(AsqM_5-Asq)) <= tolAsqM_5");
endif
np=ceil(0.15*n/(Mmodel*0.5));
TM_5=grpdelay(aM_5,dM_5,n);
tolTM_5=496*eps;
if max(abs(TM_5(1:np)-Tnominal-T(1:np))) > tolTM_5
  error("Expected max(abs(TM_5(1:np)-Tnominal-T(1:np))) <= tolTM_5");
endif
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=10*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
% Check gradient of FRM filter response squared-amplitude
wp=2*pi*fp/5;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm(wp,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
del=1e-7;
tol_gradAsq=del/2;
tol_gradT=del*5;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm(wp,xk+(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm(wp,xk-(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with 5th order Butterworth and delay
%
clear all
verbose=false;
n=128; 
w=((0:(n-1))')*pi/n;
fp=0.15;
[b_5,a_5]=butter(5,2*fp);
x0.a=b_5(:);
x0.d=a_5(:);
x0.aa=0;
x0.ac=1;
Mmodel=3;
Dmodel=5;
Tnominal=(Mmodel*Dmodel)+((max(length(x0.aa),length(x0.ac))-1)/2);
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
% Check conversion
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=10*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
% Check squared-magnitude and delay responses
try
  [Asq,T,gradAsq]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch    
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
aM_5=[x0.a(1);kron(x0.a(2:end),[zeros(Mmodel-1,1);1])];
dM_5=[x0.d(1);kron(x0.d(2:end),[zeros(Mmodel-1,1);1])];
aM_5=[zeros(Mmodel*Dmodel,1);dM_5]-[aM_5;zeros(Mmodel*Dmodel,1)];
HM_5=freqz(aM_5,dM_5,w);
AsqM_5=abs(HM_5).^2;
tolAsqM_5=46*eps;
if max(abs(AsqM_5-Asq)) > tolAsqM_5
  error("Expected max(abs(AsqM_5-Asq)) <= tolAsqM_5");
endif
TM_5=grpdelay(aM_5,dM_5,n);
tolTM_5=4210*eps;
if max(abs(TM_5(20:70)-Tnominal-T(20:70))) > tolTM_5
  error("Expected max(abs(TM_5(20:70)-Tnominal-T(20:70))) <= tolTM_5");
endif
% Check squared-magnitude and group delay gradients
wp=2*pi*fp/5;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm(wp,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
del=1e-7;
tol_gradAsq=del/2;
tol_gradT=2*del;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm(wp,xk+(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm(wp,xk-(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=shift(delxk,1);
endfor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with mn!=mr with delay
%
clear all
verbose=false;
n=1024;
fp=0.2;
fs=0.3;
% Model filter
x0.a=remez(14,2*[0 fp fs 0.5],[1 1 0 0]);
[b_mr,a_mr]=butter(10,2*fp);
x0.d=a_mr(:);
x0.aa=0;
x0.ac=1;
Mmodel=5;
Dmodel=10;
Tnominal=(Mmodel*Dmodel)+((max(length(x0.aa),length(x0.ac))-1)/2);
% Check conversion
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=22*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
% Check squared-magnitude and group delay response
aM_14_10=[x0.a(1);kron(x0.a(2:end),[zeros(Mmodel-1,1);1])];
dM_14_10=[x0.d(1);kron(x0.d(2:end),[zeros(Mmodel-1,1);1])];
aM_14_10=[zeros(Mmodel*Dmodel,1);dM_14_10]-[aM_14_10;zeros(Mmodel*Dmodel-20,1)];
[H_14_10,w]=freqz(aM_14_10,dM_14_10,n);
Asq_14_10=abs(H_14_10).^2;
T_14_10=grpdelay(aM_14_10,dM_14_10,n);
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
tolAsq_14_10=42240*eps;
if max(abs(Asq_14_10-Asq)) > tolAsq_14_10
  error("Expected max(abs(Asq_14_10-Asq)) <= tolAsq_14_10");
endif
tolT_14_10=40000*eps;
np=ceil((fp*n/0.5)/8);
if max(abs(T_14_10(2:np)-Tnominal-T(2:np))) > tolT_14_10
  error("Expected max(abs(T_14_10(2:np)-Tnominal-T(2:np))) <= tolT_14_10");
endif
% Check squared-magnitude and group delay gradients
wp=2*pi*fp/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm(wp,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
del=1e-7;
tol_gradAsq=del*5;
tol_gradT=del*5;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm(wp,xk+(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm(wp,xk-(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=shift(delxk,1);
endfor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of frequency response masking filter (na,nc odd)
%
clear all
verbose=false;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=7;
% Model filter
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
% Masking filters
na=41;
nc=33;
faap=((m-1)+fads)/Mmodel;
faas=(m-fadp)/Mmodel;
facp=(m-fads)/Mmodel;
facs=(m+fadp)/Mmodel;
Tnominal=(Mmodel*Dmodel)+((max(na,nc)-1)/2);
% Filters found with tarczynski_frm_iir_test.m
% (based on the Example of Lu and Hinamoto)
x0.a = [   0.0107663177,  -0.0161930423,   0.0130975131,  -0.0044629982, ... 
           0.0095313853,  -0.0334066318,   0.0222084312,   0.7788362513, ... 
           0.7708598412,   1.2731548244,   0.5331144613,   0.4461514291, ... 
          -0.0702607322,  -0.0182788192,  -0.0789087737 ]';
x0.d = [   1.0000000000,   0.7927922074,   1.5642325295,   0.5602642462, ... 
           0.5915798418,  -0.1051969089,   0.0093781435,  -0.1054207986, ... 
           0.0078117982,  -0.0070670502,   0.0084276205 ]';
x0.aa = [ -0.0024711433,  -0.0074412104,   0.0030392043,   0.0076255652, ... 
          -0.0267237274,  -0.0041121828,   0.0307210264,  -0.0224135676, ... 
          -0.0202555798,   0.0432962395,  -0.0042068193,  -0.0510971204, ... 
           0.0424572816,   0.0247669921,  -0.0732845183,   0.0176375255, ... 
           0.0875962209,  -0.0940192962,  -0.0898210580,   0.3129509396, ... 
           0.5703383439,   0.3129509396,  -0.0898210580,  -0.0940192962, ... 
           0.0875962209,   0.0176375255,  -0.0732845183,   0.0247669921, ... 
           0.0424572816,  -0.0510971204,  -0.0042068193,   0.0432962395, ... 
          -0.0202555798,  -0.0224135676,   0.0307210264,  -0.0041121828, ... 
          -0.0267237274,   0.0076255652,   0.0030392043,  -0.0074412104, ... 
          -0.0024711433 ]';
x0.ac = [  0.0727453045,   0.0067346451,  -0.0672368945,   0.0589133101, ... 
           0.0334083048,  -0.0915665088,   0.0375526674,   0.0874078669, ... 
          -0.1092835497,   0.0822137918,   0.1222641791,  -0.1578579444, ... 
           0.0223693261,   0.1572240726,  -0.1693567218,   0.2204852774, ... 
           0.8279331313,   0.2204852774,  -0.1693567218,   0.1572240726, ... 
           0.0223693261,  -0.1578579444,   0.1222641791,   0.0822137918, ... 
          -0.1092835497,   0.0874078669,   0.0375526674,  -0.0915665088, ... 
           0.0334083048,   0.0589133101,  -0.0672368945,   0.0067346451, ... 
           0.0727453045 ]';
% Check conversion
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=53*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
% Check squared-magnitude and delay responses
a=x1.a;
d=x1.d;
if na>nc
  aa=x1.aa;
  ac=[zeros((na-nc)/2,1);x1.ac; zeros((na-nc)/2,1)];
elseif na<nc
  aa=[zeros((nc-na)/2,1);x1.aa; zeros((nc-na)/2,1)];
  ac=x1.ac;
else
  aa=x1.aa;
  ac=x1.ac;
endif
H_aa=freqz(aa,1,w);
H_ac=freqz(ac,1,w);
H_acD=freqz([zeros(Mmodel*Dmodel,1);ac],1,w);
HM_model=freqz(a,d,w*Mmodel);
H_frm=(HM_model.*(H_aa-H_ac))+H_acD;
Asq_frm=abs(H_frm).^2;
tolAsq_frm=343*eps;
if max(abs(Asq_frm-Asq)) > tolAsq_frm
  error("Expected max(abs(Asq_frm-Asq)) <= tolAsq_frm");
endif
% Alternative calculation
aM=[a(1);kron(a(2:end),[zeros(Mmodel-1,1);1])];
dM=[d(1);kron(d(2:end),[zeros(Mmodel-1,1);1])];
dM=[dM;zeros(length(aM)-length(dM),1)];
aM_frm=[conv(aM,aa-ac);zeros(Mmodel*Dmodel,1)] ...
       +[zeros(Mmodel*Dmodel,1);conv(ac,dM)];
H_frm_alt=freqz(aM_frm,dM,w);
Asq_frm_alt=abs(H_frm_alt).^2;
tolAsq_frm_alt=337*eps;
if max(abs(Asq_frm_alt-Asq)) > tolAsq_frm_alt
  error("Expected max(abs((Asq_frm_alt-Asq))) <= tolAsq_frm_alt");
endif
np=ceil((fp*n/0.5)/2);
T_frm_alt=grpdelay(aM_frm,dM,n);
tolT_frm_alt=200000*eps;
if max(abs(T_frm_alt(2:np)-Tnominal-T(2:np))) > tolT_frm_alt
  error("Expected max(abs(T_frm_alt(2:np)-Tnominal-T(2:np))) <= tolT_frm_alt");
endif
% Check squared-magnitude and group delay gradients
wp=2*pi*fp/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm(wp,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
del=1e-7;
tol_gradAsq=del/10;
tol_gradT=del/4;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm(wp,xk+(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm(wp,xk-(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
    endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of frequency response masking filter (na,nc even)
%
clear all
verbose=false;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
Mmodel=9;
Dmodel=7;
% Model filter
m=ceil(fs*Mmodel);
fadp=m-(fs*Mmodel);
fads=m-(fp*Mmodel);
% Masking filters
na=32;
nc=34;
faap=((m-1)+fads)/Mmodel;
faas=(m-fadp)/Mmodel;
facp=(m-fads)/Mmodel;
facs=(m+fadp)/Mmodel;
Tnominal=(Mmodel*Dmodel)+((max(na,nc)-1)/2);
% Filters found with tarczynski_frm_iir_test.m
x0.a = [  -0.0784592841,   0.1863500793,  -0.0884547090,  -0.1464613536, ... 
           0.1666956842,   0.3083323588,  -0.7031082027,   0.1958969755, ... 
          -1.4517898436,   0.2572575630,   0.0823840052 ]';
x0.d = [   1.0000000000,   0.2777918176,   0.4488399617,  -0.0668630062, ... 
          -0.0858728808,   0.0241336204,   0.0112265233,  -0.0120708582, ... 
           0.0005545550,  -0.0252078435,   0.0034073846 ]';
x0.aa = [ -0.0002548695,  -0.0011537313,   0.0022115102, ... 
          -0.0010505294,  -0.0031532752,   0.0058659145,   0.0011487604, ... 
          -0.0094883306,   0.0182867162,   0.0071182461,  -0.0426198968, ... 
           0.0318505801,   0.0454904236,  -0.1173474475,   0.0379342247, ... 
           0.5311741446,   0.5311741446,   0.0379342247,  -0.1173474475, ... 
           0.0454904236,   0.0318505801,  -0.0426198968,   0.0071182461, ... 
           0.0182867162,  -0.0094883306,   0.0011487604,   0.0058659145, ... 
          -0.0031532752,  -0.0010505294,   0.0022115102,  -0.0011537313, ... 
          -0.0002548695 ]';
x0.ac = [ -0.0025489630,  -0.0014374718,   0.0041178819,  -0.0004517156, ... 
          -0.0062570691,   0.0048346297,   0.0066918384,  -0.0101843602, ... 
          -0.0016308817,   0.0255156034,  -0.0086776584,  -0.0377079171, ... 
           0.0464164953,   0.0287263914,  -0.1209045837,   0.0595655883, ... 
           0.5161480645,   0.5161480645,   0.0595655883,  -0.1209045837, ... 
           0.0287263914,   0.0464164953,  -0.0377079171,  -0.0086776584, ... 
           0.0255156034,  -0.0016308817,  -0.0101843602,   0.0066918384, ... 
           0.0048346297,  -0.0062570691,  -0.0004517156,   0.0041178819, ... 
          -0.0014374718,  -0.0025489630 ]';
% Check conversion
try
  [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_struct_to_vec() failed");
end_try_catch
try
  [Asq,T]=iir_frm(w,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm() failed");
end_try_catch
try
  x1=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("iir_frm_vec_to_struct() failed");
end_try_catch
tol=35*eps;
if max(abs(x1.a-x0.a)) > tol
  error("Expected max(abs(x1.a-x0.a)) <= tol");
endif
if max(abs(x1.d-x0.d)) > tol
  error("Expected max(abs(x1.d-x0.d)) <= tol");
endif
if max(abs(x1.aa-x0.aa)) > tol
  error("Expected max(abs(x1.aa-x0.aa)) <= tol");
endif
if max(abs(x1.ac-x0.ac)) > tol
  error("Expected max(abs(x1.ac-x0.ac)) <= tol");
endif
% Check squared-magnitude and delay responses
a=x1.a;
d=x1.d;
if na>nc
  aa=x1.aa;
  ac=[zeros((na-nc)/2,1);x1.ac; zeros((na-nc)/2,1)];
elseif na<nc
  aa=[zeros((nc-na)/2,1);x1.aa; zeros((nc-na)/2,1)];
  ac=x1.ac;
else
  aa=x1.aa;
  ac=x1.ac;
endif
H_aa=freqz(aa,1,w);
H_ac=freqz(ac,1,w);
H_acD=freqz([zeros(Mmodel*Dmodel,1);ac],1,w);
HM_model=freqz(a,d,w*Mmodel);
H_frm=(HM_model.*(H_aa-H_ac))+H_acD;
Asq_frm=abs(H_frm).^2;
tolAsq_frm=74*eps;
if max(abs(Asq_frm-Asq)) > tolAsq_frm
  error("Expected max(abs(Asq_frm-Asq)) <= tolAsq_frm");
endif
% Alternative calculation
aM=[a(1);kron(a(2:end),[zeros(Mmodel-1,1);1])];
dM=[d(1);kron(d(2:end),[zeros(Mmodel-1,1);1])];
dM=[dM;zeros(length(aM)-length(dM),1)];
aM_frm=[conv(aM,aa-ac);zeros(Mmodel*Dmodel,1)] ...
       +[zeros(Mmodel*Dmodel,1);conv(ac,dM)];
H_frm_alt=freqz(aM_frm,dM,w);
Asq_frm_alt=abs(H_frm_alt).^2;
tolAsq_frm_alt=82*eps;
if max(abs(Asq_frm_alt-Asq)) > tolAsq_frm_alt
  error("Expected max(abs((Asq_frm_alt-Asq))) <= tolAsq_frm_alt");
endif
np=ceil((fp*n/0.5)/2);
T_frm_alt=grpdelay(aM_frm,dM,n);
tolT_frm_alt=3077*eps;
if max(abs(T_frm_alt(2:np)-Tnominal-T(2:np))) > tolT_frm_alt
  error("Expected max(abs(T_frm_alt(2:np)-Tnominal-T(2:np))) <= tolT_frm_alt");
endif
% Check squared-magnitude and group delay gradients
wp=2*pi*fp/8;
[Asq_wp,T_wp,gradAsq_wp,gradT_wp] = ...
  iir_frm(wp,xk,Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
del=1e-7;
tol_gradAsq=del/9;
tol_gradT=del/10;
delxk=[del;zeros(length(xk)-1,1)];
for k=1:length(xk)
  % Approximate gradAsq and gradT for this coefficient
  [Asq_wpPdelon2,T_wpPdelon2] = ...
    iir_frm(wp,xk+(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  [Asq_wpMdelon2,T_wpMdelon2] = ...
    iir_frm(wp,xk-(delxk/2),Uad,Vad,Mad,Qad,na,nc,Mmodel,Dmodel);
  approx_gradAsq_wp=(Asq_wpPdelon2-Asq_wpMdelon2)/del;
  approx_gradT_wp=(T_wpPdelon2-T_wpMdelon2)/del;
  % Check gradAsq
  diff_gradAsq_wp=abs(gradAsq_wp(k)-approx_gradAsq_wp);
  if verbose
    printf("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp);
  endif
  if diff_gradAsq_wp > tol_gradAsq
    error("gradAsq_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradAsq_wp(k),approx_gradAsq_wp,diff_gradAsq_wp,tol_gradAsq);
  endif
  % Check gradT
  diff_gradT_wp=abs(gradT_wp(k)-approx_gradT_wp);
  if verbose
    printf("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g\n",...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp);
  endif
  if diff_gradT_wp > tol_gradT
    error("gradT_wp(%d)=%g, approx=%g, max(abs(diff))=%g>%g", ...
           k,gradT_wp(k),approx_gradT_wp,diff_gradT_wp,tol_gradT);
  endif
  % Move to next coefficient
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile iir_frm_test.diary.tmp iir_frm_test.diary;
