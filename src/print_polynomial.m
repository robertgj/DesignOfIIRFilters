function print_polynomial(x,name_str,arg3,arg4)
% print_polynomial(x,name_str)
% print_polynomial(x,name_str,format_str)
% print_polynomial(x,name_str,scale)
% print_polynomial(x,name_str,file_name_str)
% print_polynomial(x,name_str,file_name_str,format_str)
% print_polynomial(x,name_str,file_name_str,scale)
%
% Formatted printing of an array representing a polynomial with (possibly) :
%   - a printf format string (assumed if it contains "%")
%   - integer scaling
%   - an output file
%   - an output file and printf format string (it contains "%") 
%   - an output file and integer scaling

% Copyright (C) 2017-2025 Robert G. Jenssen
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

  % Initialise
  usage_str="\n      print_polynomial(x,name_str) ...\n\
      print_polynomial(x,name_str,format_str) ...\n\
      print_polynomial(x,name_str,scale) ...\n\
      print_polynomial(x,name_str,file_name_str) ...\n\
      print_polynomial(x,name_str,file_name_str,format_str) ...\n\
      print_polynomial(x,name_str,file_name_str,scale)\n";
  file_name_str="";
  format_str="%14.10f";
  scale_str="";
  fid=stdout;
  xs=x;
  tol=10*eps;
  
  % Sanity checks
  if nargin == 2
    if (~isempty(x) && ~isvector(x)) || ~all(isstrprop(name_str,"print"))
      print_usage(usage_str);
    endif
  elseif nargin == 3
    if length(arg3) == 0
           ;
    elseif isnumeric(arg3)
      if mod(arg3,1) ~= 0
        error("Expected scale to be an integer!");
      endif
      scale=round(arg3);
      scale_str=sprintf("/%d",arg3);
      format_str="%8d";
      xs=x*scale;
      if any(abs(mod(xs,1))>tol)
        error("Expected x*scale to be integers!");
      endif
    elseif length(arg3)>0 && any(arg3=="%")
      format_str=arg3;
    elseif length(arg3)>0 && all(isstrprop(arg3,"print"))
      file_name_str=arg3;
      fid=fopen(file_name_str,"wt");
    else
      print_usage(usage_str);
    endif
  elseif nargin == 4
    if length(arg3) == 0
           ;
    elseif length(arg3)>0 && all(isstrprop(arg3,"print"))
      file_name_str=arg3;
      fid=fopen(file_name_str,"wt");
    else
      print_usage(usage_str);
    endif
    if isnumeric(arg4)
      if mod(arg4,1) ~= 0
        error("Expected scale to be an integer!");
      endif
      scale=round(arg4);
      scale_str=sprintf("/%d",arg4);
      format_str="%8d";      
      xs=x*scale;
      if any(abs(mod(xs,1))>tol)
        error("Expected x*scale to be integers!");
      endif
    elseif (length(arg4)>0) && all(isstrprop(arg4,"print"))
      format_str=arg4;
    else 
      print_usage(usage_str);
    endif
  else
    print_usage(usage_str);
  endif

  % Initialise the output string
  first_str = sprintf("%s = [ ",name_str);
  space_str = ones(1,length(first_str))*" ";
  if isempty(x) || rows(x) == 1 
    tick_str = "";
  else
    tick_str = "'";
  endif

  % Print values into the output string
  fprintf(fid,"%s",first_str);
  for k=1:length(x)
    fprintf(fid,format_str,xs(k));
    if k ~= length(x)
      fprintf(fid,",");
    endif
    fprintf(fid," ");
    if (rem(k,4) == 0) && (k ~= length(x))
      fprintf(fid,"... \n%s",space_str);
    endif
  endfor
  fprintf(fid,"]%s%s;\n",tick_str,scale_str);

  % Done
  if (nargin >= 3) && (length(file_name_str) > 0)
    fclose(fid);
  endif
  
endfunction
