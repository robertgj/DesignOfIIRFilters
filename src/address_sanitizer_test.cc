// address_sanitizer_test.cc

// For address-sanitizer compile with:
#if 0
  mkoctfile -v -g -O0 -Wall -fno-omit-frame-pointer -fno-sanitize=vptr \
    -fsanitize=undefined -fsanitize=address address_sanitizer_test.cc
#endif
// and run with:
#if 0
  LD_PRELOAD=/usr/lib64/libasan.so.5 octave-cli --eval "address_sanitizer_test"
#endif

// Copyright (C) 2016 Robert Jenssen
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

#include <octave/oct.h>

DEFUN_DLD(address_sanitizer_test, args, nargout,"address_sanitizer_test")
{
  printf("In address_sanitizer_test.cc\n");
  Array<int> *a = new Array<int>();
  a->resize(dim_vector(1,1));
  a->elem(0)=1;
  Array<int> b(dim_vector(0,0));
  b.resize(dim_vector(1,1));
  b.elem(0)=1;
  Array<int> c(dim_vector(1,1));
  b=c;
  int *d=(int *)malloc(sizeof(int));
  d[0]=1;
  
  // Done
  return octave_value_list();
}
