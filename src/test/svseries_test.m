% svseries_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("svseries_test.diary");
delete("svseries_test.diary.tmp");
diary svseries_test.diary.tmp

tol=50*eps;
fc=[0.1,0.15];
nsamples=2^10;

% Input signal
u=reprand(nsamples,2);
u=u-mean(u);
u=0.25*u./std(u);

% Filter 1
[A1a, B1a, C1a, D11] = butter (3,fc(1)*2);
[A1b, B2b, C2b, D22] = butter (2,fc(1)*2,'high');
A1=[A1a,zeros(rows(A1a),columns(A1b));zeros(rows(A1b),columns(A1a)),A1b];
B1=[[B1a;zeros(rows(B2b),1)],[zeros(rows(B1a),1);B2b]];
C1=[[C1a,zeros(1,columns(C2b))];[zeros(1,columns(C1a)),C2b]];
D12=-0.2;
D21=0.1;
D1=[D11,D12;D21,D22];

% Filter 2
[a2a, b1a, c1a, d11] = butter (4,fc(2)*2);
[a2b, b2b, c2b, d22] = butter (6,fc(2)*2,'high');
a2=[a2a,zeros(rows(a2a),columns(a2b));zeros(rows(a2b),columns(a2a)),a2b];
b2=[[b1a;zeros(rows(b2b),1)],[zeros(rows(b1a),1);b2b]];
c2=[[c1a,zeros(1,columns(c2b))];[zeros(1,columns(c1a)),c2b]];
d12=-5;
d21=-0.1;
d2=[d11,d12;d21,d22];

% Run series state variable equations
xx1=zeros(nsamples,rows(A1));
xx2=zeros(nsamples,rows(a2));
y1=zeros(nsamples,2);
y2=zeros(nsamples,2);
[y1,xx1]=svf(A1,B1,C1,D1,u);
[y2,xx2]=svf(a2,b2,c2,d2,y1);

% Run with overall state variable matrix
A=[A1,zeros(rows(A1),columns(a2));b2*C1,a2];
B=[B1;b2*D1];
C=[d2*C1, c2];
D=[d2*D1];
XX=zeros(nsamples,rows(A));
Y=zeros(nsamples,2);
[Y,XX]=svf(A,B,C,D,u);

% Check
if max(max(abs(y2-Y)))>tol
  error("max(max(abs(y2-Y)))>tol");
endif
if max(max(abs([xx1,xx2]-XX)))>tol
  error("max(max(abs([xx1,xx2]-XX)))>tol");
endif

% Done
diary off
movefile svseries_test.diary.tmp svseries_test.diary;
