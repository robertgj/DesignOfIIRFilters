function showResponsePassBands(fmin,fmax,dBmin,dBmax,x,U,V,M,Q,R,str)
% showResponsePassBands(fmin,fmax,dBmin,dBmax,x,U,V,M,Q,R,str)

% Copyright (C) 2017-2020 Robert G. Jenssen
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

if (nargin ~= 10) && (nargin ~= 11)
  print_usage("showResponsePassBands(fmin,fmax,dBmin,dBmax,x,U,V,M,Q,R,str)");
endif

L=512;
fp=fmin+((fmax-fmin)*(0:(L-1))/L)';
wp=2*pi*fp;
subplot(211);
Ap=iirA(wp,x,U,V,M,Q,R);
plot(0.5*wp/pi,20*log10(Ap));
axis([fmin, fmax, dBmin, dBmax]);
ylabel("Amplitude(dB)");
grid("on");
if nargin==11
  title(str);
endif
subplot(212);
T=iirT(wp,x,U,V,M,Q,R);
plot(0.5*wp/pi,T);
axis([fmin, fmax]);
xlabel("Frequency");
ylabel("Delay(samples)");
grid("on");

endfunction

