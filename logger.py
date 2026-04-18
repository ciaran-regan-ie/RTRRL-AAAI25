"""StreamRL-style logger for tracking metrics as (step, value) pairs."""

import json
import os

from matplotlib import pyplot as plt


def plot_series(data, path, ylabel, max_points=5000):
    """Plot a time series and save to file."""
    data = data[::max(1, len(data) // max_points)]
    steps, values = zip(*data) if data else ([], [])
    fig, ax = plt.subplots()
    ax.plot(steps, values)
    ax.set_xlabel('Step')
    ax.set_ylabel(ylabel)
    os.makedirs(os.path.dirname(path), exist_ok=True) if os.path.dirname(path) else None
    fig.savefig(path, bbox_inches='tight')
    plt.close(fig)


class Logger:
    """Logs individual named metrics as (step, value) pairs. Matches streamrl interface."""

    def __init__(self, use_wandb=False, wandb_project=None, wandb_config=None, run_name=""):
        self.metrics = {}   # {name: [(step, value), ...]}
        self.summary = {}   # For __getitem__/__setitem__ (e.g. best_eval_reward)
        self.use_wandb = use_wandb
        for d in ('losses', 'stats', 'norms', 'eval', 'lr'):
            os.makedirs(d, exist_ok=True)
        if use_wandb:
            import wandb
            self._wandb = wandb
            wandb.init(project=wandb_project, config=wandb_config, name=run_name)
        else:
            self._wandb = None

    def log(self, name: str, value: float, step: int):
        """Log a single scalar metric at a given step."""
        if name not in self.metrics:
            self.metrics[name] = []
        self.metrics[name].append((step, float(value)))
        if self._wandb is not None:
            self._wandb.log({name: float(value)}, step=step)

    def log_video(self, name, frames, step=None, fps=30, caption=""):
        """Log a video to W&B."""
        if self._wandb is not None:
            self._wandb.log({name: self._wandb.Video(frames, fps=fps, caption=caption)}, step=step)

    def log_params(self, params_dict):
        """Log hyperparameters."""
        if self._wandb is not None:
            self._wandb.config.update(params_dict)

    def plot_metrics(self, step: int):
        """Save PNG plots for all tracked metrics."""
        for name, data in self.metrics.items():
            plot_series(data, path=f'{name}.png', ylabel=name.split('/')[-1])

    def save_metrics(self):
        """Dump all metrics to metrics.json."""
        with open("metrics.json", "w") as f:
            json.dump(self.metrics, f)

    def close(self):
        """Save metrics and finish W&B run."""
        self.save_metrics()
        if self._wandb is not None:
            self._wandb.finish()

    def __setitem__(self, key, value):
        self.summary[key] = value
        if self._wandb is not None:
            self._wandb.run.summary[key] = value

    def __getitem__(self, key):
        return self.summary.get(key, 0)
