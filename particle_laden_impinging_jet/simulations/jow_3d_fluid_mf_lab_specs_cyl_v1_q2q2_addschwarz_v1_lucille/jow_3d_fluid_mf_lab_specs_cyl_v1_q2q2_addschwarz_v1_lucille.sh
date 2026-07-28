#!/bin/bash
#SBATCH --job-name=charles-jow_3d_fluid_mf_lab_specs_cyl_v1_q2q2_addschwarz_v1_lucille
#SBATCH --output=log.txt
#SBATCH --ntasks=128
#SBATCH --time=24:00:00


source ~/.job_launch
source ~/.lethe
mpirun -np 128 lethe-fluid-matrix-free /data/charles/graphite_project/particle_laden_impinging_jet/prm/jow_3d_fluid_mf_lab_specs_cyl_v1_q2q2_addschwarz_v1_lucille.prm
source ~/.job_stop
