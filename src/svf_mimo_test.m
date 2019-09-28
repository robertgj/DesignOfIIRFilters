% svf_mimo_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("svf_mimo_test.diary");
unlink("svf_mimo_test.diary.tmp");
diary svf_mimo_test.diary.tmp


% Design filters
dbap=0.1;
dbas=40;
fl=0.05;
fh=0.15;
[a1,b1,c1,d1]=ellip(5,dbap,dbas,2*fl);
[a2,b2,c2,d2]=ellip(6,dbap,dbas,2*[fl,fh]);
[a3,b3,c3,d3]=ellip(7,dbap,dbas,2*fh,'high');
N=1000;
u=reprand(N,3);
u=u-mean(u);
u=0.25*std(u).*u;

% Run svf for 1 input and 3 outputs
a=[a1,zeros(rows(a1),columns(a2)+columns(a3)); ...
   zeros(rows(a2),columns(a1)),a2,zeros(rows(a2),columns(a3)); ...
   zeros(rows(a3),columns(a1)+columns(a2)),a3];
b=[b1;b2;b3];
c=[c1,zeros(1,columns(a2)+columns(a3)); ...
   zeros(1,columns(a1)),c2,zeros(1,columns(a3)); ... 
   zeros(1,columns(a1)+columns(a2)),c3];
d=[d1;d2;d3];
y1=svf(a1,b1,c1,d1,u(:,1));
y2=svf(a2,b2,c2,d2,u(:,1));
y3=svf(a3,b3,c3,d3,u(:,1));
y=svf(a,b,c,d,u(:,1));
if max(max(abs([y1,y2,y3]-y)))>eps
  error("max(max(abs([y1,y2,y3]-y)))>eps");
endif

% Run svf for 3 inputs and 1 output
a=[a1,zeros(rows(a1),columns(a2)+columns(a3)); ...
   zeros(rows(a2),columns(a1)),a2,zeros(rows(a2),columns(a3)); ...
   zeros(rows(a3),columns(a1)+columns(a2)),a3];
b=[[b1;zeros(rows(a2)+rows(a3),1)], ...
   [zeros(rows(a1),1);b2;zeros(rows(b3),1)], ...
   [zeros(rows(a1)+rows(a2),1);b3]];
c=[c1,c2,c3];
d=[d1,d2,d3];
y1=svf(a1,b1,c1,d1,u(:,1));
y2=svf(a2,b2,c2,d2,u(:,2));
y3=svf(a3,b3,c3,d3,u(:,3));
y=svf(a,b,c,d,u);
if max(abs(y1+y2+y3-y))>eps
  error("max(abs(y1+y2+y3-y))>eps");
endif

% Run svf for 3 inputs and 4 outputs
a=[a1,zeros(rows(a1),columns(a2)+columns(a3)); ...
   zeros(rows(a2),columns(a1)),a2,zeros(rows(a2),columns(a3)); ...
   zeros(rows(a3),columns(a1)+columns(a2)),a3];
b=[[b1;zeros(rows(a2)+rows(a3),1)], ...
   [zeros(rows(a1),1);b2;zeros(rows(b3),1)], ...
   [zeros(rows(a1)+rows(a2),1);b3]];
c=[c1,zeros(1,columns(a2)+columns(a3)); ...
   zeros(1,columns(a1)),c2,zeros(1,columns(a3)); ... 
   zeros(1,columns(a1)+columns(a2)),c3; ...
   c1,zeros(1,columns(a2)),c3];
d=[diag([d1,d2,d3]);d1,0,d3];
N=1000;
u=reprand(N,3);
u=u-mean(u);
u=0.25*std(u).*u;
y1=svf(a1,b1,c1,d1,u(:,1));
y2=svf(a2,b2,c2,d2,u(:,2));
y3=svf(a3,b3,c3,d3,u(:,3));
y=svf(a,b,c,d,u);
if max(max(abs([y1,y2,y3,y1+y3]-y)))>eps
  error("max(max(abs([y1,y2,y3,y1+y3]-y)))>eps");
endif

% Done
diary off
movefile svf_mimo_test.diary.tmp svf_mimo_test.diary;
