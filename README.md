## DesignOfIIRFilters
This repository contains the files required to build the document
[*DesignOfIIRFilters.pdf*](docs/public/DesignOfIIRFilters.pdf) that
reports my experiments in the design of IIR filters with integer coefficients.

[Comments](mailto:designofiirfilters@gmail.com) and
[contributions](https://github.com/robertgj/DesignOfIIRFilters/pulls) are
welcome!

### Repository contents
* *Makefile*
* *DesignOfIIRFilters.tex* and *DesignOfIIRFilters.bib* are the TeX source files
* *fig* contains the [dia](https://github.com/GNOME/dia) files for line drawings
 included in *DesignOfIIRFilters.tex*
* *src* contains the [Octave](https://www.gnu.org/software/octave) source
 required to build figures and results included in *DesignOfIIRFilters.tex*.
 It contains forks of the  [SeDuMi](https://github.com/sqlp/sedumi) and
 [SparsePOP](http://sparsepop.sourceforge.net) projects
* *patch* contains the patch files that have been applied to create the local
 versions of Octave, SeDuMi and SparsePOP
* *test* contains regression test shell scripts for the Octave scripts in *src*
* *batchtest.sh* runs the regression tests. It is intended to be used by the
 [aegis](http://aegis.sourceforge.net) software configuration management system
 and the output of the script is in aegis format
* *benchmark* contains the scripts used to run the benchmarks referred to in
 *DesignOfIIRFilters.pdf*
* *docs* contains the source for the repository web page

### Building *DesignOfIIRFilters.pdf*
To build *DesignOfIIRFilters.pdf*, run *make* in the root directory. The
*Makefile* includes a *.mk* fragment from the *src* directory for each Octave
test script required to create the figures and results included in
*DesignOfIIRFilters.tex*.

You can run individual test scripts by running the Octave script in the *src*
directory or, if *src/name_of_script_test.mk* exists, by running
```make name_of_script_test.diary``` in the root directory. 

Useful *Makefile* targets are *octfiles*, *batchtest*, *cleanall*, *backup*,
*gitignore* and *jekyll*. The regression test scripts in the *test* directory
assume that the *octfile* dependencies exist.

### Dependencies
I use the [Fedora 25](https://getfedora.org/en/workstation/) operating system
with the *gcc-6.3.1*, *liblapack-3.6.1*, *dia-0.97.3* and *texlive-2016*
packages installed from the Fedora repository. The *texlive* packages used are
listed in *DesignOfIIRFilters.tex*. Fedora 25
[provides](https://apps.fedoraproject.org/packages/octave/overview/defaults)
Octave version 4.0.3 so I use a local build of
[octave-4.2.1](https://ftp.gnu.org/gnu/octave/octave-4.2.1.tar.gz) and the
[Octave-forge](https://octave.sourceforge.io) *struct*, *optim*, *control*,
*signal* and *parallel* packages. I use the Octave *gnuplot* graphics toolkit.

The repository web page is built from the sources in the *docs* directory by
the [*Jekyll*](http://jekyllrb.com) static web page generator.

### Building a local version of Octave
The file *patch/octave-4.2.1.patch* shows a small patch required to compile
octave-4.2.1. My version
of Octave is compiled with LTO and PGO and linked to the reference
[*liblapack*](http://www.netlib.org/lapack/) and
[*libblas*](http://www.openblas.net/) libraries:
```
#!/bin/sh

#
# Generate profile
#
OPTFLAGS="-m64 -mtune=generic -O2 -flto=6 -ffat-lto-objects -fPIC"
export CFLAGS=$OPTFLAGS
export CXXFLAGS=$OPTFLAGS
export FFLAGS=$OPTFLAGS
export LDFLAGS="-pthread -lpthread"

../octave-4.2.1/configure --disable-java --without-fltk --without-qt \
   --disable-atomic-refcount --with-blas=-lblas --with-lapack=-llapack
make XTRA_CFLAGS="-fprofile-generate" XTRA_CXXFLAGS="-fprofile-generate" V=1 -j6
find . -name \*.gcda -exec rm -f {} ';'
make check

#
# Use profile
#
find . -name \*.o -exec rm -f {} ';'
find . -name \*.lo -exec rm -f {} ';'
find . -name \*.la -exec rm -f {} ';'
make XTRA_CFLAGS="-fprofile-use" XTRA_CXXFLAGS="-fprofile-use" V=1 -j6
make install

#
# Install packages
#
/usr/local/bin/octave-cli \
    --eval 'pkg install -forge struct optim control signal parallel'
```

### Reproducing my results
The Octave scripts included in this repository generate long sequences of
floating point operations. The results shown in *DesignOfIIRFilters.pdf* were
obtained on my system running Octave with a particular combination of CPU
architecture, operating system, library versions, compiler version and Octave
version. The Octave on-line FAQ [discusses](https://wiki.octave.org/FAQ#Why_is_this_floating_point_computation_wrong.3F) this problem.

**Your system will almost certainly be different to mine.**

You may need to modify a script to run on your system. Try relaxing the
constraints on the filter design, relaxing the tolerance on the optimised
result or changing the relative weights on the filter bands. If your version
of *octave-4.2.1* is linked with *libopenblas* rather than *liblapack* then try:
```
export LD_PRELOAD="/usr/lib64/liblapack.so.3.6.1"
octave-cli -p src src/name_of_script_test.m
```

### External code and licencing
The *src* directory contains the following files included from
external sources as-is or with modifications:
* a fork of [SeDuMi](https://github.com/sqlp/sedumi)
* a fork of [SparsePOP](http://sparsepop.sourceforge.net)
* *local_max.m*, *cl2lp.m* and *cl2bp.m* by
 [Selesnick et al.](http://www.ece.rice.edu/dsp/software/cl2.shtml)
* *minphase.m* by Orchard and Willson from "On the Computation of a 
 Minimum-Phase Spectral Factor", IEEE Transactions on Circuits and
 Systems-I:Fundamental Theory and Applications, Vol. 50, No. 3, March 2003,
 pp. 365-375.
* *labudde.m* from the Ph.D. thesis of
 [Rehman](http://www.lib.ncsu.edu/resolver/1840.16/6262)
* *atog.m* and *gtor.m* from the book "Statistical Digital Signal 
 Processing and Modeling", John Wiley & Sons, 1996, by Hayes 

The *src* directory contains C++ files that use the Octave *octfile* interface.
The Octave on-line FAQ [states](https://wiki.octave.org/FAQ#If_I_write_code_using_Octave_do_I_have_to_release_it_under_the_GPL.3F):
>  Code written using Octave's native plug-in interface (also known as a .oct
>  file) necessarily links with Octave internals and is considered a derivative
>  work of Octave and therefore must be released under terms that are
>  compatible with the [GPL](GPLv3).

The *docs* directory contains a fork of the [Poole](http://getpoole.com)
theme for the [Jekyll](http://jekyllrb.com) static web page generator.

All other code is licenced under the [MIT license](LICENSE).
