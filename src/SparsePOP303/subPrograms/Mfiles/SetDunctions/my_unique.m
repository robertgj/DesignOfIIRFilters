function [C,ia,ic] = my_unique(A, occurrence);
%
% This is function for using unique of version R2012b. 
% 
%

if exist('verLessThan') ~= 2
    error('Get verLessThan.m');
end

if verLessThan('matlab', '8.1.0')
% -- Put code to run under MATLAB 8.1.0 and earlier here --
else
% -- Put code to run under MATLAB 7.0.1 and later here --
end

if verLessThan('matlab', '7.3')

unique(A,occurrence,'legacy') 
