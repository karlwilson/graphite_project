#!/bin/bash
#SBATCH --time=1-00:00
#SBATCH --account=rrg-blaisbru
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=96
#SBATCH --cpus-per-task=1
#SBATCH --mem=749G
#SBATCH --mail-user=charles.wilson@umontreal.ca
#SBATCH --mail-type=BEGIN,END,FAIL

export OMP_NUM_THREADS=1
ulimit -s 8192
set -e

source $HOME/.bashrc
source $HOME/.dealii
srun $HOME/lethe/inst/bin/lethe-fluid-matrix-free $GRAPHITE_PATH/jet_on_wall/prm/jet_on_wall_matrix_free.prm
