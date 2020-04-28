#!/bin/bash
#SBATCH --job-name=Ru2Cl6-benchmark
#SBATCH --mail-type=START,END
#SBATCH --partition=xeon40
#SBATCH --output=%x-%j.out
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=40
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G

# This is a Slurm batch job script for the Ru2Cl6-benchmark.py benchmark.
# It is assumed that a GPAW 1.4 software module can be loaded.

echo Hostname: `hostname`
echo CPU type:
lscpu

module purge
echo
echo module load GPAW
# Select ONE of these modules:
# module load GPAW/20.1.0-intel-2019b-Python-3.7.4
# module load GPAW/20.1.0-foss-2019b-Python-3.7.4

module load GPAW
mpiexec gpaw info
module list
printenv | grep SLURM

# Run 1 thread per task
export OMP_NUM_THREADS=1

# mpiexec gpaw-python Ru2Cl6-benchmark.py
echo Running GPAW with $SLURM_NTASKS tasks.
mpiexec gpaw -P $SLURM_NTASKS python Ru2Cl6-benchmark.py
# Remove data file
rm -f Ru2Cl6-benchmark.gpw

echo Extract numbers for correctness and timing
grep Free Ru2Cl6-benchmark.txt
grep Total: Ru2Cl6-benchmark.txt
