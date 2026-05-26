#!/bin/bash
# Submit all Variant A training jobs to SLURM.
# Does NOT submit cascade evaluation — run that manually after all jobs finish.
#
# Usage (from repo root):
#   bash scripts/submit_all.sh

set -euo pipefail

SCRIPTS=/home/arooba/compute-aware-vit-AI-assisted/scripts
mkdir -p "${SCRIPTS}/logs"

echo "Submitting Variant A training jobs..."
echo ""

# Step 1 — Dense baseline
JID=$(sbatch --parsable "${SCRIPTS}/run_baseline.sh")
echo "  run_baseline.sh       -> job ${JID}"

# Step 2 — Static pruning
JID=$(sbatch --parsable "${SCRIPTS}/run_static_25.sh")
echo "  run_static_25.sh      -> job ${JID}"

JID=$(sbatch --parsable "${SCRIPTS}/run_static_50.sh")
echo "  run_static_50.sh      -> job ${JID}"

JID=$(sbatch --parsable "${SCRIPTS}/run_static_75.sh")
echo "  run_static_75.sh      -> job ${JID}"

# Step 3 — Fixed-budget (cascade building blocks)
JID=$(sbatch --parsable "${SCRIPTS}/run_fixed_25.sh")
echo "  run_fixed_25.sh       -> job ${JID}"

JID=$(sbatch --parsable "${SCRIPTS}/run_fixed_50.sh")
echo "  run_fixed_50.sh       -> job ${JID}"

JID=$(sbatch --parsable "${SCRIPTS}/run_fixed_75.sh")
echo "  run_fixed_75.sh       -> job ${JID}"

# Step 4 — Dynamic controller
JID=$(sbatch --parsable "${SCRIPTS}/run_controller.sh")
echo "  run_controller.sh     -> job ${JID}"

echo ""
echo "All 8 jobs submitted. Monitor with: squeue -u \$(whoami)"
echo "Logs: ${SCRIPTS}/logs/"
echo ""
echo "Next step after all jobs finish:"
echo "  Update configs/cascade.yaml with the baseline checkpoint path, then:"
echo "  cd variant_a && conda run -n ai_assisted_env python eval_cascade.py --config configs/cascade.yaml"
