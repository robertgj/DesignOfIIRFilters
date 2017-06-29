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

#ifndef _CONVERSION_
#define _CONVERSION_

#include "global.h"
#include "polynomials.h"
#include "sup.h"
#include "spvec.h"
#include "mysdp.h"
#include "clique.h"
#include "Parameters.h"

/*** conversion ****************************************/
void conversion_part1(
        /*IN*/  class s3r & sr,
        /*OUT*/ double & objconst,
        int & slen, vector<double> & scaluvalue,
        int & blen, vector<double> & bvect,
        int & mlen, vector<double> & permmatrix);

void conversion_part2(
        /*IN*/  class s3r & sr,
        vector<int> & oriidx,
        class SparseMat & extofcsp,
        /*OUT*/ class mysdp & sdpdata);

/*******************************************************/
void qsort_sups(vector<int> & slist, class spvec_array & supset);
//void qsort_normal(/*IN*/vector<int> a, int left, int right, /*OUT*/vector<int> sortedorder);
//void swap2(vector<int> a, const int & i, const int & j);

int write_sdp_polyinfo(string outname, class poly_info & polyinfo);
int write_bassinfo(string outname, class spvec_array & bassinfo);

void perturb_objective(class poly & objpoly, int dimvar, double eps);
void gen_basisindices(int sparsesw, double multifactor, class polysystem & polysys, class cliques & maxcliques, vector<list<int> > & BasisIndices);

bool comp_sup_a_block(class spvec_array & supset, int i, class sup_a_block & supblock);
bool comp_sup_a_block(class sup_a_block & supblock, /* < */ class spvec_array & supset, int i);
bool comp_sup_a_block(class mysdp & psdp, int i, class sup_a_block & supblock);
bool comp_sup_a_block(class sup_a_block & supblock, class mysdp & psdp, int i);

void variable_numbering(class spvec_array & allsups, vector<int> plist, class mysdp & psdp, vector<int> & degOneTerms, vector<vector<int> > & xIdxVec);
void variable_numbering(class spvec_array & allsups, vector<int> plist, class mysdp & psdp, vector<int> & degOneTerms, class spvec_array & xIdxVec);
void genxIdxVec(class spvec_array & allsups, vector<vector<int> > & xIdxVec, int noLinearterms);

void count_upper_nnz(vector<int> plist, class mysdp & psdp);

void get_lsdp(class spvec_array & allsupset, class mysdp & psdp, vector<int> & degOneTerms, vector<vector<int> > & xIdxVec);
void get_lsdp(class spvec_array & allsupset, class mysdp & psdp, vector<int> & degOneTerms, class spvec_array & xIdxVec);

void pushsups(/*IN*/ class spvec_array & insups, /*OUT*/ class spvec_array & outsups);
void simplification(/*IN*/ class spvec_array & vecs);

void remove_Binarysups(class mysdp & psdp, vector<int> binvec);
void remove_SquareOnesups(class mysdp & psdp, vector<int> Sqvec);
void remove_sups(class mysdp & psdp, class spvec_array & removesups);
void remove_Binarysups(vector<int> binvec, class spvec_array & allsups);
void remove_SquareOnesups(vector<int> Sqvec, class spvec_array & allsups);
void remove_sups(class spvec_array & removesups, class spvec_array & sups);

//function that write the sparse format of the SDP into the file
void write_sdpa(/*IN*/class mysdp & psdp, /*OUT*/ string sdpafile);

//return the information of POP
void get_poly_a_bass_info(
        /* IN */  class polysystem & polysys, vector<class supSet> & BaSupVect, vector<class supSet> & mmBaSupVect,
        const int mat_size,
        /* OUT */ vector<class poly_info> & polyinfo, vector<class spvec_array> & bassinfo);

void get_subjectto_polys_and_basups(
        /* IN */  class polysystem & polysys, vector<list<int> > BaIndices, vector<class supSet> & basups,
        /* OUT */ int stsize, vector<class poly_info> & polyinfo_st, vector<class bass_info> & bassinfo_st);
void get_momentmatrix_basups(class polysystem & polysys, vector<list<int> > BaIndices, vector<class supSet> & basups, vector<class bass_info> & bassinfo_st);

void get_allsups(int dim, class poly_info & polyinfo_obj, int stsize, vector<class poly_info> & polyinfo_st, vector<class bass_info> & bassinfo_st, class spvec_array & allsups);
void get_allsups_in_momentmatrix(int dimvar, int mmsize, vector<class bass_info> & bassinfo_mm, class spvec_array & mmsups);

//for sorting functions
void sort_infotable(vector<vector<int> > infotable, vector<int> stand, vector<int> infolist, int left, int right);
bool comp_InfoTable(class Vec3 vec1, class Vec3 vec2);
void sortInfoTable(vector<class Vec3 > & infotable, vector<int> & infolist);
//bool comp_infotable(vector<vector<int> > infotable, int i, vector<int> stand);
//bool comp_infotable(vector<int> stand, vector<vector<int> > infotable, int j);
bool same_edge(class EdgeSet & edge1, class EdgeSet & edge2);
bool comp_edge(class EdgeSet & edge1, class EdgeSet & edge2);

//functions that enumerate all monomials
void count_lexall_num_a_nnz(int dimvar, int deg, int & num, int & nnz);
void genLexFixDeg(int k, int n, int W, vector<vector<int> > sup, int nnz, class spvec_array & rsups);
void genLexAll(int totalOfVars, int Deg, class spvec_array & rsups);

//function that extracts the support of complimentarity constraints.
void get_removesups(/*IN*/class polysystem & polysys, /*OUT*/class spvec_array & removesups);
//function that extracts the support of binary constraints.
//int get_binarySup(class polysystem & polysys, class spvec_array & removesups);
void get_binarySup(class polysystem & polysys, vector<int> & binvec);
//function that extracts the support of {-1,1} constraints.
//int get_SquareOneSup(class polysystem & polysys, class spvec_array & removesups);
void get_SquareOneSup(class polysystem & polysys, vector<int> & Sqvec);


void initialize_spvecs(/*IN*/class supSet & supset, /*OUT*/class spvec_array & spvecs);
void initialize_spvecs(/*IN*/list<class sup> & suplist, /*OUT*/class spvec_array & spvecs);
void initialize_polyinfo(/*IN*/class polysystem & polysys, int nop, /*OUT*/class poly_info & polyinfo);
void copy_polynomialsdpdata(/*IN*/class mysdp & opsdp, /*OUT*/class mysdp & npspd);


//Sum Of Squares and Semidifinite Relaxation
class s3r{
    
public:
    
    int itemp;
    string problemName;
    class polysystem Polysys;
    class polysystem OriPolysys;
    
    s3r();//constructor
    ~s3r(){
        timedata1.clear();
        timedata.clear();
	int size = bindices.size();
        for(int i=0;i<size;i++){
            bindices[i].clear();
        }
        degOneTerms.clear();
        
        //for(int i=0; i<xIdxVec.size();i++){
        //	xIdxVec[i].clear();
        //}
        problemName.clear();
    };
    class cliques maxcliques;
    
    vector<double> timedata1;
    vector<double> timedata;
    
    vector<double> scalevalue;
    vector<double> bvect;
    vector<double> permmatrix;
    vector<list<int> > bindices;
    
    //parameter
    class pop_params param;
    
    double ctime;
    
    string isFull;
    int linearterms;
    vector<int> degOneTerms;
    //vector<vector<int> > xIdxVec;
    class spvec_array xIdxVec;
    
    string detailedInfFile;
    string sdpaDataFile;
    
    //objective function
    class poly objPoly;
    
    void set_relaxOrder(int Order=2);
    
    void genBasisSupports(class supsetSet & BasisSupports);
    void reduceSupSets(class supsetSet & BasisSupports, class supSet & allNzSups);
    void eraseBinaryInObj(vector<int> binvec); //delete the supports from objective function via binary constraints (xi^2 - xi = 0)
    void eraseSquareOneInObj(vector<int> Sqvec); //delete the supports from objective function via Square-One constraints (xi^2 -1 = 0)
    void eraseCompZeroSups(class supSet & czSups); //delete the supports from objective function via complementarity constraints
    void eraseBinarySups(vector<int> binvec, vector<class supSet> & BaSups); //delete the supports from Polynomial SDPs via binary constraints (xi^2 - xi = 0)
    void eraseSquareOneSups(vector<int> Sqvec, vector<class supSet> & BaSups); //delete the supports from Polynomial SDPs via Square-One constraints (xi^2 -1 = 0)
    void eraseCompZeroSups(class supSet & czSups, vector<class supSet> & BaSups); //delete the supports from Polynomial SDPs via complementarity constraints
    
    void disp_params();
    
    //*** conversion ***
    
    void write_pop(int i, string fname);
    void write_BasisIndices(string fname);
    void write_BasisSupports(int i, string fname, class supsetSet & BasisSupports);
    void redundant_ZeroBounds(class supsetSet & BasisSupports, class supSet & allSup, class supSet & ZeroSup);
    void redundant_OneBounds(class supsetSet & BasisSupports, class supSet & allSup, class supSet & OneSup);
    
};

class Vec3{
public:
    //vector<int> vec;
	int no;
    	int typeCone;
	int dim;
	int deg;
	Vec3(){
		typeCone = 0;
		dim = 0;
		deg = 0;
		no = 0;
	};
	~Vec3(){};
	static bool compare(Vec3 * vec1, Vec3 * vec2){
		if(vec1->typeCone == EQU){
			if(vec2->typeCone != EQU){
				return true;
			}
			return false;		
		}else if(vec2->typeCone == EQU){
			return false;
		}else{
			if(vec1->dim < vec2->dim){
				return true;
			}else if(vec1->dim > vec2->dim){
				return false;
			}else{
				return (vec1->deg > vec2->deg);
			}
		}
	}
/*
    Vec3(){};
    ~Vec3(){
        vec.clear();
    };
    void clear(){
        vec.clear();
    };
    void resize(int s, int i){
        vec.resize(s, i);
    }
*/    
};


#endif /* #ifndef_CONVERSION_ */

