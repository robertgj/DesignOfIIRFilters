% state_variable_unequal_state_length_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% Test state variable and Schur one-multiplier lattice filter implementations
% with added bits in the state variables, x. In this case delta=1, since the
% extra state variable bits is effectively a separate delta for each.
% Setting the Schur one-multiplier state variable scaling to
% p->2.^(round(log2(p))) gives a better approximation to the estimated noise
% gain but p->2.^fix(log2(p*nscale))/nscale  gives a lower measured output
% noise variance.

test_common;

strf="state_variable_unequal_state_length_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

delta=2;
nbits=10;
NB=nbits;
nscale=2^(nbits-1);
nsamples=2^16;
tol=1e-12;

for NN=1:6,
  
  %
  % Create a filter
  %
  fap=0.2;dBap=1;dBas=40;
  [n,d]=ellip(NN,dBap,dBas,2*fap);
  % fap=0.2;
  % [n,d]=butter(NN,2*fap);

  % Scale the direct form filter implementation
  [Ad,Bd,Cd,Dd]=tf2Abcd(n,d);
  [Kd,Wd]=KW(Ad,Bd,Cd,Dd);
  Td=diag([delta*sqrt(diag(Kd))]);
  invTd=inv(Td);
  Ads=invTd*Ad*Td;
  Bds=invTd*Bd;
  Cds=Cd*Td;
  Dds=Dd;
  Kds=invTd*Kd*(invTd');
  Wds=(Td')*Wd*Td;
  ngds=sum(diag(Kds).*diag(Wds));
  
  % Allocate bits for the direct form implementation
  NBids=NB+ ...
        (log2(diag(Kds).*diag(Wds))/2)- ...
        (sum(log2(diag(Kds).*diag(Wds)))/(2*NN));
  % Sanity check
  if max(abs(sum(NBids)-(NN*NB))) > tol
    error("max(abs(sum(NBids)-(NN*NB))) > tol");
  endif
  ngNBids=NN*(10^(sum(log10(diag(Kds).*diag(Wds)))/NN))*(4^(nbits-NB));
  
  % Scaling of the Schur one-multiplier lattice with powers-of-2
  [k,epsilon,p,c] = tf2schurOneMlattice(n,d);
  [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
  pow2p=2.^(round(log2(p)));
  [Ap,Bp,Cp,Dp]=schurOneMlattice2Abcd(k,epsilon,pow2p*delta,c);
  [Kp,Wp]=KW(Ap,Bp,Cp,Dp);
  ngp=sum(diag(Kp).*diag(Wp));
  if 1
    % Octave fix() rounds to zero    
    pow2palt=(2.^fix(log2(p*nscale)))/nscale;
    pow2palt2=zeros(size(p));
    plt1=find(p<1);
    pge1=find(p>1);
    pow2palt2(plt1)=2.^(sign(log2(p(plt1))).*ceil(abs(log2(p(plt1)))));
    pow2palt2(pge1)=(2.^(sign(log2(p(pge1))).*floor(abs(log2(p(pge1))))));
    if pow2palt ~= pow2palt2
      error("pow2palt ~= pow2palt2");
    endif
  else
    pow2palt=2.^fix(log2(p));
  endif
  [Apalt,Bpalt,Cpalt,Dpalt]=schurOneMlattice2Abcd(k,epsilon,pow2palt*delta,c);
  [Kpalt,Wpalt]=KW(Apalt,Bpalt,Cpalt,Dpalt);
  ngpalt=sum(diag(Kpalt).*diag(Wpalt));
    
  % NBi-scale the Schur one-multiplier lattice filter p=1 implementation 
  [A1,B1,C1,D1]=schurOneMlattice2Abcd(k,epsilon,ones(size(p)),c);
  [K1,W1]=KW(A1,B1,C1,D1);
  if max(abs(sqrt(diag(K1))-p(:))) > tol
    error("max(abs(sqrt(diag(K1))-p(:))) > tol");
  endif
  T=diag(delta*sqrt(diag(K1)));
  invT=inv(T);
  As=invT*A1*T;
  Bs=invT*B1;
  Cs=C1*T;
  Ds=D1;
  Ks=invT*K1*(invT');
  Ws=(T')*W1*T;
  ngs=sum(diag(Ks).*diag(Ws));
  % Allocate bits
  NBis=NB+(log2(diag(Ks).*diag(Ws))/2)-(sum(log2(diag(Ks).*diag(Ws)))/(2*NN));
  % Sanity check
  if max(abs(sum(NBis)-(NN*NB))) > tol
    error("max(abs(sum(NBis)-(NN*NB))) > tol");
  endif
  ngNBis=NN*(10^(sum(log10(diag(Ks).*diag(Ws)))/NN))*(4^(nbits-NB));
  
  %
  % Simulate the roundoff noise of the series combination and overall filter
  %

  % Make a quantised noise signal with standard deviation 0.25
  n60=p2n60(d);
  u=reprand(n60+nsamples,1)-0.5;
  u=0.25*u/std(u); 
  u=round(u*nscale);

  % Scaled direct form
  [yds,xxds]=svf(Ads,Bds,Cds,Dds,u,"none");
  [ydsf,xxdsf]=svf(Ads,Bds,Cds,Dds,u,"round");
  
  % Scaled direct form with extra bits
  [ydsi,xxdsi]=svf(Ads,Bds,Cds,Dds,u,"none");
  [ydsif,xxdsif]=svf(Ads,Bds,Cds,Dds,u,"bit",round(NBids)-nbits);

  % Schur one-multiplier scaled with KW
  [ys,xxs]=svf(As,Bs,Cs,Ds,u,"none");
  [ysf,xxsf]=svf(As,Bs,Cs,Ds,u,"round");

  % Schur one-multiplier scaled with KW and extra bits
  [ysi,xxsi]=svf(As,Bs,Cs,Ds,u,"none");
  [ysif,xxsif]=svf(As,Bs,Cs,Ds,u,"bit",round(NBis)-nbits);

  % Schur one-multiplier scaled with (2.^round(log2(p)))
  [yp,xxp]=svf(Ap,Bp,Cp,Dp,u,"none");
  [ypf,xxpf]=svf(Ap,Bp,Cp,Dp,u,"round");
  
  % Schur one-multiplier scaled with pow2palt*delta
  [ypalt,xxpalt]=svf(Apalt,Bpalt,Cpalt,Dpalt,u,"none");
  [ypaltf,xxpaltf]=svf(Apalt,Bpalt,Cpalt,Dpalt,u,"round");
  
  % Renove initial transients
  Rn60=(n60+1):length(u);
  u=u(Rn60);
  
  yds=yds(Rn60);
  xxds=xxds(Rn60,:);
  ydsf=ydsf(Rn60);
  xxdsf=xxdsf(Rn60,:);
  
  ydsi=ydsi(Rn60);
  xxdsi=xxdsi(Rn60,:);
  ydsif=ydsif(Rn60);
  xxdsif=xxdsif(Rn60,:);
  
  ys=ys(Rn60);
  xxs=xxs(Rn60,:);
  ysf=ysf(Rn60);
  xxsf=xxsf(Rn60,:);
  
  ysi=ysi(Rn60);
  xxsi=xxsi(Rn60,:);
  ysif=ysif(Rn60);
  xxsif=xxsif(Rn60,:);
  
  yp=yp(Rn60);
  xxp=xxp(Rn60,:);
  ypf=ypf(Rn60);
  xxpf=xxpf(Rn60,:);
  
  ypalt=ypalt(Rn60);
  xxpalt=xxpalt(Rn60,:);
  ypaltf=ypaltf(Rn60);
  xxpaltf=xxpaltf(Rn60,:);

  max_ydsf=max(abs(ydsf));
  max_ydsif=max(abs(ydsif));
  max_ysf=max(abs(ysf));
  max_ysif=max(abs(ysif));
  max_ypf=max(abs(ypf));
  max_ypaltf=max(abs(ypaltf));
  
  max_xxdsf=max(max(abs(xxdsf)));
  max_xxdsif=max(max(abs(xxdsif)));
  max_xxsf=max(max(abs(xxsf)));
  max_xxsif=max(max(abs(xxsif)));
  max_xxpf=max(max(abs(xxpf)));
  max_xxpaltf=max(max(abs(xxpaltf)));

  max_std_xxdsf=max(std(xxdsf));
  max_std_xxdsif=max(std(xxdsif));
  max_std_xxsf=max(std(xxsf));
  max_std_xxsif=max(std(xxsif));
  max_std_xxpf=max(std(xxpf));
  max_std_xxpaltf=max(std(xxpaltf));
 
  % Compare estimated and measured output round-off noise variance
  printf("\nNN=%d\n",NN);
  
  print_polynomial(round(NBids),"roundNBids","%2d");
  print_polynomial(round(NBids),"roundNBids", ...
                   sprintf("%s_NN_%d_roundNBids.m",strf,NN),"%2d");
  
  est_varydsd=(1+(ngds*delta*delta))/12;
  varydsd=var(yds-ydsf);
  printf(["ngds=%6.4f, est_varydsd=%6.4f, varydsd=%6.4f, ", ...
          "max_ydsf=%d, max_xxdsf=%d\n"], ...
         ngds, est_varydsd, varydsd, max_ydsf, max_xxdsf);

  est_varydsid=(1+(ngNBids*delta*delta))/12;
  varydsid=var(ydsi-ydsif);
  printf(["ngNBids=%6.4f, est_varydsid=%6.4f, varydsid=%6.4f, ", ...
          "max_ydsif=%d, max_xxdsif=%d\n"], ...
         ngNBids, est_varydsid, varydsid, max_ydsif, max_xxdsif);
 
  est_varysd=(1+(ngs*delta*delta))/12;
  varysd=var(ys-ysf);
  printf(["ngs=%6.4f, est_varysd=%6.4f, varysd=%6.4f, ", ...
          "max_ysf=%d, max_xxsf=%d\n"], ...
         ngs, est_varysd, varysd, max_ysf, max_xxsf);
  
  print_polynomial(round(NBis),"roundNBis","%2d"); 
  print_polynomial(round(NBis),"roundNBis", ...
                   sprintf("%s_NN_%d_roundNBis.m",strf,NN),"%2d");
  
  est_varysid=(1+(ngNBis*delta*delta))/12;
  varysid=var(ysi-ysif);
  printf(["ngNBis=%6.4f, est_varysid=%6.4f, varysid=%6.4f, ", ...
          "max_ysif=%d, max_xxsif=%d\n"], ...
         ngNBis, est_varysid, varysid, max_ysif, max_xxsif);
           
  print_polynomial(pow2p,"pow2p","%6.4f"); 
  print_polynomial(pow2p,"pow2p", ...
                   sprintf("%s_NN_%d_pow2p.m",strf,NN),"%2d");
  
  est_varypd=(1+(ngp*delta*delta))/12;
  varypd=var(yp-ypf);
  printf(["ngp=%6.4f, est_varypd=%6.4f, varypd=%6.4f, ", ...
          "max_ypf=%d, max_xxpf=%d\n"], ...
         ngp, est_varypd, varypd, max_ypf, max_xxpf);

  print_polynomial(pow2palt,"pow2palt","%6.4f"); 
  print_polynomial(pow2palt,"pow2palt", ...
                   sprintf("%s_NN_%d_pow2palt.m",strf,NN),"%2d");
  
  est_varypaltd=(1+(ngpalt*delta*delta))/12;
  varypaltd=var(ypalt-ypaltf);
  printf(["ngpalt=%6.4f, est_varypaltd=%6.4f, varypaltd=%6.4f, ", ...
          "max_ypaltf=%d, max_xxpaltf=%d\n"], ...
         ngpalt, est_varypaltd, varypaltd, max_ypaltf, max_xxpaltf);

  % Create a table of results
  sigma_y_sq_str="$\\sigma_{y}^{2}$";
  sigma_y_hat_sq_str="$\\sigma_{\\hat{y}}^{2}$"; 
  max_y_str="$\\max{}y_{f}$"; 
  max_sigma_x_str="$\\max\\sigma_{x}$"; 
  max_abs_x_str="$\\max\\mathabs{x_{f}}$";
  switch (NN)
    case {1}
      order_str=sprintf("%dst",NN);
    case {2}
      order_str=sprintf("%dnd",NN);
    case {3}
      order_str=sprintf("%drd",NN);
    otherwise
      order_str=sprintf("%dth",NN);
  endswitch
  outfile=fopen(sprintf("%s_NN_%d_results.tab",strf,NN),"w");
  fprintf...
    (outfile, ...
     ["\\begin{table} \n", ...
      "\\centering \n", ...
      "\\begin{threeparttable} \n", ...
      "\\begin{tabular}{lrrrrrr} \\toprule \n", ...
      "Low-pass Elliptic                &Filter &Est .  &Meas.  &Meas.  &Meas.  &Meas. \\\\ \n", ...
      "$n=$%d, $f_{ap}=$%4.2f           &noise  &%s     &%s     &%s     &%s     &%s    \\\\ \n", ...
      "$B=$%d, $\\delta=$%d             &gain   &       &       &       &       &      \\\\ \n", ...
      "\\midrule                                                                            \n", ...
      "Scaled direct-form SVD           & %5.3f & %5.3f & %5.3f & %d    & %5.2f & %d   \\\\ \n", ...
      "NBi-scaled direct-form SVD       & %5.3f & %5.3f & %5.3f & %d    & %5.2f & %d   \\\\ \n", ...
      "Scaled Schur lattice SVD         & %5.3f & %5.3f & %5.3f & %d    & %5.2f & %d   \\\\ \n", ...
      "NBi-scaled Schur lattice SVD     & %5.3f & %5.3f & %5.3f & %d    & %5.2f & %d   \\\\ \n", ...
      "$p_{2}$-scaled Schur lattice SVD & %5.3f & %5.3f & %5.3f & %d    & %5.2f & %d   \\\\ \n", ...
      "\\bottomrule \n", ...
      "\\end{tabular} \n ", ...
      "\\end{threeparttable} \n", ...
      "\\caption[Comparison of noise performance for a %s order ", ...
      " elliptic implementations]{Comparison of estimated and ", ...
      " measured noise performance of a %s order low-pass ", ...
      " elliptic filter with pass-band cutoff freqency $f_{ap}=$%4.2f, ", ...
      " implemented as a scaled direct form SVD with output and state ", ...
      " rounding-to-nearest to %d-bit signed-twos-complement integers.} \n", ...
      "\\label{tab:comparison-state-variable-NN-%d-NBi-noise}\n", ...
      "\\end{table}"], ...
     NN,fap,sigma_y_sq_str,sigma_y_sq_str,max_y_str,max_sigma_x_str,max_abs_x_str, ...
     nbits,delta, ...
     ngds,est_varydsd,varydsd,max_ydsf,max_std_xxdsf,max_xxdsf, ... 
     ngNBids,est_varydsid,varydsid,max_ydsif,max_std_xxdsif,max_xxdsif, ... 
     ngs,est_varysd,varysd,max_ysf,max_std_xxsf,max_xxsf, ... 
     ngNBis,est_varysid,varysid,max_ysif,max_std_xxsif,max_xxsif, ... 
     ngp,est_varypd,varypd,max_ypf,max_std_xxpf,max_xxpf, ... 
     order_str,order_str,fap,nbits,NN);
  fclose(outfile);
  
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
