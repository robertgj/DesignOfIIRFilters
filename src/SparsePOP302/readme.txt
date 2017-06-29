SparsePOP
(A Sparse SemiDefinite Programming Relaxation of 
Polynomial Optimization Problems)

Hayato Waki, Sunyoung Kim, Masakazu Kojima, 
Masakazu Muramatsu, Hiroshi Sugimoto and Makoto Yamashita

----------------------------------------
Index

1. Overview
2. System Requirements
3. Installation Guide
4. Usage of SparsePOP
5. Acknowledgements
6. License
7. E-mail address
8. History

----------------------------------------


1. Overview

SparesPOP is a MATLAB package for a sparse semidefinite 
programming (SDP) relaxation method for approximating a 
global optimal value and solution of a polynomial optimization 
problem (POP) proposed by Waki et al. The sparse SDP relaxation 
exploits a sparse structure of polynomials in POPs when applying 
"a hierarchy of LMI relaxations of increasing dimensions" by 
Lasserre. The efficiency of SparsePOP to approximate optimal 
solutions of POPs is thus increased, and larger scale POPs can 
be handled. 

Two versions of SparsePOP are available in this package:
   (A) MATLAB only version
   (B) MATLAB with C++ version
(A) will always be installed, while (B) is optional.

The functions and capabilities of the two versions are identical. 
Some of time-consuming parts of (B) is coded in C++, thus, it is
faster in generating SDP problems than (A). We recommend to use (B)
whenever possible, although in many cases (A) is sufficient.


2. System Requirements

The following software packages are required for SparsePOP.

  i. MATLAB R2009b or later for Mac OSX
     MATLAB R2008a or later for Linux

  ii. SeDuMi, SDPT3, SDPA or CDP
	 to call SeDuMi from SparsePOP for solving an SDP relaxation problem


If you want to use (B), then you need appropriate C++ compilers,
compatible with MATLAB, to compile the programs.

NOTE: If Symbolic Math Toolbox is available on your computer, 
SparsePOP can handle a gms file which contains parentheses, 
e.g. Bex2_1_2.gms.

NOTE2: If Optimization Toolbox 4.0 or later is available on your 
computer, you can refine approximated solutions of SparsePOP by 
using some functions in Optimization Toolbox. See  Section 3.4 in 
User Manual for more detail. 

NOTE3: We recommend to install Xcode to compile mex files if 
you use SparsePOP on Mac OSX. In particular, llvm-gcc and llvm-g++
in Xcode are available for compiling mex files in SparsePOP. See the 
following webpage for the detail: 
http://www.mathworks.com/matlabcentral/answers/103258-mex-on-mavericks-with-r2012b  

NOTE4: SeDuMi in Github (2014-08-14) has two bugs to use it.  We list 
two modifications of SeDuMi: 
(1) Remove % in the head of the 792nd line in sedumi.m
(2) Replace the 77th line in eigK.m by 
    lab(li+1:li+nl) = x(xi+1:xi+nl);


3. Installation Guide

See install.txt in the top directory of SparsePOP. After installing 
SparsePOP, add the path of SparsePOP in your MATLAB search path. 
	

4. Usage of SparsePOP

We assume that SDPA and/or SeDuMi have been already installed on 
your computer and that the paths of SparsePOP, their folders and 
subfolders have been already added in your Matlab search path.

The usage of SparsePOP is explained in the user manual in the 
top directory of SparsePOP. 


5. Acknowledgments

The authors are grateful to Dr. Mevissen Martine,  
Mr. Dan Gugenheim, Mr. Victor Magron, Dr. Hanne Ackermann  
and Mr. Ye Wang for bug reports.


6. License

This software is distributed under GNU General Public License 2.0


7. E-mail address

kojima-spop@is.titech.ac.jp

Please send a message if you have any questions, ideas, or 
bug reports.


8. History
Version 3.02 (December 30, 2016)
(1) Modified readGMS.m to deal with gms file which contains some 
white spaces.  

(2) Modified readGMS.m to deal with gms file which contains 
parenthesises. 

Version 3.01 (October 10, 2015)
(1) SparsePOP automatically adds the paths of the directory and 
subdirectories.  


Version 3.00 (September 30, 2014)
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
** is set. We recommend to use this parameter for small POPs with    **
** the number of variables involved in POP up to 70.                 **

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
** and 3.                                                           ** 
** param.sparseSW = 2 for a smaller SDP relax. based on Lasserre    **
** param.sparseSW = 3 for a smaller SDP relax. based on Sparse SDP  **
** relaxation.                                                      **

(6) Fix bugs reported by users


Version 2.99 (February 15, 2012)
(1) SparsePOP can be compiled by mex on Windows 7 with Visual Stadio 2010.

(2) Some elements of the structure SDPinfo returned 
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

(5) symamd in SDPrelaxationMex.m returns a segmentation fault for a POP with 
unused variables. We fixed this bug. 


Version 2.98 (December 15, 2011)
(1) Fixed a bug in readGMS.m. The previous version could not read 
the monomials which are located after the keyword ``objvar". 

(2) Fixed a bug in deleteVar.m. The previous version might substitute 
some fixed values incorrectly for POPs whose lower and upper bounds are 
identical. 

(3) Some functions for scaling POPs with polynomial sdp constraints 
do not work in the current version.

(4) SparsePOP with param.mex=1 returns the same format as param.mex=0 
when users set param.detailedInfFile.


Version 2.97 (September 30, 2011)
(1) Fixed a bug in substituteEq.m. 

(2) Improved output of information on SDPNAL in solveBySDPNAL.m
and SDPT3 in solveBySDPT3.m. 


Version 2.96 (August 31, 2011)
(1) Fixed bugs in compileSparsePOP.m and gen_basisindecies 
in conversion.cpp. 

(2) Improved the part of checking the linear independency of 
the coefficient matrix A. 


Version 2.95 (July 30, 2011)
(1) For POPs which have constraints "x in {0,1}" and/or 
"x in {-1, +1}", SparsePOP can reduce the size of the 
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


Version 2.90 (June 21, 2011)
(1) SparsePOP can read the reserved keyword "maximizing objvar"
and "binary variables". 

If an input file contains the keyword "maximizing objvar", 
then SparsePOP deals with the POP as the maximization problem. 
In addition, if an input file contains the keyword 
"binary variables", then SparsePOP adds the polynomial 
equality x(i)^2 -x(i) = 0 in the original POP for such variables x(i).

(2) Some gams files in GLOBAL Library are added in the directory 
example/GMSformat. 

(3) In the case where some variables in SDP relaxation problem 
corresponding to variables in a given POP are removed by 
setting param.reduceMomentMatSW = 1, SparsePOP returns only 
the optimal value of the resulting SDP relaxation problem. 
(In the previous version, for such a POP, SparsePOP did not 
solve the SDP relaxation problem.) 

(4) Some bugs are fixed.


Version 2.85 (May 23, 2011)
(1) Some bugs in C++ files are fixed.
The latest sparsepop can handle POPs which contain polynomial 
matrix inequalities by setting param.mex = 1.  


Version 2.80 (Feburary 7, 2011)
(1)  Users can use SDPA, SeDuMi, SDPT3, CSDP and SDPNAL for solving
SDP relaxation problems. Users can tune up paramters of the SDP
solvers by editing files in the subdirectory 
SparsePOP280/subPrograms/Mfiles/Solvers.
(2) Small bugs in C++ files are fixed.


Version 2.60 (May 9, 2010)
(1) Add some functions for computing error bounds based on the paper 

M. Kojima and M. Yamashita, "Enclosing Ellipsoids and Elliptic 
Cylinders of Semialgebraic Sets and Their Application to Error
Bounds in Polynomial Optimization", November 2009.


Version 2.50 (March 30, 2010)
(1) readGMS.m can print lucid error messages for some incorrect 
gms files.
(2) The directory example/SDPAformat is removed.
(3) Some bugs are fixed.


Version 2.20 (August 20, 2009)
(1) Users can use SDPA instead of SeDuMi for solving an SDP 
relaxation problem.  See `readmeRevision.txt' for more detail.


Version 2.15 (June 22, 2009)
(1) The function for writing an SDP as the sdpa sparse 
format is modified and included into the function 
solveBySeDuMi.m

(2) SparsePOP outputs a file which contains information 
on scaling for a given POP. See `readmeRevision.txt' for 
more detail.


Version 2.10 (April 3, 2009)
(1) SparsePOP can accept a new input format for a 
constrained nonlinear least square problem.  
(2) To refine approximated solution obtained by SparsePOP, 
users can call some functions in Optimization Toolbox. See 
`readmeRevision.txt' for more detail.


Version 2.00 (June, 2007)
(1) For speedup, C++ subroutines are developed. 
(2) The second version (B) of SparsePOP are added in 
SparsePOP.
(3) Improve user interface.
(4) Some bugs are fixed.

Version 1.20 (September, 2005)
