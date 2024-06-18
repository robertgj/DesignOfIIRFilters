function [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds]=...
           schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)
% [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
%   schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)
% [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
%   schurNSlattice2Abcd(s10,s11,s20,s00)
%
% Find the state variable description of a Schur normalised-scaled lattice
% for 6 independent lattice coefficients per section, 4 independent lattice
% coefficients per section (s10,s11,s02=-s20 and s00=s22)
%
% Inputs:
%  If there are 6 arguments: s10,s11,s20,s02,s00,s22 
%  If there are 4 arguments: s10,s11,s20,s00 (and s02=-s20,s22=s00)
% Outputs:
%   [A,B,C,D] - the state variable description of the lattice filter
%   Cap,Dap - the corresponding matrixes for the all-pass filter
%   dAds,dBds,dCds,dDds - cell arrays containing the gradients of the state
%     variable description with respect to the lattice coefficients. x
%     represents either the s10,etc linear coefficients or s10,s11 and s20
%   dCapds,dDapds - the corresponding gradients for the all-pass filter
%
% The gradients are arranged by sections with respect to the input coefficients.
% For 6 independent lattice coefficients per section:
%   grad[s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,s10_2,s11_2,s20_2,...]
% For 4 independent lattice coefficients per section:
%   grad[s10_1,s11_1,s20_1,s00_1,s10_2,s11_2,s20_2,s00_2,s10_3,...]
  
% Copyright (C) 2017-2024 Robert G. Jenssen
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

  warning("Using Octave m-file version of function schurNSlattice2Abcd()!");

  % Sanity checks
  if ((nargin~=4) && (nargin~=6)) || nargout<4
    str1="[A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds,dCapds,dDapds]=...\n\
  schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)"
    str2="[A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00)";
    print_usage(sprintf("%s\n%s",str1,str2));
  endif
  if nargin == 6
    if length(s10)~=length(s11) || ...
       length(s10)~=length(s20) || ...
       length(s10)~=length(s00) || ...
       length(s10)~=length(s02) || ...
       length(s10)~=length(s22)
      error("Input vector lengths inconsistent!");
    endif
  else
    s02=-s20;
    s22=s00;
    if length(s10)~=length(s11) || ...
       length(s10)~=length(s20) || ...
       length(s10)~=length(s00)
      error("Input vector lengths inconsistent!");
    endif
  endif
  if isempty(s10)
    error("Input vectors are empty!");
  endif
  
  % Initialise
  Ns=length(s10);
  ABCD0=[1, zeros(1,Ns);eye(Ns+1,Ns+1)];

  % Modules 1 to Ns
  ABCD=ABCD0;
  for l=1:Ns
    mMod=eye(Ns+2,Ns+2);
    mMod(l:l+2,l:l+2)=[ s02(l),      0, s00(l); ...
                        s22(l),      0, s20(l); ...
                        0,      s11(l), s10(l); ];
    ABCD=mMod*ABCD;
  endfor

  % Extract state variable description
  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  Cap=ABCD(Ns+1,1:Ns);
  Dap=ABCD(Ns+1,Ns+1);
  C=ABCD(Ns+2,1:Ns);
  D=ABCD(Ns+2,Ns+1);

  % Done?
  if nargout<=6
    return;
  endif

  if nargin == 6
    [dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
      schurNSlattice2Abcd_dABCDds_helper(s10,s11,s20,s00,s02,s22);
  else
    [dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
      schurNSlattice2Abcd_dABCDds_symmetric_helper(s10,s11,s20,s00);
  endif

endfunction

function [dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
         schurNSlattice2Abcd_dABCDds_helper(s10,s11,s20,s00,s02,s22)
  % Calculate the differentials of A,B,C,D,Cap,Dap with respect to s
  % Find modules 1 to Ns (again!)
  Ns=length(s10);
  ABCD0=[1, zeros(1,Ns);eye(Ns+1,Ns+1)];
  ABCDm=cell(size(s10));
  for l=1:Ns,
    ABCDm{l}=eye(Ns+2,Ns+2);
    ABCDm{l}(l:l+2,l:l+2)=[ s02(l),      0, s00(l); ...
                            s22(l),      0, s20(l); ...
                            0,      s11(l), s10(l); ];
  endfor
  % Find RHS cumulative product (index order is 1,2*1,...,(Ns-1)*...*1,Ns*...*1) 
  prodABCDm_rhs=cell(size(s10));
  prodABCDm_rhs{1}=ABCDm{1}*ABCD0;
  for l=2:Ns,
    prodABCDm_rhs{l}=ABCDm{l}*prodABCDm_rhs{l-1};
  endfor
  % Find LHS cumulative product(index order is Ns*..*1,Ns*..*2,..,Ns*(Ns-1),Ns)
  prodABCDm_lhs=cell(size(s10));
  prodABCDm_lhs{Ns}=ABCDm{Ns};
  for l=(Ns-1):-1:1,
    prodABCDm_lhs{l}=prodABCDm_lhs{l+1}*ABCDm{l};
  endfor
  % Find differentials with respect to s of the modules
  dABCDmds10=cell(size(s10));
  dABCDmds11=cell(size(s11));
  dABCDmds20=cell(size(s20));
  dABCDmds00=cell(size(s00));
  dABCDmds02=cell(size(s02));
  dABCDmds22=cell(size(s22));
  for l=1:Ns,
    dABCDmds10{l}=zeros(Ns+2,Ns+2);
    dABCDmds11{l}=zeros(Ns+2,Ns+2);
    dABCDmds20{l}=zeros(Ns+2,Ns+2);
    dABCDmds00{l}=zeros(Ns+2,Ns+2);
    dABCDmds02{l}=zeros(Ns+2,Ns+2);
    dABCDmds22{l}=zeros(Ns+2,Ns+2);
    dABCDmds10{l}(l:l+2,l:l+2)=[0,0,0;0,0,0;0,0,1];
    dABCDmds11{l}(l:l+2,l:l+2)=[0,0,0;0,0,0;0,1,0];
    dABCDmds20{l}(l:l+2,l:l+2)=[0,0,0;0,0,1;0,0,0];
    dABCDmds00{l}(l:l+2,l:l+2)=[0,0,1;0,0,0;0,0,0];
    dABCDmds02{l}(l:l+2,l:l+2)=[1,0,0;0,0,0;0,0,0];
    dABCDmds22{l}(l:l+2,l:l+2)=[0,0,0;1,0,0;0,0,0];
  endfor
  % Find differentials with respect to s of ABCD
  dABCDds10=cell(size(s10));
  dABCDds11=cell(size(s11));
  dABCDds20=cell(size(s20));
  dABCDds00=cell(size(s00));
  dABCDds02=cell(size(s02));
  dABCDds22=cell(size(s22));
  if Ns==1
    dABCDds10{1}=dABCDmds10{1}*ABCD0;
    dABCDds11{1}=dABCDmds11{1}*ABCD0;
    dABCDds20{1}=dABCDmds20{1}*ABCD0;
    dABCDds00{1}=dABCDmds00{1}*ABCD0;
    dABCDds02{1}=dABCDmds02{1}*ABCD0;
    dABCDds22{1}=dABCDmds22{1}*ABCD0;
  else
    dABCDds10{1}=prodABCDm_lhs{2}*dABCDmds10{1}*ABCD0;
    dABCDds11{1}=prodABCDm_lhs{2}*dABCDmds11{1}*ABCD0;
    dABCDds20{1}=prodABCDm_lhs{2}*dABCDmds20{1}*ABCD0;
    dABCDds00{1}=prodABCDm_lhs{2}*dABCDmds00{1}*ABCD0;
    dABCDds02{1}=prodABCDm_lhs{2}*dABCDmds02{1}*ABCD0;
    dABCDds22{1}=prodABCDm_lhs{2}*dABCDmds22{1}*ABCD0;
    for l=2:(Ns-1),
      dABCDds10{l}=prodABCDm_lhs{l+1}*dABCDmds10{l}*prodABCDm_rhs{l-1};
      dABCDds11{l}=prodABCDm_lhs{l+1}*dABCDmds11{l}*prodABCDm_rhs{l-1};
      dABCDds20{l}=prodABCDm_lhs{l+1}*dABCDmds20{l}*prodABCDm_rhs{l-1};
      dABCDds00{l}=prodABCDm_lhs{l+1}*dABCDmds00{l}*prodABCDm_rhs{l-1};
      dABCDds02{l}=prodABCDm_lhs{l+1}*dABCDmds02{l}*prodABCDm_rhs{l-1};
      dABCDds22{l}=prodABCDm_lhs{l+1}*dABCDmds22{l}*prodABCDm_rhs{l-1};
    endfor
    dABCDds10{Ns}=dABCDmds10{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds11{Ns}=dABCDmds11{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds20{Ns}=dABCDmds20{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds00{Ns}=dABCDmds00{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds02{Ns}=dABCDmds02{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds22{Ns}=dABCDmds22{Ns}*prodABCDm_rhs{Ns-1};
  endif
  % Make the output vectors
  dAds=cell(1,Ns*6);
  dBds=cell(1,Ns*6);
  dCds=cell(1,Ns*6);
  dDds=cell(1,Ns*6);
  dCapds=cell(1,Ns*6);
  dDapds=cell(1,Ns*6);
  for l=1:Ns
    % s10
    dAds{((l-1)*6)+1}=dABCDds10{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+1}=dABCDds10{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+1}=dABCDds10{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+1}=dABCDds10{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+1}=dABCDds10{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+1}=dABCDds10{l}(Ns+2,Ns+1);
    % s11
    dAds{((l-1)*6)+2}=dABCDds11{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+2}=dABCDds11{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+2}=dABCDds11{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+2}=dABCDds11{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+2}=dABCDds11{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+2}=dABCDds11{l}(Ns+2,Ns+1);
    % s20
    dAds{((l-1)*6)+3}=dABCDds20{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+3}=dABCDds20{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+3}=dABCDds20{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+3}=dABCDds20{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+3}=dABCDds20{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+3}=dABCDds20{l}(Ns+2,Ns+1);
    % s00
    dAds{((l-1)*6)+4}=dABCDds00{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+4}=dABCDds00{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+4}=dABCDds00{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+4}=dABCDds00{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+4}=dABCDds00{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+4}=dABCDds00{l}(Ns+2,Ns+1);
    % s02
    dAds{((l-1)*6)+5}=dABCDds02{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+5}=dABCDds02{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+5}=dABCDds02{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+5}=dABCDds02{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+5}=dABCDds02{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+5}=dABCDds02{l}(Ns+2,Ns+1);
    % s22
    dAds{((l-1)*6)+6}=dABCDds22{l}(1:Ns,1:Ns);
    dBds{((l-1)*6)+6}=dABCDds22{l}(1:Ns,Ns+1);
    dCapds{((l-1)*6)+6}=dABCDds22{l}(Ns+1,1:Ns);
    dDapds{((l-1)*6)+6}=dABCDds22{l}(Ns+1,Ns+1);
    dCds{((l-1)*6)+6}=dABCDds22{l}(Ns+2,1:Ns);
    dDds{((l-1)*6)+6}=dABCDds22{l}(Ns+2,Ns+1);
  endfor

endfunction

function [dAds,dBds,dCds,dDds,dCapds,dDapds] = ...
         schurNSlattice2Abcd_dABCDds_symmetric_helper(s10,s11,s20,s00)
  % Calculate the differentials of A,B,C,D,Cap,Dap with respect to 
  % s10,s11,s20,s02=s20,s00 and s22=s00
  % Find modules 1 to Ns (again!)
  Ns=length(s10);
  ABCD0=[1, zeros(1,Ns);eye(Ns+1,Ns+1)];
  ABCDm=cell(size(s10));
  for l=1:Ns,
    ABCDm{l}=eye(Ns+2,Ns+2);
    ABCDm{l}(l:l+2,l:l+2)=[ -s20(l),      0, s00(l); ...
                             s00(l),      0, s20(l); ...
                             0,      s11(l), s10(l); ];
  endfor
  % Find RHS cumulative product (index order is 1,2*1,...,(Ns-1)*...*1,Ns*...*1) 
  prodABCDm_rhs=cell(size(s10));
  prodABCDm_rhs{1}=ABCDm{1}*ABCD0;
  for l=2:Ns,
    prodABCDm_rhs{l}=ABCDm{l}*prodABCDm_rhs{l-1};
  endfor
  % Find LHS cumulative product(index order is Ns*..*1,Ns*..*2,..,Ns*(Ns-1),Ns)
  prodABCDm_lhs=cell(size(s10));
  prodABCDm_lhs{Ns}=ABCDm{Ns};
  for l=(Ns-1):-1:1,
    prodABCDm_lhs{l}=prodABCDm_lhs{l+1}*ABCDm{l};
  endfor
  % Find differentials with respect to s of the modules
  dABCDmds10=cell(size(s10));
  dABCDmds11=cell(size(s11));
  dABCDmds20=cell(size(s20));
  dABCDmds00=cell(size(s00));
  for l=1:Ns,
    dABCDmds10{l}=zeros(Ns+2,Ns+2);
    dABCDmds11{l}=zeros(Ns+2,Ns+2);
    dABCDmds20{l}=zeros(Ns+2,Ns+2);
    dABCDmds00{l}=zeros(Ns+2,Ns+2);
    dABCDmds10{l}(l:l+2,l:l+2)=[0,0,0;0,0,0;0,0,1];
    dABCDmds11{l}(l:l+2,l:l+2)=[0,0,0;0,0,0;0,1,0];
    dABCDmds20{l}(l:l+2,l:l+2)=[-1,0,0;0,0,1;0,0,0];
    dABCDmds00{l}(l:l+2,l:l+2)=[0,0,1;1,0,0;0,0,0];
  endfor
  % Find differentials with respect to s of ABCD
  dABCDds10=cell(size(s10));
  dABCDds11=cell(size(s11));
  dABCDds20=cell(size(s20));
  dABCDds00=cell(size(s00));
  if Ns==1
    dABCDds10{1}=dABCDmds10{1}*ABCD0;
    dABCDds11{1}=dABCDmds11{1}*ABCD0;
    dABCDds20{1}=dABCDmds20{1}*ABCD0;
    dABCDds00{1}=dABCDmds00{1}*ABCD0;
  else
    dABCDds10{1}=prodABCDm_lhs{2}*dABCDmds10{1}*ABCD0;
    dABCDds11{1}=prodABCDm_lhs{2}*dABCDmds11{1}*ABCD0;
    dABCDds20{1}=prodABCDm_lhs{2}*dABCDmds20{1}*ABCD0;
    dABCDds00{1}=prodABCDm_lhs{2}*dABCDmds00{1}*ABCD0;
    for l=2:(Ns-1),
      dABCDds10{l}=prodABCDm_lhs{l+1}*dABCDmds10{l}*prodABCDm_rhs{l-1};
      dABCDds11{l}=prodABCDm_lhs{l+1}*dABCDmds11{l}*prodABCDm_rhs{l-1};
      dABCDds20{l}=prodABCDm_lhs{l+1}*dABCDmds20{l}*prodABCDm_rhs{l-1};
      dABCDds00{l}=prodABCDm_lhs{l+1}*dABCDmds00{l}*prodABCDm_rhs{l-1};
    endfor
    dABCDds10{Ns}=dABCDmds10{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds11{Ns}=dABCDmds11{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds20{Ns}=dABCDmds20{Ns}*prodABCDm_rhs{Ns-1};
    dABCDds00{Ns}=dABCDmds00{Ns}*prodABCDm_rhs{Ns-1};
  endif
  % Make the output vectors
  dAds=cell(1,Ns*4);
  dBds=cell(1,Ns*4);
  dCds=cell(1,Ns*4);
  dDds=cell(1,Ns*4);
  dCapds=cell(1,Ns*4);
  dDapds=cell(1,Ns*4);
  for l=1:Ns
    % s10
    dAds{((l-1)*4)+1}=dABCDds10{l}(1:Ns,1:Ns);
    dBds{((l-1)*4)+1}=dABCDds10{l}(1:Ns,Ns+1);
    dCapds{((l-1)*4)+1}=dABCDds10{l}(Ns+1,1:Ns);
    dDapds{((l-1)*4)+1}=dABCDds10{l}(Ns+1,Ns+1);
    dCds{((l-1)*4)+1}=dABCDds10{l}(Ns+2,1:Ns);
    dDds{((l-1)*4)+1}=dABCDds10{l}(Ns+2,Ns+1);
    % s11
    dAds{((l-1)*4)+2}=dABCDds11{l}(1:Ns,1:Ns);
    dBds{((l-1)*4)+2}=dABCDds11{l}(1:Ns,Ns+1);
    dCapds{((l-1)*4)+2}=dABCDds11{l}(Ns+1,1:Ns);
    dDapds{((l-1)*4)+2}=dABCDds11{l}(Ns+1,Ns+1);
    dCds{((l-1)*4)+2}=dABCDds11{l}(Ns+2,1:Ns);
    dDds{((l-1)*4)+2}=dABCDds11{l}(Ns+2,Ns+1);
    % s20
    dAds{((l-1)*4)+3}=dABCDds20{l}(1:Ns,1:Ns);
    dBds{((l-1)*4)+3}=dABCDds20{l}(1:Ns,Ns+1);
    dCapds{((l-1)*4)+3}=dABCDds20{l}(Ns+1,1:Ns);
    dDapds{((l-1)*4)+3}=dABCDds20{l}(Ns+1,Ns+1);
    dCds{((l-1)*4)+3}=dABCDds20{l}(Ns+2,1:Ns);
    dDds{((l-1)*4)+3}=dABCDds20{l}(Ns+2,Ns+1);
    % s00
    dAds{((l-1)*4)+4}=dABCDds00{l}(1:Ns,1:Ns);
    dBds{((l-1)*4)+4}=dABCDds00{l}(1:Ns,Ns+1);
    dCapds{((l-1)*4)+4}=dABCDds00{l}(Ns+1,1:Ns);
    dDapds{((l-1)*4)+4}=dABCDds00{l}(Ns+1,Ns+1);
    dCds{((l-1)*4)+4}=dABCDds00{l}(Ns+2,1:Ns);
    dDds{((l-1)*4)+4}=dABCDds00{l}(Ns+2,Ns+1);
  endfor

endfunction
