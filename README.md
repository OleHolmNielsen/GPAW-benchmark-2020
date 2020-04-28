# GPAW-benchmark-2020

GPAW code building instructions and benchmark data
--------------------------------------------------

The purpose of this page is to document the building of the [GPAW](https://wiki.fysik.dtu.dk/gpaw/) code release version 20.1.0.
Subsequently a GPAW test and a GPAW benchmark run is documented.

The benchmarks are designed to reflect our HPC software environment,
and to run some representative physics problems using the GPAW code.

The prerequisite operating system is CentOS 7.7 (or compatible, for example
Red Hat RHEL 7 Update 7).

We require using the [EasyBuild](https://github.com/hpcugent/easybuild)
software build and installation framework that allows you to manage
(scientific) software on High Performance Computing (HPC) systems in an efficient way.
These instructions are based upon EasyBuild version 4.2.0.

In order to have a well-defined and reproducible software modules framework 
for the purpose of comparing benchmark results obtained on different systems,
we require the use of specific software module toolchains provided by EasyBuild version 4.2.0.
Future versions of EasyBuild will contain newer toolchains in addition to
the ones used in the present instruction.

The benchmark requires to build the GPAW code using one or both of the following 
EasyBuild software module toolchains:

1. intel-2019b: icc, ifort, imkl, impi

2. foss-2019b: BLACS, FFTW, GCC, OpenBLAS, OpenMPI, ScaLAPACK

The foss toolchain uses only Open Source software,
whereas the intel toolchain requires licensed Intel C and Fortran compilers 
as well as the Intel MKL and MPI libraries.
For systems with processors that include AVX-512 vector support,
it is expected that the MKL library will offer the best performance.

Step 1: Installing Lmod
-----------------------

A software modules tool is a prerequisite, and the recommended tool is
[Lmod](https://www.tacc.utexas.edu/research-development/tacc-projects/lmod).

Brief Lmod installation instructions for CentOS 7 may be found in
https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#install-lmod.
The root superuser may install the Lmod RPM by:

```
yum install epel-release
yum install Lmod
```

A non-root user can install Lmod as documented in http://easybuild.readthedocs.io/en/latest/Installing-Lmod-without-root-permissions.html

Step 2: Installing EasyBuild
----------------------------

EasyBuild must be installed as a normal user.

NOTICE: EasyBuild by default builds binary application codes which are optimized 
for the host/node CPU architecture.  Therefore all software must be built on the 
same type of CPU architecture that the software will eventually run on.
If you build software on an older CPU architecture, the code will only use CPU instructions
available on the old CPU architecture, and hence potentially be mush slower 
than it should be!

The CPU architecture may be printed using the command:
```
gcc -march=native -Q --help=target | grep march
```
This information is only available with the GCC compiler version 4.9 and newer.
Also the ```lscpu``` will reveal information about the type of CPU.

Brief EasyBuild installation instructions for CentOS 7 may be found in
https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules.
There is an official
[EasyBuild installation](https://easybuild.readthedocs.io/en/latest/Installation.html) 
guide with detailed instructions.

Define the top-level directory and modules tool for your modules, for example:

```
mkdir $HOME/modules
export EASYBUILD_PREFIX=$HOME/modules
export EASYBUILD_MODULES_TOOL=Lmod
```
where $HOME is the normal user's home directory.

Download and install EasyBuild:

```
curl -O https://raw.githubusercontent.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py
python bootstrap_eb.py $EASYBUILD_PREFIX
```

Update the $MODULEPATH by module use, 
then load the EasyBuild module and check the basic EasyBuild functionality:

```
module use $EASYBUILD_PREFIX/modules/all
module load EasyBuild
module list
eb --version
```

The EasyBuild version must be 4.2.0 or newer.

Step 3: Build the foss-2019b toolchain
--------------------------------------

EasyBuild version 4.2.0 (and newer) contains the foss-2019b toolchain which must be used to build GPAW.
The foss toolchain contains the following modules:

```
BLACS, FFTW, GCC, OpenBLAS, OpenMPI, ScaLAPACK
```

To build the foss-2019b toolchain run this command:

```
eb foss-2019b.eb -r
```

The building of GCC, OpenMPI and FFTW will be particularly time consuming,
and this task may take several hours!

Now the foss toolchain modules can be loaded:

```
$ module load foss/2019b
$ module list
Currently Loaded Modules:
  1) GCCcore/8.3.0                     9) hwloc/1.11.12-GCCcore-8.3.0
  2) zlib/1.2.11-GCCcore-8.3.0        10) OpenMPI/3.1.4-GCC-8.3.0
  3) binutils/2.32-GCCcore-8.3.0      11) OpenBLAS/0.3.7-GCC-8.3.0
  4) GCC/8.3.0                        12) gompi/2019b
  5) numactl/2.0.12-GCCcore-8.3.0     13) FFTW/3.3.8-gompi-2019b
  6) XZ/5.2.4-GCCcore-8.3.0           14) ScaLAPACK/2.0.2-gompi-2019b
  7) libxml2/2.9.9-GCCcore-8.3.0      15) foss/2019b
  8) libpciaccess/0.14-GCCcore-8.3.0
```

Step 4: Build the intel-2019b toolchain
---------------------------------------

EasyBuild version 4.2.0 (and later) contains the intel-2019b toolchain which must be used to build GPAW.
The intel toolchain contains the following modules:

```
icc, ifort, imkl, impi
```

The Intel compilers icc, ifort, the MKL and MPI libraries are products offered by Intel.
The intel-2019b toolchain requires exactly the Intel *Parallel Studio XE 2019 Update 5* version.

There are useful hints about Intel compiler installation and licenses in the web page
https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#intel-compiler-toolchains

Specify your Intel *license-server* host port 28518 (for example) or just the license file path:

```
export INTEL_LICENSE_FILE=28518@<license-server>
export INTEL_LICENSE_FILE=<file-path>
```

To build the intel-2019b toolchain first download the compiler and library tar-ball files as described in 
https://wiki.fysik.dtu.dk/niflheim/EasyBuild_modules#intel-compiler-toolchains
and move these files to the EasyBuild source directories:

```
mkdir -p $HOME/modules/sources/i/icc $HOME/modules/sources/i/ifort $HOME/modules/sources/i/imkl $HOME/modules/sources/i/impi
mv parallel_studio_xe_2019_update5_composer_edition.tgz $HOME/modules/sources/i/iccifort/
mv l_mkl_2019.5.281.tgz $HOME/modules/sources/i/imkl/
mv l_mpi_2018.5.288.tgz $HOME/modules/sources/i/impi/
```

Then run this command to build the intel toolchain:

```
eb intel-2019b.eb -r
```

Now the intel toolchain modules can be loaded:

```
$ module load intel/2019b
$ module list

Currently Loaded Modules:
  1) GCCcore/8.3.0                 5) impi/2018.5.288-iccifort-2019.5.281
  2) zlib/1.2.11-GCCcore-8.3.0     6) iimpi/2019b
  3) binutils/2.32-GCCcore-8.3.0   7) imkl/2019.5.281-iimpi-2019b
  4) iccifort/2019.5.281           8) intel/2019b
```

Build GPAW using the foss-2019b toolchain
-----------------------------------------

The GPAW release version 20.1.0 package is part of the EasyBuild official releases.

Build the GPAW, GPAW-setups and ASE software modules with foss-2019b by:
```
eb GPAW-20.1.0-foss-2019b-Python-3.7.4.eb -r
```

Build GPAW using the intel-2019b toolchain
------------------------------------------

The GPAW release version 20.1.0 package is part of the EasyBuild official releases.

Build the GPAW, GPAW-setups and ASE software modules with intel-2019b by:
```
eb GPAW-20.1.0-intel-2019b-Python-3.7.4.eb -r
```

Run GPAW verification tests
---------------------------

The GPAW verification tests are described in https://wiki.fysik.dtu.dk/gpaw/install.html#run-the-tests

First select ONE of the GPAW modules as built in the above:
```
module load GPAW/20.1.0-intel-2019b-Python-3.7.4
# module load GPAW/20.1.0-foss-2019b-Python-3.7.4
module list
```

The verification tests should be executed with 8 single-threaded MPI tasks by:

```
export OMP_NUM_THREADS=1 
gpaw -P 8 test 
```

Warning messages and “SKIPPED” tests in the test suite output are accepted, but FAILED tests are not acceptable and must be corrected.
The following success message must be printed at the end of the output file:
```
All tests passed!
```

An example output file is [gpaw_test.txt](gpaw_test.txt/).

Run the GPAW benchmarks
-----------------------

The subdirectory [benchmarks](benchmarks/) contains the Python scripts,
batch job shell scripts, and any further input files.
The shell scripts are configured for the [Slurm](https://slurm.schedmd.com/overview.html)
resource manager and may be adopted for other systems easily, or even run interactively.

The batch jobs script files in [benchmarks](benchmarks/) are:
```
Benchmark 1: MoS2-benchmark.sh
Benchmark 2: Ru2Cl6-benchmark.sh
```

The GPAW module with either intel or foss toolchain must be uncommented:

```
# Select ONE of these modules:
module load GPAW/20.1.0-intel-2019b-Python-3.7.4
# module load GPAW/20.1.0-foss-2019b-Python-3.7.4
```

The script must then be executed interactively or submitted to a batch queue.
Scripts must be run in the [benchmarks](benchmarks/) directory because the
Python and json input files are required.

After completing the benchmarks, results have been written to the output files :
```
Benchmark 1: MoS2-benchmark.txt
Benchmark 2: Ru2Cl6-benchmark.txt
```

Verification of correctness
---------------------------

In order to verify that the benchmark calculations have produced correct results,
numerical values in the sample output files should be compared to the reference output files.
Here the [meld](http://meldmerge.org/) visual diff and merge tool can be very useful.
The meld RPM package is available from the
[EPEL](https://fedoraproject.org/wiki/EPEL) repository.

To quickly verify the results, a few numbers from the output files may be extracted as follows:

Benchmark 1:
```
$ grep Free MoS2-benchmark.txt
Free energy:   -1287.175021
```

Benchmark 2:
```
$ grep Free Ru2Cl6-benchmark.txt
Free energy:    -29.285034
```

It is expected that the mentioned numbers should vary only in the last digit by a small amount.

Recording of timings
--------------------

The GPAW code records the elapsed wall-clock time and prints it at the end of
the output files, for example:
```
$ grep Total: MoS2-benchmark.txt
Total:                                      6596.520 100.0%
$ grep Total: Ru2Cl6-benchmark.txt 
Total:                                       720.983 100.0%
```

These ```Total:``` timings for Benchmarks 1 and 2 must be collected and rounded down to the nearest integer.
The complete output files must also be collected and submitted.
