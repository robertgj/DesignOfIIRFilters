function test20090706(filename)

param.SDPsolver = 'sdpa';
%param.SeDuMiSW = 0;

param.mex=1;
param.relaxOrder=2;
sparsePOP(filename,param);

param.SeDuMiOutFile = 1;
param.mex=1;
param.relaxOrder=2;
sparsePOP(filename,param);

param.sdpaDataFile = 'test20090706_mex1_out0.dat-s';
%param.SeDuMiOutFile = 'temp_SDPA.out';
param.SeDuMiOutFile = 1;
param.mex=1;
param.relaxOrder=2;
sparsePOP(filename,param);

param.sdpaDataFile = 'test20090706_mex1_out1.dat-s';
%param.SeDuMiOutFile = 'temp_SDPA.out';
param.SeDuMiOutFile = 1;
param.mex=1;
param.relaxOrder=2;
sparsePOP(filename,param);


param.sdpaDataFile = 'test20090706_mex0_out0.dat-s';
%param.SeDuMiOutFile = 'temp_SDPA.out';
param.SeDuMiOutFile = 1;
param.mex=0;
param.relaxOrder=2;
sparsePOP(filename,param);

param.sdpaDataFile = 'test20090706_mex0_out1.dat-s';
%param.SeDuMiOutFile = 'temp_SDPA.out';
param.SeDuMiOutFile = 1;
param.mex=0;
param.relaxOrder=2;
sparsePOP(filename,param);

return

