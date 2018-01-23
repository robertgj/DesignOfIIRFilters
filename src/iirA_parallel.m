function [A,gradA,hessA]=iirA_parallel(w,x,U,V,M,Q,R,tol,Np,parallel_threshold)
% [A,gradA,hessA]=iirA_parallel(w,x,U,V,M,Q,R,tol,Np,parallel_threshold)

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

  % Sanity checks
  if (nargin~=10) || (nargout>2)
    print_usage...
      ("[A,gradA]=iirA_parallel(w,x,U,V,M,Q,R,tol,Np,parallel_threshold)");
  endif
  if ~exist("parcellfun")
    error("parcellfun not found!");
  endif
  if isempty(w)
    error("w is empty!");
  endif
  if isempty(x)
    error("x is empty!");
  endif
  if Np<=0
    error("Np<=0!");
  endif
  if Np>nproc
    warning("Np>nproc!");
  endif
  
  % Initialise
  use_pararrayfun=true;
  Nx=length(x);
  Nw=length(w);
  w=w(:);
  nw=floor(Nw/parallel_threshold);
  nw_rm=mod(Nw,parallel_threshold);
  A=zeros(Nw,1);
  gradA=zeros(Nw,Nx);
  
  % Create a cell array of parts of w
  if nw_rm>0
    wc=cell(1,nw+1);
  else
    wc=cell(1,nw);
  endif
  for k=1:nw
    wc{k}=w((1:parallel_threshold)+((k-1)*parallel_threshold));
  endfor
  if nw_rm>0
    wc{nw+1}=w(((k*parallel_threshold)+1):end);
  endif
  Nwc=length(wc);
  xc=mat2cell(kron(ones(1,Nwc),x),length(x),ones(1,Nwc));
  Uc=mat2cell(kron(ones(1,Nwc),U),1,ones(1,Nwc));
  Vc=mat2cell(kron(ones(1,Nwc),V),1,ones(1,Nwc));
  Mc=mat2cell(kron(ones(1,Nwc),M),1,ones(1,Nwc));
  Qc=mat2cell(kron(ones(1,Nwc),Q),1,ones(1,Nwc));
  Rc=mat2cell(kron(ones(1,Nwc),R),1,ones(1,Nwc));
  tolc=mat2cell(kron(ones(1,Nwc),tol),1,ones(1,Nwc));

  % Call iirA (size(xc)~=size(U) etc. means I can't use pararrayfun())
  if nargout == 1
    Ac=parcellfun(Np,@iirA,...
                  wc,xc,Uc,Vc,Mc,Qc,Rc,tolc, ...
                  "VerboseLevel",0, ...
                  "ChunksPerProc", parallel_threshold, ...
                  "UniformOutput",false,
                  "ErrorHandler",@iirA_parallel_error_handler);
  else
    [Ac,gradAc]=parcellfun(Np,@iirA,...
                           wc,xc,Uc,Vc,Mc,Qc,Rc,tolc, ...
                           "VerboseLevel",0, ...
                           "ChunksPerProc", parallel_threshold, ...
                           "UniformOutput",false, ...
                           "ErrorHandler",@iirA_parallel_error_handler);
  endif
  
  % Rearrange the outputs
  if nargout >= 1
    if nw_rm>0
      for k=1:nw
        A((((k-1)*parallel_threshold)+1):(k*parallel_threshold))=Ac{k};
      endfor
      A(((nw*parallel_threshold)+1):end)=Ac{nw+1};
    else
      A=reshape(cell2mat(Ac),Nw,1);
    endif
  endif
  if nargout >= 2
    for k=1:nw
      gradA((((k-1)*parallel_threshold)+1):(k*parallel_threshold),:)=gradAc{k};
    endfor
    if nw_rm>0
      gradA(((nw*parallel_threshold)+1):end,:)=gradAc{nw+1};
    endif
  endif
endfunction

function iirA_parallel_error_handler(S,w,x,U,V,M,Q,R,tol)
  fprintf(stderr,"\n\niirA_parallel_error_handler():\n");
  fprintf(stderr,"S.identifier=%s\n",S.identifier);
  fprintf(stderr,"S.message=%s\n",S.message);
  fprintf(stderr,"S.index=%d\n",S.index);
  fprintf(stderr,"size(w)=[%d %d]\n",rows(w),columns(w));
  fprintf(stderr,"size(x)=[%d %d]\n",rows(x),columns(x));
  fprintf(stderr,"U=%d\n",U);
  fprintf(stderr,"V=%d\n",V);
  fprintf(stderr,"M=%d\n",M);
  fprintf(stderr,"Q=%d\n",Q);
  fprintf(stderr,"R=%d\n",R);
  fprintf(stderr,"tol=%g\n",tol);
endfunction
