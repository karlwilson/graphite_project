#!/bin/bash
#SBATCH --time=0-06:00
#SBATCH --account=def-blaisbru
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --mem=750G
#SBATCH --mail-user=charles.wilson@etud.polymtl.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=jow_3d_fluid_mf_lab_specs_boxref_q1q1_fine_lucille

export OMP_NUM_THREADS=1
ulimit -s 8192

export OMPI_MCA_btl_openib_warn_no_device_params_found=0

source $HOME/.bashrc
source $HOME/.dealii

# prm paths are relative to this directory
cd $PLIJ_PATH/simulations/jow_3d_fluid_mf_lab_specs_boxref_q1q1_fine_lucille || exit 1

mpirun $HOME/lethe/inst/bin/lethe-fluid-matrix-free ./jow_3d_fluid_mf_lab_specs_boxref_q1q1_fine_lucille.prm
