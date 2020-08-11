function printSolutionL(fileId,printLevel,POP,exitflag,output,options,objLBD)
 %
    % printSolutionL
    % prints solutions obtained by fmincon or fminunc
    %
    % Usage:
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fileId: the file ID where output goes. If this is 1, then the output is
    %       the standard output (i.e., the screen). Default is 1.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % none

    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This file is a component of SparsePOP 
    % Copyright (C) 2007 SparsePOP Project
    %
    % This program is free software; you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation; either version 2 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with this program; if not, write to the Free Software
    % Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %

    % if ~isempty(ineqPolySys)
    %     [infeasError,scaledError] = infeasibility2(ineqPolySys,POP.xVectL);
    %     POP.scaledErrorL = scaledError; 
    %     POP.absErrorL = infeasError; 
    % else
    %     POP.scaledErrorL = 0; 
    %     POP.absErrorL = 0; 
    % end    

    if ~isempty(options) && isfield(options,'Display') && strcmp(options.Display,'off')
        fprintf(fileId,'\n%s\n\n',output.message); 
    end
    if isfield(output,'algorithm')
        fprintf(fileId,'## Computational Results by %s method\n',output.algorithm); 
    elseif isfield(exitflag,'algorithm')
        fprintf(fileId,'## Computational Results by %s method\n',exitflag.algorithm); 
    end
    fprintf(fileId,'   with the initial solution obtained by the SDP relaxation ##\n');
    % if ~isempty(options)
    %     if isfield(options,'TolFun')
    %         fprintf(fileId,'  TolFun              = %8.3e\n',options.TolFun);
    %     end
    %     if isfield(options,'TolX')
    %         fprintf(fileId,'  TolX                = %8.3e\n',options.TolX);
    %     end
    %     if isfield(options,'TolCon')
    %         fprintf(fileId,'  TolCon              = %8.3e\n',options.TolCon);
    %     end
    % end
    if isfield(output,'algorithm')
        fprintf(fileId,'  exitflag            =  %5d\n',exitflag); 
        fprintf(fileId,'  iterations          =  %5d\n',output.iterations);
        fprintf(fileId,'  elapsed time        =  %8.2f\n',output.cputime);
        fprintf(fileId,'# Approximate optimal value information:\n'); 
        fprintf(fileId,'  POP.objValueL       = %+13.7e\n',POP.objValueL);
    elseif isfield(output,'Algorithm')
        if isfield(exitflag,'stepsize') 
            fprintf(fileId,'  the last step       =  %8.3e\n',exitflag.stepsize); 
        end
        fprintf(fileId,'  iterations          =  %5d\n',exitflag.iterations);
        fprintf(fileId,'  elapsed time        =  %8.2f\n',exitflag.cputime);
        fprintf(fileId,'# Approximate optimal value information:\n'); 
        fprintf(fileId,'  POP.objValueL       = %+13.7e\n',POP.objValueL);
    end
    if exist('objLBD') && ~isempty(objLBD)
        relobj = abs(POP.objValueL-objLBD)/max([1,abs(POP.objValueL)]);
        fprintf(fileId,'  relative obj error  = %+8.3e\n',relobj);
    end
    % if ~isempty(strfind(output.algorithm,'interior-point')) || ~isempty(strfind(output.algorithm,'active-set'))
    %     fprintf(fileId,'  constr violation    = %+8.3e\n',output.constrviolation);
    % end
    fprintf(fileId,'  POP.absErrorL       = %+8.3e\n',full(POP.absErrorL));
    fprintf(fileId,'  POP.scaledErrorL    = %+8.3e\n',full(POP.scaledErrorL));
    % fprintf(fileId,'  first order opt     = %+8.3e\n',output.firstorderopt);
    fprintf(fileId,'# Approximate optimal solution information:\n');
    if printLevel >= 2
        fprintf(fileId,'  POP.xVectL = ');
        lenOFx = length(POP.xVectL);
        k = 0;
        for j=1:lenOFx
            if mod(k,5) == 0
                fprintf(fileId,'\n  ');
            end
            k = k+1;
            fprintf(fileId,'%4d:%+13.7e ',j,POP.xVectL(j));
        end
        fprintf(fileId,'\n');
    end
end
