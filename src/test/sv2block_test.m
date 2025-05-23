% sv2block_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("sv2block_test.diary");
delete("sv2block_test.diary.tmp");
diary sv2block_test.diary.tmp


% Design a filter with block processing of length 4
mblock=4;
bits=10;
scale=2^(bits-1);
delta=1;
N=8;
dbap=0.1;
dbas=40;
fc=0.05;
[n,d]=ellip(N,dbap,dbas,2*fc);
n=n(:)';
d=d(:)';
n60=p2n60(d);
[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
[Topt,Kopt,Wopt]=optKW(K,W,delta);
ngABCDopt=diag(Kopt)'*diag(Wopt)
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;

% Truncate the filter coefficients
Aoptf=round(Aopt*scale)/scale;
Boptf=round(Bopt*scale)/scale;
Coptf=round(Copt*scale)/scale;
Doptf=round(Dopt*scale)/scale;

% Estimate RMS roundoff noise in bits of the block 1 filter
[Koptf,Woptf]=KW(Aoptf,Boptf,Coptf,Doptf);
ngABCDoptf=diag(Koptf)'*diag(Woptf)
est_nvABCDoptf=sqrt((1+(delta*delta*ngABCDoptf))/12)

% Make a quantised noise signal with standard deviation 0.25*2^nbits
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Run the block 1 filter
[yopt,xxopt]=svf(Aoptf,Boptf,Coptf,Doptf,u,"none");
[yoptf,xxoptf]=svf(Aoptf,Boptf,Coptf,Doptf,u,"round");

% Remove the initial transient
Rn60=(n60+1):length(u);
yopt=yopt(Rn60);
xxopt=xxopt(Rn60,:);
yoptf=yoptf(Rn60);
xxoptf=xxoptf(Rn60,:);

% Check the RMS roundoff noise in bits for the block 1 filter
nvABCDoptf=std(yoptf-yopt)

% Find the state variable equations for
% processing in blocks of mblock samples
[Ab,Bb,Cb,Db] = sv2block(mblock,Aopt,Bopt,Copt,Dopt)

% Truncate the block filter coefficients
Abf=round(Ab*scale)/scale
Bbf=round(Bb*scale)/scale
Cbf=round(Cb*scale)/scale
Dbf=round(Db*scale)/scale

% Estimate RMS roundoff noise in bits of the block filter
% (See Roberts and Mullis, Section 10.2, pp. 436-437).
ngABCDbf=ngABCDopt/mblock
est_nvABCDbf=sqrt((1+(delta*delta*ngABCDbf))/12)

% Run the block filter
ub=reshape(u(1:(mblock*floor(length(u)/mblock)))', ...
           mblock,floor(length(u)/mblock))';
yb=svf(Abf,Bbf,Cbf,Dbf,ub,"none");
yb=yb'(:);
ybf=svf(Abf,Bbf,Cbf,Dbf,ub,"round");
ybf=ybf'(:);

% Remove the initial transient
u=ub'(:);
Rn60=(n60+1):length(u);
u=u(Rn60);
yb=yb(Rn60);
ybf=ybf(Rn60);

% Check the RMS roundoff noise in bits for the block filter
nvABCDbf=std(ybf-yb)

% Plot the transfer function of the block filter
nfpts=1024;
nppts=(0:511);
Hbf=crossWelch(u,ybf,nfpts);
plot(nppts/nfpts,20*log10(abs(Hbf)));
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 5]);
grid("on");
print("sv2block_ellip8_block4_response","-dpdflatex");
close

diary off
movefile sv2block_test.diary.tmp sv2block_test.diary;
