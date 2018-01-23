function showResponse(x,U,V,M,Q,R,str)
% showResponse(x,U,V,M,Q,R,str)

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
  
if (nargin != 6) && (nargin != 7)
  print_usage("showResponse(x,U,V,M,Q,R,str)");
endif

L=1024;
w=(0:(L-1))'*pi/L;
A=iirA(w,x,U,V,M,Q,R);
T=iirT(w,x,U,V,M,Q,R);
subplot(211);
plot(0.5*w/pi,20*log10(A));
axis([0, 0.5, -60, 10]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
if nargin==7
  title(str);
endif
subplot(212);
plot(0.5*w/pi,T);
axis([0, 0.5 0 2*(U+M)]);
xlabel("Frequency");
ylabel("Delay(samples)");
grid("on");

endfunction
