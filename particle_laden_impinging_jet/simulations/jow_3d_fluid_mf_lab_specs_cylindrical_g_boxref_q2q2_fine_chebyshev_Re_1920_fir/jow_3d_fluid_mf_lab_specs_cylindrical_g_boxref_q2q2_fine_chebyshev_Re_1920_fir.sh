#!/bin/bash
#SBATCH --time=0-06:00
#SBATCH --account=def-blaisbru
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=192
#SBATCH --cpus-per-task=1
#SBATCH --mem=750G
#SBATCH --mail-user=charles.wilson@etud.polymtl.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=jow_3d_fluid_mf_lab_specs_cylindrical_g_boxref_q2q2_fine_chebyshev_Re_1920_fir

export OMP_NUM_THREADS=1
ulimit -s 8192

export OMPI_MCA_btl_openib_warn_no_device_params_found=0

export PLIJ_PATH=$SCRATCH/graphite_project/particle_laden_impinging_jet
source $HOME/.dealii

# prm paths are relative to this directory
cd $PLIJ_PATH/simulations/jow_3d_fluid_mf_lab_specs_cylindrical_g_boxref_q2q2_fine_chebyshev_Re_1920_fir || exit 1

srun $HOME/lethe/inst/bin/lethe-fluid-matrix-free ./jow_3d_fluid_mf_lab_specs_cylindrical_g_boxref_q2q2_fine_chebyshev_Re_1920_fir.prm
