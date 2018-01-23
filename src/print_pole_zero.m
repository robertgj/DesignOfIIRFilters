function print_pole_zero(x,U,V,M,Q,R,name_str,file_name_str,format_str)
% print_pole_zero(x,U,V,M,Q,R[,name_str,file_name_str,format_str])
% x is the vector:
%       [k; 
%        zR(1:U); 
%        pR(1:V); 
%        abs(z(1:Mon2)); angle(z(1:Mon2)); 
%        abs(p(1:Qon2)); angle(p(1:Qon2))];
%     where k is the gain coefficient, zR and pR represent real zeros
%     and poles and z and p represent conjugate zero and pole pairs.
  
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  % Sanity checks
  if (nargin < 7) || (nargin > 9)
    print_usage("print_pole_zero(x,U,V,M,Q,R,name[,file_name,format])");
  endif
  if ~isvector(x)
    error("%s is not a vector!",name_str);
  endif
  if length(x) ~= (1+U+V+M+Q)
    error("%s is not a pole-zero vector! Expected length(x)==%d!", ...
          name_str, (1+U+V+M+Q));
  endif
  if rem(M,2) ~= 0
    error("Expect M (number of complex zeros) to be even!");
  endif 
  if rem(Q,2) ~= 0
    error("Expected Q (number of complex poles) even!");
  endif

  % Initialise
  Mon2=M/2;
  Qon2=Q/2;

  % Initialise format and file
  if nargin == 9
    fstr=format_str;
  else
    fstr="%14.10f";
  endif
  if nargin >= 8
    fid=fopen(file_name_str,"wt");
  else
    fid=stdout;
  endif
  fprintf(fid,"U%s=%d,V%s=%d,M%s=%d,Q%s=%d,R%s=%d\n", ...
          name_str,U,name_str,V,name_str,M,name_str,Q,name_str,R);
  first_str = sprintf("%s = [ ",name_str);
  space_str = ones(1,length(first_str))*" ";
  if rows(x) == 1
    tick_str = "";
  else
    tick_str = "'";
  endif
  fprintf(fid,"%s",first_str);

  % Gain
  fprintf(fid, fstr, x(1));
  if (U ~= 0) || (V ~= 0) || (M ~= 0) || (Q ~= 0)
    fprintf(fid, ", ...\n%s",space_str);
  endif

  % Real zeros
  if U>0
    for k=1:U
      fprintf(fid,fstr,x(k+1));
      if (k~=U) || (V ~= 0) || (M ~= 0) || (Q ~= 0)
        fprintf(fid,",");
      endif
      fprintf(fid," ");
      if (rem(k,4) == 0) && (k ~= U)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    if (V ~= 0) || (M ~= 0) || (Q ~= 0)
      fprintf(fid, "...\n%s",space_str);
    endif
  endif

  % Real poles
  if V>0
    for k=1:V
      fprintf(fid,fstr,x(k+1+U));
      if (k~=V) || (M ~= 0) || (Q ~= 0)
        fprintf(fid,",");
      endif
      fprintf(fid," ");
      if (rem(k,4) == 0) && (k ~= V)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    if (M ~= 0) || (Q ~= 0)
      fprintf(fid, "...\n%s",space_str);
    endif
  endif

  % Complex zeros
  if M>0
    for k=1:Mon2
      fprintf(fid,fstr,x(k+1+U+V));
      fprintf(fid,", ");
      if (rem(k,4) == 0) && (k ~= Mon2)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    fprintf(fid, "...\n%s",space_str);
    for k=1:Mon2
      fprintf(fid,fstr,x(k+1+U+V+Mon2));
      if (k~=Mon2) || (Q ~= 0)
        fprintf(fid,",");
      endif
      fprintf(fid," ");
      if (rem(k,4) == 0) && (k ~= Mon2)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    if Qon2 ~= 0
      fprintf(fid, "...\n%s",space_str);
    endif
  endif
  
  % Complex poles
  if Q>0 
    for k=1:Qon2
      fprintf(fid,fstr,x(k+1+U+V+M));
      fprintf(fid,", ");
      if (rem(k,4) == 0) && (k ~= Qon2)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    fprintf(fid, "...\n%s",space_str);
    for k=1:Qon2
      fprintf(fid,fstr,x(k+1+U+V+M+Qon2));
      if k~=Qon2
        fprintf(fid,",");
      endif
      fprintf(fid," ");
      if (rem(k,4)== 0) && (k ~= Qon2)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
  endif
  fprintf(fid,"]%s;\n", tick_str);
  
  % Done
  if nargin >= 8
    fclose(fid);
  endif
  
endfunction
