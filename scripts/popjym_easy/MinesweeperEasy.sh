#!/bin/bash
#SBATCH --job-name=rtrrl_MinesweeperEasy
#SBATCH --partition=a3
#SBATCH --array=1-3
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:0
#SBATCH --mem=8G
#SBATCH --time=24:00:00
#SBATCH --output=logs/slurm/rtrrl_MinesweeperEasy_%A_%a.out
#SBATCH --chdir=/home/ciaran_sakana_ai/RTRRL-AAAI25
#SBATCH --export=ALL,JAX_PLATFORMS=cpu

ENV_NAME=MinesweeperEasy
SEED=$SLURM_ARRAY_TASK_ID
OUT_DIR="logs/runs/${ENV_NAME}_seed${SEED}_job${SLURM_ARRAY_JOB_ID}"
STDOUT_LOG="logs/slurm/rtrrl_${ENV_NAME}_${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out"
MANIFEST="logs/slurm/manifest.csv"

mkdir -p "$OUT_DIR" "$(dirname "$MANIFEST")"
if [ ! -s "$MANIFEST" ]; then
  echo "env,seed,array_job_id,task_id,output_dir,stdout_log" > "$MANIFEST"
fi
echo "${ENV_NAME},${SEED},${SLURM_ARRAY_JOB_ID},${SLURM_ARRAY_TASK_ID},${OUT_DIR},${STDOUT_LOG}" >> "$MANIFEST"

poetry run python rtrrl.py \
  --seed $SEED \
  --output_dir $OUT_DIR \
  --env_name $ENV_NAME \
  --hidden_size 32 \
  --gamma 0.99 \
  --optimizer_params_td.learning_rate 1e-4 \
  --optimizer_params_rnn.learning_rate 1e-4 \
  --optimizer_params_td.opt_name adam \
  --optimizer_params_rnn.opt_name adam \
  --optimizer_params_td.gradient_clip 1.0 \
  --optimizer_params_rnn.gradient_clip 1.0 \
  --eta_pi 1.0 \
  --entropy_rate 1e-5 \
  --lambda_pi 0.9 \
  --lambda_v 0.9 \
  --lambda_rnn 0.9 \
  --patience 0 \
  --normalize_obs False \
  --update_period 1 \
  --episodes 15000 \
  --steps 1000 \
  --logging streamrl
