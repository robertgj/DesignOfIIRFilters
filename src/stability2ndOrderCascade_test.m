% stability2ndOrderCascade_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("stability2ndOrderCascade_test.diary");
unlink("stability2ndOrderCascade_test.diary.tmp");
diary stability2ndOrderCascade_test.diary.tmp

format compact

[Ce,ee]=stability2ndOrderCascade(4)
if rows(Ce) ~= rows(ee)
  error("rows(Ce) ~= rows(ee)");
endif
if columns(Ce) ~= 4
  error("columns(Ce) ~= 4");
endif

[Ce,ee]=stability2ndOrderCascade(4,false)
if rows(Ce) ~= rows(ee)
  error("rows(Ce) ~= rows(ee)");
endif
if columns(Ce) ~= 4
  error("columns(Ce) ~= 4");
endif

[Cel,eel]=stability2ndOrderCascade(4,true)
if rows(Cel) ~= rows(eel)
  error("rows(Cel) ~= rows(eel)");
endif
if columns(Cel) ~= 4
  error("columns(Cel) ~= 4");
endif

[Co,eo]=stability2ndOrderCascade(5)
if rows(Co) ~= rows(eo)
  error("rows(Co) ~= rows(eo)");
endif
if columns(Co) ~= 5
  error("columns(Co) ~= 5");
endif

[Co,eo]=stability2ndOrderCascade(5,false)
if rows(Co) ~= rows(eo)
  error("rows(Co) ~= rows(eo)");
endif
if columns(Co) ~= 5
  error("columns(Co) ~= 5");
endif

[Col,eol]=stability2ndOrderCascade(5,true)
if rows(Col) ~= rows(eol)
  error("rows(Col) ~= rows(eol)");
endif
if columns(Col) ~= 5
  error("columns(Col) ~= 5");
endif

% Done
diary off
movefile stability2ndOrderCascade_test.diary.tmp ...
         stability2ndOrderCascade_test.diary;
