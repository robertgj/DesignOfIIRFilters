function [gd, w] = delayz (b, a = 1, nfft = 512, whole = "", Fs = 1)
% [gd, w] = delayz (b, a = 1, nfft = 512, whole = "", Fs = 1)
% Based on the Octave forge signal package grpdelay function,
% modified to resolve ambiguities in the API and to allow for
% arbitrary frequencies.
%
% BEWARE :
%  1. The API for delayz(b,a,n) and delayz(b,a,w) is ambiguous!
%     In the latter case, w is assumed to not be a positive integer scalar.
%  2. The API for delayz(b,a,n,Fs) and delayz(b,a,f,Fs) is ambiguous!
%     In the latter case, f is assumed to not be a positive integer scalar.
%  3. This method may be inaccurate for long IIR filters and small n!
  
## Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2004 Julius O. Smith III <jos@ccrma.stanford.edu>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING. If not, see
## <https://www.gnu.org/licenses/>.

  # Sanity checks
  if (nargin < 1 || nargin > 5)
    print_usage ();
  endif

  if isempty (nfft)
    nfft = 512;
  endif
  
  if isscalar(nfft) && (abs(round(nfft)-nfft)<eps) && (round(nfft)>0)
    nfft_is_length = true;
    nfft = round(nfft);
  else
    nfft_is_length = false;
  endif

  # Decode the API
  HzFlag=false;
  if nfft_is_length
    if (nargin == 5)
      HzFlag = true;
    elseif (nargin == 4) && (! ischar (whole))
      HzFlag = true;
      Fs = whole;
      whole = "";
    endif
    if ! strcmp(whole,"whole")
      nfft = 2*nfft;
    endif
    w = 2*pi*(0:(nfft-1))/nfft;
  else
    if (nargin > 4)
      print_usage ();
    elseif (nargin == 4)
      # delayz (B, A, F, Fs)
      HzFlag = true;
      Fs = whole;
      w = 2*pi*nfft(:)'/Fs;
    else
      # delayz (B, A, W)
      w = nfft(:)';
    endif
    whole = "";
  endif
 
  # Make sure both are row vectors
  a = a(:).';
  b = b(:).';

  oa = length (a) -1;     # order of a(z)
  if (oa < 0)             # a can be []
    a  = 1;
    oa = 0;
  endif
  ob = length (b) -1;     # order of b(z)
  if (ob < 0)             # b can be [] as well
    b  = 1;
    ob = 0;
  endif
  oc = oa + ob;           # order of c(z)

  # Calculate the group delay as shown in the reference
  c   = conv (b, fliplr (conj (a)));  # c(z) = b(z)*conj(a)(1/z)*z^(-oa)
  cr  = c.*(0:oc);                    # cr(z) = derivative of c wrt 1/z
  if nfft_is_length
    num = fft (cr, nfft);
    den = fft (c, nfft);
  else
    expjkw = exp(-j*kron((0:oc)',w));
    num = cr*expjkw;
    den = c*expjkw;
  endif

  # Check for singularities in the group delay
  minmag  = 10*eps;
  polebins = find (abs (den) < minmag);
  if ! isempty(polebins)
    warning ("signal:delayz-singularity",
             "delayz: setting group delay to 0 at singularities");
    oa = oa*ones(size(num));
    oa(polebins) = 0;
    num(polebins) = 0;
    den(polebins) = 1;
  endif
  gd = real (num ./ den) - oa;

  # Trim gd
  if nfft_is_length && (! strcmp (whole, "whole"))
    ns = nfft/2; # Matlab convention ... should be nfft/2 + 1
    gd = gd(1:ns);
    w  = w(1:ns);
  else
    ns = length(w); # used in plot below
  endif

  # Compatibility
  gd = gd(:);
  w = w(:);
  if HzFlag
    w = Fs*w/(2*pi);
  endif
  
  if (nargout == 0)
    unwind_protect
      grid ("on"); # grid() should return its previous state
      if (HzFlag)
        funits = "Hz";
      else
        funits = "radian/sample";
      endif
      xlabel (["Frequency (" funits ")"]);
      ylabel ("Group delay (samples)");
      plot (w(1:ns), gd(1:ns), ";;");
    unwind_protect_cleanup
      grid ("on");
    end_unwind_protect
  endif

endfunction

## ------------------------ DEMOS -----------------------

%!demo % 1
%! %--------------------------------------------------------------
%! % From Oppenheim and Schafer, a single zero of radius r=0.9 at
%! % angle pi should have a group delay of about -9 at 1 and 1/2
%! % at zero and 2*pi.
%! %--------------------------------------------------------------
%! delayz([1 0.9],[],512,'whole',1);
%! hold on;
%! xlabel('Normalized Frequency (cycles/sample)');
%! stem([0, 0.5, 1],[0.5, -9, 0.5],'*b;target;');
%! hold off;
%! title ('Zero at z = -0.9');
%!
%!demo % 2
%! %--------------------------------------------------------------
%! % confirm the group delays approximately meet the targets
%! % don't worry that it is not exact, as I have not entered
%! % the exact targets.
%! %--------------------------------------------------------------
%! b = poly([1/0.9*exp(1i*pi*0.2), 0.9*exp(1i*pi*0.6)]);
%! a = poly([0.9*exp(-1i*pi*0.6), 1/0.9*exp(-1i*pi*0.2)]);
%! delayz(b,a,512,'whole',1);
%! hold on;
%! xlabel('Normalized Frequency (cycles/sample)');
%! stem([0.1, 0.3, 0.7, 0.9], [9, -9, 9, -9],'*b;target;');
%! hold off;
%! title ('Two Zeros and Two Poles');

%!demo % 3
%! %--------------------------------------------------------------
%! % fir lowpass order 40 with cutoff at w=0.3 and details of
%! % the transition band [.3, .5]
%! %--------------------------------------------------------------
%! subplot(211);
%! Fs = 8000;     % sampling rate
%! Fc = 0.3*Fs/2; % lowpass cut-off frequency
%! nb = 40;
%! b = fir1(nb,2*Fc/Fs); % matlab freq normalization: 1=Fs/2
%! [H,f] = freqz(b,1,[],1);
%! [gd,f] = delayz(b,1,[],1);
%! plot(f,20*log10(abs(H)));
%! title(sprintf('b = fir1(%d,2*%d/%d);',nb,Fc,Fs));
%! xlabel('Normalized Frequency (cycles/sample)');
%! ylabel('Amplitude Response (dB)');
%! grid('on');
%! subplot(212);
%! del = nb/2; % should equal this
%! plot(f,gd);
%! title(sprintf('Group Delay in Pass-Band (Expect %d samples)',del));
%! ylabel('Group Delay (samples)');
%! axis([0, 0.2, del-1, del+1]);

%!demo % 4
%! %--------------------------------------------------------------
%! % IIR bandstop filter has delays at [1000, 3000]
%! %--------------------------------------------------------------
%! Fs = 8000;
%! [b, a] = cheby1(3, 3, 2*[1000, 3000]/Fs, 'stop');
%! [H,f] = freqz(b,a,[],Fs);
%! [gd,f] = delayz(b,a,[],Fs);
%! subplot(211);
%! plot(f,abs(H));
%! title('[b,a] = cheby1(3, 3, 2*[1000, 3000]/Fs, "stop");');
%! xlabel('Frequency (Hz)');
%! ylabel('Amplitude Response');
%! grid('on');
%! subplot(212);
%! plot(f,gd);
%! title('[gd,f] = delayz(b,a,[],Fs);');
%! ylabel('Group Delay (samples)');


% ------------------------ TESTS -----------------------

%!test % 00
%! [gd1,w] = delayz([0,1]);
%! [gd2,w] = delayz([0,1],1);
%! assert(gd1,gd2,10*eps);

%!test % 0A
%! [gd,w] = delayz([0,1],1,4);
%! assert(gd,[1;1;1;1]);
%! assert(w,pi/4*[0:3]',10*eps);

%!test % 0B
%! [gd,w] = delayz([0,1],1,4,'whole');
%! assert(gd,[1;1;1;1]);
%! assert(w,pi/2*[0:3]',10*eps);

%!test % 0C
%! [gd,f] = delayz([0,1],1,4,0.5);
%! assert(gd,[1;1;1;1]);
%! assert(f,1/16*[0:3]',10*eps);

%!test % 0D
%! [gd,w] = delayz([0,1],1,4,'whole',1);
%! assert(gd,[1;1;1;1]);
%! assert(w,1/4*[0:3]',10*eps);

%!test % 0E
%! [gd,f] = delayz([1 -0.9j],[],4,'whole',1);
%! gd0 = 0.447513812154696; gdm1 =0.473684210526316;
%! assert(gd,[gd0;-9;gd0;gdm1],20*eps);
%! assert(f,1/4*[0:3]',10*eps);

%!test % 1A:
%! gd= delayz(1,[1,.9],2*pi*[0,0.125,0.25,0.375]);
%! assert(gd, [-0.47368;-0.46918;-0.44751;-0.32316],1e-5);

%!test % 1B:
%! gd= delayz(1,[1,.9],[0,0.125,0.25,0.375],1);
%! assert(gd, [-0.47368;-0.46918;-0.44751;-0.32316],1e-5);

%!test % 2:
%! gd = delayz([1,2],[1,0.5,.9],4);
%! assert(gd,[-0.29167;-0.24218;0.53077;0.40658],1e-5);

%!test % 3
%! b1=[1,2];a1f=[0.25,0.5,1];a1=fliplr(a1f);
%! % gd1=delayz(b1,a1,4);
%! gd=delayz(conv(b1,a1f),1,4)-2;
%! assert(gd, [0.095238;0.239175;0.953846;1.759360],1e-5);

%!test % 4
%! warning ("off", "signal:delayz-singularity", "local");
%! Fs = 8000;
%! [b, a] = cheby1(3, 3, 2*[1000, 3000]/Fs, 'stop');
%! [h, w] = delayz(b, a, 256, 'half', Fs);
%! [h2, w2] = delayz(b, a, 512, 'whole', Fs);
%! assert (size(h), size(w));
%! assert (length(h), 256);
%! assert (size(h2), size(w2));
%! assert (length(h2), 512);
%! assert (h, h2(1:256));
%! assert (w, w2(1:256));

%!test % 5
%! a = [1 0 0.9];
%! b = [0.9 0 1];
%! [dh, wf] = delayz(b, a, 512, 'whole');
%! [da, wa] = delayz(1, a, 512, 'whole');
%! [db, wb] = delayz(b, 1, 512, 'whole');
%! assert(dh,db+da,1e-5);

## test for bug #39133 (do not fail for row or column vector)
%!test
%! DR= [1.00000 -0.00000 -3.37219 0.00000 ...
%!      5.45710 -0.00000 -5.24394 0.00000 ...
%!      3.12049 -0.00000 -1.08770 0.00000 0.17404];
%! N = [-0.0139469 -0.0222376 0.0178631 0.0451737 ...
%!       0.0013962 -0.0259712 0.0016338 0.0165189 ...
%!       0.0115098 0.0095051 0.0043874];
%! assert (nthargout (1:2, @delayz, N,  DR,  1024),
%!         nthargout (1:2, @delayz, N', DR', 1024));

## tests for bug #45834 (use vector of w or F values)
%!test
%! [gd,w] = delayz([1 1 0], [], 0);
%! assert (gd,0.5);
%! assert (w,0);

%!test
%! a = [1 0 0.9];
%! b = [0.9 0 1];
%! [gd, w] = delayz(b, a, 0);
## The following fails for n=2 !!
%! [gd2, w2] = delayz(b, a, 2);
%! [gd4, w4] = delayz(b, a, 4);
%! assert(w,w4(1),1000*eps);
%! assert(gd,gd4(1),1000*eps);

%!test
%! a = [1 0 0.9];
%! b = [0.9 0 1];
%! [gd, w] = delayz(b, a, 0, 1000);
## The following fails for n=2 !!
%! [gd2, w2] = delayz(b, a, 2, 1000);
%! [gd4, w4] = delayz(b, a, 4, 1000);
%! assert(w,w4(1),1000*eps);
%! assert(gd,gd4(1),1000*eps);

%!test
%! DR= [1.00000 -0.00000 -3.37219 0.00000 ...
%!      5.45710 -0.00000 -5.24394 0.00000 ...
%!      3.12049 -0.00000 -1.08770 0.00000 0.17404];
%! N = [-0.0139469 -0.0222376 0.0178631 0.0451737 ...
%!       0.0013962 -0.0259712 0.0016338 0.0165189 ...
%!       0.0115098 0.0095051 0.0043874];
%! F=(0.10:0.02:0.20);
%! [gd, w] = delayz(N, DR, 2*pi*F);
%! [gd25, w25] = delayz(N, DR, 25);
%! assert (w,2*pi*F',10*eps);
%! assert (gd,gd25(6:11),1000*eps);

%!test
%! DR= [1.00000 -0.00000 -3.37219 0.00000 ...
%!      5.45710 -0.00000 -5.24394 0.00000 ...
%!      3.12049 -0.00000 -1.08770 0.00000 0.17404];
%! N = [-0.0139469 -0.0222376 0.0178631 0.0451737 ...
%!       0.0013962 -0.0259712 0.0016338 0.0165189 ...
%!       0.0115098 0.0095051 0.0043874];
%! n=25;
%! Fs=1000;
%! F=(100:20:200);
%! [gdF, fF] = delayz(N, DR, F, Fs);
%! [gd25, w25] = delayz(N, DR, n);
%! [gd25F, f25F] = delayz(N, DR, n, Fs);
%! assert (fF,Fs*w25(6:11)/(2*pi),1000*eps);
%! assert (fF,F',1000*eps);
%! assert (gdF,gd25(6:11),1000*eps);
%! assert (gd25,gd25F,1000*eps);

%!test
%! D= [1, 0.9, 1];
%! N = [1, 0.9];
%! w = pi/4;
%! gd = delayz(N, D, w);
%! [gd4,w4] = delayz(N, D, 4);
%! assert (w,w4(2),1000*eps);
%! assert (gd,gd4(2),1000*eps);

%!test
%! DR= [1.00000 -0.00000 -3.37219 0.00000 ...
%!      5.45710 -0.00000 -5.24394 0.00000 ...
%!      3.12049 -0.00000 -1.08770 0.00000 0.17404];
%! N = [-0.0139469 -0.0222376 0.0178631 0.0451737 ...
%!       0.0013962 -0.0259712 0.0016338 0.0165189 ...
%!       0.0115098 0.0095051 0.0043874];
%! w = pi/4;
%! gd = delayz(N, DR, w);
## The following fails for n<12 !!
%! [gd8,w8] = delayz(N, DR, 8);
%! [gd12,w12] = delayz(N, DR, 12);
%! assert (w,w12(4),1000*eps);
%! assert (gd,gd12(4),1000*eps);
%! [gd16,w16] = delayz(N, DR, 16);
%! assert (w,w16(5),1000*eps);
%! assert (gd,gd16(5),1000*eps);
%! [gd256,w256] = delayz(N, DR, 256);
%! assert (w,w256(65),1000*eps);
%! assert (gd,gd256(65),1000*eps);
