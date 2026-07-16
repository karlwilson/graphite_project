#!/bin/bash
#SBATCH --job-name=charles-jow_3d_fluid_mf_lab_specs_cylindrical_boxref_q2q2_fine_chebyshev_Re_960_lucille
#SBATCH --output=log.txt
#SBATCH --ntasks=128
#SBATCH --time=24:00:00


source ~/.job_launch
source ~/.lethe
mpirun -np 128 lethe-fluid-matrix-free /data/charles/graphite_project/particle_laden_impinging_jet/simulations/jow_3d_fluid_mf_lab_specs_cylindrical_boxref_q2q2_fine_chebyshev_Re_960_lucille/jow_3d_fluid_mf_lab_specs_cylindrical_boxref_q2q2_fine_chebyshev_Re_960_lucille.prm
source ~/.job_stop
