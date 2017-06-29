function showResponseBands(fap,ftp,fas,x,U,V,M,Q,R,str)
% showResponseBands(fap,ftp,fas,x,U,V,M,Q,R,str)

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

if (nargin != 9) && (nargin != 10)
  print_usage("showResponseBands(fap,ftp,fas,x,U,V,M,Q,R,str)";
endif
L=512;
subplot(311);
wap=fap*(0:(L-1))*2*pi/L;
Ap=iirA(wap,x,U,V,M,Q,R);
plot(0.5*wap/pi,20*log10(Ap));
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
if nargin==10
  title(str);
endif
subplot(312);
wtp=ftp*(0:(L-1))*2*pi/L;
T=iirT(wtp,x,U,V,M,Q,R);
plot(0.5*wtp/pi,T);
xlabel("Frequency");
ylabel("Delay(samples)");
subplot(313);
dfas=(0.5-fas)/(L-1);
was=2*pi*(fas+(dfas*(0:(L-1))));
As=iirA(was,x,U,V,M,Q,R);
plot(0.5*was/pi,20*log10(As));
axis([fas, 0.5, -60, -20]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");

endfunction

