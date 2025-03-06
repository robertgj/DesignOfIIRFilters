function [h,rs,del_p,del_s] = faffine(M,wp,ws,Kp,Ks,eta_p,eta_s);
% [h,rs,del_p,del_s] = faffine(M,wp,ws,Kp,Ks,eta_p,eta_s);
% Lowpass linear phase FIR filter design by a REMEZ-like algorithm
%  h   : filter of length 2*M+1
%  rs  : reference set upon convergence
%  del_p : passband error, del_p = Kp * del + eta_p
%  del_s : stopband error, del_s = Kp * del + eta_s
%  wp,ws : band edges
% EXAMPLE
%{
 M=200;wp=2*pi*0.1;ws=2*pi*0.11;Kp=1;Ks=0;eta_p=0;eta_s=0.00001;
 [h,rs,del_p,del_s] = faffine(M,wp,ws,Kp,Ks,eta_p,eta_s);
 [H,w]=freqz(h,1,10000);
 plot(w*0.5/pi,20*log10(abs(H)));
%}
% author: IVAN SELESNICK

  % ------------------ initialize some constants ------------------------------
  L = 2^ceil(log2(10*M));			% grid size
  SN = 1e-7;                        % Small Number (stopping criterion)
  w  = [0:L]*pi/L;                  % frequency axis

  S = M + 2;		                % S = size of reference set
  np = round(S*(wp+ws)/(2*pi));     % initial no. of ref. set freq. in passband
  np = max([np, 1]);
  if np == S
    np = np - 1;
  endif
  ns = S - np;                      % initial no. of ref. set freq. in stopband
  if np > 1
    r_pass = [0:np-1]*wp/(np-1);
  else
    r_pass = wp;
  endif
  if ns > 1
    r_stop = [0:ns-1]*(pi-ws)/(ns-1)+ws;
  else
    r_stop = ws;
  endif
  rs = [r_pass, r_stop]';           % initial ref. set
  D = [ones(np,1); zeros(ns,1)];    % desired amplitude over ref. set
  sp = [(-1).^(np:-1:1)'; zeros(ns,1)]; % alternating signs in passband
  ss = [zeros(np,1); (-1).^(0:ns-1)']; % alternating signs in stopband

  Z = zeros(2*(L+1-M)-3,1);
  PF = 0;                           % PF : flag : Plot Figures

  % begin looping
  Err = 1;
  while Err > SN

    % --------------- calculate cosine coefficients ---------------------------
    x = [cos(rs*[0:M]), -sp, -ss, zeros(M+2,1); ...
         [zeros(2,M+1), [1 0 -Kp; 0 1 -Ks]]] \ [D; eta_p; eta_s];
    a = x(1:M+1);
    del_p = x(M+2);
    del_s = x(M+3);
    del   = x(M+4);
    if (del_p<0) && (del_s<0)
      error("both del_p and del_s are negative!")
    elseif del_s < 0
      % set del_s equal to 0
      disp("del_s < 0")
      x = [cos(rs*[0:M]), -sp] \ D;
      a = x(1:M+1);
      del_p = x(M+2);
      del_s = 0;
    elseif del_p < 0
      % set del_p equal to 0
      disp("del_p < 0")
      x = [cos(rs*[0:M]), -ss] \ D;
      a = x(1:M+1);
      del_p = 0;
      del_s = x(M+2);
    endif
    A = real(fft([a(1);a(2:M+1)/2;Z;a(M+1:-1:2)/2])); A = A(1:L+1);

    % Plot Figures if PF == 1
    if PF
      figure(1),
      plot(w/pi,A), 
      hold on, 
      plot(rs/pi,D+sp*del_p+ss*del_s,"o"), 
      hold off, 
      % axis([0 1 -.2 1.2])
      grid
      pause(.5)
    endif

    % --------------- determine new reference set-----------------------------
    ri = sort([local_max(A); local_max(-A)]);   
    rs = (ri-1)*pi/L;
    rs = frefine(a,rs);             % refine ref. set using Newtons method
    rsp = rs(rs<wp);                % passband ref. set frequencies
    rss = rs(rs>ws);                % stopband ref. set frequencies
    rs = [rsp; wp; ws; rss];        % new reference set
    np = length(rsp)+1;             % no. of passband ref. set frequencies
    ns = length(rss)+1;             % no. of stopband ref. set frequencies
    D  = [ones(np,1); zeros(ns,1)]; % desired amplitude over rs
    sp = [(-1).^(np:-1:1)'; zeros(ns,1)];
    ss = [zeros(np,1); (-1).^(0:ns-1)'];
    lr = length(rs);  
    Ar = cos(rs*[0:M])*a;  

    if lr > M+2                     % ref. set too big - (one freq. too many)
      if A(1) < A(2)
        cp = -1;
      else
        cp = 1;
      endif
      if A(L+1) < A(L)
        cs = -1;
      else
        cs = 1;
      endif 
      if (A(1)-1)*cp-del_p < A(L+1)*cs-del_s
        q = 1;
      else
        q = lr;
      endif
      sp(q) = [];
      ss(q) = [];
      D(q)  = [];
      Ar(q) = [];
      rs(q) = [];
    endif 

    % -------- calculate stopping criterion ------------
    Err = max(abs((Ar - D) - ((Kp*del+eta_p)*sp + (Ks*del+eta_s)*ss)));
    disp(sprintf("    Err = %20.15f",Err));
  endwhile

  if PF
    figure(1), 
    plot(w/pi,A), hold on, plot(rs/pi,Ar,"o"), hold off
    % axis([0 1 -.2 1.2]);
    xlabel("w/pi"), ylabel("A"), title("Frequency Response Amplitude");
  endif
  
  % -------- filter coefficients ------------
  h = [a(M+1:-1:2)/2; a(1); a(2:M+1)/2];

endfunction

