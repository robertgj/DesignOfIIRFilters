% Abcd2cc_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("Abcd2cc_test.diary");
unlink("Abcd2cc_test.diary.tmp");
diary Abcd2cc_test.diary.tmp


% Design a filter
bits=8
scale=2^(bits-1)
delta=1
N=8
P=12
dbap=0.1
dbas=40
fc=0.05
[n,d]=ellip(N,dbap,dbas,2*fc)
n=n(:)';
d=d(:)';
[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
[Topt,Kopt,Wopt]=optKW(K,W,delta);
ngABCDopt=diag(Kopt)'*diag(Wopt)
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;

% Common strings
name=sprintf("ellip%dABCD%d",N,P);
strf=sprintf("Abcd2cc_test_%s",name);

% Generate a random input signal
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Truncate the filter coefficients of the block 1 optimum noise filter
Aoptf=round(Aopt*scale)/scale;
Boptf=round(Bopt*scale)/scale;
Coptf=round(Copt*scale)/scale;
Doptf=round(Dopt*scale)/scale;

% Estimate the roundoff noise of the block 1 truncated optimum noise filter
[Koptf,Woptf]=KW(Aoptf,Boptf,Coptf,Doptf);
ngABCDoptf=diag(Koptf)'*diag(Woptf)
est_nvABCDoptf=sqrt((1+(delta*delta*ngABCDoptf))/12)

% Run the block 1 truncated optimum noise filter
[yopt,xxopt]=svf(Aoptf,Boptf,Coptf,Doptf,u,"none");
[yoptf,xxoptf]=svf(Aoptf,Boptf,Coptf,Doptf,u,"round");

% Check the roundoff noise for the block 1 truncated optimum noise filter
nvABCDoptf=std(yoptf-yopt)

% Convert the state space filter to do processing in blocks of P samples
[Ab,Bb,Cb,Db] = sv2block(P,Aopt,Bopt,Copt,Dopt)

% Truncate the filter coefficients of the block P filter
Abf=round(Ab*scale)/scale;
Bbf=round(Bb*scale)/scale;
Cbf=round(Cb*scale)/scale;
Dbf=round(Db*scale)/scale;

% Estimate the roundoff noise gain of the  block P filter from the
% untruncated block 1 optimum noise filter noise gain
ngABCDbf=ngABCDopt/P
est_nvABCDbf=sqrt((1+(delta*delta*ngABCDbf))/12)

% Generate C++ code and compile an octfile:
Abcd2cc(Abf,Bbf,Cbf,Dbf,bits,name);
[output,status]=mkoctfile(sprintf("%s.cc",name), "-D USING_OCTAVE -Wall");
if status
  error("mkoctfile() failed for %s! : (%s)", name, output);
endif
%  If testing with address-sanitizer add these flags for mkoctfile:
%{
   "-O0 -g -fsanitize=address -fsanitize=undefined -fno-sanitize=vptr \
    -fno-omit-frame-pointer"
%}
%  and run octave with:
%    LD_PRELOAD=/usr/lib64/libasan.so.5 octave-cli

% Run the block processing filters
ub=u(1:(floor(nsamples/P)*P));
ub=reshape(ub(:)',P,floor(nsamples/P))';
[yb,xxb]=svf(Abf,Bbf,Cbf,Dbf,ub,"none");
yb=yb'(:);
[ybf,xxbf]=svf(Abf,Bbf,Cbf,Dbf,ub,"round");
ybf=ybf'(:);
yccbf=feval(name,u);

% Check the roundoff noise for the block processing filter
nvbf=std(ybf-yb)
nvccbf=std(yccbf(1:length(yb))-yb)

% Plot the transfer function of the filter
nfpts=8192;
nppts=(0:((nfpts/2)-1));
Hoptf=crossWelch(u,yoptf,nfpts);
Hccbf=crossWelch(u,yccbf,nfpts);
plot(nppts/nfpts,20*log10(abs(Hoptf)),"linestyle","--", ...
     nppts/nfpts,20*log10(abs(Hccbf)),"linestyle","-");
legend("Block length 1", sprintf("Block length %d",P));
legend("boxoff");
legend("left");
legend("location","northwest");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 10]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close
plot(nppts/nfpts,20*log10(abs(Hoptf)),"linestyle","--", ...
     nppts/nfpts,20*log10(abs(Hccbf)),"linestyle","-");
legend("Block length 1", sprintf("Block length %d",P));
legend("boxoff");
legend("left");
legend("location","northwest");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.06 -1 3]);
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Multipliers per output
printf("N=%d,P=%d\n", N,P);
printf("For block length 1, multipliers/output=%f\n",(2*N)+(N*N)+1);
printf("For block length %d, multipliers/output=%f\n",P,(2*N)+(N*N/P)+((P+1)/2));

% Done
diary off
movefile Abcd2cc_test.diary.tmp Abcd2cc_test.diary;
