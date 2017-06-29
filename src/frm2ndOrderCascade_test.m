% frm2ndOrderCascade_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% The frm2ndOrderCascade response is linear with respect to the FIR
% and IIR numerator polynomial coefficients.

test_common;

unlink("frm2ndOrderCascade_test.diary");
unlink("frm2ndOrderCascade_test.diary.tmp");
diary frm2ndOrderCascade_test.diary.tmp

format compact

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency vector
%
clear all
tol=20*eps;
M=9;
mn=14;
mr=10;
td=9;
fp=0.3;
fs=0.305;
% Model filter
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
x0.a=remez(mn,2*[0 fadp fads 0.5],[1 1 0 0]);
x0.d=[1;zeros(mr,1)];
% Masking filters
na=41;
faap=((m-1)+fads)/M;
faas=(m-fadp)/M;
aa=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.aa=aa;
facp=(m-fads)/M;
facs=(m+fadp)/M;
nc=33;
ac=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.ac=ac;
try
  xk=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade([],xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
if !isempty(Hw)
  error("Expected Hw=[]");
endif
if !isempty(gradHw)
  error("Expected gradHw=[]");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check response
%
% Check response of model filter
% Model filter is 4th order Butterworth
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.15;
[b_4,a_4]=butter(4,2*fp);
x0.a=b_4(:);
x0.d=a_4(:);
x0.aa=1;
x0.ac=0;
M=1;
td=0;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_4=freqz(b_4,a_4,w);
if max(abs(Hw_4-Hw)) > tol
  error("Expected max(abs(Hw_4-Hw)) <= tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with 5th order Butterworth
%
clear all
tol=25*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.15;
[b_5,a_5]=butter(5,2*fp);
x0.a=b_5(:);
x0.d=a_5(:);
x0.aa=1;
x0.ac=0;
M=1;
td=0;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch    
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_5=freqz(b_5,a_5,w);
if max(abs(Hw_5-Hw)) > tol
  error("Expected max(abs(Hw_5-Hw)) <= tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.0015;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with mn!=mr
%
clear all
tol=21*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.2;
fs=0.3;
% Model filter
x0.a=remez(14,2*[0 fp fs 0.5],[1 1 0 0]);
[b_mr,a_mr]=butter(10,2*fp);
x0.d=[a_mr(:);zeros(4,1)];
x0.aa=1;
x0.ac=0;
M=1;
td=0;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
% Compare with freqz
Hw_14_10=freqz(x0.a,x0.d,w);
if max(abs(Hw_14_10-Hw)) > 100*tol
  error("Expected max(abs(Hw_14_10-Hw)) <= 100*tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Repeat with mn==mr (d padded with zeros)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
mnk=14;
mrk=10;
fp=0.2;
fs=0.3;
% Model filter
x0.a=remez(mnk,2*[0 fp fs 0.5],[1 1 0 0]);
[b_mr,a_mr]=butter(mrk,2*fp);
x0.d=[a_mr(:);zeros(mnk-mrk,1)];
x0.aa=1;
x0.ac=0;
M=1;
td=0;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
% Compare with freqz
Hw_14_10=freqz(x0.a,x0.d,w);
if max(abs(Hw_14_10-Hw)) > 100*tol
  error("Expected max(abs(Hw_14_10-Hw)) <= 100*tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of masking filter (odd length)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
M=9;
td=0;
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
faap=((m-1)+fads)/M;
faas=(m-fadp)/M;
nak=41;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.a=1;
x0.d=1;
x0.aa=aa;
x0.ac=0;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_aa=freqz(x0.aa,1,w);
if max(abs(Hw_aa-(Hw.*exp(-j*w*(na-1)/2)))) > tol
  error("Expected max(abs(Hw_aa-(Hw.*exp(-j*w*(na-1)/2)))) > tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if gradHw_wp(k) ~= 0
    if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
             k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
             abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
      error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
    endif
  else
    if abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(k)) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del));
      error("abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(%d)) > %f",k,reltol);
    endif
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of masking filter (even length)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
M=9;
td=0;
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
faap=((m-1)+fads)/M;
faas=(m-fadp)/M;
nak=40;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.a=1;
x0.d=1;
x0.aa=aa;
x0.ac=[0 0];
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_aa=freqz(x0.aa,1,w);
if max(abs(Hw_aa-(Hw.*exp(-j*w*(na-1)/2)))) > tol
  error("Expected max(abs(Hw_aa-(Hw.*exp(-j*w*(na-1)/2)))) > tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if gradHw_wp(k) ~= 0
    if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
             k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
             abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
      error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
    endif
  else
    if abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(k)) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del));
      error("abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(%d)) > %f",k,reltol);
    endif
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of complementary model masking filter (odd length)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
M=9;
td=0;
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
facp=(m-fads)/M;
facs=(m+fadp)/M;
nck=33;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.a=0;
x0.d=1;
x0.aa=0;
x0.ac=ac;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_ac=freqz(x0.ac,1,w);
if max(abs(Hw_ac-(Hw.*exp(-j*w*(nc-1)/2)))) > tol
  error("max(abs(Hw_ac-(Hw.*exp(-j*w*(nc-1)/2)))) > tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00125;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if gradHw_wp(k) ~= 0
    if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
             k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
             abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
      error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
    endif
  else
    if abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(k)) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del));
      error("abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(%d)) > %f",k,reltol);
    endif
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of complementary model masking filter (even length)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
fp=0.3;
fs=0.305;
M=9;
td=0;
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
facp=(m-fads)/M;
facs=(m+fadp)/M;
nck=32;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.a=0;
x0.d=1;
x0.aa=[0 0];
x0.ac=ac;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
Hw_ac=freqz(x0.ac,1,w);
if max(abs(Hw_ac-(Hw.*exp(-j*w*(nc-1)/2)))) > tol
  error("max(abs(Hw_ac-(Hw.*exp(-j*w*(nc-1)/2)))) > tol");
endif
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Check gradient of model filter response
reltol=0.00001;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if gradHw_wp(k) ~= 0
    if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
             k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
             abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))));
      error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
    endif
  else
    if abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(k)) > reltol
      printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del));
      error("abs(((Hw_wpD-Hw_wp)/del) - gradHw_wp(%d)) > %f",k,reltol);
    endif
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of frequency response masking filter (na,nc odd)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
mnk=14;
mrk=10;
fp=0.3;
fs=0.305;
M=9;
td=9;
% Model filter
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
x0.a=remez(mnk,2*[0 fadp fads 0.5],[1 1 0 0]);
[b_mr,a_mr]=butter(mrk,2*fp);
x0.d=[a_mr(:);zeros(mnk-mrk,1)];
% Masking filters
nak=41;
faap=((m-1)+fads)/M;
faas=(m-fadp)/M;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.aa=aa;
facp=(m-fads)/M;
facs=(m+fadp)/M;
nck=33;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.ac=ac;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
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
% Compare with freqz
a=x1.a;
d=x1.d;
if na>nc
  aa=x1.aa;
  ac=[zeros((na-nc)/2,1);x1.ac; zeros((na-nc)/2,1)];
elseif na<nc
  aa=[zeros((nc-na)/2,1);x1.aa; zeros((nc-na)/2,1)];
  ac=x1.ac;
endif
Hw_aa=freqz(aa,1,w);
Hw_ac=freqz(ac,1,w);
Hw_acD=freqz([zeros(M*td,1);ac],1,w);
HwM_model=freqz(a,d,w*M);
Hw_frm=(HwM_model.*(Hw_aa-Hw_ac))+Hw_acD;
if max(abs(Hw_frm-(Hw.*exp(-j*w*((td*M)+((na-1)/2)))))) > 20*tol
  error("Expected max(abs(Hw_frm-(Hw.*exp(-j*w*((td*M)+((na-1)/2))))))<=20*tol");
endif
% Alternative calculation
aM=[a(1);kron(a(2:end),[zeros(M-1,1);1])];
dM=[d(1);kron(d(2:end),[zeros(M-1,1);1])];
aM_frm=[conv(aM,aa-ac);zeros(M*td,1)]+[zeros(M*td,1);conv(ac,dM)];
Hw_frm_alt=freqz(aM_frm,dM,w);
if max(abs(Hw_frm_alt-Hw_frm)) > 20*tol
  error("Expected max(abs((Hw_frm_alt-Hw_frm))) <= 20*tol");
endif
% Check gradient of model filter response
reltol=0.0002;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp*0.9;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k))))); 
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check response of frequency response masking filter (na,nc even)
%
clear all
tol=20*eps;
n=1024;
w=((0:(n-1))*pi/n)';
mnk=14;
mrk=14;
fp=0.3;
fs=0.305;
M=9;
td=9;
% Model filter
m=ceil(fs*M);
fadp=m-(fs*M);
fads=m-(fp*M);
[x0.a,x0.d]=butter(mnk,2*fp);
x0.a=x0.a(:);
x0.d=x0.d(:);
% Masking filters
nak=42;
faap=((m-1)+fads)/M;
faas=(m-fadp)/M;
aa=remez(nak-1,2*[0 faap faas 0.5],[1 1 0 0]);
x0.aa=aa;
facp=(m-fads)/M;
facs=(m+fadp)/M;
nck=34;
ac=remez(nck-1,2*[0 facp facs 0.5],[1 1 0 0]);
x0.ac=ac;
try
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_struct_to_vec() failed");
end_try_catch
try
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade() failed");
end_try_catch
try
  x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("frm2ndOrderCascade_vec_to_struct() failed");
end_try_catch
tol=90*eps;
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
% Compare with freqz
a=x1.a;
d=x1.d;
if na>nc
  aa=x1.aa;
  ac=[zeros((na-nc)/2,1);x1.ac; zeros((na-nc)/2,1)];
elseif na<nc
  aa=[zeros((nc-na)/2,1);x1.aa; zeros((nc-na)/2,1)];
  ac=x1.ac;
endif
Hw_aa=freqz(aa,1,w);
Hw_ac=freqz(ac,1,w);
Hw_acD=freqz([zeros(M*td,1);ac],1,w);
HwM_model=freqz(a,d,w*M);
Hw_frm=(HwM_model.*(Hw_aa-Hw_ac))+Hw_acD;
tol=7791*eps;
if max(abs(Hw_frm-(Hw.*exp(-j*w*((td*M)+((na-1)/2)))))) > tol
  error("Expected max(abs(Hw_frm-(Hw.*exp(-j*w*((td*M)+((na-1)/2))))))<=tol");
endif
% Alternative calculation
aM=[a(1);kron(a(2:end),[zeros(M-1,1);1])];
dM=[d(1);kron(d(2:end),[zeros(M-1,1);1])];
aM_frm=[conv(aM,aa-ac);zeros(M*td,1)]+[zeros(M*td,1);conv(ac,dM)];
Hw_frm_alt=freqz(aM_frm,dM,w);
tol=818*eps;
if max(abs(Hw_frm_alt-Hw_frm)) > tol
  error("Expected max(abs((Hw_frm_alt-Hw_frm))) <= tol");
endif
% Check gradient of model filter response
reltol=0.0003;
del=abs(min(xk)/1000);
delxk=[del;zeros(length(xk)-1,1)];
wp=2*pi*fp/10;
[Hw_wp,gradHw_wp]=frm2ndOrderCascade(wp,xk,mn,mr,na,nc,M,td);
for k=1:length(xk)
  Hw_wpD=frm2ndOrderCascade(wp,xk+delxk,mn,mr,na,nc,M,td);
  if abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k)))) > reltol
    printf("abs(gradHw_wp(%d))=%f, abs(approx)=%f, abs(rel. diff)=%f\n",...
           k,abs(gradHw_wp(k)),abs((Hw_wpD-Hw_wp)/del), ...
           abs(1-((abs(Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(k))))); 
    error("abs(1-(((Hw_wpD-Hw_wp)/del)/abs(gradHw_wp(%d)))) > %f",k,reltol);
  endif
  delxk=shift(delxk,1);
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile frm2ndOrderCascade_test.diary.tmp frm2ndOrderCascade_test.diary;
