---
layout: post
title: On the Design of IIR Filters
---
An *Infinite-Impulse-Response* (IIR) filter can approximate a desired amplitude
response with fewer coefficients than a *Finite-Impulse-Response* (FIR)
filter.  The design of IIR filters is more difficult than the design of FIR
filters. FIR filters are inherently stable. An FIR filter design problem can
be formulated as a convex optimisation problem with a global solution. The
coefficient-response surface of an IIR filter rational polynomial transfer
function is more complicated than that of an FIR polynomial transfer
function. An IIR filter design procedure must find a locally optimal solution
that satisfies the response specifications and the coefficients of the IIR
transfer function denominator polynomial must be constrained to ensure that
the IIR filter is stable. The document
[DesignOfIIRFilters.pdf]({{ site.baseurl }}/public/DesignOfIIRFilters.pdf)
reports my experiments in the design of IIR filters with constraints on the
amplitude, phase and group delay responses and truncated or quantised
coefficients. I intended to show that it is possible to design a
*good-enough* IIR digital filter with coefficients that are implemented by
a limited number of shift-and-add operations and so do not require
software or hardware multiplications. I programmed these
experiments in the [Octave](https://www.gnu.org/software/octave)
language. Octave is an
[*almost*](https://wiki.octave.org/FAQ#Differences_between_Octave_and_Matlab)
compatible open-source-software clone of the commercial
[MATLAB](http://mathworks.com) package.

The *Minimum-Mean Squared Error* (MMSE)
approximation to the required IIR filter response is found by either a
*Sequential-Quadratic-Programming* (SQP) solver or by the
[SeDuMi](https://github.com/sqlp/sedumi) *Second-Order-Cone-Programming*
(SOCP) solver. The stability of the filter is ensured by constraining the pole
locations of the filter transfer function when expressed in *gain-pole-zero*
form or by constraining the *reflection coefficients* of a tapped all-pass
lattice filter implementation. A valid initial solution for the MMSE solver is
found by *eye* or by unconstrained optimisation with a *penalty* function.
Response constraints are applied with a *Peak-Constrained-Least-Squares* (PCLS)
exchange algorithm.

The lattice filter has good round-off noise and coefficient
sensitivity performance when implemented with integer coefficients. For
coefficient word lengths greater than 10-bits the coefficients are allocated
signed-digits and *branch-and-bound* or *relaxation* search is used to find an
acceptable response. For lesser coefficient word-lengths *simulated-annealing*
gives the best results.

## Optimising the IIR filter frequency response
One formulation of the filter optimisation problem is to
minimise the *weighted-squared-error* of the frequency response:

>**minimise**
>\\(E_{H}(x)=\int W(\omega)\left|H(x,\omega)-H_{d}(\omega)\right|^{2}d\omega\\)
>
>**subject to** \\(H\\) is stable

where \\(x\\) is the coefficient vector of the filter, \\(E_{H}\\) is
the weighted sum of the squared error, \\(W(\omega)\\) is the
frequency weighting, \\(H(x,\omega)\\) is the filter frequency
response and \\(H_{d}(\omega)\\) is the desired filter frequency
response. The solution proceeds by choosing an initial coefficient vector
and calling the SQP solver to find the coefficient vector that
optimises a second-order approximation to \\(E_{H}\\). The solution is
repeated until the difference between successive errors or
successive coefficient vectors is sufficiently small.

Alternatively, the optimisation problem can be expressed as a
*weighted-mini-max* problem:

>**minimise max**
>\\(W(\omega)\left|H(x,\omega)-H_{d}(\omega)\right|\\)
>
>**subject to** \\(H\\) is stable

Similarly, in this case, given an initial coefficient vector, the
solution proceeds by calling the SOCP solver to find the coefficient vector
that minimises the maximum error of a first-order approximation to \\(H\\).

When optimising the coefficients of the filter with integer values, the
*relaxation* solution proceeds by fixing a coefficient and optimising the
response over the remaining coefficients, repeating until all coefficients
have been fixed.

The following plot compares the pass-band and stop-band
amplitude responses and pass-band group delay responses for a one-multiplier
tapped all-pass lattice bandpass filter with a transfer function of order 20
and with denominator polynomial coefficients only in powers of \\(z^{2}\\).
The plot compares the responses with exact coefficients and with 10 bit integer
coefficients found by allocating an average of 3 signed-digits to each
coefficient and performing SQP-relaxation optimisation. The optimised
coefficient multiplications are implemented with 61 signed-digits and 31
shift-and-add operations.

![]({{ site.baseurl }}/public/sqp_relaxation_schurOneMlattice_bandpass_R2_10_nbits_test_intro.svg "Comparison of the responses of a one-multiplier lattice band-pass filter with exact coefficients and 3-signed-digit integer coefficients optimised with SQP-relaxation.")

## Reproducing my results
The Octave scripts included in this repository generate long sequences of
floating point operations. The results shown in the report were obtained on
my system running with a particular combination of CPU architecture, operating
system, library versions, compiler version and Octave version.
**Your system will almost certainly be different.**
**You may need to modify a script to run on your system**.

## About this page
This page was generated by the [Jekyll](http://jekyllrb.com) static site
generator using the [Poole](http://getpoole.com) theme by
[Mark Otto]({{ site.baseurl }}/LICENSE.md). The equations were rendered by
[MathJax](https://www.mathjax.org/).

