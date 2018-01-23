% casc2tf_tf2casc_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("casc2tf_tf2casc_test.diary");
unlink("casc2tf_tf2casc_test.diary.tmp");
diary casc2tf_tf2casc_test.diary.tmp

format short e

tol=1e-11

% a=[]
p=casc2tf([])
if p~=1
  error("p~=1");
endif

% p=1
p=1
[a,k]=tf2casc(p)
if ~isempty(a)
  error("~isempty(a)");
endif
if k~=p(1)
  error("k~=p(1)");
endif

% Even n with real poles
p=4*conv([1;-4;5],conv([1;-4;4],[1;-6;9]));
[a,k]=tf2casc(p)
pp=casc2tf(a)*k
if max(abs(pp-p)) > tol
  error("max(abs(pp-p)) > tol");
endif

% Odd n
p=6*conv([1 -4 5],conv([1 -2],conv([1 -4 4],[1 0 1])))
[a,k]=tf2casc(p)
pp=casc2tf(a)*k
if max(abs(pp-p)) > tol
  error("max(abs(pp-p)) > tol");
endif

% Found in debugging frm2ndOrderCascade_socp.m: tf2casc.m moves sections
dk = [  -1.2724130709,   0.4044774680,  -0.2116238277,   0.0962458657, ... 
         0.1991685836,  -0.0116871426,   0.1872238136,   0.0030039240, ... 
         0.2958810000,   0.5601777415 ]'
d=casc2tf(dk)
nd=norm(d-conv([1; dk(1); dk(2)], ...
               conv([1; dk(3); dk(4)], ...
                    conv([1; dk(5); dk(6)], ...
                         conv([1; dk(7); dk(8)],[1; dk(9); dk(10)])))));
if nd > eps
  error("nd > eps");
endif

pr=roots(d)
for m=2:2:rows(pr)
  conv([1 -pr(m)],[1 -pr(m-1)])
endfor

[spr,ipr]=sort(abs(imag(pr)));
ppr=pr(ipr);
for m=2:2:rows(ppr)
  conv([1 -ppr(m)],[1 -ppr(m-1)])
endfor

[dktmp,k]=tf2casc(d)
dd=casc2tf(dktmp)
if max(abs(dd-d)) > 10*eps
  error("max(abs(dd-d)) > 10*eps");
endif

diary off
movefile casc2tf_tf2casc_test.diary.tmp casc2tf_tf2casc_test.diary;
