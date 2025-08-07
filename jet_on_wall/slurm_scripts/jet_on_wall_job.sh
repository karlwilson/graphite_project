#!/bin/bash
#SBATCH --time=0-02:00
#SBATCH --account=def-blaisbru
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=48G

export OMP_NUM_THREADS=1
ulimit -s 8192

source $HOME/.bashrc
source $HOME/.dealii
srun $HOME/lethe/inst/bin/lethe-fluid ../jet_on_wall_mini.prm
