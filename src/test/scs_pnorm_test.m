% scs_pnorm_test.m
% Modified from SCS run_pnorm_ex.m

test_common;

strf="scs_pnorm_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

n = 1000;
m = ceil(n/2);
density = 0.1;

randn("seed",0xBAADC0DE);
rand("seed",0xDEADBEEF);

pow = pi;
G = sprandn(m,n,density);
f = randn(m,1) * n * density;

%% scs, with power cone formulation
Anz = nnz(G) + n + 1 + 3*n;
data.A = sparse([],[],[],m+3*n,2*n+1,Anz);
data.A(1:m+1,:) = [G sparse(m,n) sparse(m,1); ...
                   sparse(1,n) ones(1,n) -1];
for k=1:n
  ek = sparse(n,1);
  ek(k) = -1;
  data.A(m+1+(k-1)*3+1:m+1+k*3,:) = [sparse(1,n), ek', 0; ...
                                     sparse(1,2*n), -1; ...
                                     ek', sparse(1,n), 0];
end
data.c = [zeros(2*n,1); 1];
data.b = [f; 0 ; zeros(3*n,1)];
K = struct("z", m+1, "p", ones(n,1) / pow);

params.eps = 1e-3;
params.scale = 1;
params.cg_rate = 1.5;

[dir_x_scs,dir_y_scs,dir_s_scs,dir_info] = scs_direct(data, K, params);
[indir_x_scs,indir_y_scs,indir_s_scs,indir_info] = scs_indirect(data, K, params);

% Save 
print_polynomial(dir_info.pobj,"dir_info.pobj","%10.7f");
print_polynomial(dir_info.pobj,"dir_info.pobj", ...
                 strcat(strf,"_dir_info_pobj_coef.m"),"%10.7f");
print_polynomial(indir_info.pobj,"indir_info.pobj","%10.7f");
print_polynomial(indir_info.pobj,"indir_info.pobj", ...
                 strcat(strf,"_indir_info_pobj_coef.m"),"%10.7f");

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
