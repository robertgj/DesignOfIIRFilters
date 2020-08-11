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

#ifndef _MYSDP_
#define _MYSDP_

#include "global.h"
#include "polynomials.h"
#include "spvec.h"
#include "sup.h"

void get_moment_matrix(const class spvec_array & bassinfo, class spvec_array & mm_mat);
void convert_obj(  class poly_infon & polyinfo, class mysdp & psdp);
void convert_eq(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp);
void convert_ineq_a_ba1(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp);
void convert_ba1mmt(  class spvec_array & bassinfo, class mysdp & psdp);
void convert_ineq_a_ba2(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp);
void convert_sdp(class poly_info & polyinfo, class spvec_array & bassinfo, class mysdp & psdp);
void convert_ba2mmt(  class spvec_array & bassinfo, class mysdp & psdp);
void gather_diag_blocks(int gbs, vector<vector<int> > ggg, class mysdp & psdp);
void get_psdp(/*IN*/int mdim, int msize, vector<class poly_info> & polyinfo, vector<class spvec_array> & bassinfo , /*OUT*/class mysdp & psdp);

//bool comp_sup(class sup & sup1, class sup & sup2);
void qsort_psdp(vector<int> & slist, class mysdp & psdp);

void info_a_nnz_a_struct_size_eq( class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void info_a_nnz_a_struct_size_ineq_a_ba1( class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void info_a_nnz_a_struct_size_ba1mmt( class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void info_a_nnz_a_struct_size_ineq_a_ba2( class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void info_a_nnz_a_struct_size_ba2mmt( class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void info_a_nnz_a_struct_size_sdp(int mdim, class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & struct_size);
void get_info_a_nnz_a_struct_size(int mdim, int msize, vector<class poly_info> & polyinfo, vector<class spvec_array> bassinfo, int & info_size, int & nnz_size, int & blst_size);

void initialize_supset(/*IN*/class spvec_array & spvecs, /*OUT*/class supSet & supset);

class mat_info{
    
public:
    vector<vector<int> > bij;
    vector<double> coef;
    class spvec_array sup;
    
    void del();
    
    mat_info();
    ~mat_info();
    
};
class mysdp{
public:
	int mDim;
	int nBlocks;
	vector<int> bLOCKsTruct;
	vector<vector<int> > block_info;	//
	class mat_info ele;

	int utsize;
 	vector<vector<int> > utnnz;

	mysdp();	//constructor
	~mysdp();	//destructor
    
	void alloc_structs(int blst_size);
	void alloc(int blst_size, int ele_size, int nnz_size);
	void del();
	void disp();
	void disp(int b1, int b2);
	void disp_lsdp();
	void disp_sparseformat();
	void write(string fname);
	void write_utnnz(string fname);
	void input(string fname);
	void set_struct_info(int matstruct, int pos, int nnz_size, int typecone);
};

class sup_a_block{
public:
    int block;
    int deg;
    int nnzsize;
    vector<int> vap0;
    vector<int> vap1;
    
    sup_a_block();
    ~sup_a_block();
    
    void alloc(int mdim);
    void input(class mysdp & psdp, int i);
    void input(class spvec_array & supset, int i);
    void disp();
    
};
#endif /* ifndef _MYSDP_ */
