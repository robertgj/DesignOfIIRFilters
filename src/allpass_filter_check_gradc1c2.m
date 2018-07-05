function allpass_filter_check_gradc1c2(pfx,w,c1,c2,del,tol)
% allpass_filter_check_gradc1c2(pfx,w,c1,c2,del)
% Helper function for the allpass section tests  
  
% Copyright (C) 2018 Robert G. Jenssen
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

  if !is_function_handle(pfx)
    error("Expected pfx to be a function handle!");
  endif
  
  cdel=del/2;

  % Calculate frequency response
  [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=feval(pfx,c1,c2);
  [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
  [~,gradP]=H2P(H,dHdx);
  [~,gradT]=H2T(H,dHdw,dHdx,d2Hdwdx);

  % Check gradP(:,1)
  [AP,BP,CP,DP]=feval(pfx,c1+cdel,c2);
  HP = Abcd2H(w,AP,BP,CP,DP);
  PP=H2P(HP);
  [AM,BM,CM,DM]=feval(pfx,c1-cdel,c2);
  HM = Abcd2H(w,AM,BM,CM,DM);
  PM=H2P(HM); 
  approx_gradP=(PP-PM)/del;
  max_diff_gradP_c1=max(abs(gradP(:,1)-approx_gradP));
  if max_diff_gradP_c1 > tol
    error("max_diff_gradP_c1(%g) > tol",max_diff_gradP_c1);
  endif

  % Check gradP(:,2)
  [AP,BP,CP,DP]=feval(pfx,c1,c2+cdel);
  HP = Abcd2H(w,AP,BP,CP,DP);
  PP=H2P(HP);
  [AM,BM,CM,DM]=feval(pfx,c1,c2-cdel);
  HM = Abcd2H(w,AM,BM,CM,DM);
  PM=H2P(HM); 
  approx_gradP=(PP-PM)/del;
  max_diff_gradP_c2=max(abs(gradP(:,2)-approx_gradP));
  if max_diff_gradP_c2 > tol
    error("max_diff_gradP_c(%g)2 > tol",max_diff_gradP_c2);
  endif

  % Check gradT(:,1)
  [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]=feval(pfx,c1+cdel,c2);
  [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
  TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
  [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]=feval(pfx,c1-cdel,c2);
  [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
  TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
  approx_gradT=(TP-TM)/del;
  max_diff_gradT_c1=max(abs(gradT(:,1)-approx_gradT));
  if max_diff_gradT_c1 > tol
    error("max_diff_gradT_c1(%g) > tol",max_diff_gradT_c1);
  endif
  
  % Check gradT(:,2)
  [AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx]=feval(pfx,c1,c2+cdel);
  [HP,dHPdw,dHPdx,d2HPdwdx] = Abcd2H(w,AP,BP,CP,DP,dAPdx,dBPdx,dCPdx,dDPdx);
  TP=H2T(HP,dHPdw,dHPdx,d2HPdwdx);
  [AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx]=feval(pfx,c1,c2-cdel);
  [HM,dHMdw,dHMdx,d2HMdwdx] = Abcd2H(w,AM,BM,CM,DM,dAMdx,dBMdx,dCMdx,dDMdx);
  TM=H2T(HM,dHMdw,dHMdx,d2HMdwdx);
  approx_gradT=(TP-TM)/del;
  max_diff_gradT_c2=max(abs(gradT(:,2)-approx_gradT));
  if max_diff_gradT_c2 > tol
    error("max_diff_gradT_c2(%g) > tol",max_diff_gradT_c2);
  endif
  
endfunction
