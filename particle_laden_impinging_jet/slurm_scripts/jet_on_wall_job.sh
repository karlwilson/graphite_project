#!/bin/bash
#SBATCH --time=06:00:00
#SBATCH --account=rrg-blaisbru
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=192
#SBATCH --mail-user=charles.wilson@umontreal.ca
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCG --job-name=jet_on_wall_2d_fluid

export OMP_NUM_THREADS=1
ulimit -s 8192
set -e

source $HOME/.bashrc
source $HOME/.dealii
srun $HOME/lethe/inst/bin/lethe-fluid $GRAPHITE_PATH/particle_laden_impinging_jet/prm/jet_on_wall_2d_fluid.prm

