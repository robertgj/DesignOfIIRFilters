function [T,Kopt,Wopt]=optKW(K,W,d)
% [T,Kopt,Wopt]=optKW(K,W,d)
% optKW finds the transformation, T, that optimises
% the K and W matrices for minimum roundoff noise with
% scaling d.

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

% Check the input arguments
if nargin ~= 3 
  error("Expected three input arguments");
end 

% Do an SVD decomposition of W
[U1,D1,V1]=svd(W);

% Diagonalise K
T1=U1/sqrt(D1);
K1=inv(T1)*K*inv(T1)';

% Do an SVD decomposition of K1
[U2,D2,V2]=svd(K1);

% Find the transformation that makes the elements of sqrt(D2) equal
% Use repeated plane rotations, R, that replace two diagonal elements 
% with their average in a similarity transformation, R'*D3*R.
D3=sqrt(D2);
U3=eye(size(D3));
tol = 100*eps;
% Make the diagonal elements of D3 equal
while abs(max(diag(D3))-min(diag(D3))) > tol
  % Find the positions of the max. and min. diagonal elements
  pdD3max = find(diag(D3)==max(diag(D3)));
  pdD3max = pdD3max(1);
  pdD3min = find(diag(D3)==min(diag(D3)));
  pdD3min = pdD3min(1);
  % Find the elements of D3 to be rotated
  px=min(pdD3min,pdD3max);
  x=D3(px,px);
  y=D3(pdD3min,pdD3max);
  if abs(y-D3(pdD3max,pdD3min))>tol
      error("D3 is no longer symmetric");
  end
  pz=max(pdD3min,pdD3max);
  z=D3(pz,pz);
  % Find the required rotation angle
  if y == 0
       theta=pi/4;
  else
       theta=0.5*atan((x-z)/(2*y));
  end
  % Build a rotation matrix
  R=eye(size(D3));
  R(px,px)=cos(theta);
  R(pz,pz)=cos(theta);
  R(px,pz)=sin(theta);
  R(pz,px)=-sin(theta);
  % Do the similarity transform
  D3=R'*D3*R;
  % Update the transform
  U3=U3*R;
end

% Construct the optimising transform
T=T1*U2*sqrt(sqrt(D2))*U3;

% Scale the covariance matrix using d
K3=inv(T)*K*inv(T)';
S=d*diag(sqrt(diag(K3)));
T=T*S;

% Find the optimised Kopt, Wopt
Kopt=inv(T)*K*inv(T)';
Wopt=T'*W*T;

endfunction
