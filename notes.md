# Benchmarking

## Launch all jobs

```bash
bash scripts/popjym_easy/launch_all.sh       # CTRNN
bash scripts/popjym_easy_lru/launch_all.sh   # LRU
```

Each script submits a Slurm array job with seeds 1, 2, 3.

## Tasks

AutoencodeEasy, BattleshipEasy, ConcentrationEasy, CountRecallEasy, HigherLowerEasy, MinesweeperEasy, MultiArmedBanditEasy, NoisyStatelessCartPoleEasy, NoisyStatelessPendulumEasy, RepeatFirstEasy, RepeatPreviousEasy, StatelessCartPoleEasy, StatelessPendulumEasy

## Hyperparameters

| Param | Value |
|---|---|
| hidden_size | 32 |
| gamma | 0.99 |
| lr (td + rnn) | 1e-4 |
| optimizer | adam |
| gradient_clip | 1.0 |
| eta_pi | 1.0 |
| entropy_rate | 1e-5 |
| lambda_pi / lambda_v / lambda_rnn | 0.9 |
| episodes | 15000 |
| steps | 1000 |
| normalize_obs | False |
| update_period | 1 |

LRU scripts additionally pass `--rnn_model lru`.

## Check status

```bash
squeue -u $USER -o "%.10i %.30j %.8T %.10M %.6D %R" | column -t
```
