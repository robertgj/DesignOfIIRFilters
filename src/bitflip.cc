// bitflip.cc
//
// Bit-flipping algorithm for optimising the coefficients
// of a digital filter. This implementation uses the bitand()
// etc functions. Those functions assume that the coefficients
// are non-negative binary integers and that the LSB is bit 1.
//
// Inputs:
//   pcostfun - pointer to a function: "cost=pcostfun(cof)"
//   cof0 - initial coefficients with 0 <= cof0(k) < 2^nbits
//   nbits - number of bits in the coefficients
//   bitstart - first bit to alter with msize <= bitstart <= nbits
//   msize - 0 < mask size <= nbits (number of bits changed) 
//   verbose - optional
//   testcof - During testing, only flip this coefficient. Optional.
// Outputs:
//   cof - optimised coefficients
//   cost - cost for optimised coefficients
//   fiter - number of cost function iterations
//
// See "Two Approaches for fixed-point filter design: 'bit-flipping'
// algorithm and constrained down-hill Simplex method", A.Krukowski 
// and I.Kale, Proceedings ISSPA99, pp. 965-968.


// Copyright (C) 2017 Robert G. Jenssen
//
// This program is free software; you can redistribute it and/or 
// modify it underthe terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 3 of 
// the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

#include <iomanip>

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD(bitflip, args, nargout,"[cof,cost,fiter] = ...\n\
  bitflip(pcostfun,cof0,nbits,bitstart,msize[,verbose,testcof])")
{
  // Sanity check
  if ((args.length() < 5) || (nargout > 3))
    {
      print_usage();
    }
  if (!args(0).is_function_handle())
    {
      error("pcostfun not a function handle!");
    }   

  // Get arguments
  octave_function *pcostfun = args(0).function_value ();
  RowVector cof = args(1).vector_value(true);
  uint64_t ncof = args(1).length();
  const uint64_t nbits = args(2).uint64_value(true);
  octave_value_list flintmax_retval = feval("flintmax");
  uint64_t max_nbits = floor(log2(flintmax_retval(0).double_value(true)));
  if ((nbits<1) ||(nbits>max_nbits))
    {
      error("Expect 1 <= nbits(%ld) <= max_nbits(%ld)",nbits,max_nbits);
    }
  const uint64_t bitstart = args(3).uint64_value(true);
  if ((bitstart<1) ||(bitstart>nbits))
    {
      error("Expect 1 <= bitstart(%ld) <= nbits(%ld)",bitstart,nbits);
    }
  const uint64_t msize = args(4).uint64_value(true);
  if ((msize<1) ||(msize>bitstart))
    {
      error("Expect 1 <= msize(%ld) <= bitstart(%ld)",msize,bitstart);
    }
  // For testing
  bool verbose = false;
  if (args.length() >= 6)
    {
      verbose = args(5).bool_value(true);
    }
  bool do_testcof = false;
  uint64_t testcof = -1;
  if (args.length() == 7)
    {
      do_testcof = true;
      testcof = args(6).uint64_value(true);
      if ((testcof<1) || (testcof > ncof))
        {
          error("Invalid testcof(%ld) of cof(length %ld)",testcof,ncof);
        }
      testcof=testcof-1;
    }

  // Initialise outputs
  octave_value_list costfun_args(1);
  costfun_args(0)=cof;
  octave_value_list costfun_retval = feval(pcostfun,costfun_args);
  double cost=costfun_retval(0).double_value(true);
  uint64_t fiter=0;
  if (verbose)
    {
      octave_stdout << "bitflip.cc:initial cost="
                    << std::fixed << std::setprecision(7) << cost
                    << std::endl;
    }

  // Bit-flipping loop moving the mask from bitstart down to msize
  for(uint64_t bit=bitstart;bit>=msize;bit--)
    {
      while (true)
        { 
          bool OK=false;
          uint64_t mask_step=1<<(bit-msize);
          uint64_t mask_end=mask_step*((1<<msize)-1);
          uint64_t mask=mask_end^((1<<nbits)-1);
          // Loop over all coefficients
          for(uint64_t k=0;k<ncof;k++)
            {
              if (do_testcof && (k != testcof))
                {
                  continue;
                }
              // Bit-flip within the mask
              RowVector newcof(cof);
              uint64_t cofk=cof(k);
              uint64_t newcofkmask=cofk&mask;
              for(uint64_t l=0;l<=mask_end;l+=mask_step)
                {
                  // Make new coefficient
                  newcof(k)= newcofkmask + l;
                  // Calculate cost function
                  costfun_args(0)=newcof;
                  costfun_retval = feval(pcostfun,costfun_args);
                  double newcost=costfun_retval(0).double_value(true);
                  fiter=fiter+1;
                  if (newcost < cost)
                    {
                      if(verbose)
                        {
                          uint64_t newcofk=newcof(k);
                          octave_stdout << "bitflip.cc:cof("
                                        << std::dec << k+1
                                        << ")=0x"
                                        << std::hex << cofk
                                        << ":cost "
                                        << std::fixed << std::setprecision(6)
                                                      << cost
                                        << ">"
                                        << std::fixed << newcost
                                        << " for 0x"
                                        << std::hex << newcofk
                                        << "(mask=0x"
                                        << std::hex << mask
                                        << ",l=0x"
                                        << std::hex << l
                                        << ",bit="
                                        << std::dec << bit
                                        << ")"
                                        << std::endl;
                        }
                      cost=newcost;
                      cof(k)=newcof(k);
                      cofk=cof(k);
                      OK=true;
                    }
                }
            }

          // No further improvement at this level
          if(OK == false)
            {
              break;
            } 
        }
    }

  if (verbose)
    {
      octave_stdout << "bitflip.cc:final cost="
                    << std::fixed << std::setprecision(7) << cost
                    << ",fiter="
                    << std::dec << fiter
                    << std::endl;
    }

  // Done
  octave_value_list retval(3);
  retval(0)=cof;
  retval(1)=cost;
  retval(2)=fiter;
  
  return octave_value_list(retval);
}
