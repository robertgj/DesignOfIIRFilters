function h = cl2bp(m,w1,w2,up,lo,L)
% h = cl2bp(m,w1,w2,up,lo,L)
% Constrained L2 BandPass FIR filter design
% (odd lengths only)
% Author: Ivan Selesnick, Rice University, 1995
%  m   : degree of cosine polynomial
%  w1,w2 : first and second band edges
%  up  : vector of upper bounds
%  lo  : vector of lower bounds
%  L   : grid size
% output:
%   h  : 2*m+1 filter coefficients
% example
%   w1 = 0.3*pi; 
%   w2 = 0.6*pi;
%   up = [0.02, 1.02, 0.02]; 
%   lo = [-0.02, 0.98, -0.02];
%   h  = cl2bp(30,w1,w2,up,lo,2^11);

% ----- calculate Fourier coefficients and upper ---
% ----- and lower bound functions ------------------

q1 = round(L*w1/pi);
q2 = round(L*(w2-w1)/pi);
q3 = L + 1 - q1 - q2;
u = [up(1)*ones(q1,1); up(2)*ones(q2,1); up(3)*ones(q3,1)];
l = [lo(1)*ones(q1,1); lo(2)*ones(q2,1); lo(3)*ones(q3,1)];
w = [0:L]'*pi/L;
Z = zeros(2*L-1-2*m,1);   
r = sqrt(2);
c = [(w2-w1)*r; 2*[(sin(w2*[1:m])-sin(w1*[1:m]))./[1:m]]']/pi;
a = c;       	% best L2 cosine coefficients
mu = [];     	% Lagrange multipliers
SN = 1e-9;   	% Small Number
kmax = []; uvo = 0;
kmin = []; lvo = 0;

while 1
  if any(uvo > SN/2) || any(lvo > SN/2)
     % ----- include old extremal ----------------
     if uvo > lvo
        kmax = [kmax; okmax(k1)]; okmax(k1) = [];
     else
        kmin = [kmin; okmin(k2)]; okmin(k2) = [];
     end
  else
     % ----- calculate A -------------------------
     A = fft([a(1)*r;a(2:m+1);Z;a(m+1:-1:2)]);
     A = real(A(1:L+1))/2;
     % ----- find extremals ----------------------
     okmax = kmax;         okmin = kmin;
     kmax  = local_max(A); kmin  = local_max(-A);
     kmax  = kmax( A(kmax) > u(kmax)-SN/10 );
     kmin  = kmin( A(kmin) < l(kmin)+SN/10 );
     % ----- check stopping criterion ------------
     Eup = A(kmax)-u(kmax); Elo = l(kmin)-A(kmin);
     E = max([Eup; Elo; 0])
     if E < SN, break, end
  end

  % ----- calculate new multipliers -----------
  n1 = length(kmax); n2 = length(kmin);
  O  = [ones(n1,m+1); -ones(n2,m+1)];
  G  = O .* cos(w([kmax;kmin])*[0:m]);
  G(:,1) = G(:,1)/r;
  d  = [u(kmax); -l(kmin)];
  mu = (G*G')\(G*c-d);            
  % ----- remove negative multiplier ----------
  [min_mu,K] = min(mu);
  while min_mu < 0
    G(K,:) = []; d(K) = [];
    mu = (G*G')\(G*c-d);            
    if K > n1
       kmin(K-n1) = []; n2 = n2 - 1; 
    else
       kmax(K) = []; n1 = n1 - 1;
    end
    [min_mu,K] = min(mu);
  end
  % ----- determine new coefficients ----------
  a = c-G'*mu;

  if length(okmax)>0
    Aokmax = a(1)/r + cos(w(okmax)*[1:m])*a(2:m+1);
    [uvo,k1] = max([Aokmax-u(okmax); 0]);
  else
    uvo = 0;
  end
  if length(okmin)>0
     Aokmin = a(1)/r + cos(w(okmin)*[1:m])*a(2:m+1);
     [lvo,k2] = max([l(okmin)-Aokmin; 0]);
  else
     lvo = 0;
  end

end

h = [a(m+1:-1:2); a(1)*r; a(2:m+1)]/2;

