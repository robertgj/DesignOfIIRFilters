function [C, ia, ic] = my_unique(A, msg)
if ~strcmp(msg, 'rows');
	error('msg should be rows in my_unique.');
end

% For Octave:
[C, ia, ic] = unique(A,msg);

% For matlab:
%{ 
 if verLessThan('matlab', '8.0.1')
    % This part is the same as unique in R2012b or earlier version
    [C, ia, ic] = unique(A, msg);
@@ -10,4 +16,6 @@
    % We use legacy mode of unique.
    [C, ia, ic] = unique(A, msg, 'last', 'legacy');
 end
%}

return
