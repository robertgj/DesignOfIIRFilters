/* 
 * Test uni_qdblflt() in reprand.cc has a uniform distribution. From:
 * http://rosettacode.org/wiki/Verify_distribution_uniformity/Chi-squared_test
 *
 * Compile with :
 *  gcc -std=c99 -Wall -o reprand_test reprand_test.c -lgsl
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <gsl/gsl_sf_gamma.h>

#define REPRAND_TEST

#include "reprand.cc"

double chi2UniformDistance( const double const *ds, int dslen)
{
    double expected = 0.0;
    double sum = 0.0;
    int k;
 
    for (k=0; k<dslen; k++) 
      {
        expected += ds[k];
      }
    expected /= k;
 
    for (k=0; k<dslen; k++) 
      {
        double x = ds[k] - expected;
        sum += x*x;
      } 
    return sum/expected;
}
 
double chi2Probability(double dof, double distance)
{
  return gsl_sf_gamma_inc_Q( 0.5*dof, 0.5*distance);
}
 
int chiIsUniform
( const double * const dset, const int dslen, const double significance)
{
    int dof = dslen -1;
    double dist = chi2UniformDistance( dset, dslen);
    return chi2Probability( dof, dist ) > significance;
}

int main(int argc, char **argv)
{
  /* Example sets */
  const double const dset1[] = { 199809., 200665., 199607., 200270., 199649. };
  const double const dset2[] = { 522573., 244456., 139979.,  71531.,  21461. };

  /* Data set for getRan() */
  const uint32_t N=0x10000;
  double dset_getRan[N];
  /* Initialise with getRan() */
  init_JKISS();
  for(uint32_t k=0;k<N;k++)
    {
      dset_getRan[k]=uni_qdblflt();
    }

  /* Run chi^2 tests. Start with the example sets */
  const double * const dsets[] = { dset1, dset2, dset_getRan };
  const uint32_t const dslens[] = { 5, 5, N };
  for (uint32_t k=0; k<sizeof(dslens)/sizeof(uint32_t); k++) 
    {
      double dist = chi2UniformDistance(dsets[k], dslens[k]);
      uint32_t dof = dslens[k]-1;
      double prob = chi2Probability( dof, dist ); 
      const double significance = 0.001;
      char * const uniform = 
        chiIsUniform(dsets[k], dslens[k], significance) ? "Yes":"No";

      printf("dof: %d, dist.: %.4f, prob.: %.6f, uniform? %s, sig. %.3f\n",
             dof, dist, prob, uniform, significance);
    } 

    return 0;
}
