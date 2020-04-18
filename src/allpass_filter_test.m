% allpass_filter_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("allpass_filter_test.diary");
delete("allpass_filter_test.diary.tmp");
diary allpass_filter_test.diary.tmp

n=1024;
w=pi*(0:(n-1))'/n;
thetaR=pi*sort([(0.01:0.02:0.99),0.495,0.4975,0.5025,0.505]);
realR=0.01:0.02:0.99;
rR=0.01:0.01:0.99;

first={"dir1","dir1_retimed","GM1","LS1"};
for nm=first,
  coef_fn=sprintf("allpass_%s_pole2coef",nm{1});
  Abcd_fn=sprintf("allpass_%s_coef2Abcd",nm{1});
  PS=zeros(size(rR));
  ng1=zeros(size(rR));
  for l=1:length(rR),
    b=feval(coef_fn,rR(l));
    [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=feval(Abcd_fn,b);
    ng1(l)=Abcd2ng(A,B,C,D);
    [H,~,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [~,gradP]=H2P(H,dHdx);
    PS(l)=max(abs(gradP));
  endfor
  semilogy(rR,PS);
  xlabel("Pole radius");
  ylabel("Maximum phase gradient");
  axis([0 1 10^0 10^2]);
  print(sprintf("allpass_filter_test_%s_pgrad",nm{1}),"-dpdflatex");
  close
  semilogy(rR,ng1);
  xlabel("Pole radius");
  ylabel("Noise gain");
  axis([0 1 10^-1 10^2]);
  print(sprintf("allpass_filter_test_%s_ng",nm{1}),"-dpdflatex");
  close
endfor

second={"dir2","dir2_retimed","AL7c","AL7c_retimed","GM2","GM2_retimed", ...
        "IS","IS_retimed","LS2a","MH2d","MH2d_retimed","MH3d"};
rR=[99,75,50,25];
for nm=1:length(second),

  coef_fn=sprintf("allpass_%s_pole2coef",second{nm});
  Abcd_fn=sprintf("allpass_%s_coef2Abcd",second{nm});

  % Real poles
  PSR=zeros(length(realR),length(rR));
  ngR=zeros(length(realR),length(rR));
  for l=1:length(rR),
    for m=1:length(realR),
      [b1,b2]=feval(coef_fn,realR(m),rR(l)/100,"real");
      [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=feval(Abcd_fn,b1,b2);
      ng2R(m,l)=Abcd2ng(A,B,C,D);
      [H,~,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
      [~,gradP]=H2P(H,dHdx);
      PSR(m,l)=max(max(abs(gradP)));
    endfor
  endfor
  semilogy(realR,PSR(:,1),'linestyle',':', ...
           realR,PSR(:,2),'linestyle','-', ...
           realR,PSR(:,3),'linestyle','-.', ...
           realR,PSR(:,4),'linestyle','--');
  xlabel("Pole radius r1");
  ylabel("Maximum phase gradient");
  axis([0 1 10^0 10^3]);
  grid("on");
  legend("r2=0.99","r2=0.75","r2=0.50","r2=0.25");
  legend("location","northwest");
  legend("boxoff");
  print(sprintf("allpass_filter_test_%s_real_pgrad",second{nm}),"-dpdflatex");
  close
  semilogy(realR,ng2R(:,1),'linestyle',':', ...
           realR,ng2R(:,2),'linestyle','-', ...
           realR,ng2R(:,3),'linestyle','-.', ...
           realR,ng2R(:,4),'linestyle','--');
  xlabel("Pole radius r1");
  ylabel("Noise gain");
  axis([0 1 10^-1 10^2]);
  grid("on");
  legend("r2=0.99","r2=0.75","r2=0.50","r2=0.25");
  legend("location","northwest");
  legend("boxoff");
  print(sprintf("allpass_filter_test_%s_real_ng",second{nm}),"-dpdflatex");
  close

  % Complex poles
  PStheta=zeros(length(thetaR),length(rR));
  ng2C=zeros(length(thetaR),length(rR));
  for l=1:length(rR),
    for m=1:length(thetaR),
      [b1,b2]=feval(coef_fn,rR(l)/100,thetaR(m),"complex");
      [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=feval(Abcd_fn,b1,b2);
      ng2C(m,l)=Abcd2ng(A,B,C,D);
      [H,~,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
      [~,gradP]=H2P(H,dHdx);
      PStheta(m,l)=max(max(abs(gradP)));
    endfor
  endfor
  semilogy(thetaR/pi,PStheta(:,1),'linestyle',':', ...
           thetaR/pi,PStheta(:,2),'linestyle','-', ...
           thetaR/pi,PStheta(:,3),'linestyle','-.', ...
           thetaR/pi,PStheta(:,4),'linestyle','--');
  xlabel("Pole angle(rad./$\\pi$)");
  ylabel("Maximum phase gradient");
  axis([0 1 10^0 10^3]);
  grid("on");
  legend("r=0.99","r=0.75","r=0.50","r=0.25");
  legend("location","north");
  legend("boxoff");
  print(sprintf("allpass_filter_test_%s_complex_pgrad",second{nm}),"-dpdflatex");
  close
  semilogy(thetaR/pi,ng2C(:,1),'linestyle',':', ...
           thetaR/pi,ng2C(:,2),'linestyle','-', ...
           thetaR/pi,ng2C(:,3),'linestyle','-.', ...
           thetaR/pi,ng2C(:,4),'linestyle','--');
  xlabel("Pole angle(rad./$\\pi$)");
  ylabel("Noise gain");
  axis([0 1 10^-1 10^2]);
  grid("on");
  legend("r=0.99","r=0.75","r=0.50","r=0.25");
  legend("location","north");
  legend("boxoff");
  print(sprintf("allpass_filter_test_%s_complex_ng",second{nm}),"-dpdflatex");
  close

endfor

% Done
diary off
movefile allpass_filter_test.diary.tmp allpass_filter_test.diary;
