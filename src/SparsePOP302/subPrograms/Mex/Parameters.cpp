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

#include "Parameters.h"

pop_params::pop_params(){
	relax_Order		= 1;
	sparseSW		= 1;
	multiCliquesFactor	= 0;
 	scalingSW		= 1;
	boundSW			= 2;
	eqTolerance		= 0;
	perturbation		= 0.0;
	reduceMomentMatSW   	= 1;
	complementaritySW	= 0;
	SquareOneSW		= 1;
	binarySW 		= 1;
	reduceAMatSW		= 1;
	SeDuMiSW 		= 1;
	SeDuMiEpsilon 		= 1.0e-8;
	SeDuMiOnScreen		= 1;
	SDPsolverSW 		= 1;
	SDPsolver		= "";
	SDPsolverEpsilon	= 1.0e-8;
	SDPsolverOutFile 	= "";
	#ifdef MATLAB_MEX_FILE 
	SDPAOnScreen 		= 0;//For only SparsePOPC++
	#else
	SDPAOnScreen 		= 1;//For only SparsePOPC++
	#endif /* MATLAB_MEX_FILE */
	sdpaDataFile		= "";
	detailedInfFile		= "";
	printFileName		= "";
	printOnScreen 		= 1;
	printLevel1 		= 2;
	printLevel2 		= 2;
	symbolicMath 		= 1;
	mex 			= 1;
	POPsolver		= "";
	errorBdIdxSW		= 0;
	errorBdIdxVec.resize(0);
	Method 			= "symamd";
	aggressiveSW		= 0;
}
void pop_params::write_parameters(string fname){
	
	FILE *fp = fopen(fname.c_str(), "a+");
	if(fp==NULL){
		printf("Cannot open %s.\n", fname.c_str());
		exit(EXIT_FAILURE);
	}	
	fprintf(fp, "# parameters:\n");;
	fprintf(fp,"  relaxOrder         = %d\n",relax_Order);
	fprintf(fp,"  sparseSW           = %d\n",sparseSW);
	fprintf(fp,"  multiCliquesFactor = %6.2e\n",multiCliquesFactor);
	fprintf(fp,"  scalingSW          = %d\n",scalingSW);
	fprintf(fp,"  boundSW            = %d\n",boundSW);
	fprintf(fp,"  eqTolerance        = %6.2e\n",eqTolerance);
	fprintf(fp,"  perturbation       = %6.2e\n",perturbation);
	fprintf(fp,"  reduceMomentMatSW  = %d\n",reduceMomentMatSW);
	fprintf(fp,"  complementaritySW  = %d\n",complementaritySW);
	fprintf(fp,"  SquareOneSW        = %d\n",SquareOneSW);
	fprintf(fp,"  binarySW           = %d\n",binarySW);
	fprintf(fp,"  reduceAMatSW       = %d\n",reduceAMatSW);
	fprintf(fp,"  SDPsolverSW        = %d\n",SDPsolverSW);
	fprintf(fp,"  SDPsolver          = %s\n", SDPsolver.c_str());
	fprintf(fp,"  SDPsolverEpsilon   = %6.2e\n",SDPsolverEpsilon);
	if(this->SDPAOnScreen == 1){
		fprintf(fp,"  SDPsolverOutFile   = 1\n");
	}else if(this->SDPAOnScreen == 0 && this->SDPsolverOutFile.empty() == false){
		fprintf(fp,"  SDPsolverOutFile   = %s\n", SDPsolverOutFile.c_str());
	}else if(this->SDPAOnScreen == 0 && this->SDPsolverOutFile.empty() == true){
		fprintf(fp,"  SDPsolverOutFile   = 0\n");
	}
	if(this->sdpaDataFile.empty() == false){
		fprintf(fp,"  sdpaDataFile       = %s\n",sdpaDataFile.c_str());
	}else{
		fprintf(fp,"  sdpaDataFile       = \n");
	}
	if(this->detailedInfFile.empty() == false){
		fprintf(fp,"  detailedInfFile    = %s\n",detailedInfFile.c_str());
	}else{
		fprintf(fp,"  detailedInfFile    = \n");
	}
	if(this->printOnScreen == 1){
		fprintf(fp,"  printFileName      = 1\n");
	}else if(this->printOnScreen == 0 && this->printFileName.empty() == false){
		fprintf(fp,"  printFileName      = %s\n", printFileName.c_str());
	}else if(this->printOnScreen == 0 && this->printFileName.empty() == true){
		fprintf(fp,"  printFileName      = 0\n");
	}
	fprintf(fp,"  printLevel         = [%d, %d]\n",printLevel1, printLevel2);
	fprintf(fp,"  symbolicMath       = %d\n", symbolicMath);
	if(this->POPsolver.empty() == false){
		fprintf(fp,"  POPsolver          = %s\n", POPsolver.c_str());
	}else{
		fprintf(fp,"  POPsolver          = \n");
	}
	fprintf(fp,"  mex                = %d\n", mex);
	if(this->aggressiveSW == 1){
		fprintf(fp,"  aggressiveSW       = 1 // for developers of SparsePOP \n");
	}
	fprintf(fp, "\n");
	fclose(fp);
}
void pop_params::disp_parameters(){
	cout << "# parameters:" << endl;
	cout << "  relaxOrder         = " << relax_Order << endl;
	cout << "  sparseSW           = " << sparseSW << endl;
	printf("  multiCliquesFactor = %3.2e\n", multiCliquesFactor);
	cout << "  scalingSW          = " << scalingSW << endl;
	cout << "  boundSW            = " << boundSW << endl;
	printf("  eqTolerance        = %6.2e\n", eqTolerance);
	printf("  perturbation       = %6.2e\n", perturbation);
	cout << "  reduceMomentMatSW  = " << reduceMomentMatSW << endl;
	cout << "  complementaritySW  = " << complementaritySW << endl;
	cout << "  SquareOneSW        = " << SquareOneSW << endl;
	cout << "  binarySW           = " << binarySW << endl;
	cout << "  reduceAMatSW       = " << reduceAMatSW << endl;
	cout << "  SDPsolverSW        = " << SDPsolverSW << endl;
	cout << "  SDPsolver          = " << SDPsolver << endl;
	printf("  SDPsolverEpsilon   = %6.2e\n", SDPsolverEpsilon);
	if(SDPAOnScreen == 1){
		cout << "  SDPsolverOutFile   = " << 1 << endl;
	}else if(SDPAOnScreen == 0 && SDPsolverOutFile.empty() == false){
		cout << "  SDPsolverOutFile   = " << SDPsolverOutFile << endl;
	}else if(SDPAOnScreen == 0 && SDPsolverOutFile.empty() == true){
		cout << "  SDPsolverOutFile   = 0" << endl;
	}
	if(sdpaDataFile.empty() == false){
		cout << "  sdpaDataFile       = " << sdpaDataFile << endl;
	}else{
		cout << "  sdpaDataFile       = " << endl;
	}
	if(detailedInfFile.empty() == false){
		cout << "  detailedInfFile    = " << detailedInfFile << endl;
	}else{
		cout << "  detailedInfFile    = " << endl;
	}
	if(printOnScreen == 1){
		cout << "  printFileName      = " << 1 << endl;
	}else if(printOnScreen == 0 && printFileName.empty() == false){
		cout << "  printFileName      = " << printFileName << endl;
	}else if(printOnScreen == 0 && printFileName.empty() == true){
		cout << "  printFileName      = 0" << endl;
	}
	cout << "  printLevel         = [" << printLevel1 << ", " << printLevel2 << "]" << endl;
	cout << "  symbolicMath       = " << symbolicMath << endl;
	if(POPsolver.empty() == false){
		cout << "  POPsolver          = " << POPsolver << endl;
	}else{
		cout << "  POPsolver          = " << endl;
	}
	cout << "  mex                = " << mex << endl;
	if(this->aggressiveSW == 1){
		cout << "  aggressiveSW       = 1 // for developers of SparsePOP" << endl;
	}
	cout << endl;
}

#ifdef MATLAB_MEX_FILE 
void   pop_params::mxSetParameters(const mxArray *data){
	print_msg("Start to set param");
	mxSetRelaxOrder(data); 
	mxSetSparseSW(data); 
	mxSetMultiCF(data);
	mxSetScalingSW(data);
	mxSetBoundSW(data);
	mxSetEqTolerance(data);
	mxSetPerturbation(data);
	mxSetReduceMomentMatSW(data);
	mxSetComplementaritySW(data);
	mxSetSquareOneSW(data);
	mxSetBinarySW(data);
	mxSetReduceAMatSW(data);
	mxSetSDPsolverSW(data);
	mxSetSDPsolver(data);
	mxSetSDPsolverEpsilon(data);
	mxSetSDPsolverOutFile(data);
	//mxSetSDPAOnScreen(data);//For only SparsePOPC++
	mxSetDetailedInfFile(data); 
	mxSetSdpaDataFile(data); 
	mxSetPrintOnScreen(data);
	mxSetPrintFileName(data);
	mxSetPrintLevel(data);
	mxSetSymbolicMath(data);
	mxSetPOPsolver(data); 
	mxSetMex(data);
	mxSetErrorBoundVec(data);
	mxSetAggressiveSW(data);
	print_msg("End to set param");
}
void pop_params::mxSetRelaxOrder(const mxArray *data){
	print_msg("relaxOrder");
	const mxArray *pm;
	pm = mxGetField(data, 0, "relaxOrder");
	if(pm != NULL){
		relax_Order = (int)mxGetScalar(pm);
	}else{
		relax_Order = 1;
	}
}
void pop_params::mxSetSparseSW(const mxArray* data){
	print_msg("sparseSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "sparseSW");
	if(pm != NULL){
		sparseSW = (int)mxGetScalar(pm);
	}else{
		sparseSW = 0;;
	}
}
void pop_params:: mxSetMultiCF(const mxArray *data){
	print_msg("multiCliquesFactor");
	const mxArray *pm;
	pm = mxGetField(data, 0, "multiCliquesFactor");
	if(pm != NULL){
		multiCliquesFactor =  mxGetScalar(pm);
	}else{
		multiCliquesFactor = 1.00;;
	}
}
void pop_params::mxSetScalingSW(const mxArray *data){
	print_msg("scalingSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "scalingSW");
	if(pm != NULL){
		scalingSW = (int)mxGetScalar(pm);
	}else{
		scalingSW = 1;
	}
}
void pop_params::mxSetBoundSW(const mxArray *data){
	print_msg("boundSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "boundSW");
	if(pm != NULL){
		boundSW = (int)mxGetScalar(pm);
	}else{
		boundSW = 2;
	}
}
void pop_params::mxSetEqTolerance(const mxArray *data){
	print_msg("eqTolerance");
	const mxArray *pm;
	pm = mxGetField(data, 0, "eqTolerance");
	if(pm != NULL){
		eqTolerance = mxGetScalar(pm);
	}else{
		eqTolerance = 0.0;
	}
}
void pop_params::mxSetPerturbation(const mxArray *data){
	print_msg("perturbation");
	const mxArray *pm;
	pm = mxGetField(data, 0, "perturbation");
	if(pm != NULL){
		perturbation = mxGetScalar(pm);
	}else{
		perturbation = 0.0;
	}
}
void pop_params::mxSetReduceMomentMatSW(const mxArray *data){
	print_msg("reduceMomentMatSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "reduceMomentMatSW");
	if(pm != NULL){
		reduceMomentMatSW = (int)mxGetScalar(pm);
	}else{
		reduceMomentMatSW = 1;
	}
}
void pop_params::mxSetComplementaritySW(const mxArray *data){
	print_msg("complementaritySW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "complementaritySW");
	if(pm != NULL){
		complementaritySW = (int)mxGetScalar(pm);
	}else{
		complementaritySW = 0;
	}
}
void pop_params::mxSetSquareOneSW(const mxArray *data){
	print_msg("SquareOneSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SquareOneSW");
	if(pm != NULL){
		SquareOneSW = (int)mxGetScalar(pm);
	}else{
		SquareOneSW = 1;
	}
}
void pop_params::mxSetBinarySW(const mxArray *data){
	print_msg("binarySW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "binarySW");
	if(pm != NULL){
		binarySW = (int)mxGetScalar(pm);
	}else{
		binarySW = 1;
	}
}
void pop_params::mxSetReduceAMatSW(const mxArray *data){
	print_msg("reduceAMatSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "reduceAMatSW");
	if(pm != NULL){
		reduceAMatSW = (int)mxGetScalar(pm);
	}else{
		reduceAMatSW = 1;
	}
}
void pop_params::mxSetSeDuMiSW(const mxArray *data){
	print_msg("SeDuMiSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SeDuMiSW");
	if(pm != NULL){
		SeDuMiSW = (int)mxGetScalar(pm);
	}else{
		SeDuMiSW = 1;
	}
}
void pop_params::mxSetSeDuMiEpsilon(const mxArray *data){
	print_msg("SeDuMiEpsilon");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SeDuMiEpsilon");
	if(pm != NULL ){
		SeDuMiEpsilon = mxGetScalar(pm);
	}else{
		SeDuMiEpsilon = 1.0e-9;
	}
}
void pop_params::mxSetSeDuMiOutFile(const mxArray *data){
	print_msg("SeDuMiOutFile");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SeDuMiOutFile");
	if( pm != NULL){
		int buflen, status;
		char *input_buf;
		if(mxGetClassID(pm) == mxCHAR_CLASS){
			// maximum number of character 'fileName'
			buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
			// Allocate dynamic memory for 'fileName'
			input_buf = (char *)mxCalloc(buflen, sizeof(char));
			// Copy 'fileName' to 'input_buf'
			status = mxGetString(pm, input_buf, buflen);
			if(status == 1){// Can't allocate memory, then print the warning msg.
				mexErrMsgTxt("## Not enough space, String is truncated.");
				mexPrintf("## param.SeDuMiOutFile = %s\n", input_buf);
			}
			SeDuMiOutFile = input_buf;
			mxFree(input_buf);
		}else if(mxGetClassID(pm) == mxDOUBLE_CLASS){
			SeDuMiOnScreen = (int)mxGetScalar(pm);
		}else{
			mexErrMsgTxt("Parameters have something wrong.");
		}
	}
} 
void pop_params::mxSetSeDuMiOnScreen(const mxArray *data){
	print_msg("SeDuMiOnScreen");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SeDuMiOnScreen");
	if(pm != NULL){
		SeDuMiOnScreen = (int)mxGetScalar(pm);
	}else{
		SeDuMiOnScreen = 0;
	}
}
void pop_params::mxSetSDPsolverSW(const mxArray *data){
	print_msg("SDPsolverSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SDPsolverSW");
	if(pm != NULL){
		SDPsolverSW = (int)mxGetScalar(pm);
	}else{
		SDPsolverSW = 0;
	}
}
void pop_params::mxSetSDPsolver(const mxArray *data){
	print_msg("SDPsolver");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SDPsolver");
	if( pm != NULL){
		int buflen, status;
		char *input_buf;
		// maximum number of character 'fileName'
		buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
		// Allocate dynamic memory for 'fileName'
		input_buf = (char *)mxCalloc(buflen, sizeof(char));
		// Copy 'fileName' to 'input_buf'
		status = mxGetString(pm, input_buf, buflen);
		if(status == 1){// Can't allocate memory, then print the warning msg.
			mexWarnMsgTxt("## Not enough space, String is truncated.");
			mexPrintf("## param.SDPsolver = %s\n", input_buf);
		}
		SDPsolver = input_buf;
		mxFree(input_buf);
	}
}
void pop_params::mxSetSDPsolverEpsilon(const mxArray *data){
	print_msg("SDPsolverEpsilon");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SDPsolverEpsilon");
	if(pm != NULL ){
		SDPsolverEpsilon = mxGetScalar(pm);
	}else{
		SDPsolverEpsilon = 1.0e-8;
	}
}
void pop_params::mxSetSDPsolverOutFile(const mxArray *data){
	print_msg("SDPsolverOutFile");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SDPsolverOutFile");
	if( pm != NULL){
		if(mxGetClassID(pm) == mxCHAR_CLASS){
			int buflen, status;
			char *input_buf;
			// maximum number of character 'fileName'
			buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
			// Allocate dynamic memory for 'fileName'
			input_buf = (char *)mxCalloc(buflen, sizeof(char));
			// Copy 'fileName' to 'input_buf'
			status = mxGetString(pm, input_buf, buflen);
			if(status == 1){// Can't allocate memory, then print the warning msg.
				mexWarnMsgTxt("## Not enough space, String is truncated.");
				mexPrintf("## param.SDPsolverOutFile = %s\n", input_buf);
			}
			SDPsolverOutFile = input_buf;
			mxFree(input_buf);
		}else if(mxGetClassID(pm) == mxDOUBLE_CLASS){
			SDPAOnScreen = (int)mxGetScalar(pm);
		}else{
			mexErrMsgTxt("Parameters have something wrong.");
		}
	}
} 
void pop_params::mxSetSDPAOnScreen(const mxArray *data){
	print_msg("SDPAOnScreen");
	const mxArray *pm;
	pm = mxGetField(data, 0, "SDPAOnScreen");
	if(pm != NULL){
		SDPAOnScreen = (int)mxGetScalar(pm);
	}else{
		SDPAOnScreen = 0;
	}
}
void pop_params::mxSetSdpaDataFile(const mxArray *data){
	print_msg("sdpaDataFile");
	const mxArray *pm;
	pm = mxGetField(data, 0, "sdpaDataFile");
	if(pm != NULL){
		int buflen, status;
		char *input_buf;
		// maximum number of character 'fileName'
		buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
		// Allocate dynamic memory for 'fileName'
		input_buf = (char *)mxCalloc(buflen, sizeof(char));
		// Copy 'fileName' to 'input_buf'
		status = mxGetString(pm, input_buf, buflen);
		if(status == 1){// Can't allocate memory, then print the warning msg.
			mexWarnMsgTxt("## Not enough space, String is truncated.");
			mexPrintf("## param.sdpaDataFile = %s\n", input_buf);
		}
		sdpaDataFile = input_buf;
		mxFree(input_buf);
	}
} 
void pop_params::mxSetDetailedInfFile(const mxArray *data){
	print_msg("detailedInfFile");
	const mxArray *pm;
	pm = mxGetField(data, 0, "detailedInfFile");
	if( pm != NULL){
		int buflen, status;
		char *input_buf;
		// maximum number of character 'fileName'
		buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
		// Allocate dynamic memory for 'fileName'
		input_buf = (char *)mxCalloc(buflen, sizeof(char));
		// Copy 'fileName' to 'input_buf'
		status = mxGetString(pm, input_buf, buflen);
		if(status == 1){// Can't allocate memory, then print the warning msg.
			mexWarnMsgTxt("## Not enough space, String is truncated.");
			mexPrintf("## param.detailedInfFile = %s\n", input_buf);
		}
		detailedInfFile = input_buf;
		mxFree(input_buf);
	}
} 
void pop_params::mxSetPrintFileName(const mxArray *data){
	print_msg("printFileName");
	const mxArray *pm;
	pm = mxGetField(data, 0, "printFileName");
	if(pm != NULL){
		int buflen, status;
		char *input_buf;
		if(mxGetClassID(pm) == mxCHAR_CLASS){
			// maximum number of character 'fileName'
			buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
			// Allocate dynamic memory for 'fileName'
			input_buf = (char *)mxCalloc(buflen, sizeof(char));
			// Copy 'fileName' to 'input_buf'
			status = mxGetString(pm, input_buf, buflen);
			if(status == 1){// Can't allocate memory, then print the warning msg.
				mexErrMsgTxt("## Not enough space, String is truncated.");
				mexPrintf("## param.printFileName = %s\n", input_buf);
			}
			printFileName = input_buf;
			mxFree(input_buf);
		}else if(mxGetClassID(pm) == mxDOUBLE_CLASS){
			printOnScreen = (int)mxGetScalar(pm);
		}else{
			mexErrMsgTxt("Parameters have something wrong.");
		}
	}
}
void pop_params::mxSetPrintLevel(const mxArray *data){
	print_msg("printLevel");
	const mxArray *pm;
	pm = mxGetField(data, 0, "printLevel");
	if(pm != NULL ){
		int row = mxGetM(pm);//row = 1
		int col = mxGetN(pm);//col = 2
		double *pvect = mxGetPr(pm);
		printLevel1 = (int)pvect[0];
		if(col > 1){
			printLevel2 = (int)pvect[1];
		}else{
			printLevel2 = 0;
		}
		//mexPrintf("row, col = %d, %d\n",row,col);
		//mexPrintf("printLevel1 = %d\n", params.printLevel1);
		//mexPrintf("printLevel2 = %d\n", params.printLevel2);
	}else{
		printLevel1       = 2;
		printLevel2       = 2;
    }
}
void pop_params::mxSetPrintOnScreen(const mxArray *data){
	print_msg("printOnScreen");
	const mxArray *pm;
	pm = mxGetField(data, 0, "printOnScreen");
	if(pm != NULL ){
		printOnScreen = (int)mxGetScalar(pm);
	}else{
		printOnScreen = 0;    
	}
}
void pop_params::mxSetSymbolicMath(const mxArray *data){
	print_msg("symbolicMath");
	const mxArray *pm;
	pm = mxGetField(data, 0, "symbolicMath");
	if( pm != NULL ){
		symbolicMath = (int)mxGetScalar(pm);
	}else{
		symbolicMath = 1;
	}
}
void pop_params::mxSetPOPsolver(const mxArray *data){
	print_msg("POPsolver");
	const mxArray *pm;
	pm = mxGetField(data, 0, "POPsolver");
	if(pm != NULL){
		if(mxGetClassID(pm) == mxCHAR_CLASS){
			int buflen, status;
			char *input_buf;
			// maximum number of character 'fileName'
			buflen = (mxGetM(pm)*mxGetN(pm)*sizeof(mxChar))+1;
			// Allocate dynamic memory for 'fileName'
			input_buf = (char *)mxCalloc(buflen, sizeof(char));
			// Copy 'fileName' to 'input_buf'
			status = mxGetString(pm, input_buf, buflen);
			if(status == 1){// Can't allocate memory, then print the warning msg.
				mexWarnMsgTxt("## Not enough space, String is truncated.");
				mexPrintf("## param.POPsolver = %s\n", input_buf);
			}
			POPsolver = input_buf;
			mxFree(input_buf);
		}
	}
} 
void pop_params::mxSetMex(const mxArray *data){
	print_msg("mex");
	const mxArray *pm;
	pm = mxGetField(data, 0, "mex");
	if(pm != NULL ){
		mex = (int) mxGetScalar(pm);
	}else{
		mex = 1;
	}
}
void pop_params::mxSetErrorBoundVec(const mxArray *data){
	print_msg("errorBdIdx");
	const mxArray *pm;
	pm = mxGetField(data, 0, "errorBdIdx");
	if(pm != NULL ){
		int cellSW = (int)mxIsClass(pm,  "cell");
		if(cellSW == 1){
			errorBdIdxSW = 1;
			const mxArray *cell_ptr;
			mwSize num = mxGetNumberOfElements(pm);
			int val;
			for(mwIndex index=0; index<num; index++){
				cell_ptr = mxGetCell(pm, index);
				if(cell_ptr == NULL){
					mexPrintf("## param.errorBdIdx is empty.\n");
				}else{
					val = (int)mxIsEmpty(cell_ptr);
					if(val == 0){
						errorBdIdxSW = 1;
       		 				int row = mxGetM(cell_ptr);//row = 1
        					int col = mxGetN(cell_ptr);//col <=nDim
        					double *pvect = mxGetPr(cell_ptr);
						for(int i=0;i<col;i++){ 
							errorBdIdxVec.push_back((int)pvect[i]-1);
						} 
					}else{
						errorBdIdxSW = 0; 
					}
				}
			}
			vector<int>::iterator begin_it = errorBdIdxVec.begin();
			vector<int>::iterator end_it = errorBdIdxVec.end();
			sort(begin_it, end_it);
			vector<int>::iterator end_uit = unique(begin_it, end_it);
			errorBdIdxVec.erase(end_uit, end_it);
		}else{
			int val = (int)mxIsEmpty(pm);//row = 1
			if(val == 0){
				errorBdIdxSW = 1;
        			int row = mxGetM(pm);//row = 1
        			int col = mxGetN(pm);//col <=nDim
        			double *pvect = mxGetPr(pm);
				for(int i=0;i<col;i++){ 
					errorBdIdxVec.push_back((int)pvect[i]-1);
				}		 
			}	
		}
   }else{
		errorBdIdxSW = 0; 
   } 
	//for(int i=0;i<POP.param.errorBdIdxVec.size();i++){ 
	//	cout << POP.param.errorBdIdxVec[i] << endl;
	//} 
}
void pop_params::mxSetAggressiveSW(const mxArray *data){
	print_msg("aggressiveSW");
	const mxArray *pm;
	pm = mxGetField(data, 0, "aggressiveSW");
	if(pm != NULL ){
		aggressiveSW = (int) mxGetScalar(pm);
	}else{
		aggressiveSW = 0;
	}
}
#else
void pop_params::SetParameters(string pname, int dimvar){
	ifstream pf(pname.c_str());
	vector<string> strtype,values;
	string line,tmp1,tmp2;
	string::iterator it;
	int pos1,pos2,size;
	if(pf.is_open()){
		while(!pf.eof()){
			/* read line of param file */
			getline(pf,line);
			/* delete white spaces */
			it = remove_if(line.begin(), line.end(),bind2nd(equal_to<char>(),'\n'));
			line = string(line.begin(), it);		
			it = remove_if(line.begin(), line.end(),bind2nd(equal_to<char>(),'\t'));
			line = string(line.begin(), it);		
			it = remove_if(line.begin(), line.end(),bind2nd(equal_to<char>(),' '));
			line = string(line.begin(), it);		
			pos1 = line.find(",");
			pos2 = line.find(",",pos1+1);
			size = line.find(";"); 
			tmp1 = line.substr(pos1+1,pos2-pos1-1);
			tmp2 = line.substr(pos2+1,size-pos2-1);
			strtype.push_back(tmp1);
			values.push_back(tmp2);
			/*
			cout << "tmp1 = " << tmp1 << endl;
			cout << "tmp2 = " << tmp2 << endl;
			*/
		}
		pf.close();	
	}else{
		errorMsg("## Can not read param.pop.");
		exit(EXIT_FAILURE);
	}	
	//printStrVec(strtype);
	//printStrVec(values);
	SetRelaxOrder(values[0]);
	SetSparseSW(values[1]);
	SetMultiCF(strtype[2], values[2], dimvar);
	SetScalingSW(values[3]);
	SetBoundSW(values[4]);
	SetEqTolerance(values[5]);
	SetPerturbation(values[6]);
	SetReduceMomentMatSW(values[7]);
	SetComplementaritySW(values[8]);
	SetSquareOneSW(values[9]);
	SetBinarySW(values[10]);
	SetReduceAMatSW(values[11]);
	SetSDPsolver(values[12]); 
	SetSDPsolverEpsilon(values[13]);
	SetSDPsolverOutFile(strtype[14], values[14]); 
	SetSDPAOnScreen(values[15]);
	SetSdpaDataFile(strtype[16], values[16]); 
	SetDetailedInfFile(strtype[17], values[17]); 
	SetPrintOnScreen(values[18]);
	SetPrintFileName(strtype[19], values[19]);
	SetPrintLevel(values[20], values[21]);
	SetMethod(strtype[22], values[22]);
	if(values.size() >= 24){
		SetAggressiveSW(values[23]);
	}else{
		aggressiveSW = 0;	
	}
}
void   pop_params::SetRelaxOrder(string value){
	if(value.empty()){
		relax_Order = 1;
	}else{
		relax_Order = atoi(value.c_str());
	}
}
void   pop_params::SetSparseSW(string value){
	if(value.empty()){
		sparseSW = 1;
	}else{
		sparseSW = atoi(value.c_str());
	}
}
void   pop_params::SetMultiCF(string strtype, string value, int dimvar){
	if(strtype == "int"){
		multiCliquesFactor = atoi(value.c_str());
	}else if(strtype == "string" || strtype == "char"){
		multiCliquesFactor = dimvar;
	}else{
		errorMsg(" ## The second column of multiCliquesFactor in param.pop is something wrong. ");
		exit(EXIT_FAILURE);
	}
}
void   pop_params::SetScalingSW(string value){
	if(value.empty()){
		scalingSW = 1;
	}else{
		scalingSW = atoi(value.c_str());
	}
}
void   pop_params::SetBoundSW(string value){
	if(value.empty()){
		boundSW = 2;
	}else{
		boundSW = atoi(value.c_str());
	}
}
void   pop_params::SetEqTolerance(string value){
	if(value.empty()){
		eqTolerance = 0.0;
	}else{
		eqTolerance = atof(value.c_str());
	}
}
void   pop_params::SetPerturbation(string value){
	if(value.empty()){
		perturbation = 0.0;
	}else{
		perturbation = atof(value.c_str());
	}
}
void   pop_params::SetReduceMomentMatSW(string value){
	if(value.empty()){
		reduceMomentMatSW = 1;
	}else{
		reduceMomentMatSW = atoi(value.c_str());
	}
}
void   pop_params::SetComplementaritySW(string value){
	if(value.empty()){
		complementaritySW = 1;
	}else{
		complementaritySW = atoi(value.c_str());
	}
}
void   pop_params::SetSquareOneSW(string value){
	if(value.empty()){
		SquareOneSW = 1;
	}else{
		SquareOneSW = atoi(value.c_str());
	}
}
void   pop_params::SetBinarySW(string value){
	if(value.empty()){
		binarySW = 1;
	}else{
		binarySW = atoi(value.c_str());
	}
}
void   pop_params::SetReduceAMatSW(string value){
	if(value.empty()){
		reduceAMatSW = 1;
	}else{
		reduceAMatSW = atoi(value.c_str());
	}
}
/*
*/
void   pop_params::SetSDPsolver(string value){
	if(value.empty()){
		SDPsolverSW = 1;
	}else{
		SDPsolverSW = atoi(value.c_str());
	}
}
void   pop_params::SetSDPsolverEpsilon(string value){
	if(value.empty()){
		SDPsolverEpsilon = 0.0;
	}else{
		SDPsolverEpsilon = atof(value.c_str());
	}
}
void   pop_params::SetSDPsolverOutFile(string strtype, string value){ 
	if(strtype != "string"){
		errorMsg("## Should be string at the second column of SDPsolverOutFile.");
		exit(EXIT_FAILURE);
	}
	SDPsolverOutFile = value;
}
void   pop_params::SetSDPAOnScreen(string value){
	if(value.empty()){
		SDPAOnScreen = 1;
	}else{
		SDPAOnScreen = atoi(value.c_str());
	}
}
void   pop_params::SetSdpaDataFile(string strtype, string value){ 
	if(strtype != "string"){
		errorMsg("## Should be string at the second column of sdpaDataFile.");
		exit(EXIT_FAILURE);
	}
	sdpaDataFile = value;
}
void   pop_params::SetDetailedInfFile(string strtype, string value){ 
	if(strtype != "string"){
		errorMsg("## Should be string at the second column of detailedInfFile.");
		exit(EXIT_FAILURE);
	}
	detailedInfFile = value;
}
void   pop_params::SetPrintOnScreen(string value){
	/* printOnScreen */
	if(value.empty()){
		printOnScreen = 1;
	}else{
		printOnScreen = atoi(value.c_str());
	}
}
void   pop_params::SetPrintFileName(string strtype, string value){
	/* printFileName */
	if(strtype != "string"){
		errorMsg("## Should be string at the second column of printFileName.");
		exit(EXIT_FAILURE);
	}
	printFileName = value;
}
void   pop_params::SetPrintLevel(string value1, string value2){
	/* printLevel1,2 */
	if(value1.empty()){
		printLevel1 = 0;
	}else{
		printLevel1 = atoi(value1.c_str());
	}
	if(value2.empty()){
		printLevel1 = 0;
	}else{
		printLevel1 = atoi(value2.c_str());
	}
}
void   pop_params::SetMethod(string strtype, string value){
	/* Method */
	if(strtype != "string"){
		errorMsg("## Should be string at the second column of Method.");
		exit(EXIT_FAILURE);
	}
	Method = value;
	if(Method != "symamd" && Method != "metis"){
		errorMsg("## Should be metis or symamd in param.Method.");
		exit(EXIT_FAILURE);
	}else{
		//cout << param.Method << endl;
	}
}
void   pop_params::SetAggressiveSW(string value){
	if(value.empty()){
		aggressiveSW = 0;
	}else{
		aggressiveSW = atoi(value.c_str());
	}
}
#endif /* MATLAB_MEX_FILE */
 
