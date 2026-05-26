#!/bin/bash
#SBATCH --job-name=fixed_25
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --mem=20G
#SBATCH --time=24:00:00
#SBATCH --output=/home/arooba/compute-aware-vit-AI-assisted/scripts/logs/fixed_25_%j.out
#SBATCH --error=/home/arooba/compute-aware-vit-AI-assisted/scripts/logs/fixed_25_%j.err

set -euo pipefail

echo "Job ID   : ${SLURM_JOB_ID}"
echo "Node     : ${SLURMD_NODENAME}"
echo "Started  : $(date)"

mkdir -p /home/arooba/compute-aware-vit-AI-assisted/scripts/logs

source /home/arooba/miniconda3/etc/profile.d/conda.sh
conda activate ai_assisted_env

cd /home/arooba/compute-aware-vit-AI-assisted/variant_a
echo "Workdir  : $(pwd)"
echo "Python   : $(which python)"

nohup python train_dynamic_fixed.py --config configs/fixed_budget_25.yaml

echo "Finished : $(date)"
