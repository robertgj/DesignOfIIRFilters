% exhaustive_schurOneMlattice_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

% To divide this script into 8 parts:
%{ 
   #!/bin/sh
   sname=exhaustive_schurOneMlattice_bandpass_test
   for i in `seq 0 7`;do \
     cp $sname.m $sname"_"$i.m; \
     sed -i -e "s/$sname/$sname"_"$i/" $sname"_"$i.m; \
     sed -i -e "s/m_start=0/m_start=$i/" $sname"_"$i.m; \
     sed -i -e "s/m_step=1/m_step=8/" $sname"_"$i.m; \
     octave-cli -q $sname"_"$i.m &
   done
%}

test_common;

unlink("exhaustive_schurOneMlattice_bandpass_test.diary");
unlink("exhaustive_schurOneMlattice_bandpass_test.diary.tmp");
diary exhaustive_schurOneMlattice_bandpass_test.diary.tmp

schurOneMlattice_bandpass_10_nbits_common;

% Find the coefficient indexes included in the search
kc_ul_index=find(ones(size(kc0))-((kc0==0)+(kc0_sdu==1)+(kc0_sdl==-1)));

% Exhaustive search
m_start=0;
m_step=1;
min_m=-1;
min_cost=inf;
tic
for m=m_start:m_step:((2^(length(kc_ul_index)))-1)
  % Find coefficients
  nm=dec2bin(m,length(kc_ul_index));
  nm=flipud(str2num(nm(:)));
  kc=zeros(size(kc0));
  kc(kc_ul_index)=kc0_sdl(kc_ul_index)+(nm.*kc0_sdul(kc_ul_index));
  % Find cost
  cost=schurOneMlatticeEsq(kc(1:Nk),epsilon0,p0,kc((Nk+1):end), ...
                           wa,Asqd,Wa,wt,Td,Wt);
  % Compare cost
  if cost < min_cost
    min_cost=cost;
    min_m=m;
    printf("min_m=%d,min_cost=%g\n",min_m,min_cost);
  endif
  if rem(m,1000)==m_start
    printf("m=%d\n",m);
  endif
endfor
toc
printf("min_m=%d,min_cost=%g\n",min_m,min_cost);

% Done
diary off
movefile exhaustive_schurOneMlattice_bandpass_test.diary.tmp ...
         exhaustive_schurOneMlattice_bandpass_test.diary;
