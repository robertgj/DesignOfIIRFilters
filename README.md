## DesignOfIIRFilters
This repository contains the files required to build the document
[*DesignOfIIRFilters.pdf*](docs/public/DesignOfIIRFilters.pdf) that
reports my experiments in the design of IIR filters with integer coefficients.
[*DesignOfSchurLatticeFilters.pdf*](docs/public/DesignOfSchurLatticeFilters.pdf)
is a summary version.

[Comments](mailto:designofiirfilters@gmail.com) and
[contributions](https://github.com/robertgj/DesignOfIIRFilters/pulls) are
welcome!

### Repository contents
* *Makefile*
* *DesignOfIIRFilters.tex* and *DesignOfIIRFilters.bib* are the TeX source
  files.
* *build-octave.sh* builds a patched local version of
  [Octave](https://www.gnu.org/software/octave) and the required numerical
  libraries and installs the [SeDuMi](https://github.com/sqlp/sedumi),
  [SDPT3](https://github.com/sqlp/sdpt3)
  and [YALMIP](https://yalmip.github.io/) solvers from their GitHub repositories 
  and forks of the 
  [gloptipoly3](http://homepages.laas.fr/henrion/software/gloptipoly3) and
  [SparsePOP](http://sparsepop.sourceforge.net) solvers from my
  [repository](https://github.com/robertgj). 
* *patch* contains the patch files that have been applied to create forks
 [SparsePOP](http://sparsepop.sourceforge.net) and
* *batchtest.sh* runs the regression tests. It can be run standalone but is intended to be used by the
[aegis](https://sourceforge.net/projects/aegis/files/aegis/4.24/aegis-4.24.tar.gz/download)
 software configuration management system and the output of the script is in aegis format.
* *fig* contains the [dia](https://wiki.gnome.org/Apps/Dia) files for
  the line drawings included in *DesignOfIIRFilters.tex*.
* *src* contains the Octave m-files and C++ source required to create the
  figures and results included in *DesignOfIIRFilters.tex*. 
* *test* contains regression test shell scripts for the Octave scripts in *src*.
* *benchmark* contains the shell scripts used to run the benchmarks referred to
 in *DesignOfIIRFilters.pdf*.
* *docs* contains the source for the web page.

### Building *DesignOfIIRFilters.pdf*
To build *DesignOfIIRFilters.pdf*, run *make* in the root directory. The
*Makefile* includes a *.mk* fragment from the *src* directory for each Octave
m-file test script required to create the figures and results included in
*DesignOfIIRFilters.tex*.

Useful *Makefile* targets are ```octfiles```, ```batchtest```, ```cleanall```,
 ```backup```, ```gitignore```, ```jekyll```. If
 *src/name_of_script_test.mk* exists, then ```make name_of_script_test.diary```
 builds any oct- and mex-file dependencies and then runs the corresponding
 Octave script.

### Reproducing my results
The Octave scripts included in this repository generate long sequences of
floating point operations. The results shown in
[*DesignOfIIRFilters.pdf*](docs/public/DesignOfIIRFilters.pdf)
were obtained on my system running Octave with a particular combination of
CPU architecture, operating system, library versions, compiler version and
Octave version. **Your system will almost certainly be different to mine.**
The Octave on-line FAQ
[discusses](https://wiki.octave.org/FAQ#Why_is_Octave.27s_floating-point_computation_wrong.3F)
this. You may need to modify an Octave script to run on your system. Try
relaxing the constraints on the filter design, relaxing the tolerance on the
optimised result or changing the relative weights on the filter bands. I
endeavour to build the *DesignOfIIRFilters.pdf* document with user-mode
virtual machine QEMU emulation of an Intel Nehalem CPU.

### External source code and licensing

**Read the licences!**

* Octave, SeDuMi, SparsePOP and SDPT3 have a GPL licence.

* The YALMIP licence is MIT-style for non-commercial use with an
attribution clause. 
  
The *src* directory contains the following files included from
external sources as-is or with modifications:

* *faffine.m*, *local_max.m*, *cl2lp.m* and *cl2bp.m* by
 [Selesnick et al.](http://www.ece.rice.edu/dsp/software/rufilter.shtml)
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

All other code is licensed under the [MIT licence](LICENCE).
