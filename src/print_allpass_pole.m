function print_allpass_pole(a,V,Q,R,name_str,file_name_str,format_str)
% print_allpass_pole(a,V,Q,R[,name_str,file_name_str,format_str])
% Print the single vector representation of an all-pass filter. a is the
% vector [pR(1:V); abs(p(1:Qon2)); angle(p(1:Qon2))] where pR represents
% real poles and p represents conjugate pole pairs.
  
% Copyright (C) 2018 Robert G. Jenssen
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
  if (nargin < 5) || (nargin > 7)
    print_usage("print_allpass_pole(a,V,Q,R,name[,file_name,format])");
  endif
  if ~isvector(a)
    error("%s is not a vector!",name_str);
  endif
  if length(a) ~= (V+Q)
    error("%s is not an all-pass vector! Expected length(a)==%d!", ...
          name_str,(V+Q));
  endif
  if rem(Q,2) ~= 0
    error("Expected Q (number of conjugate poles) even!");
  endif

  % Initialise
  Qon2=Q/2;

  % Fix conjugate pole angles
  for k=(V+1):(V+Qon2)
    if a(k) < 0
      a(k)=-a(k);
      if a(Qon2+k) < 0
        a(Qon2+k)=a(Qon2+k)+pi;
      else
        a(Qon2+k)=a(Qon2+k)-pi;
      endif
    endif
  endfor
  for k=(V+Qon2+1):(V+Q)
    if a(k) < -pi
      a(k)=(2*pi)+a(k);
    elseif a(k) > pi
      a(k)=(2*pi)-a(k);
    endif
    a(k)=abs(a(k));
  endfor
  
  % Sort by radius then angle
  % Real poles
  [~,kV]=sort(a(1:V));
  a(1:V)=a(kV);
  % Conjugate poles
  rp=a((V+1):(V+Qon2));
  thp=a((V+Qon2+1):(V+Q));
  [~,kQon2]=sort(rp.*exp(j*thp));
  a((V+1):(V+Qon2))=a(V+kQon2);
  a((V+Qon2+1):(V+Q))=a(V+Qon2+kQon2);

  % Initialise format and file
  if nargin == 7
    fstr=format_str;
  else
    fstr="%14.10f";
  endif
  fid=stdout;
  if (nargin >= 6) && (length(file_name_str) > 0)
    fid=fopen(file_name_str,"wt");
  endif
  fprintf(fid,"%% All-pass single-vector representation\n");
  fprintf(fid,"V%s=%d,Q%s=%d,R%s=%d\n",name_str,V,name_str,Q,name_str,R);
  first_str = sprintf("%s = [ ",name_str);
  space_str = ones(1,length(first_str))*" ";
  if rows(a) == 1
    tick_str = "";
  else
    tick_str = "'";
  endif
  fprintf(fid,"%s",first_str);

  % Real poles
  if V>0
    for k=1:V
      fprintf(fid,fstr,a(k));
      if (k~=V) || (Q ~= 0)
        fprintf(fid,",");
      endif
      fprintf(fid," ");
      if (rem(k,4) == 0) && (k ~= V)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    if (Q ~= 0)
      fprintf(fid, "...\n%s",space_str);
    endif
  endif

  % Complex poles
  if Q>0 
    for k=1:Qon2
      fprintf(fid,fstr,a(V+k));
      fprintf(fid,", ");
      if (rem(k,4) == 0) && (k ~= Qon2)
        fprintf(fid,"... \n%s",space_str);
      endif
    endfor
    fprintf(fid, "...\n%s",space_str);
    for k=1:Qon2
      fprintf(fid,fstr,a(V+Qon2+k));
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
  if (nargin >= 6) && (length(file_name_str) > 0)
    fclose(fid);
  endif
  
endfunction
