function print_polynomial(x,name_str,file_name_str,format_str)
% print_polynomial(x,name_str[,file_name_str,format_str])

% Copyright (C) 2017 Robert G. Jenssen
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

  if (nargin < 2) || (nargin > 4)
    print_usage("print_polynomial(x,name_str[,file_name_str,format_str])");
  endif
  if ~isvector(x)
    error("%s is not a vector!",name_str);
  endif
  if nargin == 4
    fstr=format_str;
  else
    fstr="%14.10f";
  endif
  if nargin >= 3
    fid=fopen(file_name_str,"wt");
  else
    fid=stdout;
  endif

  first_str = sprintf("%s = [ ",name_str);
  space_str = ones(1,length(first_str))*" ";
  if rows(x) == 1
    tick_str = "";
  else
    tick_str = "'";
  endif

  fprintf(fid,"%s",first_str);
  for k=1:length(x)
    fprintf(fid,fstr,x(k));
    if k ~= length(x)
      fprintf(fid,",");
    endif
    fprintf(fid," ");
    if (rem(k,4) == 0) && (k ~= length(x))
      fprintf(fid,"... \n%s",space_str);
    endif
  endfor
  fprintf(fid,"]%s;\n", tick_str);

  % Done
  if nargin >= 3
    fclose(fid);
  endif
  
endfunction
