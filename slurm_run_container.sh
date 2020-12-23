#!/bin/bash
# Use this if you want to minimally run the container on a SLURM node
srun --pty ./singularity_run_container.sh

# Use this if you want to enforce a GPU node (with maximum time dd-hh:mm:ss)
# srun --gres=gpu --time 21-00:00:00 --pty ./singularity_run_container.sh

# Use this if you want a specific machine (with maximum time dd-hh:mm:ss)
# srun --nodelist=lebkuchen --time 21-00:00:00 --pty ./singularity_run_container.sh
