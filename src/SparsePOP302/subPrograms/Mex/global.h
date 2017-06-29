/* -------------------------------------------------------------
 *
 * This file is a component of SparsePOP
 * Copyright (C) 2007 SparsePOP Project
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
#ifndef _GLOBAL_
#define _GLOBAL_
// Header files
#include <iostream>
#include <cstdio>
#include <string>
#include <fstream>
#include <cstdlib>
#include <vector>
#include <cmath>
#include <list>
#include <ctime>
#include <algorithm>
#include <numeric>
#include <set>
//#include <sstream>
#include <functional>
#include <cassert>
#include <iterator>
using namespace std;

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#define printf mexPrintf
#if linux == 0
typedef int mwSize;
typedef int mwIndex;
#endif
#else
typedef int mwSize;
typedef int mwIndex;
#define mexErrMsgTxt printf
#include "colamd.h"
#ifdef __cplusplus
extern "C" {
#include "metis.h"
#endif /* __cplusplus */
typedef int integer;
typedef double doublereal;
 int dpptrf_(char *uplo, integer *n, doublereal *ap, integer * info);
#ifdef __cplusplus
}
#endif /* ifdef __cplusplus */

#endif /* ifdef MEX_H */


// macros
#define EPS (1.0e-12)
#define MAX (1.0e9)
#define MIN (-1.0e9)
#define YES  1
#define NO  -1

//def. of typeCones
enum Cones{
    EQU=-1,		// equality constraint
    INE=1,		// inequality constriant or objective function
    SOC=2,		// second-order cone constraint
    SDP=3,		// positive semidefinite cone constraint
};


#define errorMsg(_msg) \
	{ printf("## An error is found at %d in %s of %s\n", __LINE__, __func__, __FILE__); \
	mexErrMsgTxt(_msg); \
	printf("\n");}

#define ArrayAlloc(array, size) \
	{ try{ array.resize(size); } \
	catch (bad_alloc){ \
		errorMsg("## Failed to allocate an array."); exit(EXIT_FAILURE);} \
	catch (...){ \
		errorMsg("## Failed to allocate an array due to the illegal size."); exit(EXIT_FAILURE); } \
	} 
//
// We use useful macros in the following site:
// http://www.hausmilbe.net/index.php?option=com_content&task=view&id=40&Itemid=7
//

//#define DEBUG
#ifdef DEBUG
#ifdef __GNUC__ 
	#define print_msg(_msg) printf("[ %s|%s,%3d]: %s\n", __FILE__, __PRETTY_FUNCTION__, __LINE__, _msg);
#else
	#define print_msg(_msg) printf("[ %s|%s,%3d]: %s\n", __FILE__, __func__, __LINE__, _msg);
#endif
#define print_time() printf("[ %s|%s,%3d]: time = %s\n", __FILE__, __func__, __LINE__, __TIME__);
#define print_int(_val) printf("[ %s|%s,%3d]: %s = %d\n", __FILE__, __func__, __LINE__, #_val, _val);
#define print_dbl(_val) printf("[ %s|%s,%3d]: %s = %f\n", __FILE__, __func__, __LINE__, #_val, _val);
#define print_ptr(_val) printf("[ %s|%s,%3d]: %s = %p\n", __FILE__, __func__, __LINE__, #_val, _val);
/*
#define getmem() \ 
system("top -b -n 1 | grep sparsePOP | head -1 |awk '{printf(\"memory = %s\\n\"), $6}' ");
*/
#define getmem() 0; 
#else
#define print_msg(_msg)
#define print_int(_val)
#define print_dbl(_val)
#define print_ptr(_val)
#define getmem() 0;
#endif /* ifdef DEBUG */
#endif /* ifndef _GLOBAL_ */
