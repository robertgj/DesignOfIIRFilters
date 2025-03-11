% svcasc2noise_example_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("svcasc2noise_example_test.diary");
delete("svcasc2noise_example_test.diary.tmp");
diary svcasc2noise_example_test.diary.tmp

% The parallel package is not supported on Windows but it speeds up this test.
try
  pkg load parallel
catch
  warning("Loading the parallel package failed!");
end_try_catch

N=20;
fc=0.1;
delta=4;
for t=1:2
  if t==1
    pass="low";
    [dd,p1,p2,q1,q2]=butter2pq(N,fc);
    [~,d]=butter(N,fc);
    n60=p2n60(d);
  else
    pass="high";
    [dd,p1,p2,q1,q2]=butter2pq(N,fc,pass);
    [~,d]=butter(N,fc,pass);
    n60=p2n60(d);
  endif
  printf("\nButterworth %s-pass filter with N=%d, fc=%f, n60=%d\n", ...
         pass,N,fc,n60);

  % Direct form sections
  [a11dir,a12dir,a21dir,a22dir,b1dir,b2dir,c1dir,c2dir] = ...
    pq2svcasc(p1,p2,q1,q2,"direct");
  % Overall noise gain
  [ngcascdir,Hl2dir,xbitsdir]= ...
    svcasc2noise(a11dir,a12dir,a21dir,a22dir,b1dir,b2dir,c1dir,c2dir,dd);

  % Bomar Type III
  [a11bom,a12bom,a21bom,a22bom,b1bom,b2bom,c1bom,c2bom] = ...
    pq2svcasc(p1,p2,q1,q2,"bomar3");
  % Overall noise gain
  [ngcascbom,Hl2bom,xbitsbom]= ...
    svcasc2noise(a11bom,a12bom,a21bom,a22bom,b1bom,b2bom,c1bom,c2bom,dd);
 
  % Minimum noise sections
  [a11min,a12min,a21min,a22min,b1min,b2min,c1min,c2min] = ...
    pq2svcasc(p1,p2,q1,q2,"mininimum"); 
  % Overall noise gain
  [ngcascmin,Hl2min,xbitsmin]= ...
    svcasc2noise(a11min,a12min,a21min,a22min,b1min,b2min,c1min,c2min,dd);

  % Compare the Bomar Type III and minimum-noise section output noise gains
  % Bomar Type III section output noise gain
  for k=1:length(dd)
    Abom=[a11bom(k), a12bom(k); a21bom(k), a22bom(k)];
    bbom=[b1bom(k); b2bom(k)];
    cbom=[c1bom(k), c2bom(k)];
    [Kbom,Wbom]=KW(Abom,bbom,cbom,dd(k));
    ngcascbomsect(k) = sum(diag(Kbom).*diag(Wbom));
  endfor
  % Minimum-noise section output noise gain
  for k=1:length(dd)
    Amin=[a11min(k), a12min(k); a21min(k), a22min(k)];
    bmin=[b1min(k); b2min(k)];
    cmin=[c1min(k), c2min(k)];
    [Kmin,Wmin]=KW(Amin,bmin,cmin,dd(k));
    ngcascminsect(k) = sum(diag(Kmin).*diag(Wmin));
  endfor
  % Sanity check
  if any(ngcascbomsect<ngcascminsect)
    error("Expect all(ngcascbomsect>ngcascminsect)!");
  endif
  
  % Compare section noise gains for the minimum-noise filter sections
  % designed with Bomars equations to the noise gains of the sections
  % designed by optimising the direct-form sections.
  for k=1:length(dd)
    Adir=[a11dir(k), a12dir(k); a21dir(k), a22dir(k)];
    bdir=[b1dir(k); b2dir(k)];
    cdir=[c1dir(k), c2dir(k)];
    [Kdir,Wdir]=KW(Adir,bdir,cdir,dd(k));
    [Tdiropt,Kdiropt,Wdiropt]=optKW2(Kdir,Wdir,delta);
    ngcascdiroptsect(k) = sum(diag(Kdiropt).*diag(Wdiropt));
  endfor 
  if max(abs(ngcascdiroptsect-ngcascminsect)) > 227*eps
    error("max(abs(ngcascdiroptsect-ngcascminsect))(=%f*eps) > 227*eps",
          max(abs(ngcascdiroptsect-ngcascminsect))/eps);
  endif
  
  % Block optimise the filter and examine the section-by-section noise gain
  [a11bopt,a12bopt,a21bopt,a22bopt,b1bopt,b2bopt,c1bopt,c2bopt] = ...
    pq2blockKWopt(dd,p1,p2,q1,q2,delta);
  % Overall noise gain
  [ngcascbopt,Hl2bopt,xbitsbopt]= ...
    svcasc2noise(a11bopt,a12bopt,a21bopt,a22bopt,b1bopt,b2bopt,c1bopt,c2bopt,dd);

  % Globally optimise the filter noise gain
  [AOdir,bOdir,cOdir,dOdir]=svcasc2Abcd(a11dir,a12dir,a21dir,a22dir, ...
                                        b1dir,b2dir,c1dir,c2dir,dd);
  [KOdir,WOdir]=KW(AOdir,bOdir,cOdir,dOdir);
  [TGopt,KGopt,WGopt]=optKW(KOdir,WOdir,delta);
  AGopt=inv(TGopt)*AOdir*TGopt;
  bGopt=inv(TGopt)*bOdir;
  cGopt=cOdir*TGopt;
  dGopt=dOdir;
  ngABCDGopt=sum(diag(KGopt).*diag(WGopt));

  % Reverse section order and compare overall filter noise gains
  [ngcascdirR,Hl2dirR,xbitsdirR]= ...
    svcasc2noise(flipud(a11dir),flipud(a12dir), ...
                 flipud(a21dir),flipud(a22dir), ...
                 flipud(b1dir),flipud(b2dir), ...
                 flipud(c1dir),flipud(c2dir), ...
                 flipud(dd));

  [ngcascbomR,Hl2bomR,xbitsbomR]= ...
    svcasc2noise(flipud(a11bom),flipud(a12bom), ...
                 flipud(a21bom),flipud(a22bom), ...
                 flipud(b1bom),flipud(b2bom), ...
                 flipud(c1bom),flipud(c2bom), ...
                 flipud(dd));

  [ngcascminR,Hl2minR,xbitsminR]= ...
    svcasc2noise(flipud(a11min),flipud(a12min), ...
                 flipud(a21min),flipud(a22min), ...
                 flipud(b1min),flipud(b2min), ...
                 flipud(c1min),flipud(c2min), ...
                 flipud(dd));

  % Reverse block optimised filter with and without re-optimising
  [a11boptR,a12boptR,a21boptR,a22boptR,b1boptR,b2boptR,c1boptR,c2boptR] = ...
    pq2blockKWopt(flipud(dd),flipud(p1),flipud(p2),flipud(q1),flipud(q2),delta);
  [ngcascboptR,Hl2boptR,xbitsboptR]= ... 
    svcasc2noise(a11boptR,a12boptR,a21boptR,a22boptR, ...
                 b1boptR,b2boptR,c1boptR,c2boptR,flipud(dd));
  [ngcascboptRp,Hl2boptRp,xbitsboptRp]= ... 
    svcasc2noise(flipud(a11bopt),flipud(a12bopt), ...
                 flipud(a21bopt),flipud(a22bopt), ...
                 flipud(b1bopt),flipud(b2bopt), ...
                 flipud(c1bopt),flipud(c2bopt), ...
                 flipud(dd));

  % Globally optimised noise gain of reversed cascade
  [AOdirR,bOdirR,cOdirR,dOdirR] = ...
    svcasc2Abcd(flipud(a11dir),flipud(a12dir), ...
                flipud(a21dir),flipud(a22dir), ...
                flipud(b1dir),flipud(b2dir), ...
                flipud(c1dir),flipud(c2dir), ...
                flipud(dd));
  [KOdirR,WOdirR]=KW(AOdirR,bOdirR,cOdirR,dOdirR);
  [TGoptR,KGoptR,WGoptR]=optKW(KOdirR,WOdirR,delta);
  AGoptR=inv(TGoptR)*AOdirR*TGoptR;
  bGoptR=inv(TGoptR)*bOdirR;
  cGoptR=cOdirR*TGoptR;
  dGoptR=dOdirR;
  ngABCDGoptR=sum(diag(KGoptR).*diag(WGoptR));

  % Make LaTeX table for section noise gains
  fname=sprintf("svcasc2noise_butterworth_%d_%s_section_noise_gain.tab",N,pass);
  fid=fopen(fname,"wt");
  fprintf(fid,"\\begin{table}[hptb]\n");
  fprintf(fid,"\\centering\n");
  fprintf(fid,"\\begin{threeparttable}\n");
  fprintf(fid,"\\begin{tabular}{lrrrr}  \\toprule\n");
  fprintf(fid,"Section & Direct & Bomar III & Min. Noise & Block Opt.\\\\ \n");
  fprintf(fid,"\\midrule\n");
  for k=1:length(a11dir)
    fprintf(fid,"%d & %8.4f & %8.4f & %8.4f & %8.4f \\\\ \n", ...
            k,ngcascdir(k),ngcascbom(k),ngcascmin(k),ngcascbopt(k));
  endfor

  fprintf(fid,"\\bottomrule\n");
  fprintf(fid,"\\end{tabular}\n");
  fprintf(fid,"\\end{threeparttable}\n");
  fprintf(fid,["\\caption[Butterworth $%d$th order %spass section noise ", ...
               "gains]"], ...
          N, pass);
  fprintf(fid, ...
          ["{Section noise gains for the $%d$th order Butterworth %spass ", ...
           "filter}\n"], ...
          N, pass);
  fprintf(fid, ...
          "\\label{tab:Section-noise-gain-%d-order-Butterworth-%s-pass}\n", ...
         N, pass);
  fprintf(fid,"\\end{table}\n");
  fclose(fid);

  % Make LaTeX table for overall noise gains
  fname=sprintf("svcasc2noise_butterworth_%d_%s_overall_noise_gain.tab",N,pass);
  fid=fopen(fname,"wt");
  fprintf(fid,"\\begin{table}[hptb]\n");
  fprintf(fid,"\\centering\n");
  fprintf(fid,"\\begin{threeparttable}\n");
  fprintf(fid,"\\begin{tabular}{lrr} \\toprule\n");
  fprintf(fid,"Section  & Section pole & Section pole \\\\ \n");
  fprintf(fid,"design & angle increasing & angle decreasing \\\\ \\midrule\n");
  fprintf(fid,"Direct & %8.4f & %8.4f \\\\ \n", ...
          sum(ngcascdir), sum(ngcascdirR)); 
  fprintf(fid,"Bomar III & %8.4f & %8.4f \\\\ \n", ...
          sum(ngcascbom), sum(ngcascbomR)); 
  fprintf(fid,"Min. Noise & %8.4f & %8.4f \\\\ \n", ...
          sum(ngcascmin), sum(ngcascminR)); 
  fprintf(fid,"Block Opt. & %8.4f & %8.4f (%6.2f)\\\\ \n", ...
          sum(ngcascbopt), sum(ngcascboptR), sum(ngcascboptRp)); 
  fprintf(fid,"\\midrule\n");
  fprintf(fid,"Global Opt. & %8.4f & %8.4f \\\\ \n", ...
          ngABCDGopt, ngABCDGoptR); 
  fprintf(fid,"\\bottomrule\n");
  fprintf(fid,"\\end{tabular}\n");
  fprintf(fid,"\\end{threeparttable}\n");
  fprintf(fid, ...
          "\\caption[Butterworth $%d$th order %spass overall noise gains]", ...
          N, pass);
  fprintf(fid,["{Overall noise gains for the %dth order Butterworth ", ...
 "%spass filter}\n"], N, pass);
  fprintf(fid,["\\label{tab:Overall-noise-gain-%d-order-Butterworth-", ...
 "%s-pass}\n"], N, pass);
  fprintf(fid,"\\end{table}\n");
  fclose(fid);

  %
  % Simulations
  %

  % Rounding
  bits=10;
  scale=2^(bits-1);

  % Delta-scale the direct-form coefficients for equal state variance
  [Adir,bdir,cdir,ddir]=svcasc2Abcd(a11dir,a12dir,a21dir,a22dir, ...
                                    b1dir,b2dir,c1dir,c2dir,dd);
  [Kdir,Wdir]=KW(Adir,bdir,cdir,ddir);
  for k=1:length(dd)
    l=(2*k)-1;
    Kk=Kdir(l:l+1,l:l+1);
    [Kdir,Wdir]=KW(Adir,bdir,cdir,dd(k));
    Tdir=sqrt(diag([Kdir(l,l),Kdir(l+1,l+1)]))*delta;
    Adirk=[a11dir(k),a12dir(k);a21dir(k),a22dir(k)];
    bdirk=[b1dir(k);b2dir(k)];
    cdirk=[c1dir(k),c2dir(k)];
    AdirS=inv(Tdir)*Adirk*Tdir;
    bdirS=inv(Tdir)*bdirk;
    cdirS=cdirk*Tdir;
    a11dirS(k)=AdirS(1,1);a12dirS(k)=AdirS(1,2);
    a21dirS(k)=AdirS(2,1);a22dirS(k)=AdirS(2,2);
    b1dirS(k)=bdirS(1);b2dirS(k)=bdirS(2);
    c1dirS(k)=cdirS(1);c2dirS(k)=cdirS(2);
  endfor 

  % Round the delta-scaled direct-form coefficients
  a11dirf=round(a11dirS*scale)/scale;
  a12dirf=round(a12dirS*scale)/scale;
  a21dirf=round(a21dirS*scale)/scale;
  a22dirf=round(a22dirS*scale)/scale;
  b1dirf=round(b1dirS*scale)/scale;
  b2dirf=round(b2dirS*scale)/scale;
  c1dirf=round(c1dirS*scale)/scale;
  c2dirf=round(c2dirS*scale)/scale;
  dddirf=round(dd*scale)/scale;
  
  % Estimate noise performance with rounded direct-form coefficients
  [ngcascdirf,Hl2dirf,xbitsdirf]= ...
    svcasc2noise(a11dirf,a12dirf,a21dirf,a22dirf, ...
                 b1dirf,b2dirf,c1dirf,c2dirf,dddirf);

  % Round the block optimised coefficients
  a11boptf=round(a11bopt*scale)/scale;
  a12boptf=round(a12bopt*scale)/scale;
  a21boptf=round(a21bopt*scale)/scale;
  a22boptf=round(a22bopt*scale)/scale;
  b1boptf=round(b1bopt*scale)/scale;
  b2boptf=round(b2bopt*scale)/scale;
  c1boptf=round(c1bopt*scale)/scale;
  c2boptf=round(c2bopt*scale)/scale;
  ddboptf=round(dd*scale)/scale;

  % Estimate noise performance with rounded block-optimised coefficients
  [ngcascboptf,Hl2boptf,xbitsboptf]= ...
    svcasc2noise(a11boptf,a12boptf,a21boptf,a22boptf, ...
                 b1boptf,b2boptf,c1boptf,c2boptf,ddboptf);
  % Extra bits
  xbits=ceil(xbitsboptf);
  xbits(xbits<0)=0
  %xbits=round(xbitsboptf);
  
  % Input waveform
  nsamples=2^14;
  rand("seed",0xdeadbeef)
  u=rand(n60+nsamples,1)-0.5;
  u=round(u*(2^bits)/(std(u)*delta));

  % Run svcascf for direct-form and block optimised coefficients
  if exist("parcellfun")
    [y,xx1,xx2] = ...
    parcellfun(5,@svcascf, ...
               {a11dirf,a11dirf,a11boptf,a11boptf,a11boptf}, ...
               {a12dirf,a12dirf,a12boptf,a12boptf,a12boptf}, ...
               {a21dirf,a21dirf,a21boptf,a21boptf,a21boptf}, ...
               {a22dirf,a22dirf,a22boptf,a22boptf,a22boptf}, ...
               {b1dirf,b1dirf,b1boptf,b1boptf,b1boptf}, ...
               {b2dirf,b2dirf,b2boptf,b2boptf,b2boptf}, ...
               {c1dirf,c1dirf,c1boptf,c1boptf,c1boptf}, ...
               {c2dirf,c2dirf,c2boptf,c2boptf,c2boptf}, ...
               {dddirf,dddirf,ddboptf,ddboptf,ddboptf}, ...
               {u,u,u,u,u},
               {"none","round","none","round","round"}, ...
               {zeros(size(dddirf)),zeros(size(dddirf)), ...
                zeros(size(ddboptf)),zeros(size(ddboptf)),xbits}, ...
               "UniformOutput", false);
    ydir=y{1};    xx1dir=xx1{1};    xx2dir=xx2{1};
    ydirf=y{2};   xx1dirf=xx1{2};   xx2dirf=xx2{2};
    ybopt=y{3};   xx1bopt=xx1{3};   xx2bopt=xx2{3};
    yboptf=y{4};  xx1boptf=xx1{4};  xx2boptf=xx2{4};
    yboptfx=y{5}; xx1boptfx=xx1{5}; xx2boptfx=xx2{5};
  else                     
    [ydir,xx1dir,xx2dir] = ...
      svcascf(a11dirf,a12dirf,a21dirf,a22dirf, ...
              b1dirf,b2dirf,c1dirf,c2dirf,dddirf,u,"none");
    [ydirf,xx1dirf,xx2dirf] = ...
      svcascf(a11dirf,a12dirf,a21dirf,a22dirf, ...
              b1dirf,b2dirf,c1dirf,c2dirf,dddirf,u,"round");
    [ybopt,xx1bopt,xx2bopt] = ...
      svcascf(a11boptf,a12boptf,a21boptf,a22boptf, ...
              b1boptf,b2boptf,c1boptf,c2boptf,ddboptf,u,"none");
    [yboptf,xx1boptf,xx2boptf] = ...
      svcascf(a11boptf,a12boptf,a21boptf,a22boptf, ...
              b1boptf,b2boptf,c1boptf,c2boptf,ddboptf,u,"round");
    [yboptfx,xx1boptfx,xx2boptfx] = ...
      svcascf(a11boptf,a12boptf,a21boptf,a22boptf, ...
              b1boptf,b2boptf,c1boptf,c2boptf,ddboptf,u,"round",xbits);
  endif

  % Remove initial transient
  Rn60=(n60+1):length(u);
  ub=u(Rn60);
  ydir=ydir(Rn60,:);
  xx1dir=xx1dir(Rn60,:);
  xx2dir=xx2dir(Rn60,:);
  ydirf=ydirf(Rn60,:);
  xx1dirf=xx1dirf(Rn60,:);
  xx2dirf=xx2dirf(Rn60,:);
  ybopt=ybopt(Rn60,:);
  xx1bopt=xx1bopt(Rn60,:);
  xx2bopt=xx2bopt(Rn60,:);
  yboptf=yboptf(Rn60,:);
  xx1boptf=xx1boptf(Rn60,:);
  xx2boptf=xx2boptf(Rn60,:);
  yboptfx=yboptfx(Rn60,:);
  xx1boptfx=xx1boptfx(Rn60,:);
  xx2boptfx=xx2boptfx(Rn60,:);
  
  % Check state and output variances for the direct-form filter
  stdydirf=std(ydirf)
  stdxx1dirf=std(xx1dirf)
  stdxx2dirf=std(xx2dirf)
  varyddirf=var(ydir(:,end)-ydirf(:,end))
  est_varyddirf=sum((delta*delta*ngcascdirf)+Hl2dirf)/12

  % Check state and output variances for the block optimised filter
  stdyboptf=std(yboptf)
  stdxx1boptf=std(xx1boptf)
  stdxx2boptf=std(xx2boptf)
  varydboptf=var(ybopt(:,end)-yboptf(:,end))
  est_varydboptf=sum((delta*delta*ngcascboptf)+Hl2boptf)/12
  
  % Check state and output variance for the block optimised filter
  % with extra bits. Note use of 2.^(-2*xbits) not 2.^(-xbits)
  % because we are calculating the variance
  stdyboptfx=std(yboptfx)
  stdxx1boptfx=std(xx1boptfx)
  stdxx2boptfx=std(xx2boptfx)
  varydboptfx=var(ybopt(:,end)-yboptfx(:,end))
  est_varydboptfx=sum(((2.^(-2*xbits).*ngcascboptf)*delta*delta)+Hl2boptf)/12

  % Compare with globally optised noise performance
  AGoptf=round(AGopt*scale)/scale;
  bGoptf=round(bGopt*scale)/scale;
  cGoptf=round(cGopt*scale)/scale;
  dGoptf=round(dGopt*scale)/scale;
  [KGoptf,WGoptf]=KW(AGoptf,bGoptf,cGoptf,dGoptf);
  ngABCDGoptf=sum(diag(KGoptf).*diag(WGoptf));
  [yGopt,xxGopt] = svf(AGoptf,bGoptf,cGoptf,dGoptf,u,"none");
  [yGoptf,xxGoptf] = svf(AGoptf,bGoptf,cGoptf,dGoptf,u,"round");
  est_varydGoptf=((delta*delta*ngABCDGoptf)+1)/12
  varydGoptf=var(yGopt-yGoptf)
  stdyGoptf=std(yGopt)
  stdxxGoptf=std(xxGoptf)

  % Plot the simulated response
  nfpts=1024;
  nppts=(0:511);
  Hf=crossWelch(ub,yboptf(:,end),nfpts);
  subplot(111);
  plot(nppts/nfpts,20*log10(abs(Hf)));
  xlabel("Frequency")
  ylabel("Amplitude(dB)")
  axis([0 0.5 -80 1]);
  grid("on");
  print(sprintf("svcasc2noise_%spass_response",pass),"-dpdflatex");
  close

  % Make a LaTeX table for noise performance
  fname=sprintf("svcasc2noise_butterworth_%d_%s_noise_simulation.tab",N,pass);
  fid=fopen(fname,"wt");
  fprintf(fid,"\\begin{table}[hptb]\n");
  fprintf(fid,"\\centering\n");
  fprintf(fid,"\\begin{threeparttable}\n");
  fprintf(fid,"\\begin{tabular}{lrrr}  \\toprule\n");
  fprintf(fid,"& Estimated & Estimated & Simulated \\\\ \n");
  fprintf(fid,"& noise gain & noise variance & noise variance\\\\ \n");
  fprintf(fid,"\\midrule\n");
  fprintf(fid," Scaled Direct & %5.2f & %5.2f & %5.2f \\\\ \n", ...
          sum(ngcascdirf), est_varyddirf, varyddirf); 
  fprintf(fid," Block Opt.& %5.2f & %5.2f & %5.2f \\\\ \n", ...
          sum(ngcascboptf), est_varydboptf, varydboptf);
  fprintf(fid," Block Opt. (extra bits) & %5.2f & %5.2f & %5.2f \\\\ \n", ...
          sum((2.^(-2*xbits).*ngcascboptf)), est_varydboptfx, varydboptfx);
  fprintf(fid," Global Opt. & %5.2f & %5.2f & %5.2f \\\\ \n", ...
          sum(ngABCDGoptf), est_varydGoptf, varydGoptf);
  fprintf(fid,"\\bottomrule\n");
  fprintf(fid,"\\end{tabular}\n");
  fprintf(fid,"\\end{threeparttable}\n");
  fprintf(fid,"\\caption[Butterworth %dth order %spass noise simulation]", ...
          N, pass);
  fprintf(fid, ...
          ["{Estimated noise gain and estimated and simulated output ", ...
 "roundoff noise variances for the $%d$th order Butterworth ", ...
 "%spass filter with $%d$ bit rounded coefficients.}\n"], N, pass, bits);
  fprintf(fid, ...
          "\\label{tab:Simulated-noise-%d-order-Butterworth-%s-pass}\n", ...
          N, pass);
  fprintf(fid,"\\end{table}\n");
  fclose(fid);

endfor

diary off
movefile svcasc2noise_example_test.diary.tmp svcasc2noise_example_test.diary;
