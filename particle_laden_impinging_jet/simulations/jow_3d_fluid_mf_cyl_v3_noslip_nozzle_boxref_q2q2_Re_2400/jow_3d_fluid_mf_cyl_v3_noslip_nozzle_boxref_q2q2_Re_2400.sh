#!/bin/bash
#SBATCH --time=0-06:00
#SBATCH --account=rrg-blaisbru
#SBATCH --nodes=4
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=charles.wilson@etud.polymtl.ca
#SBATCH --mail-type=ALL
#SBATCH --job-name=jow_3d_fluid_mf_cyl_v3_noslip_nozzle_boxref_q2q2_Re_2400

export OMP_NUM_THREADS=1
ulimit -s 8192

export OMPI_MCA_btl_openib_warn_no_device_params_found=0

export PLIJ_PATH=$SCRATCH/graphite_project/particle_laden_impinging_jet
source $HOME/.dealii

# prm paths are relative to this directory
cd $PLIJ_PATH/simulations/jow_3d_fluid_mf_cyl_v3_noslip_nozzle_boxref_q2q2_Re_2400 || exit 1

mpirun $HOME/lethe/inst/bin/lethe-fluid-matrix-free ./jow_3d_fluid_mf_cyl_v3_noslip_nozzle_boxref_q2q2_Re_2400.prm
