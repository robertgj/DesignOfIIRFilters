/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparseCoLO 
% Copyright (C) 2009 
% Masakazu Kojima Group
% Department of Mathematical and Computing Sciences
% Tokyo Institute of Technology
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

#include <time.h>
#ifndef _MSC_VER
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>
    #ifndef CLK_TCK
    #define  CLK_TCK  sysconf(_SC_CLK_TCK)
    #endif
#endif

#define rMessage(message) \
{cout << message << " :: line " << __LINE__ \
  << " in " << __FILE__ << endl; }

class Time
{
public:
  static double rGetUseTime();
  static void   rSetTimeVal(struct timeval & targetVal);
  static double rGetRealTime(const struct timeval & start,
                             const struct timeval & end);
};

#ifdef _MSC_VER // for Windows (Visual C++ 2008)

#define TimeStart(START__) static clock_t START__; START__ = clock();
#define TimeEnd(END__)     static clock_t END__  ; END__   = clock();
#define TimeCal(START__,END__) ((double)(END__-START__))/CLOCKS_PER_SEC;

#else // for Linux & Mac

#if 1 // count time with process time
#define TimeStart(START__) \
   static double START__; START__ = Time::rGetUseTime()
#define TimeEnd(END__) \
   static double END__;   END__ = Time::rGetUseTime()
#define TimeCal(START__,END__) (END__ - START__)
#else // count time with real time
#define TimeStart(START__) \
   static struct timeval START__; Time::rSetTimeVal(START__)
#define TimeEnd(END__) \
   static struct timeval END__; Time::rSetTimeVal(END__)
#define TimeCal(START__,END__) Time::rGetRealTime(START__,END__)
#endif

#endif


