function h = cl2lp(m,wo,up,lo,L)
% Constrained L2 Low Pass FIR filter design
%
% Author: Ivan Selesnick, Rice University, 1994
% Constrained Least Square Design of FIR
% Filters Without Specified Transition Bands
% by I.W.Selesnick, M.Lang, C.S.Burrus, IEEE
% Proc. ICASSP, May 1995, Vol. 2, pp1260-1263
%
%   h : 2*m+1 filter coefficients
%   m : degree of cosine polynomial
%   wo : cut-off frequency in (0,pi)
%   up : upper bound in passband, stopband]
%   lo : lower bound in passband, stopband]
%   L : grid size
%
% example
%   up = [1.025, 0.025]; 
%   lo = [0.975, -0.025];
%   h = cl2lp(30,0.3*pi,up,lo,2^10);

r = sqrt(2);
w = [0:L]'*pi/L;
Z = zeros(2*L-1-2*m,1);
q = round(wo*L/pi);
u = [up(1)*ones(q,1); up(2)*ones(L+1-q,1)];
l = [lo(1)*ones(q,1); lo(2)*ones(L+1-q,1)];
c = 2*[wo/r; [sin(wo*[1:m])./[1:m]]']/pi;
a = c;        % best L2 cosine coefficients
mu = [];      % Lagrange multipliers
SN = 1e-7;    % Small Number
while 1
  % ----- calculate H -------------------------
  H = fft([a(1)*r;a(2:m+1);Z;a(m+1:-1:2)]);
  H = real(H(1:L+1))/2;
  % ----- find extremals ----------------------
  kmax = local_max(H);
  kmin = local_max(-H);
  kmax = kmax( H(kmax) > u(kmax)-SN );
  kmin = kmin( H(kmin) < l(kmin)+SN );
  % ----- check stopping criterion ------------
  Eup = H(kmax)-u(kmax);
  Elo = l(kmin)-H(kmin);
  E = max([Eup; Elo; 0]); 
  if E < SN, break, end
  % ----- calculate new multipliers -----------
  n1 = length(kmax);
  n2 = length(kmin);
  O = [ones(n1,m+1); -ones(n2,m+1)];
  G = O .* cos(w([kmax;kmin])* [0:m]);
  G(:,1) = G(:,1)/r;
  d = [u(kmax); -l(kmin)];
  mu = (G*G')\(G*c-d);
  % ----- remove negative multiplier ----------
  [min_mu,K] = min(mu);
  while min_mu < 0
    G(K,:) = []; 
    d(K) = [];
    mu = (G*G')\(G*c-d);
    [min_mu,K] = min(mu);
  end
  % ----- determine new coefficients ----------
  a = c-G'*mu;
end
h = [a(m+1:-1:2); a(1)*r; a(2:m+1)]/2;
endfunction

