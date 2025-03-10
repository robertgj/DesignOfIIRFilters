// qroots.cc - find the roots of a polynomial with quad float arithmetic

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

#include <quadmath.h>
#include <stdlib.h>
#include <stdio.h>

/* From complex/gsl_complex.h: */
typedef __float128 *       qgsl_complex_packed_ptr ;

/* From poly/gsl_poly.h : */
typedef struct 
{ 
  size_t nc ;
  __float128 * matrix ; 
} 
qgsl_poly_complex_workspace ;

/* From complex/gsl_complex.h: */
#define QGSL_SET_COMPLEX_PACKED(zp,n,x,y) do {*((zp)+2*(n))=(x); \
                                              *((zp)+(2*(n)+1))=(y);} while(0)
/* From err/gsl_errno.h: */
enum { 
  QGSL_SUCCESS  = 0,
  QGSL_FAILURE  = -1,
  QGSL_EDOM     = 1,   /* input domain error, e.g sqrtq(-1) */
  QGSL_EINVAL   = 4,   /* invalid argument supplied by user */
  QGSL_EFAILED  = 5,   /* generic failure */
  QGSL_ENOMEM   = 8,   /* malloc failed */
} ;
#define QGSL_ERROR(reason, qgsl_errno) \
  fflush (stdout); \
  do { \
   fprintf(stderr,"ERROR (%s:%d) %s\n",__FILE__,__LINE__,reason); \
   fflush (stderr); \
   return qgsl_errno ; \
  } while (0)
#define QGSL_ERROR_VAL(reason, qgsl_errno, value) \
  fflush (stdout); \
  do { \
   fprintf(stderr,"ERROR %d (%s:%d) %s\n",qgsl_errno,__FILE__,__LINE__,reason); \
   fflush (stderr); \
   return value ; \
  } while (0)

/* C-style matrix elements */
#define MAT(m,i,j,n) ((m)[(i)*(n) + (j)])

/* Fortran-style matrix elements */
#define FMAT(m,i,j,n) ((m)[((i)-1)*(n) + ((j)-1)])

static void
set_companion_matrix (const __float128 *a, size_t nc, __float128 *m)
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
balance_companion_matrix (__float128 *m, size_t nc)
{
  int not_converged = 1;

  __float128 row_norm = 0;
  __float128 col_norm = 0;

  while (not_converged)
    {
      size_t i, j;
      __float128 g, f, s;

      not_converged = 0;

      for (i = 0; i < nc; i++)
        {
          /* column norm, excluding the diagonal */

          if (i != nc - 1)
            {
              col_norm = fabsq (MAT (m, i + 1, i, nc));
            }
          else
            {
              col_norm = 0;

              for (j = 0; j < nc - 1; j++)
                {
                  col_norm += fabsq (MAT (m, j, nc - 1, nc));
                }
            }

          /* row norm, excluding the diagonal */

          if (i == 0)
            {
              row_norm = fabsq (MAT (m, 0, nc - 1, nc));
            }
          else if (i == nc - 1)
            {
              row_norm = fabsq (MAT (m, i, i - 1, nc));
            }
          else
            {
              row_norm = (fabsq (MAT (m, i, i - 1, nc)) 
                          + fabsq (MAT (m, i, nc - 1, nc)));
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
qr_companion (__float128 *h, size_t nc, qgsl_complex_packed_ptr zroot)
{
  __float128 t = 0.0;

  size_t iterations, e, i, j, k, m;

  __float128 w, x, y, s, z;

  __float128 p = 0, q = 0, r = 0; 

  /* FIXME: if p,q,r, are not set to zero then the compiler complains
     that they ``might be used uninitialized in this
     function''. Looking at the code this does seem possible, so this
     should be checked. */

  int notlast;

  size_t n = nc;

next_root:

  if (n == 0)
    return QGSL_SUCCESS ;

  iterations = 0;

next_iteration:

  for (e = n; e >= 2; e--)
    {
      __float128 a1 = fabsq (FMAT (h, e, e - 1, nc));
      __float128 a2 = fabsq (FMAT (h, e - 1, e - 1, nc));
      __float128 a3 = fabsq (FMAT (h, e, e, nc));

      if (a1 <= FLT128_EPSILON * (a2 + a3))
        break;
    }

  x = FMAT (h, n, n, nc);

  if (e == n)
    {
      QGSL_SET_COMPLEX_PACKED (zroot, n-1, x + t, 0); /* one real root */
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
      y = sqrtq (fabsq (q));

      x += t;

      if (q > 0)                /* two real roots */
        {
          if (p < 0)
            y = -y;
          y += p;

          QGSL_SET_COMPLEX_PACKED (zroot, n-1, x - w / y, 0);
          QGSL_SET_COMPLEX_PACKED (zroot, n-2, x + y, 0);
        }
      else
        {
          QGSL_SET_COMPLEX_PACKED (zroot, n-1, x + p, -y);
          QGSL_SET_COMPLEX_PACKED (zroot, n-2, x + p, y);
        }
      n -= 2;

      goto next_root;
      /*continue;*/
    }

  /* No more roots found yet, do another iteration */

  if (iterations == 240)  /* increased from 30 to 120 */
    {
      /* too many iterations - give up! */

      return QGSL_FAILURE ;
    }

  if (iterations % 10 == 0 && iterations > 0)
    {
      /* use an exceptional shift */

      t += x;

      for (i = 1; i <= n; i++)
        {
          FMAT (h, i, i, nc) -= x;
        }

      s = fabsq (FMAT (h, n, n - 1, nc)) + fabsq (FMAT (h, n - 1, n - 2, nc));
      y = 0.75 * s;
      x = y;
      w = -0.4375 * s * s;
    }

  iterations++;

  for (m = n - 2; m >= e; m--)
    {
      __float128 a1, a2, a3;

      z = FMAT (h, m, m, nc);
      r = x - z;
      s = y - z;
      p = FMAT (h, m, m + 1, nc) + (r * s - w) / FMAT (h, m + 1, m, nc);
      q = FMAT (h, m + 1, m + 1, nc) - z - r - s;
      r = FMAT (h, m + 2, m + 1, nc);
      s = fabsq (p) + fabsq (q) + fabsq (r);
      p /= s;
      q /= s;
      r /= s;

      if (m == e)
        break;
      
      a1 = fabsq (FMAT (h, m, m - 1, nc));
      a2 = fabsq (FMAT (h, m - 1, m - 1, nc));
      a3 = fabsq (FMAT (h, m + 1, m + 1, nc));

      if (a1 * (fabsq (q) + fabsq (r)) <= FLT128_EPSILON * fabsq (p) * (a2 + a3))
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

  /* __float128 QR step */

  for (k = m; k <= n - 1; k++)
    {
      notlast = (k != n - 1);

      if (k != m)
        {
          p = FMAT (h, k, k - 1, nc);
          q = FMAT (h, k + 1, k - 1, nc);
          r = notlast ? FMAT (h, k + 2, k - 1, nc) : 0.0;

          x = fabsq (p) + fabsq (q) + fabsq (r);

          if (x == 0)
            continue;           /* FIXME????? */

          p /= x;
          q /= x;
          r /= x;
        }

      s = sqrtq (p * p + q * q + r * r);

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
qgsl_poly_complex_solve (const __float128 *a, size_t n,
                        qgsl_poly_complex_workspace * w,
                        qgsl_complex_packed_ptr z)
{
  int status;
  __float128 *m;

  if (n == 0)
    {
      QGSL_ERROR ("number of terms must be a positive integer", QGSL_EINVAL);
    }

  if (n == 1)
    {
      QGSL_ERROR ("cannot solve for only one term", QGSL_EINVAL);
    }

  if (a[n - 1] == 0)
    {
      QGSL_ERROR ("leading term of polynomial must be non-zero", QGSL_EINVAL) ;
    }

  if (w->nc != n - 1)
    {
      QGSL_ERROR ("size of workspace does not match polynomial", QGSL_EINVAL);
    }
  
  m = w->matrix;

  set_companion_matrix (a, n - 1, m);

  balance_companion_matrix (m, n - 1);

  status = qr_companion (m, n - 1, z);

  if (status)
    {
      QGSL_ERROR("root solving qr method failed to converge", QGSL_EFAILED);
    }

  return QGSL_SUCCESS;
}


static qgsl_poly_complex_workspace * 
qgsl_poly_complex_workspace_alloc (size_t n)
{
  size_t nc ;

  qgsl_poly_complex_workspace * w ;
  
  if (n == 0)
    {
      QGSL_ERROR_VAL ("matrix size n must be positive integer", QGSL_EDOM, 0);
    }

  w = (qgsl_poly_complex_workspace *) 
    malloc (sizeof(qgsl_poly_complex_workspace));

  if (w == 0)
    {
      QGSL_ERROR_VAL ("failed to allocate space for struct", QGSL_ENOMEM, 0);
    }

  nc = n - 1;

  w->nc = nc;

  w->matrix = (__float128 *) malloc (nc * nc * sizeof(__float128));

  if (w->matrix == 0)
    {
      free (w) ;       /* error in constructor, avoid memory leak */
      
      QGSL_ERROR_VAL ("failed to allocate space for workspace matrix", 
                        QGSL_ENOMEM, 0);
    }

  return w ;
}

static void 
qgsl_poly_complex_workspace_free (qgsl_poly_complex_workspace * w)
{
  if (!w) { return ; }
  free(w->matrix) ;
  free(w);
}

#if defined(TEST_QROOTS)

/* Compile with : g++ -o qroots qroots.cc -lquadmath -DTEST_QROOTS */

static __float128 qgsl_hypot (const __float128 x, const __float128 y)
{
  __float128 xabs = fabsq(x) ;
  __float128 yabs = fabsq(y) ;
  __float128 min, max;

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
    __float128 u = min / max ;
    return max * sqrtq (1 + u * u) ;
  }
}

int
main (void)
{
  size_t N1=20;
  __float128 pt1[N1+1] = {      1,     20,    190,     1140,     4845,
                            15504,  38760,  77520,   125970,   167960,
                           184756,
                           167960, 125970,  77520,    38760,    15504,
                             4845,   1140,    190,       20,        1 }; 
  size_t N2=5;
  __float128 pt2[N2+1]={  1.0000, -3.6247,  5.4033, -4.1093,  1.5890, -0.2491 };
  
  const size_t num_tests=2;
  struct ptest {size_t N; __float128 *p;} pt[num_tests] = {{N1,pt1}, {N2,pt2}};
  
  for (size_t n=0;n<num_tests;n++)
    {
      __float128 z[2*(pt[n].N)];

      qgsl_poly_complex_workspace * w 
        = qgsl_poly_complex_workspace_alloc ((pt[n].N)+1);
  
      qgsl_poly_complex_solve (pt[n].p, (pt[n].N)+1, w, z);

      qgsl_poly_complex_workspace_free (w);

      for (size_t i = 0; i < pt[n].N; i++)
        {
          size_t width=36;
          char bufr[128];
          char bufi[128];
          char bufm[128];

          quadmath_snprintf (bufr, sizeof(bufr),"%+-#*.30Qe",width, z[2*i]);
          quadmath_snprintf (bufi, sizeof(bufi),"%+-#*.30Qe",width, z[2*i+1]);
          __float128 m = qgsl_hypot(z[2*i],z[2*i+1]);
          quadmath_snprintf (bufm, sizeof(bufm),"%+-#*.30Qe",width, m);
          printf ("z%d=%s %s \n(%s)\n", i, bufr, bufi, bufm);
        }
    }

  return 0;
}
#else
// Compile with:
/*
    mkoctfile -o qroots.oct -march=native -O2 -Wall -lquadmath \
     -lgmp -lmpfr -fext-numeric-literals qroots.cc
*/

#include <octave/oct.h>

DEFUN_DLD(qroots, args, nargout, "r=qroots(p) \n p is assumed real")
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
  __float128 a[N];
  for(auto row=0;row<N;row++)
    {
      a[row]=p(p.numel()-1-row);
    }

  // Call the solver. For a length N polynomial I expect N-1 zeros.
  __float128 z[2*(N-1)];
  qgsl_poly_complex_workspace * w = qgsl_poly_complex_workspace_alloc (N);
  int res=qgsl_poly_complex_solve (a, N, w, z);
  qgsl_poly_complex_workspace_free (w);
  if (res)
    {
      octave_value_list retval(0);
      return retval;
    }
  
  // Copy to an Octave vector
  ComplexColumnVector r(N-1);
  for(auto row=0;row<(N-1);row++)
    {
      double tmpr=z[2*row];
      double tmpi=z[(2*row)+1];
      std::complex<double> tmp;
      tmp.real(tmpr);
      tmp.imag(tmpi);
      r(row)=tmp;
    }

  // Sort r by abs(r) in descending order
  ColumnVector rabs(N-1);
  rabs=r.abs();
  Array<octave_idx_type> idx = rabs.sort_rows_idx (DESCENDING);
  ComplexColumnVector rsorted(N-1);
  for(auto row=0;row<(N-1);row++)
    {
      rsorted(row)=r(idx(row));
    }

  // Done
  octave_value_list retval(1);
  retval(0)=rsorted;

  return retval;
}

#endif
