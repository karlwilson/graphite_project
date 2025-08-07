#!/bin/bash
#SBATCH --time=1-00:00
#SBATCH --account=rrg-blaisbru
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --mem=249G

export OMP_NUM_THREADS=1
ulimit -s 8192

source $HOME/.bashrc
source $HOME/.dealii
srun $HOME/lethe/inst/bin/lethe-fluid $GRAPHITE_PATH/jet_on_wall/prm/jet_on_wall.prm
