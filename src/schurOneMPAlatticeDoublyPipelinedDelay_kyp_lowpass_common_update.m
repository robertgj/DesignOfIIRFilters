% schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_update.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% Update coefficients
k=k+value(dk);

% Update state transition matrix
apA=apA0;
for mm=1:N,
  apA=apA+(k(mm)*apAm{mm});
endfor
A=[[apA,zeros(napA,nDD)];[zeros(nDD,napA),ADD]];

% Update pass band SDP variables
Esq_p=Esq_p+value(dEsq_p);
XYZ_p=XYZ_p+value(dXYZ_p);

% Update stop band SDP variables
Esq_s=Esq_s+value(dEsq_s);
XYZ_s=XYZ_s+value(dXYZ_s);

printf("m=%d : Esq_p=%g, dEsq_p=%g, Esq_s=%g, dEsq_s=%g\n", ...
       m,Esq_p,value(dEsq_p),Esq_s,value(dEsq_s));

printf("value(Objective)=%g\n",value(Objective));

printf("norm(value(dz))=%g\n",norm(value(dz)));
printf("norm(value(dk))=%g\n",norm(value(dk)));

print_polynomial(value(dk),"dk","%g");
print_polynomial(k,"k","%g");

Asq=schurOneMPAlatticeAsq(wplot,k,k1,k1,kDD,kDD1,kDD1);
printf("10*log10(min(Asq))(pass)=%g dB\n",10*log10(min(Asq(1:nap))));
printf("10*log10(max(Asq))(stop)=%g dB\n",10*log10(max(Asq(nas:end))));

[Esq,gradEsq,diagHessEsq,hessEsq]= ...
  schurOneMPAlatticeEsq(k,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq(1:N),"gradEsq","%g");
print_polynomial(diagHessEsq(1:N),"diagHessEsq","%g");

printf("\n");

list_Objective=[list_Objective;value(Objective)];
list_norm_dz=[list_norm_dz;norm(value(dz))];
list_norm_dk=[list_norm_dk;norm(value(dk))];
list_Esq=[list_Esq;Esq];
list_Esq_s=[list_Esq_s;Esq_s];
list_Esq_p=[list_Esq_p;Esq_p];
list_Asq_min=[list_Asq_min;min(Asq(1:nap))];
list_Asq_max=[list_Asq_max;max(Asq(nas:end))];
list_k{length(list_norm_dk)}=k;
