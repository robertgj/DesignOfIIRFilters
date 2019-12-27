function rs = frefine(a,rs)
% f = frefine(a,rs);
% refine local minima and maxima of H using Newton's method
% H  : H = a(1)+a(2)*cos(w)+...+a(n+1)*cos(n*w)
% rs : initial values for the extrema of H
% see also : frefine.m, frefine_e.m
% author: IVAN SELESNICK
  a = a(:);
  w = rs(:);
  m = length(a)-1;
  for k = 1:12
    H = cos(w*[0:m]) * a;
    H1 = -sin(w*[0:m]) * ([0:m]'.*a);
    H2 = -cos(w*[0:m]) * (([0:m].^2)'.*a);
    w = w - H1./H2;
  endfor
  rs(:) = w;
endfunction

