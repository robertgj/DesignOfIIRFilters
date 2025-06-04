% tf2Abcd_test .m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="tf2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

NN=5;
fc=0.05;
[N,D]=butter(NN,2*fc);

%
% Check arguments
try
  [A,b,c,d]=tf2Abcd();
catch
  fprintf(stderr,"Caught nargin==0!\n");
end_try_catch
try
  [A,b,c,d]=tf2Abcd(N);
catch
  fprintf(stderr,"Caught nargin==1!\n");
end_try_catch
try
  [A,b,c,d]=tf2Abcd(N,D,B);
catch
  fprintf(stderr,"Caught nargin==3!\n");
end_try_catch
try
  tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==0!\n");
end_try_catch
try
  [A,b,c]=tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==3!\n");
end_try_catch
try
  [A,b,c,d,e]=tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==5!\n");
end_try_catch
try
  [A,b,c,d,e,f]=tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==6!\n");
end_try_catch
try
  [A,b,c,d,e,f,g]=tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==7!\n");
end_try_catch
try
  [A,b,c,d,e,f,g,h,i]=tf2Abcd(N,D);
catch
  fprintf(stderr,"Caught nargout==9!\n");
end_try_catch
try
  [A,b,c,d]=tf2Abcd([],1);
catch
  fprintf(stderr,"Caught N is empty!\n");
end_try_catch
try
  [A,b,c,d]=tf2Abcd(1,[]);
catch
  fprintf(stderr,"Caught D is empty!\n");
end_try_catch

[A,b,c,d]=tf2Abcd(3,2)
[A,b,c,d,dAdx,dbdx,dcdx,dddx]=tf2Abcd(3,2)

% Check results
f=cell(1,5);
f{1}.N=N;      f{1}.D=D;
f{2}.N=[1];    f{2}.D=D;
f{3}.N=N;      f{3}.D=[1];
f{4}.N=N(1:3); f{4}.D=D;
f{5}.N=N;      f{5}.D=D(1:3);

tol=1e-8;
del=1e-6;

for k=1:length(f)
  
  printf("k=%d\n",k);
  printf("N=");
  disp(f{k}.N);
  printf("D=");
  disp(f{k}.D);

  [A,b,c,d]=tf2Abcd(f{k}.N,f{k}.D)
  [~,~,~,~,dAdx,dbdx,dcdx,dddx]=tf2Abcd(f{k}.N,f{k}.D)

  deln=zeros(size(f{k}.N));
  deln(1)=del/2;
  for l=1:length(f{k}.N)
    [AP,bP,cP,dP]=tf2Abcd(f{k}.N+deln,f{k}.D);
    [AN,bN,cN,dN]=tf2Abcd(f{k}.N-deln,f{k}.D);
    deln=circshift(deln,1);
    est_dAdx=(AP-AN)/del;
    if max(abs(abs(est_dAdx-dAdx{l}))) > tol
      error("max(abs(abs(est_dAdx-dAdx{l}))) > tol");
    endif
    est_dbdx=(bP-bN)/del;
    if max(abs(est_dbdx-dbdx{l})) > tol
      error("max(abs(est_dbdx-dbdx{l})) > tol");
    endif
    est_dcdx=(cP-cN)/del;
    if max(abs(est_dcdx-dcdx{l})) > tol
      error("max(abs(est_dcdx-dcdx{l})) > tol");
    endif
    est_dddx=(dP-dN)/del;
    if max(abs(est_dddx-dddx{l})) > tol
      error("max(abs(est_dddx-dddx{l})) > tol");
    endif
  endfor

  deld=zeros(size(f{k}.D));
  deld(2)=del/2;
  for l=1:(length(f{k}.D)-1)
    [AP,bP,cP,dP]=tf2Abcd(f{k}.N,f{k}.D+deld);
    [AN,bN,cN,dN]=tf2Abcd(f{k}.N,f{k}.D-deld);
    deld=circshift(deld,1);
    est_dAdx=(AP-AN)/del;
    if max(abs(abs(est_dAdx-dAdx{length(f{k}.N)+l}))) > tol
      error("max(abs(abs(est_dAdx-dAdx{length(f{k}.N)+l}))) > tol");
    endif
    est_dbdx=(bP-bN)/del;
    if max(abs(est_dbdx-dbdx{length(f{k}.N)+l})) > tol
      error("max(abs(est_dbdx-dbdx{length(f{k}.N)+l})) > tol");
    endif
    est_dcdx=(cP-cN)/del;
    if max(abs(est_dcdx-dcdx{length(f{k}.N)+l})) > tol
      error("max(abs(est_dcdx-dcdx{length(f{k}.N)+l})) > tol");
    endif
    est_dddx=(dP-dN)/del;
    if max(abs(est_dddx-dddx{length(f{k}.N)+l})) > tol
      error("max(abs(est_dddx-dddx{length(f{k}.N)+l})) > tol");
    endif
  endfor
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
