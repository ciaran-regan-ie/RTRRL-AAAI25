#!/bin/bash
# Submit all popjym Easy task sbatch scripts using LRU RNN (seeds 1,2,3 as array).
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in "$DIR"/*.sh; do
  name="$(basename "$f")"
  if [ "$name" = "launch_all.sh" ]; then
    continue
  fi
  echo "Submitting $name"
  sbatch "$f"
done
