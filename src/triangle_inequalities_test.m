% triangle_inequalities_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("triangle_inequalities_test.diary");
unlink("triangle_inequalities_test.diary.tmp");
diary triangle_inequalities_test.diary.tmp

for yi = -1:2:1,
  for yj = -1:2:1,
    Yij=yi*yj;
    if (yi+yj+Yij) < -1
      error("(yi(%d)+yj(%d)+Yij) < -1",yi,yj);
    endif
    if (yi-yj-Yij) < -1
      error("(yi(%d)-yj(%d)-Yij) < -1",yi,yj);
    endif
    if (-yi-yj+Yij) < -1
      error("(-yi(%d)-yj(%d)+Yij) < -1",yi,yj);
    endif
    if (-yi+yj-Yij) < -1
      error("(-yi(%d)+yj(%d)-Yij) < -1",yi,yj);
    endif
  endfor
endfor

for yi = -1:2:1,
  for yj = -1:2:1,
    for yk = -1:2:1,
      Yij=yi*yj;
      Yik=yi*yk;
      Yjk=yj*yk;
      if (Yij+Yik+Yjk) < -1
        error("(Yij(%d)+Yik(%d)+Yjk(%d)) < -1",Yij,Yik,Yjk);
      endif
      if (Yij-Yik-Yjk) < -1
        error("(Yij(%d)-Yik(%d)-Yjk(%d)) < -1",Yij,Yik,Yjk);
      endif
      if (-Yij-Yik+Yjk) < -1
        error("(-Yij(%d)-Yik(%d)+Yjk(%d)) < -1",Yij,Yik,Yjk);
      endif
      if (-Yij+Yik-Yjk) < -1
        error("(-Yij(%d)+Yik(%d)-Yjk(%d)) < -1",Yij,Yik,Yjk);
      endif
    endfor
  endfor
endfor

% Done
diary off
movefile triangle_inequalities_test.diary.tmp triangle_inequalities_test.diary;
