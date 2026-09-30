#!/bin/bash
#SBATCH --job-name=jow_3d_particle_fluid_mf_cyl_v4_noslip_nozzle_q2q2_Re_480
#SBATCH --output=log.txt
#SBATCH --ntasks=128
#SBATCH --time=24:00:00

source ~/.job_launch
source ~/.lethe
mpirun -np 128 lethe-fluid-particles-matrix-free ./jow_3d_particle_fluid_mf_cyl_v4_noslip_nozzle_q2q2_Re_480.prm
source ~/.job_stop
