/* -------------------------------------------------------------
 *
 * This file is a component of SparsePOP
 * Copyright (C) 2007-2011 SparsePOP Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 * ------------------------------------------------------------- */

#ifndef _PARAMETERS_
#define _PARAMETERS_

#include "global.h"

//function that reads the parameter file
//bool input_params(class pop_params & params);

class pop_params{
public:
	//See defaultParamters.m for more details
	//1. Paramters to control the basic relaxation scheme.
	int relax_Order;	//RelaxOrder
	int sparseSW;
	double multiCliquesFactor;
	//2. Switch to handle numerical difficulties.
	int scalingSW;
	int boundSW;
	double eqTolerance;
	double perturbation;
	int reduceMomentMatSW;
	int complementaritySW;
	int SquareOneSW;
	int binarySW;
	int reduceAMatSW;
	//3. Parameters for SDP solvers.
	int SeDuMiSW;
	double SeDuMiEpsilon;
	string SeDuMiOutFile;
	int SeDuMiOnScreen;// This variable is not defined in defaultParameters.
	int SDPsolverSW;
	string SDPsolver;
	double SDPsolverEpsilon;// The default value is 1.0e-7. This is different from matlab version of SparsePOP.
	string SDPsolverOutFile;
	int SDPAOnScreen; // This variable is not defined in defaultParameters. For only SparsePOPC++
	string sdpaDataFile; //name of file to write SDPA sparse format
	//4. Parameters for printing numerical results.
	string detailedInfFile; //name of file to write information of POP
	string printFileName;
	int printOnScreen;// This variable is not defined in defaultParameters.
	int printLevel1;// The first component of printLevel defined in defualtParameters.
	int printLevel2;// The second component of printLevel defined in defaultParameters.
	//5. Parameters to use Symbolic Math Toolbox, Opt. Toolbox and C++ subroutines. 
	int symbolicMath;
	string POPsolver;
	int mex;
	//6. Parameters of error bounds 
	int errorBdIdxSW;
	vector<int> errorBdIdxVec;
	//7. This variable is only used for SparsePOPC++. 
	string Method;
	//8. Paramters for developers of SparsePOP.
	int aggressiveSW;
	
	//Functions
	pop_params();
	void disp_parameters();
	void write_parameters(string fname);
	#ifdef MATLAB_MEX_FILE
	/* functions for converting MATLAB into Ç++ */
	void   mxSetParameters(const mxArray *data);
	void   mxSetRelaxOrder(const mxArray *data);
	void   mxSetSparseSW(const mxArray *data);
	void   mxSetMultiCF(const mxArray *data);
	void   mxSetScalingSW(const mxArray *data);
	void   mxSetBoundSW(const mxArray *data);
	void   mxSetEqTolerance(const mxArray *data);
	void   mxSetPerturbation(const mxArray *data);
	void   mxSetReduceMomentMatSW(const mxArray *data);
	void   mxSetComplementaritySW(const mxArray *data);
	void   mxSetSquareOneSW(const mxArray *data);
	void   mxSetBinarySW(const mxArray *data);
	void   mxSetReduceAMatSW(const mxArray *data);
	void   mxSetSeDuMiSW(const mxArray *data);
	void   mxSetSeDuMiEpsilon(const mxArray *data);
	void   mxSetSeDuMiOutFile(const mxArray *data); 
	void   mxSetSeDuMiOnScreen(const mxArray *data);
	void   mxSetSDPsolverSW(const mxArray *data);
	void   mxSetSDPsolver(const mxArray *data); 
	void   mxSetSDPsolverEpsilon(const mxArray *data);
	void   mxSetSDPsolverOutFile(const mxArray *data); 
	void   mxSetSDPAOnScreen(const mxArray *data);
	void   mxSetDetailedInfFile(const mxArray *data); 
	void   mxSetSdpaDataFile(const mxArray *data); 
	void   mxSetPrintOnScreen(const mxArray *data);
	void   mxSetPrintFileName(const mxArray *data);
	void   mxSetPrintLevel(const mxArray *data);
	void   mxSetSymbolicMath(const mxArray *data);
	void   mxSetPOPsolver(const mxArray *data); 
	void   mxSetMex(const mxArray *data);
	void   mxSetErrorBoundVec(const mxArray *data);
	void   mxSetAggressiveSW(const mxArray *data);
	#else
	void   SetParameters(string pname, int dimvar);
	void   SetRelaxOrder(string value);
	void   SetSparseSW(string value);
	void   SetMultiCF(string strtype, string value, int dimvar);
	void   SetScalingSW(string value);
	void   SetBoundSW(string value);
	void   SetEqTolerance(string value);
	void   SetPerturbation(string value);
	void   SetReduceMomentMatSW(string value);
	void   SetComplementaritySW(string value);
	void   SetSquareOneSW(string value);
	void   SetBinarySW(string value);
	void   SetReduceAMatSW(string value);
	void   SetSDPsolver(string value); 
	void   SetSDPsolverEpsilon(string value);
	void   SetSDPsolverOutFile(string strtype, string value); 
	void   SetSDPAOnScreen(string value);
	void   SetSdpaDataFile(string strtype, string value); 
	void   SetDetailedInfFile(string strtype, string value); 
	void   SetPrintOnScreen(string value);
	void   SetPrintFileName(string strtype, string value);
	void   SetPrintLevel(string value1, string value2);
	void   SetMethod(string strtype, string value);
	void   SetAggressiveSW(string value);
	#endif /* MATLAB_MEX_FILE */
};

#endif /* #ifndef _PARAMETERS_ */
