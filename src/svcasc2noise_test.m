% svcasc2noise_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("svcasc2noise_test.diary");
delete("svcasc2noise_test.diary.tmp");
diary svcasc2noise_test.diary.tmp


N=19;
fc=0.1;
[dd,p1,p2,q1,q2]=butter2pq(N,fc);
[a11,a12,a21,a22,b1,b2,c1,c2] = pq2svcasc(p1,p2,q1,q2,"min"); 
[ngcasc,Hl2,xbits]=svcasc2noise(a11,a12,a21,a22,b1,b2,c1,c2,dd);
printf("ngcasc=[ ");printf("%5.3f ",ngcasc);printf("]\n");
printf("Hl2=[ ");printf("%5.3f ",Hl2);printf("]\n");
printf("xbits=[ ");printf("%5.3f ",xbits);printf("]\n");

diary off
movefile svcasc2noise_test.diary.tmp svcasc2noise_test.diary;
