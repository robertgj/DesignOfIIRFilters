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

#include "mysdp.h"

mat_info::mat_info(){
    //this->bij = NULL;
}

void mat_info::del(){
    this->bij.clear();
    this->coef.clear();
    this->sup.del();
}
mat_info::~mat_info(){
    this->del();
}
void mysdp::alloc(int blst_size, int ele_size, int nnz_size){
    
    this->bLOCKsTruct.resize(blst_size, 0);
    block_info.resize(3);
    block_info[0].resize(blst_size, 0);
    block_info[1].resize(blst_size, 0);
    block_info[2].resize(blst_size, 0);
    ele.bij.resize(3);
    ele.bij[0].resize(ele_size, 0);
    ele.bij[1].resize(ele_size, 0);
    ele.bij[2].resize(ele_size, 0);
    this->ele.sup.alloc(ele_size, nnz_size);
    this->ele.coef.resize(ele_size, 0);
}
void mysdp::del(){
    //cout << "delete mysdp" <<endl;
    this->bLOCKsTruct.clear();
    this->block_info.clear();
    this->ele.del();
}
mysdp::mysdp(){
    this->nBlocks = 0;
}
mysdp::~mysdp(){
    this->del();
}
void mysdp::disp(){
    
    cout<<"psdp.data out--------------------------------"<<endl;
    cout<<"block[ "<<0<<" ] --> [ "<<this->nBlocks<<" ] "<<endl;
    cout<<"nBlocks = "<<this->nBlocks<<endl;
    
    //for(int i=0;i<this->nBlocks+1;i++){
    for(int i=0;i<this->nBlocks;i++){
        cout<<"--- BLOCK [ "<<i<<" ] ----BlockStruct = "<< this->bLOCKsTruct[i]<<"--"<<endl;
        
        for(int j=this->block_info[0][i];j<this->block_info[0][i]+this->block_info[1][i];j++){
            cout<<"[ "<<j<<" ] ";
            cout<<"bij= ";
            cout<<this->ele.bij[0][j]<<" ";
            cout<<this->ele.bij[1][j]<<" ";
            cout<<this->ele.bij[2][j]<<" ";
            
            cout<<"coef= ";
            cout.precision(3);
            cout.width(7);
            cout<<this->ele.coef[j]<<" ";
            cout.width();
            cout<<"sup.idx ";
            for(int k=this->ele.sup.pnz[0][j];k<this->ele.sup.pnz[0][j]+this->ele.sup.pnz[1][j];k++){
                cout<<this->ele.sup.vap[0][k]<<" ";
            }
            cout<<"vap ";
            for(int k=this->ele.sup.pnz[0][j];k<this->ele.sup.pnz[0][j]+this->ele.sup.pnz[1][j];k++){
                cout<<this->ele.sup.vap[1][k]<<" ";
            }
            cout<<endl;
        }
    }
    cout<<"-----------------------------"<<endl<<endl;
}

void mysdp::disp(int b1, int b2){
    cout<<"psdp.data out-----------------"<<endl;
    
    cout<<"block[ "<<b1<<" ] --> [ "<<b2<<" ] "<<endl;
    cout<<"nBlocks = "<<this->nBlocks<<endl;
    if(b2 > this->nBlocks ){
        cout<<"error@mysdp::disp :: b2(="<<b2<<") is over(>"<<this->nBlocks<<")"<<endl;
        exit(EXIT_FAILURE);
    }
    
    for(int i=b1;i<b2;i++){
        cout<<"--- BLOCK [ "<<i<<" ] ----------"<<endl;
        
        for(int j=this->block_info[0][i];j<this->block_info[0][i]+this->block_info[1][i];j++){
            cout<<"[ "<<j<<" ] ";
            cout<<"bij= ";
            cout<<this->ele.bij[0][j]<<" ";
            cout<<this->ele.bij[1][j]<<" ";
            cout<<this->ele.bij[2][j]<<" ";
            
            cout<<"coef= ";
            cout.precision(3);
            cout.width(7);
            cout<<this->ele.coef[j]<<" ";
            cout.width();
            cout<<"sup.idx ";
            for(int k=this->ele.sup.pnz[0][j];k<this->ele.sup.pnz[0][j]+this->ele.sup.pnz[1][j];k++){
                cout<<this->ele.sup.vap[0][k]<<" ";
            }
            cout<<"vap ";
            for(int k=this->ele.sup.pnz[0][j];k<this->ele.sup.pnz[0][j]+this->ele.sup.pnz[1][j];k++){
                cout<<this->ele.sup.vap[1][k]<<" ";
            }
            cout<<endl;
        }
    }
    cout<<"-------------------"<<endl<<endl;
    
}
void mysdp::disp_lsdp(){
    
    cout<<"--- LSDP ------------------------------------"<<endl;
    cout<<"block[ "<<0<<" ] --> [ "<<this->nBlocks<<" ] "<<endl;
    cout<<"nBlocks = "<<this->nBlocks<<endl;
    cout<<"bLOCKsTRUCT: "<<endl;
    for(int i=0;i<=this->nBlocks;i++){
        cout<<" "<<this->bLOCKsTruct[i];
    }
    cout<<endl;
    
    for(int i=0;i<=this->nBlocks;i++){
        cout<<"--- BLOCK [ "<<i<<" ] ----BlockStruct = "<< this->bLOCKsTruct[i]<<"-----"<<endl;
        for(int j=this->block_info[0][i];j<this->block_info[0][i]+this->block_info[1][i];j++){
            cout<<" [ "<<j<<" ] ";
            cout<<" var= "<<this->ele.sup.pnz[0][j]<<" ";
            cout<<"bij= ";
            cout<<this->ele.bij[0][j]<<" ";
            cout<<this->ele.bij[1][j]<<" ";
            cout<<this->ele.bij[2][j]<<" ";
            
            cout<<"coef= ";
            cout.precision(3);
            cout.width(7);
            cout<<this->ele.coef[j]<<" ";
            cout.width();
            cout<<endl;
        }
    }
    
    cout<<"----------------------------------"<<endl<<endl;
    
}
void mysdp::disp_sparseformat(){
    
    cout<<" *** sparse format *** "<<endl;
    cout<<" mDim = "<<this->mDim<<endl;
    cout<<" nBlocks = "<<this->nBlocks-1;
    cout<<" bLOCKsTRUCT. "<<endl;
    for(int i=1;i<this->nBlocks;i++){
        cout.width(7); cout<<this->bLOCKsTruct[i];
        if( i% 5 == 0){
            cout<<endl;
        }
    }
    cout<<endl;
    cout<<" cvect."<<endl;
    for(int i=0;i<this->block_info[1][0];i++){
        cout.width(10); cout<<this->ele.sup.pnz[0][i];
        cout.width(5); cout<<this->ele.coef[i]<<endl;
    }
    cout<<endl;
    
    cout<<" sparse data."<<endl;
    int num=1;
    for(int i=1;i<this->nBlocks;i++){
        for(int j=this->block_info[0][i];j<this->block_info[0][i]+this->block_info[1][i];j++){
            cout.width(5); cout<<" "<<num++<<". ";
            cout.width(5); cout<<this->ele.sup.pnz[0][j];
            cout.width(5); cout<<this->ele.bij[0][j];
            cout.width(5); cout<<this->ele.bij[1][j];
            cout.width(5); cout<<this->ele.bij[2][j];
            
            cout.width(10); cout.precision(3); cout<<this->ele.coef[j];
            cout<<endl;
        }
    }
}

void mysdp::write(string fname){
    // This function does not output sdpa sparse format.
    // Function write_sdpa outputs sdpa sparse format for an obtained SDP.
    //file open
    std::ofstream fout;
    fout.open(fname.c_str(), ios::out);
    fout.close();
    fout.open(fname.c_str(), ios::app );
    if( fout.fail() ){//error check of opening file
        cout << "error:file not open for output" << endl;
        cout << fname;
        exit(EXIT_FAILURE);
    }
    
    // mDim;
    fout<<this->mDim<<endl;
    // nBlocks;
    fout<<this->nBlocks<<endl;
    // pnz_size
    fout<<this->ele.sup.pnz_size<<endl;
    // vap_size
    fout<<this->ele.sup.vap_size<<endl;
    cout<<endl;
    //* bLOCKsTruct,block_info[0],block_info[1]
    for(int i=0;i<this->nBlocks;i++){
        fout<<this->bLOCKsTruct[i]<<" ";
        fout<<this->block_info[0][i]<<" ";
        fout<<this->block_info[1][i]<<" ";
        fout<<endl;
    }
    fout<<endl;
    
    // pnz[0],pnz[1],bij[0],bij[1],bij[2],coef
    for(int i=0;i<this->ele.sup.pnz_size;i++){
        fout<<this->ele.sup.pnz[0][i]<<" ";
        fout<<this->ele.sup.pnz[1][i]<<" ";
        fout<<this->ele.bij[0][i]<<" ";
        fout<<this->ele.bij[1][i]<<" ";
        fout<<this->ele.bij[2][i]<<" ";
        fout<<this->ele.coef[i]<<endl;
    }
    fout<<endl;
    
    // vap[0],vap[1]
    for(int i=0;i<this->ele.sup.vap_size;i++){
        fout<<this->ele.sup.vap[0][i]<<" ";
        fout<<this->ele.sup.vap[1][i]<<" ";
        fout<<endl;
    }
    fout<<endl;
    fout.close();
}
void mysdp::write_utnnz(string fname){
    
    // file open
    std::ofstream fout;
    fout.open(fname.c_str(), ios::out);
    fout.close();
    fout.open(fname.c_str(), ios::app );
    if( fout.fail() ){//error check
        cout << "error:file not open for output" << endl;
        cout << fname;
        exit(EXIT_FAILURE);
    }
    
    fout<<this->utsize<<endl;
    for(int i=0;i<this->utsize;i++){
        fout<<this->utnnz[0][i]<<" "<<this->utnnz[1][i]<<" "<<this->utnnz[2][i]<<endl;
    }
    // mDim;
    fout.close();
}
void info_a_nnz_a_struct_size_eq(class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    info_size=0;
    nnz_size =0;
    
    int mcsize = polyinfo.numMs;
    for(int i=0;i<polyinfo.sizeCone;i++){
        for(int k=0;k<mcsize;k++){
            if(polyinfo.coef[k][i] != 0){
                info_size++;
            }
        }
    }
    
    nnz_size   = ( polyinfo.sup.pnz_size*bassinfo.get_nnz() +bassinfo.pnz_size*polyinfo.sup.get_nnz() ) << 1;
    info_size *= (bassinfo.pnz_size << 1);
    blst_size  = 1;
    
}
void info_a_nnz_a_struct_size_ineq_a_ba1( class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    info_size=0;
    nnz_size=0;
    
    int mcsize = polyinfo.numMs;
    for(int i=0; i<mcsize; i++){
        for(int j=0; j<polyinfo.sizeCone; j++){
            if(polyinfo.coef[i][j] != 0){
                info_size++;
                nnz_size += polyinfo.sup.pnz[1][i];
            }
        }
    }
    blst_size =1;
}
void info_a_nnz_a_struct_size_ba1mmt( class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    if( bassinfo.pnz[1][0] == 0 ){
        info_size = 0;
        nnz_size  = 0;
        blst_size = 0;
    }
    else{
        info_size = 1;
        nnz_size  = bassinfo.pnz[1][0];
        blst_size = 1;
    }
}
void info_a_nnz_a_struct_size_ineq_a_ba2( class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    info_size=0;
    nnz_size =0;
    
    int ndum=0;
    int mna = bassinfo.pnz_size * bassinfo.vap_size;
    int mmsize = bassinfo.pnz_size * ( bassinfo.pnz_size + 1 ) / 2;
    int numms;
    
    for(int i=0;i<polyinfo.sizeCone;i++){
        numms=0;
        ndum=0;
        for(int j=0;j<polyinfo.numMs;j++){
            if(polyinfo.coef[j][i] != 0){
                info_size++;
                numms++;
                ndum += polyinfo.sup.pnz[1][j];
            }
        }
        nnz_size += numms * mna + mmsize * ndum;
    }
    info_size *= bassinfo.pnz_size*(bassinfo.pnz_size+1)/2;
    blst_size =polyinfo.sizeCone;
    
}
void info_a_nnz_a_struct_size_ba2mmt( class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    info_size = bassinfo.pnz_size*(bassinfo.pnz_size+1)/2;
    nnz_size  = bassinfo.pnz_size * bassinfo.vap_size;
    blst_size = 1;
    
}
void info_a_nnz_a_struct_size_sdp(int mdim, class poly_info & polyinfo, class spvec_array & bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    //info_size = number of all supports
    //nnz_size  = nonzeros of all supports
    
    info_size=0;
    nnz_size =0;
    //get number of all supports
    int nnzTotalMx;
    
    int nnzDiagMx = bassinfo.pnz_size;
    int nnzMx = nnzDiagMx*nnzDiagMx;
    int nnzDiagAa = 0;
   
    int k=0;
    for(int i=0;i<polyinfo.numMs;i++){
        for(int j=0;j<polyinfo.sizeCone;j++){
            if( polyinfo.mc[k+1] - polyinfo.mc[k] ){
                if( polyinfo.mr[polyinfo.mc[k]] == j){
                    nnzDiagAa++;
                }
            }
            k++;
        }
	//cout << "i = "<< i << ",  nnzDiagAa = " << nnzDiagAa << endl;
    }
    
    int nnzAa =  2 * polyinfo.mc[k] - nnzDiagAa;
    
    info_size = (nnzMx*nnzAa + nnzDiagMx*nnzDiagAa)/2;
    
    //get number of vairables of which the moment vector consist
    //int maxlength = bassinfo.dim2;
    
    //get nonzeros fo all supports
    int totalnnz;
    k=0;
    for(int i=0;i<polyinfo.numMs;i++){
        
        nnzMx=0;
        nnzDiagMx=0;
        for(int j=0;j<bassinfo.pnz_size;j++){
            for(int t=j;t<bassinfo.pnz_size;t++){
                
                totalnnz = polyinfo.sup.pnz[1][i] + bassinfo.pnz[1][j] + bassinfo.pnz[1][t];
                //if(totalnnz > maxlength)
                //    totalnnz = maxlength;
                
                if(j==t){
                    nnzDiagMx += totalnnz;
                }
                nnzMx += totalnnz;
            }
        }
        nnzTotalMx = 2*nnzMx - nnzDiagMx;
        
        nnzAa=0;
        nnzDiagAa=0;
        for(int s=0;s<polyinfo.sizeCone;s++){
            if( polyinfo.mc[k+1] - polyinfo.mc[k] ){
                if( polyinfo.mr[polyinfo.mc[k]] == s){
                    nnzDiagAa++;
                }
                nnzAa += polyinfo.mc[k+1]-polyinfo.mc[k];
            }
            k++;
        }
        nnzAa = nnzAa - nnzDiagAa;
        nnz_size += nnzDiagAa*nnzMx + nnzAa*nnzTotalMx;
    }
    blst_size = 1;
}
void info_a_nnz_a_struct_size_obj(class poly_info & polyinfo, int & info_size, int & nnz_size, int & blst_size){
    info_size = polyinfo.sup.pnz_size;
    nnz_size  = polyinfo.sup.vap_size;
    blst_size = 1;
}

void get_info_a_nnz_a_struct_size(int mdim, int msize, vector<class poly_info> & polyinfo, vector<class spvec_array> bassinfo, int & info_size, int & nnz_size, int & blst_size){
    
    info_size   = 0;
    nnz_size    = 0;
    blst_size   = 0;
    
    int idum;
    int ndum;
    int bdum;
    
    info_a_nnz_a_struct_size_obj(polyinfo[0], idum, ndum, bdum);
    info_size += idum;
    nnz_size  += ndum;
    blst_size += bdum;
    
    for(int i=1;i<msize;i++){
        idum = 0;
        ndum = 0;
        bdum = 0;
        
        if(polyinfo[i].typeCone == EQU){
            info_a_nnz_a_struct_size_eq(polyinfo[i], bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @info_size_eq"<<endl;
	}else if(polyinfo[i].typeCone == 0){
		//Nothing to do
        }else if(polyinfo[i].typeCone == INE && bassinfo[i].pnz_size == 1){
            info_a_nnz_a_struct_size_ineq_a_ba1(polyinfo[i], bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @ineq_a_ba1"<<endl;
        }else if(polyinfo[i].typeCone == INE && bassinfo[i].pnz_size >= 2){
            info_a_nnz_a_struct_size_ineq_a_ba2(polyinfo[i], bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @ineq_a_ba2"<<endl;
        }else if(polyinfo[i].typeCone == SDP){
            info_a_nnz_a_struct_size_sdp(mdim, polyinfo[i], bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @sdp"<<endl;
        }else if(bassinfo[i].pnz_size == 1){
            info_a_nnz_a_struct_size_ba1mmt(bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @ba1mmt"<<endl;
        }else if(bassinfo[i].pnz_size >= 2){
            info_a_nnz_a_struct_size_ba2mmt(bassinfo[i], idum, ndum, bdum);
            //cout<<" size[ "<<i-1<<" ] info = "<<idum<<" nz = "<<ndum<<" @ba2mmt"<<endl;
        }else {
            cout<<"error@get_info_size :: not available combinatio of typeCone and basupsize"<<endl;
            exit(EXIT_FAILURE);
        }
        info_size += idum;
        nnz_size  += ndum;
        blst_size += bdum;
    }
}

void initialize_supset(class spvec_array & spvecs, class supSet & supset){
    
    supset.supList.clear();
    supset.dimVar = spvecs.dim;
    
    for(int i=0;i<spvecs.pnz_size;i++){
        class sup Sup;
        int a = spvecs.pnz[0][i];
        //cout << " i = " << i << endl;
        for(int j=0;j<spvecs.pnz[1][i];j++){
            Sup.idx.push_back(spvecs.vap[0][a]);
            Sup.val.push_back(spvecs.vap[1][a]);
            a++;
        }
        //cout << " i = " << i << ", spvecs.pnz_size = " << spvecs.pnz_size << endl;
        supset.supList.push_back(Sup);
    }
}

void get_moment_matrix(  class spvec_array & bassinfo, class spvec_array & mm_mat){
    
    int bsize = bassinfo.pnz_size;
    
    mm_mat.alloc(bsize*(bsize+1)/2, bsize*bassinfo.get_nnz());
    mm_mat.pnz_size = 0;
    mm_mat.vap_size = 0;
    
    int nnz3=0;
    int i, pos1, max1, pos2, max2;
    int vidx = 0;
    int sidx = 0;
    
    for(i=0;i<bsize;i++){
        for(int j=i;j<bsize;j++){
            pos1 = bassinfo.pnz[0][i];
            max1 = pos1+bassinfo.pnz[1][i];
            pos2 = bassinfo.pnz[0][j];
            max2 = pos2+bassinfo.pnz[1][j];
            
            //computation of summation--
            //In case that both supports are not zero.
            if(pos1 >= 0 && pos2 >= 0){
                nnz3=0;
                mm_mat.pnz[0][sidx] = vidx;
                while(pos1<max1 && pos2<max2){
                    if(bassinfo.vap[0][pos1] < bassinfo.vap[0][pos2]){
                        mm_mat.vap[0][vidx] = bassinfo.vap[0][pos1];
                        mm_mat.vap[1][vidx] = bassinfo.vap[1][pos1];
                        vidx++;
                        nnz3++;
                        pos1++;
                    }else if(bassinfo.vap[0][pos1] > bassinfo.vap[0][pos2]){
                        
                        mm_mat.vap[0][vidx] = bassinfo.vap[0][pos2];
                        mm_mat.vap[1][vidx] = bassinfo.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos2++;
                    }else {
                        mm_mat.vap[0][vidx] = bassinfo.vap[0][pos1];
                        mm_mat.vap[1][vidx] = bassinfo.vap[1][pos1] + bassinfo.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos1++;
                        pos2++;
                    }
                }
                while(pos1 < max1){
                    mm_mat.vap[0][vidx] = bassinfo.vap[0][pos1];
                    mm_mat.vap[1][vidx] = bassinfo.vap[1][pos1];
                    vidx++;
                    nnz3++;
                    pos1++;
                    
                }
                while(pos2 < max2){
                    mm_mat.vap[0][vidx] = bassinfo.vap[0][pos2];
                    mm_mat.vap[1][vidx] = bassinfo.vap[1][pos2];
                    vidx++;
                    nnz3++;
                    pos2++;
                }
                mm_mat.pnz[1][sidx] = nnz3;
            }else if(pos1 >= 0 && pos2 < 0){
                mm_mat.pnz[0][sidx] = vidx;
                while(pos1 < max1){
                    mm_mat.vap[0][vidx] = bassinfo.vap[0][pos1];
                    mm_mat.vap[1][vidx] = bassinfo.vap[1][pos1];
                    vidx++;
                    pos1++;
                }
                mm_mat.pnz[1][sidx] = bassinfo.pnz[1][i];
            }else if(pos2 >= 0 && pos1 < 0){
                mm_mat.pnz[0][sidx] = vidx;
                while(pos2 < max2){
                    mm_mat.vap[0][vidx] = bassinfo.vap[0][pos2];
                    mm_mat.vap[1][vidx] = bassinfo.vap[1][pos2];
                    vidx++;
                    pos2++;
                }
                mm_mat.pnz[1][sidx] = bassinfo.pnz[1][j];
            }else {// pos1 < 0 && pos2 < 0
                mm_mat.pnz[0][sidx] = -1;
                mm_mat.pnz[1][sidx] =  0;
            }
            sidx++;
        }
    }
    mm_mat.pnz_size = sidx;
    mm_mat.vap_size = vidx;
}
void convert_obj(  class poly_info & polyinfo, class mysdp & psdp){
    
    int fsize = polyinfo.sup.pnz_size;
    int i, pos1, max1;
    int vidx = 0;
    int sidx = 0;
    int	sno_f = 0;
    psdp.nBlocks=0;
    for(i=0;i<fsize;i++){
        pos1 = polyinfo.sup.pnz[0][i];
        max1 = pos1+polyinfo.sup.pnz[1][i];
        psdp.ele.sup.pnz[0][sidx] = vidx;
        while(pos1 < max1){
            psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
            psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
            vidx++;
            pos1++;
        }
        psdp.ele.sup.pnz[1][sidx] = polyinfo.sup.pnz[1][i];
        psdp.ele.bij[0][sidx]= 0;
        psdp.ele.bij[1][sidx]= 1 ;
        psdp.ele.bij[2][sidx]= 1 ;
        psdp.ele.coef[sidx] = polyinfo.coef[i][0];
        sidx++;
    }
    psdp.set_struct_info(1, sno_f, sidx-sno_f, -999);
    /*
     * cout << "nBlocks = " << psdp.nBlocks << endl;
     * cout << psdp.block_info[0][psdp.nBlocks] << endl;
     * cout << psdp.block_info[1][psdp.nBlocks] << endl;
     * cout << psdp.block_info[2][psdp.nBlocks] << endl;
     */
    psdp.ele.sup.pnz_size = sidx;
    psdp.ele.sup.vap_size = vidx;
}



void convert_eq(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp){
    
    int size1 = polyinfo.sup.pnz_size;
    int size2 = bassinfo.pnz_size;
    int nnz3=0;
    int pos1, max1, pos2, max2;
    int idx  = psdp.ele.sup.vap_size;
    int idx2 = psdp.ele.sup.pnz_size;
    int	sno_f = idx2;
    int vno_f = idx;
    
    psdp.nBlocks++;
    int i, j;
    for(int s=0;s<polyinfo.sizeCone;s++){
        for(j=0;j<size2;j++){
            for(i=0;i<size1;i++){
                if(fabs(polyinfo.coef[i][s]) > 1.0e-12){
                    pos1 = polyinfo.sup.pnz[0][i];
                    max1 = pos1+polyinfo.sup.pnz[1][i];
                    pos2 = bassinfo.pnz[0][j];
                    max2 = pos2+bassinfo.pnz[1][j];
                    
                    //computation of summation--
                    //In case that both supports are not zero.
                    if(pos1 >= 0 && pos2 >= 0){
                        nnz3=0;
                        psdp.ele.sup.pnz[0][idx2] = idx;
                        while(pos1<max1 && pos2<max2){
                            if(polyinfo.sup.vap[0][pos1] < bassinfo.vap[0][pos2]){
                                psdp.ele.sup.vap[0][idx] = polyinfo.sup.vap[0][pos1];
                                psdp.ele.sup.vap[1][idx] = polyinfo.sup.vap[1][pos1];
                                idx++;
                                nnz3++;
                                pos1++;
                            }else if(polyinfo.sup.vap[0][pos1] > bassinfo.vap[0][pos2]){
                                psdp.ele.sup.vap[0][idx] = bassinfo.vap[0][pos2];
                                psdp.ele.sup.vap[1][idx] = bassinfo.vap[1][pos2];
                                idx++;
                                nnz3++;
                                pos2++;
                            }else {
                                psdp.ele.sup.vap[0][idx] = polyinfo.sup.vap[0][pos1];
                                psdp.ele.sup.vap[1][idx] = polyinfo.sup.vap[1][pos1] + bassinfo.vap[1][pos2];
                                idx++;
                                nnz3++;
                                pos1++;
                                pos2++;
                            }
                        }
                        while(pos1 < max1){
                            psdp.ele.sup.vap[0][idx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][idx] = polyinfo.sup.vap[1][pos1];
                            idx++;
                            nnz3++;
                            pos1++;
                        }
                        while(pos2 < max2){
                            psdp.ele.sup.vap[0][idx] = bassinfo.vap[0][pos2];
                            psdp.ele.sup.vap[1][idx] = bassinfo.vap[1][pos2];
                            idx++;
                            nnz3++;
                            pos2++;
                        }
                        psdp.ele.sup.pnz[1][idx2] = nnz3;
                    }else if(pos1 >= 0 && pos2 < 0){
                        psdp.ele.sup.pnz[0][idx2] = idx;
                        while(pos1 < max1){
                            psdp.ele.sup.vap[0][idx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][idx] = polyinfo.sup.vap[1][pos1];
                            idx++;
                            pos1++;
                        }
                        psdp.ele.sup.pnz[1][idx2] = polyinfo.sup.pnz[1][i];
                    }else if(pos2 >= 0 && pos1 < 0){
                        psdp.ele.sup.pnz[0][idx2] = idx;
                        while(pos2 < max2){
                            psdp.ele.sup.vap[0][idx] = bassinfo.vap[0][pos2];
                            psdp.ele.sup.vap[1][idx] = bassinfo.vap[1][pos2];
                            idx++;
                            pos2++;
                        }
                        psdp.ele.sup.pnz[1][idx2] = bassinfo.pnz[1][j];
                    }else {// pos1 < 0 && pos2 < 0
                        psdp.ele.sup.pnz[0][idx2] = -1;
                        psdp.ele.sup.pnz[1][idx2] =  0;
                    }
                    psdp.ele.bij[0][idx2]=psdp.nBlocks;
                    psdp.ele.bij[1][idx2]=j + 1 +s ;
                    psdp.ele.bij[2][idx2]=j + 1 +s ;
                    psdp.ele.coef[idx2] = polyinfo.coef[i][s];
                    idx2++;
                }
            }
        }
    }
    
    //copy supports
    int size = idx - vno_f;
    for(int i=idx;i<idx+size;i++){
        psdp.ele.sup.vap[0][ i ] = psdp.ele.sup.vap[0][i - size ];
        psdp.ele.sup.vap[1][ i ] = psdp.ele.sup.vap[1][i - size ];
    }
    idx += size;
    //copy sup, bij and val
    size = idx2 - sno_f;
    int move_size = size2 + polyinfo.sizeCone -1;
    for(int i=idx2;i<idx2+size;i++){
        psdp.ele.sup.pnz[0][i] = psdp.ele.sup.pnz[0][i - size];
        psdp.ele.sup.pnz[1][i] = psdp.ele.sup.pnz[1][i - size ];
        psdp.ele.bij[0][i] = psdp.ele.bij[0][i-size] ;
        psdp.ele.bij[1][i] = psdp.ele.bij[1][i-size] +  move_size;
        psdp.ele.bij[2][i] = psdp.ele.bij[2][i-size] +  move_size;
        psdp.ele.coef[i] = -psdp.ele.coef[i-size];
    }
    
    idx2 += size;
    psdp.set_struct_info(-2*polyinfo.sizeCone*bassinfo.pnz_size, sno_f, 2*size, EQU);
    psdp.ele.sup.vap_size = idx;
    psdp.ele.sup.pnz_size = idx2;
    //psdp.disp(psdp.nBlocks -1, psdp.nBlocks);
    //cout<<"*****************************************"<<endl;
    //psdp.ele.sup.disp(sno_f,idx2);
    //cout<<"*****************************************"<<endl;
}

void get_psdp(/*IN*/int mdim, int msize, vector<class poly_info> & polyinfo, vector<class spvec_array> & bassinfo , /*OUT*/class mysdp & psdp){
    
    //set number of variables
    psdp.mDim = mdim;
    
    int info_size;
    int nnz_size;
    int blst_size;
    
    //get number and nonzeros of all supports, and blocks.
    get_info_a_nnz_a_struct_size(mdim, msize, polyinfo, bassinfo, info_size, nnz_size, blst_size);
    psdp.alloc(blst_size, info_size, nnz_size);
    vector<vector<int> > ggg(2);
    int ng = 2;
    for(int i=0;i<ng;i++){
        ggg[i].resize(2, 0);
        ggg[i][0] = -1;
        ggg[i][1] =  0;
    }
    
    convert_obj(polyinfo[0], psdp);
    for(int i=1;i<msize;i++){
        //int dum = info_size;
        //(negative) equality constraints
        if(polyinfo[i].typeCone == EQU){
            polyinfo[i].no = i;
            if(ggg[0][0] == -1){
                ggg[0][0] = psdp.nBlocks;
            }
            convert_eq(polyinfo[i], bassinfo[i], psdp);
            ggg[0][1] = psdp.nBlocks - ggg[0][0];
            //polyinfo[i].disp();
        }
	else if(polyinfo[i].typeCone == 0){
		//Complementarity constraint, binary constraint and Squareone constraint
		//Nothing to do
	}
        //(negative) inequality constraints with the size of basis supports 1
        else if(polyinfo[i].typeCone == INE && bassinfo[i].pnz_size == 1){
            polyinfo[i].no = i;
            if(ggg[1][0] == -1){
                ggg[1][0] = psdp.nBlocks;
            }
            convert_ineq_a_ba1(polyinfo[i], bassinfo[i], psdp);
            ggg[1][1] = psdp.nBlocks - ggg[1][0];
            //cout<<"mat[ "<<i<< " ] ineq_a_ba1"<<endl;
            //polyinfo[i].disp();
        }
        //(positive) inequality constraints with the size of basis supports more than 1
        else if(polyinfo[i].typeCone == INE && bassinfo[i].pnz_size >= 2){
            polyinfo[i].no = i;
            convert_ineq_a_ba2(polyinfo[i], bassinfo[i], psdp);
            //cout<<"mat[ "<<i<< " ] ineq_a_ba2"<<endl;
        }
        //(positive) SDP
        else if(polyinfo[i].typeCone == SDP){
            polyinfo[i].no = i;
            convert_sdp(polyinfo[i], bassinfo[i], psdp);
            //cout<<"mat[ "<<i<< " ] sdp"<<endl;
        }
        //(negative) Moment matrices with size 1
        else if(bassinfo[i].pnz_size == 1){
            //cout << bassinfo[i].pnz[0][0] << endl;
            //cout << bassinfo[i].pnz[1][0] << endl;
            polyinfo[i].no = i;
            if(ggg[1][0] == -1 && bassinfo[i].pnz[1][0] > 0){
                ggg[1][0] = psdp.nBlocks;
            }
            convert_ba1mmt(bassinfo[i], psdp);
            if(bassinfo[i].pnz[1][0] > 0){
                ggg[1][1] = psdp.nBlocks - ggg[1][0];
            }
            //cout<<"mat[ "<<i<< " ] ba1mmt"<<endl;
        }
        //(positive) Moment matrices with size > 1
        else if(bassinfo[i].pnz_size >= 2){
            polyinfo[i].no = i;
            convert_ba2mmt(bassinfo[i], psdp);
            //cout<<"mat[ "<<i<< " ] ba2mmt"<<endl;
        }
        // Error handling
        else {
            cout<<"error@get_psdp :: not available combinatio of typeCone and basupsize"<<endl;
            exit(EXIT_FAILURE);
        }
	polyinfo[i].del();
	bassinfo[i].del();
    }
	polyinfo.clear();
	bassinfo.clear();
    //psdp.disp();
    /*
     * cout << "ggg info = " << endl;
     * cout << " ggg[0][0] = " << ggg[0][0] << endl;
     * cout << " ggg[0][1] = " << ggg[0][1] << endl;
     * cout << " ggg[1][0] = " << ggg[1][0] << endl;
     * cout << " ggg[1][1] = " << ggg[1][1] << endl;
     */
    psdp.nBlocks ++;
    //psdp.disp(0,1);
    gather_diag_blocks(ng, ggg, psdp);
    //psdp.disp(0,1);
    //cout<<" <--- get_psdp <*** "<<endl;
}

void convert_ineq_a_ba1(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp){
    
    int fsize = polyinfo.sup.pnz_size;
    int nnz3=0;
    int pos1, max1, pos2, max2;
    int vidx  = psdp.ele.sup.vap_size;
    int sidx = psdp.ele.sup.pnz_size;
    int	sno_f = sidx;
    psdp.nBlocks++;
    int i;
    
    for(int s=0;s<polyinfo.sizeCone;s++){
        for(i=0;i<fsize;i++){
            if(fabs(polyinfo.coef[i][s]) > 1.0e-12){
                pos1 = polyinfo.sup.pnz[0][i];
                max1 = pos1+polyinfo.sup.pnz[1][i];
                pos2 = bassinfo.pnz[0][0];
                max2 = pos2+bassinfo.pnz[1][0];
                
                //computation of summation--
                //In case that both supports are not zero.
                if(pos1 >= 0 && pos2 >= 0){
                    nnz3=0;
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos1<max1 && pos2<max2){
                        if(polyinfo.sup.vap[0][pos1] < bassinfo.vap[0][pos2]){
                            psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                            vidx++;
                            nnz3++;
                            pos1++;
                        }else if(polyinfo.sup.vap[0][pos1] > bassinfo.vap[0][pos2]){
                            psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                            psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                            vidx++;
                            nnz3++;
                            pos2++;
                        }else {
                            psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1] + bassinfo.vap[1][pos2];
                            vidx++;
                            nnz3++;
                            pos1++;
                            pos2++;
                        }
                    }
                    while(pos1 < max1){
                        psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                        vidx++;
                        nnz3++;
                        pos1++;
                    }
                    while(pos2 < max2){
                        psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                        psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos2++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = nnz3;
                }else if(pos1 >= 0 && pos2 < 0){
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos1 < max1){
                        psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                        vidx++;
                        pos1++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = polyinfo.sup.pnz[1][i];
                }else if(pos2 >= 0 && pos1 < 0){
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos2 < max2){
                        psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                        psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                        vidx++;
                        pos2++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = bassinfo.pnz[1][0];
                }else {// pos1 < 0 && pos2 < 0
                    psdp.ele.sup.pnz[0][sidx] = -1;
                    psdp.ele.sup.pnz[1][sidx] =  0;
                }
                psdp.ele.bij[0][sidx]=psdp.nBlocks;
                psdp.ele.bij[1][sidx]= s + 1 ;
                psdp.ele.bij[2][sidx]= s + 1 ;
                psdp.ele.coef[sidx] = polyinfo.coef[i][s];
                sidx++;
            }
        }
    }
    psdp.set_struct_info(-1*polyinfo.sizeCone, sno_f, sidx-sno_f, INE);
    psdp.ele.sup.pnz_size = sidx;
    psdp.ele.sup.vap_size = vidx;
}

void mysdp::set_struct_info(int matstruct, int pos, int nnz_size, int typecone){
    
    this->bLOCKsTruct[this->nBlocks]   = matstruct;
    this->block_info[0][this->nBlocks] = pos;
    this->block_info[1][this->nBlocks] = nnz_size;
    this->block_info[2][this->nBlocks] = typecone;
    
}
void convert_ba1mmt(  class spvec_array & bassinfo, class mysdp & psdp){
    
    if(bassinfo.pnz[1][0] != 0){
        int vidx  = psdp.ele.sup.vap_size;
        int sidx = psdp.ele.sup.pnz_size;
        psdp.nBlocks++;
        psdp.ele.sup.pnz[0][sidx] = vidx;
        psdp.ele.sup.pnz[1][sidx] = bassinfo.pnz[1][0];
        psdp.ele.bij[0][sidx] =psdp.nBlocks;
        psdp.ele.bij[1][sidx] =1;
        psdp.ele.bij[2][sidx] =1;
        psdp.ele.coef[sidx] = 1;
        for(int i=0;i<bassinfo.pnz[1][0];i++){
            psdp.ele.sup.vap[0][vidx + i] = bassinfo.vap[0][i];
            psdp.ele.sup.vap[1][vidx + i] = 2*bassinfo.vap[1][i];
        }
        psdp.set_struct_info(-1, sidx, bassinfo.pnz[1][0], INE);
        psdp.ele.sup.vap_size += bassinfo.pnz[1][0];
        psdp.ele.sup.pnz_size++;
    }
}

void convert_ineq_a_ba2(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp){
    
    int bsize = bassinfo.pnz_size;
    
    //generate upper part of moment matrix
    class spvec_array mm_mat;
    get_moment_matrix(bassinfo, mm_mat);
    
    //set result of products of polynomial form and moment matrix
    int fsize = polyinfo.sup.pnz_size;
    int nnz3=0;
    
    int pos1, max1, pos2, max2;
    int i, j, k, u;
    
    for(int s=0;s<polyinfo.sizeCone;s++){
        int vidx  = psdp.ele.sup.vap_size;
        int sidx = psdp.ele.sup.pnz_size;
        int	snof = sidx;
        psdp.nBlocks++;
        u=0;
        for(j=0;j<bsize;j++){
            for(k=j;k<bsize;k++){
                for(i=0;i<fsize;i++){
                    if(fabs(polyinfo.coef[i][s]) > 1.0e-12){
                        pos1 = polyinfo.sup.pnz[0][i];
                        max1 = pos1+polyinfo.sup.pnz[1][i];
                        pos2 = mm_mat.pnz[0][u];
                        max2 = pos2+mm_mat.pnz[1][u];
                        //computation of summation--
                        //In case that both supports are not zero.
                        if(pos1 >= 0 && pos2 >= 0){
                            nnz3=0;
                            psdp.ele.sup.pnz[0][sidx] = vidx;
                            while(pos1<max1 && pos2<max2){
                                if(polyinfo.sup.vap[0][pos1] < mm_mat.vap[0][pos2]){
                                    psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                                    psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                                    vidx++;
                                    nnz3++;
                                    pos1++;
                                }else if(polyinfo.sup.vap[0][pos1] > mm_mat.vap[0][pos2]){
                                    psdp.ele.sup.vap[0][vidx] = mm_mat.vap[0][pos2];
                                    psdp.ele.sup.vap[1][vidx] = mm_mat.vap[1][pos2];
                                    vidx++;
                                    nnz3++;
                                    pos2++;
                                }else {
                                    psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                                    psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1] + mm_mat.vap[1][pos2];
                                    vidx++;
                                    nnz3++;
                                    pos1++;
                                    pos2++;
                                }
                            }
                            while(pos1 < max1){
                                psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                                psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                                vidx++;
                                nnz3++;
                                pos1++;
                            }
                            while(pos2 < max2){
                                psdp.ele.sup.vap[0][vidx] = mm_mat.vap[0][pos2];
                                psdp.ele.sup.vap[1][vidx] = mm_mat.vap[1][pos2];
                                vidx++;
                                nnz3++;
                                pos2++;
                            }
                            psdp.ele.sup.pnz[1][sidx] = nnz3;
                        }else if(pos1 >= 0 && pos2 < 0){
                            psdp.ele.sup.pnz[0][sidx] = vidx;
                            while(pos1 < max1){
                                psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                                psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                                vidx++;
                                pos1++;
                            }
                            psdp.ele.sup.pnz[1][sidx] = polyinfo.sup.pnz[1][i];
                        }else if(pos2 >= 0 && pos1 < 0){
                            psdp.ele.sup.pnz[0][sidx] = vidx;
                            while(pos2 < max2){
                                psdp.ele.sup.vap[0][vidx] = mm_mat.vap[0][pos2];
                                psdp.ele.sup.vap[1][vidx] = mm_mat.vap[1][pos2];
                                vidx++;
                                pos2++;
                            }
                            psdp.ele.sup.pnz[1][sidx] = mm_mat.pnz[1][u];
                        }else {// pos1 < 0 && pos2 < 0
                            psdp.ele.sup.pnz[0][sidx] = -1;
                            psdp.ele.sup.pnz[1][sidx] =  0;
                        }
                        psdp.ele.bij[0][sidx]=psdp.nBlocks;
                        psdp.ele.bij[1][sidx]= j + 1;
                        psdp.ele.bij[2][sidx]= k + 1;
                        psdp.ele.coef[sidx] = polyinfo.coef[i][s];
                        sidx++;
                    }
                }
                u++;
            }
        }
        psdp.set_struct_info(bsize, snof, sidx - snof, SDP);
        psdp.ele.sup.pnz_size = sidx;
        psdp.ele.sup.vap_size = vidx;
    }
}


void convert_sdp(  class poly_info & polyinfo,  class spvec_array & bassinfo, class mysdp & psdp){
    
    int rowlength = bassinfo.pnz_size;
    //generate upper part of moment matrix
    class spvec_array momentmatrix;
    get_moment_matrix(bassinfo, momentmatrix);
    
    //get product of polynomial form and moment matrix;
    psdp.nBlocks++;
    int vidx  = psdp.ele.sup.vap_size;
    int sidx = psdp.ele.sup.pnz_size;
    int	snof = sidx;
    int orividx, orisidx;
    int nnz3=0;
    int pos1, max1, pos2, max2;
    int u, t, r;
    int rowsize, colsize;
    u=0;
    t=0;
    for(int j=0;j<rowlength;j++){
        rowsize = j*polyinfo.sizeCone;
        for(int k=j;k<rowlength;k++){
            colsize = k*polyinfo.sizeCone;
            r=0;
            t=0;
            for(int i=0;i<polyinfo.sup.pnz_size;i++){
                //get product of support from polynomial form and support from moment matrix
                pos1 = polyinfo.sup.pnz[0][i];
                max1 = pos1+polyinfo.sup.pnz[1][i];
                pos2 = momentmatrix.pnz[0][u];
                max2 = pos2 + momentmatrix.pnz[1][u];
                
                //computation of summation--
                //In case that both supports are not zero.
                if(pos1 >= 0 && pos2 >= 0){
                    nnz3=0;
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos1<max1 && pos2<max2){
                        if(polyinfo.sup.vap[0][pos1] < momentmatrix.vap[0][pos2]){
                            psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                            vidx++;
                            nnz3++;
                            pos1++;
                        }else if(polyinfo.sup.vap[0][pos1] > momentmatrix.vap[0][pos2]){
                            psdp.ele.sup.vap[0][vidx] = momentmatrix.vap[0][pos2];
                            psdp.ele.sup.vap[1][vidx] = momentmatrix.vap[1][pos2];
                            vidx++;
                            nnz3++;
                            pos2++;
                        }else {
                            psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                            psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1] + momentmatrix.vap[1][pos2];
                            vidx++;
                            nnz3++;
                            pos1++;
                            pos2++;
                        }
                    }
                    while(pos1 < max1){
                        psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                        vidx++;
                        nnz3++;
                        pos1++;
                    }
                    while(pos2 < max2){
                        psdp.ele.sup.vap[0][vidx] = momentmatrix.vap[0][pos2];
                        psdp.ele.sup.vap[1][vidx] = momentmatrix.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos2++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = nnz3;
                }else if(pos1 >= 0 && pos2 < 0){
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos1 < max1){
                        psdp.ele.sup.vap[0][vidx] = polyinfo.sup.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = polyinfo.sup.vap[1][pos1];
                        vidx++;
                        pos1++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = polyinfo.sup.pnz[1][i];
                }else if(pos2 >= 0 && pos1 < 0){
                    psdp.ele.sup.pnz[0][sidx] = vidx;
                    while(pos2 < max2){
                        psdp.ele.sup.vap[0][vidx] = momentmatrix.vap[0][pos2];
                        psdp.ele.sup.vap[1][vidx] = momentmatrix.vap[1][pos2];
                        vidx++;
                        pos2++;
                    }
                    psdp.ele.sup.pnz[1][sidx] = momentmatrix.pnz[1][u];
                }else {// pos1 < 0 && pos2 < 0
                    psdp.ele.sup.pnz[0][sidx] = -1;
                    psdp.ele.sup.pnz[1][sidx] =  0;
                }
                
                //set data for each nonzero value of coefficient matrix of polynomial form
                orisidx = sidx;
                orividx = psdp.ele.sup.pnz[0][sidx];
                max1 = orividx + psdp.ele.sup.pnz[1][sidx];
                if(orividx >= 0){
                    vidx = orividx;
                }
                if(j==k){
                    for(int s=0;s<polyinfo.sizeCone;s++){
                        if( polyinfo.mc[t+1] - polyinfo.mc[t] > 0){
                            while(r<polyinfo.mc[t+1]){
                                
                                //set block_number , row_index and col_index
                                psdp.ele.bij[0][sidx] = psdp.nBlocks;
                                psdp.ele.bij[1][sidx] = polyinfo.mr[r] + rowsize +1;
                                psdp.ele.bij[2][sidx] = s + colsize +1;
                                psdp.ele.coef[sidx] = polyinfo.coef[r][0];
                                
                                //set(copy) value of indecies and nonzeros of supports
                                if(orividx >= 0){
                                    psdp.ele.sup.pnz[0][sidx] = vidx;
                                    psdp.ele.sup.pnz[1][sidx] = psdp.ele.sup.pnz[1][orisidx];
                                    for(int q = orividx; q < max1; q ++ ){
                                        psdp.ele.sup.vap[0][vidx] = psdp.ele.sup.vap[0][q];
                                        psdp.ele.sup.vap[1][vidx] = psdp.ele.sup.vap[1][q];
                                        vidx++;
                                    }
                                }else{
                                    psdp.ele.sup.pnz[0][sidx] = -1;
                                    psdp.ele.sup.pnz[1][sidx] =  0;
                                }
                                sidx ++ ;
                                r++;
                            }
                        }
                        t++;
                    }
                }else{
                    max1 = orividx + psdp.ele.sup.pnz[1][sidx];
                    for(int s=0;s<polyinfo.sizeCone;s++){
                        if( polyinfo.mc[t+1] - polyinfo.mc[t] > 0){
                            while(r<polyinfo.mc[t+1]){
                                
                                //set block_number , row_index and col_index
                                psdp.ele.bij[0][sidx] = psdp.nBlocks;
                                psdp.ele.bij[1][sidx] = polyinfo.mr[r] + rowsize +1;
                                psdp.ele.bij[2][sidx] = s + colsize + 1;
                                psdp.ele.coef[sidx] = polyinfo.coef[r][0];
                                
                                //set(copy) value of indecies and nonzeros of supports
                                if(orividx >= 0){
                                    psdp.ele.sup.pnz[0][sidx] = vidx;
                                    psdp.ele.sup.pnz[1][sidx] = psdp.ele.sup.pnz[1][orisidx];
                                    for(int q = orividx; q < max1; q ++ ){
                                        psdp.ele.sup.vap[0][vidx] = psdp.ele.sup.vap[0][q];
                                        psdp.ele.sup.vap[1][vidx] = psdp.ele.sup.vap[1][q];
                                        vidx++;
                                    }
                                }else{
                                    psdp.ele.sup.pnz[0][sidx] = -1;
                                    psdp.ele.sup.pnz[1][sidx] =  0;
                                }
                                sidx ++ ;
                                if(polyinfo.mr[r] != s){
                                    //set block_number , row_index and col_index
                                    psdp.ele.bij[0][sidx] = psdp.nBlocks;
                                    psdp.ele.bij[1][sidx] = s + rowsize + 1;
                                    psdp.ele.bij[2][sidx] = polyinfo.mr[r] + colsize + 1;
                                    psdp.ele.coef[sidx] = polyinfo.coef[r][0];
                                    
                                    //set(copy) value of indecies and nonzeros of supports
                                    if( orividx >= 0 ){
                                        psdp.ele.sup.pnz[0][sidx] = vidx;
                                        psdp.ele.sup.pnz[1][sidx] = psdp.ele.sup.pnz[1][orisidx];
                                        for(int q = orividx; q < max1; q ++ ){
                                            psdp.ele.sup.vap[0][vidx] = psdp.ele.sup.vap[0][q];
                                            psdp.ele.sup.vap[1][vidx] = psdp.ele.sup.vap[1][q];
                                            vidx++;
                                        }
                                    }else{
                                        psdp.ele.sup.pnz[0][sidx] = -1;
                                        psdp.ele.sup.pnz[1][sidx] =  0;
                                    }
                                    sidx ++ ;
                                }
                                r++;
                            }
                        }
                        t++;
                    }
                }
            }
            u++;
        }
    }
    psdp.set_struct_info(bassinfo.pnz_size*polyinfo.sizeCone, snof, sidx - snof, SDP);
    psdp.ele.sup.pnz_size = sidx;
    psdp.ele.sup.vap_size = vidx;
}

void convert_ba2mmt(  class spvec_array & bassinfo, class mysdp & psdp){
    
    int bsize = bassinfo.pnz_size;
    int vidx  = psdp.ele.sup.vap_size;
    int sidx = psdp.ele.sup.pnz_size;
    int	snof = sidx;
    
    psdp.nBlocks++;
    
    int nnz3=0;
    int pos1, max1, pos2, max2;
    int i;
    
    for(i=0;i<bsize;i++){
        for(int j=i;j<bsize;j++){
            pos1 = bassinfo.pnz[0][i];
            max1 = pos1+bassinfo.pnz[1][i];
            pos2 = bassinfo.pnz[0][j];
            max2 = pos2+bassinfo.pnz[1][j];
            
            //computation of summation--
            //In case that both supports are not zero.
            if(pos1 >= 0 && pos2 >= 0){
                nnz3=0;
                psdp.ele.sup.pnz[0][sidx] = vidx;
                while(pos1<max1 && pos2<max2){
                    if(bassinfo.vap[0][pos1] < bassinfo.vap[0][pos2]){
                        psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos1];
                        vidx++;
                        nnz3++;
                        pos1++;
                    }else if(bassinfo.vap[0][pos1] > bassinfo.vap[0][pos2]){
                        psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                        psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos2++;
                    }else {
                        psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos1];
                        psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos1] + bassinfo.vap[1][pos2];
                        vidx++;
                        nnz3++;
                        pos1++;
                        pos2++;
                    }
                }
                while(pos1 < max1){
                    psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos1];
                    psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos1];
                    vidx++;
                    nnz3++;
                    pos1++;
                }
                while(pos2 < max2){
                    psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                    psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                    vidx++;
                    nnz3++;
                    pos2++;
                }
                psdp.ele.sup.pnz[1][sidx] = nnz3;
            }else if(pos1 >= 0 && pos2 < 0){
                psdp.ele.sup.pnz[0][sidx] = vidx;
                while(pos1 < max1){
                    psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos1];
                    psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos1];
                    vidx++;
                    pos1++;
                }
                psdp.ele.sup.pnz[1][sidx] = bassinfo.pnz[1][i];
            }else if(pos2 >= 0 && pos1 < 0){
                psdp.ele.sup.pnz[0][sidx] = vidx;
                while(pos2 < max2){
                    psdp.ele.sup.vap[0][vidx] = bassinfo.vap[0][pos2];
                    psdp.ele.sup.vap[1][vidx] = bassinfo.vap[1][pos2];
                    vidx++;
                    pos2++;
                }
                psdp.ele.sup.pnz[1][sidx] = bassinfo.pnz[1][j];
            }else {// pos1 < 0 && pos2 < 0
                psdp.ele.sup.pnz[0][sidx] = -1;
                psdp.ele.sup.pnz[1][sidx] =  0;
            }
            psdp.ele.bij[0][sidx]=psdp.nBlocks;
            psdp.ele.bij[1][sidx]= i + 1;
            psdp.ele.bij[2][sidx]= j + 1;
            psdp.ele.coef[sidx] = 1.0;
            sidx++;
        }
    }
    psdp.set_struct_info(bsize, snof, sidx - snof, SDP);
    psdp.ele.sup.pnz_size = sidx;
    psdp.ele.sup.vap_size = vidx;
    
    //psdp.disp(psdp.nBlocks-1,psdp.nBlocks);
}
void gather_diag_blocks(int gbs, vector<vector<int> > dibs, class mysdp & psdp){
    //cout<<" ***> gather_diag_blocks ---> "<<endl;
    int matsize;
    //psdp.disp();
    //gather diagonal parts in each block
    for(int i=0;i<gbs;i++){
        if(dibs[i][0] >=0 ){
            //In case of gathering blocks corresponding to free variables
            if(i==0){
                // copy information on position of supports and save other memroy.
                int totalnum=0;
                
                for(int b=dibs[i][0];b<=dibs[i][0]+dibs[i][1];b++){
                    totalnum += psdp.block_info[1][b];
                }
                vector<vector<int> > temppnz(2);
                temppnz[0].clear();
                temppnz[1].clear();
                temppnz[0].resize(totalnum, 0);
                temppnz[1].resize(totalnum, 0);
                
                for(int s =  psdp.block_info[0][dibs[i][0]+1];s <  psdp.block_info[0][dibs[i][0]+dibs[i][1]]+psdp.block_info[1][dibs[i][0]+dibs[i][1]];s ++){
                    temppnz[0][s] = psdp.ele.sup.pnz[0][s];
                    temppnz[1][s] = psdp.ele.sup.pnz[1][s];
                }
                
                //shift information of sup,bij,coef into other memory
                matsize = 0;
                int numsup = psdp.block_info[1][0] + (psdp.block_info[1][dibs[i][0]+1] >> 1);
                int tmp = 0;
                for(int b=dibs[i][0]+2;b<=dibs[i][0]+dibs[i][1];b++){
                    tmp = -psdp.bLOCKsTruct[b-1];
                    tmp = (tmp >> 1);
                    matsize += tmp;
                    //matsize += abs(psdp.bLOCKsTruct[b-1])/2;
                    for(int j=psdp.block_info[0][b];j<psdp.block_info[0][b]+(psdp.block_info[1][b] >> 1);j++){
                        
                        //sup
                        psdp.ele.sup.pnz[0][numsup] = temppnz[0][j];
                        psdp.ele.sup.pnz[1][numsup] = temppnz[1][j];
                        
                        //bij[1],bij[2]
                        psdp.ele.bij[1][numsup] = psdp.ele.bij[1][j] + matsize;
                        psdp.ele.bij[2][numsup] = psdp.ele.bij[2][j] + matsize;
                        
                        //coef
                        psdp.ele.coef[numsup] = psdp.ele.coef[j];
                        
                        numsup++;
                    }
                }
                tmp = -psdp.bLOCKsTruct[dibs[i][0]+dibs[i][1]];
                tmp = (tmp >> 1);
                matsize += tmp;
                //matsize += abs(psdp.bLOCKsTruct[dibs[i][0]+dibs[i][1]])/2;
                int numsup2 = psdp.block_info[1][0];
                for(int b=dibs[i][0]+1;b<=dibs[i][0]+dibs[i][1];b++){
                    for(int j=psdp.block_info[0][b] + (psdp.block_info[1][b] >> 1);j<psdp.block_info[0][b]+psdp.block_info[1][b];j++){
                        
                        //sup
                        psdp.ele.sup.pnz[0][numsup] = temppnz[0][j];
                        psdp.ele.sup.pnz[1][numsup] = temppnz[1][j];
                        
                        //bij[1],bij[2]
                        psdp.ele.bij[1][numsup] = psdp.ele.bij[1][numsup2] + matsize ;
                        psdp.ele.bij[2][numsup] = psdp.ele.bij[2][numsup2] + matsize ;
                        
                        //coef
                        psdp.ele.coef[numsup] = -1*psdp.ele.coef[numsup2];
                        
                        numsup ++;
                        numsup2++;
                    }
                    psdp.block_info[0][b] = -1;
                    psdp.block_info[1][b] =  0;
                }
                psdp.block_info[0][dibs[i][0]+1] = psdp.block_info[1][0];
                psdp.block_info[1][dibs[i][0]+1] = numsup - psdp.block_info[1][0];
                psdp.bLOCKsTruct[dibs[i][0]+1] = -(matsize << 1);
                psdp.block_info[2][dibs[i][0]+1] = EQU;
            }
            //In case of gathering blocks corresponding to nonnegative variables
            else{
                matsize = 0;
                for(int b=dibs[i][0]+2;b<=dibs[i][0]+dibs[i][1];b++){
                    matsize += abs(psdp.bLOCKsTruct[b-1]);
                    for(int j=psdp.block_info[0][b];j<psdp.block_info[0][b]+psdp.block_info[1][b];j++){
                        psdp.ele.bij[1][j] += matsize;
                        psdp.ele.bij[2][j] += matsize;
                    }
                    psdp.block_info[1][dibs[i][0]+1] += psdp.block_info[1][b];
                    psdp.block_info[0][b] = -1;
                    psdp.block_info[1][b] =  0;
                }
                matsize += abs(psdp.bLOCKsTruct[dibs[i][0]+dibs[i][1]]);
                /*
                 * cout << "size of psdp.bLOCKsTruct = " << psdp.bLOCKsTruct.size() << endl;
                 * cout << "index = " << dibs[i][0]+1 << endl;
                 */
                psdp.bLOCKsTruct[dibs[i][0]+1] = -1*matsize;
                psdp.block_info[2][dibs[i][0]+1] = INE;
                /*
                 * cout << "matsize = " << matsize << endl;
                 * for(int i=0; i<psdp.bLOCKsTruct.size(); i++){
                 * cout << psdp.bLOCKsTruct[i] << endl;
                 * }
                 */
            }
        }
    }
    //renumbering no. of blocks
    int a = 1;
    for(int i=1;i<psdp.nBlocks;i++){
        if(psdp.block_info[1][i] > 0){
            psdp.block_info[0][a] = psdp.block_info[0][i];
            psdp.block_info[1][a] = psdp.block_info[1][i];
            psdp.block_info[2][a] = psdp.block_info[2][i];
            psdp.bLOCKsTruct[a]   = psdp.bLOCKsTruct[i];
            for(int j=psdp.block_info[0][a];j<psdp.block_info[0][a]+psdp.block_info[1][a];j++){
                psdp.ele.bij[0][j] = a;
            }
            a++;
        }
    }
    psdp.nBlocks = a;
    //psdp.disp();
    //cout<<" <--- gather_diag_blocks <*** "<<endl<<endl;
}
/*    
bool comp_sup(class sup & sup1, class sup & sup2){
//	return (sup1 < sup2);
	if(sup1 < sup2){
		return true;
	}else if(sup2 < sup1){
		return false;
	}else{
		return (sup1.bij < sup2.bij);
	}
}
*/
void qsort_psdp(vector<int> & slist, class mysdp & psdp){
#ifdef DEBUG
	double t1, t2, t3, t4, t5, t6;
	t1 = (double)clock();
#endif /* #ifdef DEBUG */
	
	int pointer = 0;
	if(pointer == 0){
		class supSet supsets;
		initialize_supset(psdp.ele.sup, supsets);
#ifdef DEBUG
		t2 = (double)clock();
#endif /* #ifdef DEBUG */
		list<class sup>::iterator ite;
		int i = 0;
		for(ite=supsets.begin(); ite!=supsets.supList.end(); ++ite){
			//(*ite).bij = psdp.ele.bij[0][i];
			(*ite).no = i;
			i++;
		}
#ifdef DEBUG
		t3 = (double)clock();
#endif /* #ifdef DEBUG */
		supsets.supList.sort(comp_sup);
#ifdef DEBUG
		t4 = (double)clock();
#endif /* #ifdef DEBUG */
		i=0;
		for(ite=supsets.begin(); ite!=supsets.supList.end(); ++ite){
			slist[i] = (*ite).no;
			i++;
		}
#ifdef DEBUG
		t5 = (double)clock();
#endif /* #ifdef DEBUG */
		supsets.clear();
	}else{
#ifdef DEBUG
		t2 = (double)clock();
#endif /* #ifdef DEBUG */
		vector<sup*> array;
		for(int i=0; i<psdp.ele.sup.pnz_size;i++){
			sup* Sup = new sup;
			int a = psdp.ele.sup.pnz[0][i];
			//cout << " i = " << i << endl;
			for(int j=0;j<psdp.ele.sup.pnz[1][i];j++){
				Sup->idx.push_back(psdp.ele.sup.vap[0][a]);
				Sup->val.push_back(psdp.ele.sup.vap[1][a]);
				a++;
			}
			array.push_back(Sup); 
		}
		for(int i=0; i<array.size();i++){
			array[i]->no = i;
		}
#ifdef DEBUG
		t3 = (double)clock();
#endif /* #ifdef DEBUG */
		//sort(array.begin(), array.end(), sup::compare);
		sort(array.begin(), array.end(), sup());
#ifdef DEBUG
		t4 = (double)clock();
#endif /* #ifdef DEBUG */
		for(int i=0;i<array.size();i++){
			//sup* Sup = array[i];
			//slist[i] = Sup->no;
			slist[i] = array[i]->no;
			delete array[i];
		}
#ifdef DEBUG
		t5 = (double)clock();
#endif /* #ifdef DEBUG */
		array.clear();
	}
#ifdef DEBUG
	t6 = (double)clock();
	printf("%4.2f sec in qsort_psdp\n", (double)(t2-t1)/(double)CLOCKS_PER_SEC);
	printf("%4.2f sec in qsort_psdp\n", (double)(t3-t2)/(double)CLOCKS_PER_SEC);
	printf("%4.2f sec in qsort_psdp\n", (double)(t4-t3)/(double)CLOCKS_PER_SEC);
	printf("%4.2f sec in qsort_psdp\n", (double)(t5-t4)/(double)CLOCKS_PER_SEC);
	printf("%4.2f sec in qsort_psdp\n", (double)(t6-t5)/(double)CLOCKS_PER_SEC);
#endif /* #ifdef DEBUG */
}

