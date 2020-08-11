What is new in SparsePOP303?
                                                       September 11, 2018
(1) Modified sdpSolve.m and m-files in Solvers. 

(2) Modified readGMS.m. 

(3) SDPNAL++ is available to solve the generated SDP 
relaxation problems. Recommend MATLAB R2014b or later. 

---
What is new in SparsePOP302?
                                                       December 30, 2016
(1) Modified readGMS.m to deal with gms file which contains some white
spaces.  

(2) Modified readGMS.m to deal with gms file which contains 
parenthesises. 

---
What is new in SparsePOP301?
                                                        October 10, 2015
(1) SparsePOP automatically adds the paths of the directory and 
subdirectories.  

---
What is new in SparsePOP300?
                                                       September 30, 2014
(1) SparsePOP returns a lucid message when it cannot allocate 
an array due to the integer overflow.

(2) Modified simplifyPolynomial.m. Since output of built-in function 
`unique' in  MATLAB changed from R2013a or later, this function returned 
a wrong result. 

(3) Implemented a reduction method described in the following paper: 
``AN EXTENSION OF THE ELIMINATION METHOD FOR A SPARSE SOS POLYNOMIALby 
H. Waki and M. Muramatsu''
This method works in only MATLAB by setting param.reduceMomentMatSW = 2. 

** This method works in only MATLAB when param.reduceMomentMatSW = 2 **
** is set. Not implemented by C++. We recommend to use this parameter**
** for small POPs with the number of variables involved in POP up to **
** 70.                                                               **

(4) Add a parameter for reducing the moment matrices more aggressively. 
Any candidate for solution of POP may not be retrieved, while a smaller
SDP relaxation problems may be obtained. In fact, this reduction may be
remove some SDP variables which correspond to variables in the original
POP.  

** This reduction works in both MATLAB and C++ when                 **
** param.aggressiveSW = 1                                           **
** Combining param.reduceMomentMatSW = 1 or 2 with this, a much     **
** smaller SDP relaxation may be obatined.                          **

(5) Implemented an SDP relaxation described in the following paper: 
``A Perturbed Sums of Squares Theorem for Polynomial Optimization and 
its Applications by H. Waki, M. Muramatsu and L. Tuncel''

** This method works in only MATLAB by setting param.sparseSW = 2   **
** and 3. Not implemented by C++                                    ** 
** param.sparseSW = 2 for a smaller SDP relax. based on Lasserre    **
** param.sparseSW = 3 for a smaller SDP relax. based on Sparse SDP  **
** relaxation.                                                      **

(6) Fix bugs reported by users

---
What is new in SparsePOP299?
                                                         February 15, 2012
(1) SparsePOP can be compiled by mex on Windows 7 with Visual Stadio 2010.

(2) Some elements of the structure `SDPinfo' returned 
from SDPrelaxation.m and SDPrelaxationMex.m are changed:
[Add] 
SDPinfo.SeDuMiA: the coefficient matrix A in the SDP with the SeDuMi format
SDPinfo.SeDuMib: the coefficient vector b in the SDP with the SeDuMi format
SDPinfo.SeDuMic: the objective vector c in the SDP with the SeDuMi format
SDPinfo.SeDuMiK: the cone K in the SDP with the SeDuMi format
SDPinfo.objeConstant: trans.objVonstant
SDPinfo.objValScale: trans.objValScale
SDPinfo.Amat: trans.Amat
SDPinfo.bVect: trans.bVect
[Delete]
SDPinfo.K, SDPinfo.A, SDPinfo.b, SDPinfo.c, SDPinfo.K.f, SDPinfo.J.

(3) We checked that SparsePOP can be compiled under a Windows machine with 
Microsoft Visual C++ 7.0 or later.

(4) The previous version of readGMS.m recognized the expression `+ - 0.5' 
as 0.5, not -0.5. We fixed this bug. The current version read it as `-0.5'.
In addition, we changed the number of digit for vpa. 

(5) symamd in SDPrelaxationMex.m returns a segmentation fault for a POP with 
unused variables. We fixed this bug. 

---
What is new in SparsePOP298?
                                                          December 15, 2011
(1) Fixed a bug in readGMS.m. The previous version could not read 
the monomials which are located after the keyword ``objvar". 

(2) Fixed a bug in deleteVar.m. The previous version might substitute 
some fixed values incorrectly for POPs whose lower and upper bounds are 
identical. 

(3) Some functions for scaling POPs with polynomial sdp constraints 
do not work in the current version.

(4) SparsePOP with param.mex=1 returns the same format as param.mex=0 
when users set param.detailedInfFile.

---
What is new in SparsePOP297?
                                                          September 30, 2011
(1) Fixed a bug in substituteEq.m. 

(2) Improved output of information on SDPNAL in solveBySDPNAL.m
and SDPT3 in solveBySDPT3.m. 

---
What is new in SparsePOP296?
(1) Fixed bugs in compileSparsePOP.m and gen_basisindecies 
in conversion.cpp. 

(2) Improved the part of checking the linear independency of 
the coefficient matrix A. 

---
What is new in SparsePOP295?
                                                            July 30, 2011
(1) For POPs which have constraints "x in {0,1}" and/or 
"x in {-1, 1}", SparsePOP can reduce the size of the 
resulting SDP relaxation problem by exploiting their 
constraints. This reduction is based on the following paper:

J.B.Lasserre, "An explicit equivalent positive semidefinite
program for nonlinear 0-1 programs", SIAM J.Optim., 12, 
pp. 756--769.

* For the reduction for a POP which has constraint "x in {0, 1}",
  set param.binarySW = 1. 
* For the reduction for a POP which has constraint "x in {-1, +1}",
  set param.SquareOneSW = 1. 
However, these reductions do not work when user computes error 
bounds of an approximated solution obtained by SparsePOP.

(2) The reductions executed by reduceMomentMatSW = 1 and/or  
reduceAMatSW = 1 work when user computes error bounds of an 
approximated solution obtained by SparsePOP.

(3) We move "class pop_params" from conversion.h into Parameters.h.

(4) Some bugs are fixed.

----
What is new in SparsePOP290?
                                                            June 21, 2011

(1) SparsePOP can read the reserved keyword "maximizing objvar" 
and "binary variables". 

If an input file contains the keyword "maximizing objvar", 
then SparsePOP deals with the POP as the maximization problem. 
In addition, if an input file contains the keyword "binary variables", 
then SparsePOP adds the polynomial equality x(i)^2 -x(i) = 0 in 
the original POP for such variables x(i).

(2) Some gams files in GLOBALLIB are added in the directory 
example/GMSformat. 

(3) In the case where some variables in SDP relaxation problem 
corresponding to variables in a given POP are removed by 
setting param.reduceMomentMatSW = 1, SparsePOP returns only 
the optimal value of the resulting SDP relaxation problem. 
(In the previous version, for such a POP, SparsePOP did not 
solve the SDP relaxation problem.) 

(4) Some bugs are fixed.

----
What is new in SparsePOP285?
                                                            May 23, 2011

(1) Some bugs in C++ files are fixed. 

The latest sparsepop can handle POPs which contain polynomial matrix 
inequalities by setting param.mex = 1.  

----
What is new in SparsePOP280?
                                                            Feburary 7, 2011

(1) Users can solve SDP relaxation problems by the following SDP solvers:
SeDuMi
SDPA
SDPT3
CSDP
SDPNAL

User can controll parameters of these SDP solvers by editing files in the
subdirectory subPrograms/Mfiles/Solvers. For instance, if users want to
change parameters of SeDuMi, edit solverBySeDuMi.m.

(2) Small bugs in C++ files are fixed.

----
What is new in SparsePOP260?
                                                              May 9, 2010

(1) Computing error bounds based on the paper 

M. Kojima and M. Yamashita, "Enclosing Ellipsoids and Elliptic Cylinders
of Semialgebraic Sets and Their Application to Error Bounds in Polynomial 
Optimization", November 2009. 

The user can specify the set of indices of variables whose values are to 
be checked in the new parameter param.errorBdIdx. 
  (a) If param.errorBdIdx = 'a' or 'A' then sparsePOP outputs xCenter and 
      zeta such that 
          ||x - xCenter|| <= sqrt(zeta)
      for every feasible solution of the POP with an objective value, 
      where the objective value is either the one given by
      param.fValueUbd, the one computed by the param.POPsolver, or the one 
      computed by the param.SDPsolver.  
  (b) If param.errorBdIdx = indexSet, then sparsePOP outputs xCenter 
      and zeta such that 
          ||x(indexSet) - xCenter(indexSet)|| <= sqrt(zeta)
      for every feasible solution x of the POP with an objective value, 
      where the objective value is either the one given by
      param.fValueUbd, the one computed by the param.POPsolver, or the one 
      computed by the param.SDPsolver.  For example, 
      param.errorBdIdx = 1, param.errorBdIdx = [1,3,5], 
      param.errorBdIdx = [2:10]. 
  (c) The user can specify multiple index sets. For example, 
      param.errorBdIdx{1} = 'a'; 
      param.errorBdIdx{2} = 1;
      param.errorBdIdx{3} = [2,3]; 

!! This new feature is available only for the mex version of SparsePOP !!

----
What is new in SparsePOP250?
                                                              March 30, 2010

(1) readGMS.m can print lucid error messages for some incorrect gms files.

(2) The directory example/SDPAformat is removed.

(3) Some bugs are fixed.

----
What is new in SparsePOP220?
                                                        August 20, 2009

(1) SDPA can be used to solve the SDP relaxation problem by setting a new 
parameter param.SDPsolver = 'sdpa'. The default is param.SDPsolver = 'sedumi',
which indicates that SeDuMi will be used to solve the SDP relaxaion problem. 
 

(2) Additional installation to use the SDPA

----
What is revised in SparsePOP215?  
                                                         June 22, 2009

(1) The function for writing an SDP in the sdpa sparse format is modified 
    and included in the function solveBySeDuMi.m

(2) If param.scalingSW = 1 and param.sdpaDataFile is not empty, then 
    SparsePOP generates a file with "info" extension. This file contains
    three columns for information on scaling for a given POP.
    One can retrieve a solution of the original POP from a solution of 
    the scaled POP, which is generated by SparsePOP, by using this file.

    The first column is an index of variables in the POP.
    The second and third colmuns indicate coefficients for scaling. 

    For example, assume that this file has the following three columns:
    
    1   0.50000     4.0000
    2   -2.00000    0.7000
    3   -0.50000    1.0000
    4   1.00000     0.0000

    If z is obtained as a solution of the scaled POP, x can be computed
    as follows: 

    x(1) = 0.50000*z(1) + 4.0000,
    x(2) =-2.00000*z(2) + 0.7000,
    x(3) =-0.50000*z(3) + 1.0000,  
    x(4) = 1.00000*z(4) + 0.0000,

----
SparsePOP210: a revision of SparsePOP200
                                                         April 3, 2009

(1) Input for nonlinear least square problem. The user can represent a 
constrained nonlinear least square problem 
  minimize    \sum_{j=1}^m f_j(x)^2
  subject to  g_k(x) >= 0 (or = 0) (k=1,2,...,m), lbd_i <= x_i <= ubd_i
in the SparsePOP format. Each function f_j in the objective function is
described in terms of objPoly{j}, while the constraint of the problem in
terms of ineqPolySys, lbd and ubd in the same way as a nominal POP. 
When size(objOpt,2) >= 2, the sparsePOP automatically regards that the 
given problem is a nonlinear least square problem, and applies the 
sparse/dense SDP relaxation to it. For example,
>> sparsePOP('BroydenTriLS.m');  

(2) Refinement of solutions by local optimization methods. Optimization 
Toolbox is necessary to use this feature. The new version incorporated 
MATLAB functions 
    fmincon, fminunc and lsqnonlin in Optimization Toolbox, 
so that the user can refine the solution obtained from the sparse/dense SDP 
relaxation by setting the parameter 
    param.POPsolver = 'active-set';
    param.POPsolver = 'interior-point';
    param.POPsolver = 'trust-region-reflective'; or
    param.POPsolver = 'lsqnonlin';
The former three methods are for general polynomial optimization problems, 
while the last 'lsqnonlin' is valid only for polynomial least square problems 
with bounded variables and no equality/inequality constraints; 
        size(objPoly,2) >= 2 and ineqPolySys =[]. 
For example,  
>> param.POPsolver = 'active-set';
>> sparsePOP210('example1.gms',param);
to apply fmincon with 'active-set' method. Or
>> pram.POPsolver = 'lsqnonlin';
>> sparsePOP210('BroydenTriLS(10)',param); 
to apply lsqnonlin to the nonlinear least square problem 'BroydenTriLS(10)'
with bounds. 

(3) function [x,fval,exitflag,output] ...
    = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0,options);
The user can use POPfmincon.m as standalone MATLAB progams to solve a POP 
in the SparsePOP format. Optimization Toolbox is necessary to utilize this 
feature. There are two ways of using POPfmincon.m. The one is: 
>> POPfmincon('DataFile)'), 
where DataFile) is a file name of a POP in the gms format or the SparsePOP 
format. For example, 
>> [x,fval,exitflag,output] = POPfmincon('example1.gms');
Here x is the approximate optimal solution computed and fval the objective 
function value at x. exitflag and output are output arguments from fmincon. 
The user can specify an initial point x0 and options for fmincon;
>> x0 = ones(10,1); 
>> [x,fval,exitflag,output] = POPfmincon('example1.gms',x0);
>> options = optimset('Algorithm','active-set','GradObj','on',...
            'GradConstr','on','HessFcn',@hessianfcn,'Display','iter');
>> [x,fval,exitflag,output] = POPfmincon('example1.gms',x0,options); 
The user can choose 'active-set', 'trust-region-reflective' or 'interior-point' 
for the option Algorithm. The function can process a polynomial least square 
problem with inequality/equality constraints and bounds described in the 
SparsePOP format. See (1) above. For example, 
>> x0 = ones(10,1); 
>> [x,fval,exitflag,output] = POPfmincon('BroydenTriLS(10)',x0);
The other way is: 
>> [x,fval,exitflag,output]  = POPfmincon(objPoly,ineqPolySys,lbd,ubd);
>> [x,fval,exitflag,output]  = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0);
or 
>> [x,fval,exitflag,output]  = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0,options);
See the help on fmincon for detais of exitflag, output and options.  

(4) function [x,fval,exitflag,output] = POPlsqnonlin(LSobjPoly,lbd,ubd,x0,options)
The user can use POPlsqnonlin.m as standalone MATLAB programs to solve a polynomial 
least square problem with bounds in the SparsePOP format. If the problem involves 
equality/inequality constraits besides bounds, i.e., inequPolySys is nonempty,  
then use POPfmincon above. Optimization Toolbox is necessary to utilize this 
feature. There are two ways of using POPlsqnonlin.m. The one is: 
>> POPlsqnonlin('DataFile'), 
where DataFile is a file name of a polynomial least square problem POP in 
the SparsePOP format; the gms formt file is not available. For example, 
>> [x,fval,exitflag,output] = POPlsqnonlin('BroydenTriLS(12)');
Here x is the approximate optimal solution computed and fval the objective 
function value at x. exitflag and output are output arguments from lsqnonlin. 
The user can specify an initial point x0 and options for lsqnonlin;
>> x0 = ones(10,1); 
>> [x,fval,exitflag,output] = POPlsqnonlin('BroydenTriLS(12)',x0);
>> options = optimset('Jacobian','on','Display','iter');
>> [x,fval,exitflag,output] = POPfmincon('example1.gms',x0,options); 
See the help on lsqnonlin for detais of exitflag, output and options. 

----
SparsePOP200: a revision of SparsePOP120

1) C++ subroutines can be used to speedup the construction of a 
sparse SDP relaxation problem from a given a sparse polynomial optimization  
problem.

2) Two kinds of SparsePOP are included: A set of MATLAB programs combined
with C++ subroutines and a set of all MATLAB programs. 
Input and output are same for both SparsePOPs, and they construct the 
same SDP relaxation problem from a polynomial optimization problem.

3) User interface is improved. 
