% pq2svcasc_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("pq2svcasc_test.diary");
unlink("pq2svcasc_test.diary.tmp");
diary pq2svcasc_test.diary.tmp


fc=0.1;
delta=4; % For optKW2()
for N=1:13
  for t=1:2

    % Generate d-p-q and transfer function coefficients
    if t==1
      printf("\nTesting Butterworth low-pass filter with N=%d,fc=%f\n",N,fc);
      [n,d]=butter(N,fc*2);
      [dd,p1,p2,q1,q2]=butter2pq(N,fc);
    else
      printf("\nTesting Butterworth high-pass filter with N=%d,fc=%f\n",N,fc);
      [n,d]=butter(N,fc*2,"high");
      [dd,p1,p2,q1,q2]=butter2pq(N,fc,"high");
    endif
    printf("dd=[");printf(" %10.6f",dd(:)');printf("]\n");
    printf("p1=[");printf(" %10.6f",p1(:)');printf("]\n");
    printf("p2=[");printf(" %10.6f",p2(:)');printf("]\n");
    printf("q1=[");printf(" %10.6f",q1(:)');printf("]\n");
    printf("q2=[");printf(" %10.6f",q2(:)');printf("]\n");

    % Direct form sections
    [a11dir,a12dir,a21dir,a22dir,b1dir,b2dir,c1dir,c2dir]= ...
      pq2svcasc(p1,p2,q1,q2,"direct");
    printf("a11dir=[");printf(" %10.6f",a11dir(:)');printf("]\n");
    printf("a12dir=[");printf(" %10.6f",a12dir(:)');printf("]\n");
    printf("a21dir=[");printf(" %10.6f",a21dir(:)');printf("]\n");
    printf("a22dir=[");printf(" %10.6f",a22dir(:)');printf("]\n");
    printf("b1dir=[");printf(" %10.6f",b1dir(:)');printf("]\n");
    printf("b2dir=[");printf(" %10.6f",b2dir(:)');printf("]\n");
    printf("c1dir=[");printf(" %10.6f",c1dir(:)');printf("]\n");
    printf("c2dir=[");printf(" %10.6f",c2dir(:)');printf("]\n");
    % Sanity check
    [Ndir,Ddir]=svcasc2tf(a11dir,a12dir,a21dir,a22dir,b1dir,b2dir,c1dir,c2dir,dd);
    if max(abs(Ndir-n)./abs(n)) > 10*eps
      error("max(abs(Ndir-n)./abs(n)) > 10*eps");
    endif 
    if max(abs(Ddir-d)./abs(d)) > 10*eps
      error("max(abs(Ddir-d)./abs(d)) > 10*eps");
    endif
    % Noise gain by section
    for k=1:length(a11dir)
      Adir=[a11dir(k), a12dir(k); a21dir(k), a22dir(k)];
      bdir=[b1dir(k); b2dir(k)];
      cdir=[c1dir(k), c2dir(k)];
      [Kdir,Wdir]=KW(Adir,bdir,cdir,dd(k));
      ngcascdir(k) = sum(diag(Kdir).*diag(Wdir));
    endfor
    printf("ngcascdir=[");printf(" %10.6f",ngcascdir);printf("]\n");

    % Bomar Type III
    [a11bom,a12bom,a21bom,a22bom,b1bom,b2bom,c1bom,c2bom]= ...
      pq2svcasc(p1,p2,q1,q2,"bomar3");
    printf("a11bom=[");printf(" %10.6f",a11bom(:)');printf("]\n");
    printf("a12bom=[");printf(" %10.6f",a12bom(:)');printf("]\n");
    printf("a21bom=[");printf(" %10.6f",a21bom(:)');printf("]\n");
    printf("a22bom=[");printf(" %10.6f",a22bom(:)');printf("]\n");
    printf("b1bom=[");printf(" %10.6f",b1bom(:)');printf("]\n");
    printf("b2bom=[");printf(" %10.6f",b2bom(:)');printf("]\n");
    printf("c1bom=[");printf(" %10.6f",c1bom(:)');printf("]\n");
    printf("c2bom=[");printf(" %10.6f",c2bom(:)');printf("]\n");
    % Sanity check
    [Nbom,Dbom]=svcasc2tf(a11bom,a12bom,a21bom,a22bom,b1bom,b2bom,c1bom,c2bom,dd);
    if max(abs(Nbom-n)./abs(n)) > 15*eps
      error("max(abs(Nbom-n)./abs(n)) > 15*eps");
    endif 
    if max(abs(Dbom-d)./abs(d)) > 10*eps
      error("max(abs(Dbom-d)./abs(d)) > 10*eps");
    endif
    % Noise gain by section
    for k=1:length(a11bom)
      Abom=[a11bom(k), a12bom(k); a21bom(k), a22bom(k)];
      bbom=[b1bom(k); b2bom(k)];
      cbom=[c1bom(k), c2bom(k)];
      [Kbom,Wbom]=KW(Abom,bbom,cbom,dd(k));
      ngcascbom(k) = sum(diag(Kbom).*diag(Wbom));
    endfor
    printf("ngcascbom=[");printf(" %10.6f",ngcascbom);printf("]\n");

    % Minimum noise sections
    [a11min,a12min,a21min,a22min,b1min,b2min,c1min,c2min]= ...
      pq2svcasc(p1,p2,q1,q2,"mininimum"); 
    printf("a11min=[");printf(" %10.6f",a11min(:)');printf("]\n");
    printf("a12min=[");printf(" %10.6f",a12min(:)');printf("]\n");
    printf("a21min=[");printf(" %10.6f",a21min(:)');printf("]\n");
    printf("a22min=[");printf(" %10.6f",a22min(:)');printf("]\n");
    printf("b1min=[");printf(" %10.6f",b1min(:)');printf("]\n");
    printf("b2min=[");printf(" %10.6f",b2min(:)');printf("]\n");
    printf("c1min=[");printf(" %10.6f",c1min(:)');printf("]\n");
    printf("c2min=[");printf(" %10.6f",c2min(:)');printf("]\n");
    % Sanity check
    [Nmin,Dmin]=svcasc2tf(a11min,a12min,a21min,a22min,b1min,b2min,c1min,c2min,dd);
    if max(abs(Nmin-n)./abs(n)) > 150*eps
      error("max(abs(Nmin-n)./abs(n)) > 150*eps");
    endif 
    if max(abs(Dmin-d)./abs(d)) > 10*eps
      error("max(abs(Dmin-d)./abs(d)) > 10*eps");
    endif
    % Noise gain by section
    for k=1:length(a11min)
      Amin=[a11min(k), a12min(k); a21min(k), a22min(k)];
      bmin=[b1min(k); b2min(k)];
      cmin=[c1min(k), c2min(k)];
      [Kmin,Wmin]=KW(Amin,bmin,cmin,dd(k));
      ngcascmin(k) = sum(diag(Kmin).*diag(Wmin));
    endfor
    printf("ngcascmin=[");printf(" %10.6f",ngcascmin);printf("]\n");
    % Expect section ngcasc for Bomar Type III to be greater than for min.
    if any((ngcascbom-ngcascmin)<0);
      error("Expect ngcascbom>=ngcascmin!");
    endif
    % Compare minimum-noise noise gain by section with optimised value.
    % Recall that the minimum-noise sections have delta=1.
    for k=1:length(a11min)
      Amin=[a11min(k), a12min(k); a21min(k), a22min(k)];
      bmin=[b1min(k); b2min(k)];
      cmin=[c1min(k), c2min(k)];
      [Kmin,Wmin]=KW(Amin,bmin,cmin,dd(k));
      if max(abs(diag(Kmin)-[1;1])) > 310*eps
        error("max(abs(diag(Kmin)-[1;1])) > 310*eps");
      endif
      [T,Kopt,Wopt]=optKW2(Kmin,Wmin,delta);
      ngcascopt(k) = sum(diag(Kopt).*diag(Wopt));
    endfor
    if max(abs(ngcascopt-ngcascmin)) > 40*eps
      error("max(abs(ngcascopt-ngcascmin)) > 40*eps");
    endif
  endfor
endfor

diary off
movefile pq2svcasc_test.diary.tmp pq2svcasc_test.diary;
