// mzsolve.cc - find the roots of a polynomial with MPFR arithmetic
// This file uses modified versions of the following files from gsl-2.4: 
// poly/zsolve.c poly/companion.c poly/balance.c poly/qr.c. Here is the
// copyright notice from those files:
// 
// Copyright (C) 1996, 1997, 1998, 1999, 2000, 2007 Brian Gough
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or (at
// your option) any later version.
// 
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

#include <cstdlib>
#include <iostream>
#include <boost/multiprecision/mpfr.hpp>

typedef boost::multiprecision::mpfr_float_100 mpfloat;
typedef mpfloat * mgsl_complex_packed_ptr; 

/* From poly/gsl_poly.h : */
typedef struct { size_t nc; mpfloat * matrix; } mgsl_poly_complex_workspace;
   
/* From complex/gsl_complex.h: */
#define MGSL_SET_COMPLEX_PACKED(zp,n,x,y) do {*((zp)+2*(n))=(x); \
                                              *((zp)+(2*(n)+1))=(y);} while(0)
/* From err/gsl_errno.h: */
enum { 
  MGSL_SUCCESS  = 0,
  MGSL_FAILURE  = -1,
  MGSL_EDOM     = 1,   /* input domain error, e.g sqrt(-1) */
  MGSL_EINVAL   = 4,   /* invalid argument supplied by user */
  MGSL_EFAILED  = 5,   /* generic failure */
  MGSL_ENOMEM   = 8,   /* malloc failed */
} ;
#define MGSL_ERROR(reason, mgsl_errno) \
  fflush (stdout); \
  do { \
   fprintf(stderr,"ERROR (%s:%d) %s\n",__FILE__,__LINE__,reason); \
   fflush (stderr); \
   return mgsl_errno ; \
  } while (0)
#define MGSL_ERROR_VAL(reason, mgsl_errno, value) \
  fflush (stdout); \
  do { \
   fprintf(stderr,"ERROR %d (%s:%d) %s\n",mgsl_errno,__FILE__,__LINE__,reason); \
   fflush (stderr); \
   return value ; \
  } while (0)

/* C-style matrix elements */
#define MAT(m,i,j,n) ((m)[(i)*(n) + (j)])

/* Fortran-style matrix elements */
#define FMAT(m,i,j,n) ((m)[((i)-1)*(n) + ((j)-1)])

static void
set_companion_matrix (const mpfloat *a, size_t nc, mpfloat *m)
{
  size_t i, j;

  for (i = 0; i < nc; i++)
    for (j = 0; j < nc; j++)
      MAT (m, i, j, nc) = 0.0;

  for (i = 1; i < nc; i++)
    MAT (m, i, i - 1, nc) = 1.0;

  for (i = 0; i < nc; i++)
    MAT (m, i, nc - 1, nc) = -a[i] / a[nc];
}

#define RADIX 2
#define RADIX2 (RADIX*RADIX)

static void
balance_companion_matrix (mpfloat *m, size_t nc)
{
  int not_converged = 1;

  mpfloat row_norm = 0;
  mpfloat col_norm = 0;

  while (not_converged)
    {
      size_t i, j;
      mpfloat g, f, s;

      not_converged = 0;

      for (i = 0; i < nc; i++)
        {
          /* column norm, excluding the diagonal */

          if (i != nc - 1)
            {
              col_norm = abs (MAT (m, i + 1, i, nc));
            }
          else
            {
              col_norm = 0;

              for (j = 0; j < nc - 1; j++)
                {
                  col_norm += abs (MAT (m, j, nc - 1, nc));
                }
            }

          /* row norm, excluding the diagonal */

          if (i == 0)
            {
              row_norm = abs (MAT (m, 0, nc - 1, nc));
            }
          else if (i == nc - 1)
            {
              row_norm = abs (MAT (m, i, i - 1, nc));
            }
          else
            {
              row_norm = (abs (MAT (m, i, i - 1, nc)) 
                          + abs (MAT (m, i, nc - 1, nc)));
            }

          if (col_norm == 0 || row_norm == 0)
            {
              continue;
            }

          g = row_norm / RADIX;
          f = 1;
          s = col_norm + row_norm;

          while (col_norm < g)
            {
              f *= RADIX;
              col_norm *= RADIX2;
            }

          g = row_norm * RADIX;

          while (col_norm > g)
            {
              f /= RADIX;
              col_norm /= RADIX2;
            }

          if ((row_norm + col_norm) < 0.95 * s * f)
            {
              not_converged = 1;

              g = 1 / f;

              if (i == 0)
                {
                  MAT (m, 0, nc - 1, nc) *= g;
                }
              else
                {
                  MAT (m, i, i - 1, nc) *= g;
                  MAT (m, i, nc - 1, nc) *= g;
                }

              if (i == nc - 1)
                {
                  for (j = 0; j < nc; j++)
                    {
                      MAT (m, j, i, nc) *= f;
                    }
                }
              else
                {
                  MAT (m, i + 1, i, nc) *= f;
                }
            }
        }
    }
}

static int
qr_companion (mpfloat *h, size_t nc, mgsl_complex_packed_ptr zroot)
{
  mpfloat t = 0.0;

  size_t iterations, e, i, j, k, m;

  mpfloat w, x, y, s, z;

  mpfloat p = 0, q = 0, r = 0; 

  /* FIXME: if p,q,r, are not set to zero then the compiler complains
     that they ``might be used uninitialized in this
     function''. Looking at the code this does seem possible, so this
     should be checked. */

  int notlast;

  size_t n = nc;

next_root:

  if (n == 0)
    return MGSL_SUCCESS ;

  iterations = 0;

next_iteration:

  for (e = n; e >= 2; e--)
    {
      mpfloat a1 = abs (FMAT (h, e, e - 1, nc));
      mpfloat a2 = abs (FMAT (h, e - 1, e - 1, nc));
      mpfloat a3 = abs (FMAT (h, e, e, nc));

      if (a1 <= FLT128_EPSILON * (a2 + a3))
        break;
    }

  x = FMAT (h, n, n, nc);

  if (e == n)
    {
      MGSL_SET_COMPLEX_PACKED (zroot, n-1, x + t, 0); /* one real root */
      n--;
      goto next_root;
      /*continue;*/
    }

  y = FMAT (h, n - 1, n - 1, nc);
  w = FMAT (h, n - 1, n, nc) * FMAT (h, n, n - 1, nc);

  if (e == n - 1)
    {
      p = (y - x) / 2;
      q = p * p + w;
      y = sqrt (abs (q));

      x += t;

      if (q > 0)                /* two real roots */
        {
          if (p < 0)
            y = -y;
          y += p;

          MGSL_SET_COMPLEX_PACKED (zroot, n-1, x - w / y, 0);
          MGSL_SET_COMPLEX_PACKED (zroot, n-2, x + y, 0);
        }
      else
        {
          MGSL_SET_COMPLEX_PACKED (zroot, n-1, x + p, -y);
          MGSL_SET_COMPLEX_PACKED (zroot, n-2, x + p, y);
        }
      n -= 2;

      goto next_root;
      /*continue;*/
    }

  /* No more roots found yet, do another iteration */

  if (iterations == 240)  /* increased from 30 to 120 */
    {
      /* too many iterations - give up! */

      return MGSL_FAILURE ;
    }

  if (iterations % 10 == 0 && iterations > 0)
    {
      /* use an exceptional shift */

      t += x;

      for (i = 1; i <= n; i++)
        {
          FMAT (h, i, i, nc) -= x;
        }

      s = abs (FMAT (h, n, n - 1, nc)) + abs (FMAT (h, n - 1, n - 2, nc));
      y = 0.75 * s;
      x = y;
      w = -0.4375 * s * s;
    }

  iterations++;

  for (m = n - 2; m >= e; m--)
    {
      mpfloat a1, a2, a3;

      z = FMAT (h, m, m, nc);
      r = x - z;
      s = y - z;
      p = FMAT (h, m, m + 1, nc) + (r * s - w) / FMAT (h, m + 1, m, nc);
      q = FMAT (h, m + 1, m + 1, nc) - z - r - s;
      r = FMAT (h, m + 2, m + 1, nc);
      s = abs (p) + abs (q) + abs (r);
      p /= s;
      q /= s;
      r /= s;

      if (m == e)
        break;
      
      a1 = abs (FMAT (h, m, m - 1, nc));
      a2 = abs (FMAT (h, m - 1, m - 1, nc));
      a3 = abs (FMAT (h, m + 1, m + 1, nc));

      if (a1 * (abs (q) + abs (r)) <= FLT128_EPSILON * abs (p) * (a2 + a3))
        break;
    }

  for (i = m + 2; i <= n; i++)
    {
      FMAT (h, i, i - 2, nc) = 0;
    }

  for (i = m + 3; i <= n; i++)
    {
      FMAT (h, i, i - 3, nc) = 0;
    }

  /* mpfloat QR step */

  for (k = m; k <= n - 1; k++)
    {
      notlast = (k != n - 1);

      if (k != m)
        {
          p = FMAT (h, k, k - 1, nc);
          q = FMAT (h, k + 1, k - 1, nc);
          r = notlast ? FMAT (h, k + 2, k - 1, nc) : 0.0;

          x = abs (p) + abs (q) + abs (r);

          if (x == 0)
            continue;           /* FIXME????? */

          p /= x;
          q /= x;
          r /= x;
        }

      s = sqrt (p * p + q * q + r * r);

      if (p < 0)
        s = -s;

      if (k != m)
        {
          FMAT (h, k, k - 1, nc) = -s * x;
        }
      else if (e != m)
        {
          FMAT (h, k, k - 1, nc) *= -1;
        }

      p += s;
      x = p / s;
      y = q / s;
      z = r / s;
      q /= p;
      r /= p;

      /* do row modifications */

      for (j = k; j <= n; j++)
        {
          p = FMAT (h, k, j, nc) + q * FMAT (h, k + 1, j, nc);

          if (notlast)
            {
              p += r * FMAT (h, k + 2, j, nc);
              FMAT (h, k + 2, j, nc) -= p * z;
            }

          FMAT (h, k + 1, j, nc) -= p * y;
          FMAT (h, k, j, nc) -= p * x;
        }

      j = (k + 3 < n) ? (k + 3) : n;

      /* do column modifications */

      for (i = e; i <= j; i++)
        {
          p = x * FMAT (h, i, k, nc) + y * FMAT (h, i, k + 1, nc);

          if (notlast)
            {
              p += z * FMAT (h, i, k + 2, nc);
              FMAT (h, i, k + 2, nc) -= p * r;
            }
          FMAT (h, i, k + 1, nc) -= p * q;
          FMAT (h, i, k, nc) -= p;
        }
    }

  goto next_iteration;
}

static int
mgsl_poly_complex_solve (const mpfloat *a, size_t n,
                         mgsl_poly_complex_workspace * w,
                         mgsl_complex_packed_ptr z)
{
  int status;
  mpfloat *m;

  if (n == 0)
    {
      MGSL_ERROR ("number of terms must be a positive integer", MGSL_EINVAL);
    }

  if (n == 1)
    {
      MGSL_ERROR ("cannot solve for only one term", MGSL_EINVAL);
    }

  if (a[n - 1] == 0)
    {
      MGSL_ERROR ("leading term of polynomial must be non-zero", MGSL_EINVAL) ;
    }

  if (w->nc != n - 1)
    {
      MGSL_ERROR ("size of workspace does not match polynomial", MGSL_EINVAL);
    }
  
  m = w->matrix;

  set_companion_matrix (a, n - 1, m);

  balance_companion_matrix (m, n - 1);

  status = qr_companion (m, n - 1, z);

  if (status)
    {
      MGSL_ERROR("root solving qr method failed to converge", MGSL_EFAILED);
    }

  return MGSL_SUCCESS;
}


static mgsl_poly_complex_workspace * 
mgsl_poly_complex_workspace_alloc (size_t n)
{
  size_t nc ;

  mgsl_poly_complex_workspace * w ;
  
  if (n == 0)
    {
      MGSL_ERROR_VAL ("matrix size n must be positive integer", MGSL_EDOM, 0);
    }

  w = (mgsl_poly_complex_workspace *) 
    calloc (1, sizeof(mgsl_poly_complex_workspace));

  if (w == 0)
    {
      MGSL_ERROR_VAL ("failed to allocate space for struct", MGSL_ENOMEM, 0);
    }

  nc = n - 1;

  w->nc = nc;

  w->matrix = (mpfloat *) calloc (nc*nc, sizeof(mpfloat));

  if (w->matrix == 0)
    {
      free (w) ;       /* error in constructor, avoid memory leak */
      
      MGSL_ERROR_VAL ("failed to allocate space for workspace matrix", 
                        MGSL_ENOMEM, 0);
    }

  return w ;
}

static void 
mgsl_poly_complex_workspace_free (mgsl_poly_complex_workspace * w)
{
  if (!w) { return ; }
  free(w->matrix) ;
  free(w);
}

#if defined(TEST_MZSOLVE)

//  Compile with :
/*
g++ -o mzsolve src/mzsolve.cc -lmpfr -lquadmath -DTEST_MZSOLVE
*/

static mpfloat mgsl_hypot (const mpfloat x, const mpfloat y)
{
  mpfloat xabs = abs(x) ;
  mpfloat yabs = abs(y) ;
  mpfloat min, max;

  if (xabs < yabs) {
    min = xabs ;
    max = yabs ;
  } else {
    min = yabs ;
    max = xabs ;
  }

  if (min == 0) 
    {
      return max ;
    }

  {
    mpfloat u = min / max ;
    return max * sqrt (1 + u * u) ;
  }
}

int main (void)
{
  size_t N=20;
  mpfloat p[N+1] = {      1,     20,    190,     1140,     4845,
                      15504,  38760,  77520,   125970,   167960,
                     184756,
                     167960, 125970,  77520,    38760,    15504,
                       4845,   1140,    190,       20,        1 };
  
  mpfloat z[2*N];
  mgsl_poly_complex_workspace *w;
  w=mgsl_poly_complex_workspace_alloc(N+1);
  mgsl_poly_complex_solve (p, N+1, w, z);
  mgsl_poly_complex_workspace_free (w);
  
  std::cout << std::setprecision(10);
  for (size_t i = 0; i < N; i++)
    {
      mpfloat m = mgsl_hypot(z[2*i],z[2*i+1]);
      std::cout << z[2*i] << " " << z[2*i+1] << "(" << m << ")" << std::endl;
    }
  
  return 0;
}

#else

#include <octave/oct.h>

DEFUN_DLD(mzsolve, args, nargout, "r=mzsolve(p)")
{

  // Sanity checks
  octave_idx_type nargin=args.length();
  if ((nargin!=1) || (nargout>1))
    {
      print_usage();
    }
  if (args(0).is_complex_scalar() || args(0).is_complex_matrix())
    {
      error("Expected real argument!");
      return octave_value();
    }

  // Input arguments
  ColumnVector p = args(0).column_vector_value();
  
  if (p.numel()<=1)
    {
      Matrix r;
      octave_value_list retval(1);
      retval(0)=r;
      return retval;
    }

  // Count the leading zero coefficients 
  octave_idx_type num_leading_zeros=0;
  for(auto row=0;row<p.numel();row++)
    {
      if (p(row) != 0)
        {
          break;
        }
      num_leading_zeros++;
    }
  if (num_leading_zeros == p.numel())
    {
      octave_value_list retval(1);
      retval(0)=0;
      return retval;      
    }

  // Initialise arguments. 
  octave_idx_type N=p.numel()-num_leading_zeros;
  mpfloat a[N];
  for(auto row=0;row<N;row++)
    {
      a[row]=p(p.numel()-1-row);
    }

  // Call the solver. For a length N polynomial I expect N-1 zeros.
  mpfloat z[2*(N-1)];
  mgsl_poly_complex_workspace *w;
  w = mgsl_poly_complex_workspace_alloc (N);
  int res=mgsl_poly_complex_solve (a, N, w, z);
  mgsl_poly_complex_workspace_free (w);
  if (res)
    {
      octave_value_list retval(0);
      return retval;
    }
  
  // Done
  ComplexColumnVector r(N-1);
  for(auto row=0;row<(N-1);row++)
    {
      double tmpr=(z[2*row]).convert_to<double>();
      double tmpi=(z[(2*row)+1]).convert_to<double>();
      std::complex<double> tmp;
      tmp.real(tmpr);
      tmp.imag(tmpi);
      r(row)=tmp;
    }
  octave_value_list retval(1);
  retval(0)=r;

  return retval;
}
#endif

