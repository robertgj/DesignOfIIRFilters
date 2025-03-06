% svfeedback_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("svfeedback_test.diary");
delete("svfeedback_test.diary.tmp");
diary svfeedback_test.diary.tmp

fc=[0.1,0.15];

% Input signals
nsamples=2^10;
u=reprand(nsamples,2);
u1=u(:,1);
u1=u1-mean(u1);
u1=0.25*u1./std(u1);
w2=u(:,2);
w2=w2-mean(w2);
w2=0.25*w2./std(w2);

% A1,B1,B1,C1,C2,D11,D12,D21,D22 filter
[A1a, B1a, C1a, D11] = butter (3,fc(1)*2);
[A1b, B2b, C2b, D22] = butter (2,fc(1)*2,"high");
A1=[A1a,zeros(rows(A1a),columns(A1b));zeros(rows(A1b),columns(A1a)),A1b];
B1=[B1a;zeros(rows(B2b),1)];
B2=[zeros(rows(B1a),1);B2b];
C1=[C1a,zeros(1,columns(C2b))];
C2=[zeros(1,columns(C1a)),C2b];
D12=-0.2;
D21=0.1;

% A2,b1,b1,c1,c2,d12,d21,d22 filter
[A2a, b1a, c1a, d12] = butter (4,fc(2)*2);
[A2b, b2b, c2b, d22] = butter (6,fc(2)*2,"high");
A2=[A2a,zeros(rows(A2a),columns(A2b));zeros(rows(A2b),columns(A2a)),A2b];
b1=[b1a;zeros(rows(b2b),1)];
b2=[zeros(rows(b1a),1);b2b];
c1=[c1a,zeros(1,columns(c2b))];
c2=[zeros(1,columns(c1a)),c2b];
d21=0.1;

% Run feedback state variable equations
x1=zeros(rows(A1),1);
x2=zeros(rows(A2),1);
xx1=zeros(nsamples,rows(A1));
xx2=zeros(nsamples,rows(A2));
y1=zeros(nsamples,1);
v2=zeros(nsamples,1);
for k=1:nsamples
  v1=(c1*x2)+(d12*w2(k));
  nextx1=(A1*x1)+(B1*u1(k))+(B2*v1);
  y1(k)=(C1*x1)+(D11*u1(k))+(D12*v1);
  y2=(C2*x1)+(D21*u1(k))+(D22*v1);
  nextx2=(A2*x2)+(b1*y2)+(b2*w2(k));
  v2(k)=(c2*x2)+(d21*y2)+(d22*w2(k));
  x1=nextx1;
  x2=nextx2;
  xx1(k,:)=x1';
  xx2(k,:)=x2';
endfor

% Run with overall state variable matrix
Abcd=[A1,B2*c1,B1,B2*d12; ...
      b1*C2,(b1*D22*c1+A2),b1*D21,(b1*D22*d12+b2); ...
      C1,D12*c1,D11,D12*d12; ...
      d21*C2,(d21*D22*c1+c2),d21*D21,(d21*D22*d12+d22)];
X1=zeros(rows(A1),1);
X2=zeros(rows(A2),1);
XX1=zeros(nsamples,rows(A1));
XX2=zeros(nsamples,rows(A2));
Y1=zeros(nsamples,1);
V2=zeros(nsamples,1);
for k=1:nsamples
  tmp=Abcd*[X1;X2;u1(k);w2(k)];
  X1=tmp(1:rows(A1));
  X2=tmp((rows(A1)+1):(rows(A1)+rows(A2)));
  Y1(k)=tmp(rows(A1)+rows(A2)+1);
  V2(k)=tmp(rows(A1)+rows(A2)+2);
  XX1(k,:)=X1';
  XX2(k,:)=X2';
endfor

% Check
if max(abs(y1-Y1))>eps
  error("max(abs(y1-Y1))>eps");
endif
if max(abs(v2-V2))>eps
  error("max(abs(v2-V2))>eps");
endif
if max(max(abs(xx1-XX1)))>eps
  error("max(max(abs(xx1-XX1)))>eps");
endif
if max(max(abs(xx2-XX2)))>eps
  error("max(max(abs(xx2-XX2)))>eps");
endif

% Done
diary off
movefile svfeedback_test.diary.tmp svfeedback_test.diary;
