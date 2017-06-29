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

#include "ccputime.h"
#ifndef _MSC_VER

double Time::rGetUseTime()
{
  struct tms TIME;
  times(&TIME);
  return (double)TIME.tms_utime/(double)CLK_TCK; 
}

void Time::rSetTimeVal(struct timeval& targetVal)
{
  static struct timezone tz;
  gettimeofday(&targetVal,&tz);
}

double Time::rGetRealTime(const struct timeval& start,
                           const struct timeval& end)
{
  const long int second = end.tv_sec - start.tv_sec;
  const long int usecond = end.tv_usec - start.tv_usec;
  return ((double)second) + ((double)usecond)*(1.0e-6);
}
#endif
