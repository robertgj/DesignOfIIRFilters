% schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_update.m
% Copyright (C) 2024 Robert G. Jenssen

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
P_p=P_p+value(dP_p);
Q_p=Q_p+value(dQ_p);
XYZ_p=XYZ_p+value(dXYZ_p);

% Update stop band SDP variables
Esq_s=Esq_s+value(dEsq_s);
P_s=P_s+value(dP_s);
Q_s=Q_s+value(dQ_s);
XYZ_s=XYZ_s+value(dXYZ_s);

printf("m=%d : Esq_p=%g, dEsq_p=%g, Esq_s=%g, dEsq_s=%g\n", ...
       m,Esq_p,value(dEsq_p),Esq_s,value(dEsq_s));

printf("value(Objective)=%g\n",value(Objective));

printf("norm(value(dz))=%g\n",norm(value(dz)));
printf("norm(value(dk))=%g\n",norm(value(dk)));

print_polynomial(value(dk),"dk","%g");
print_polynomial(k,"k","%g");

Asq=schurOneMPAlatticeAsq(wplot,k,k1,k1,kDD,kDD1,kDD1);
printf("10*log10(min(Asq))(pass)=%g,10*log10(max(Asq))(stop)=%g\n", ...
        10*log10(min(Asq(1:nap))),10*log10(max(Asq(nas:end))));

[Esq,gradEsq,diagHessEsq]= ...
  schurOneMPAlatticeEsq(k,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq(1:N),"gradEsq","%g");
print_polynomial(diagHessEsq(1:N),"diagHessEsq","%g");

printf("\n");

list_norm_dk=[list_norm_dk;norm(value(dk))];
list_Esq=[list_Esq;Esq];

