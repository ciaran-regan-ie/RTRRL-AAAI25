#!/bin/bash
# Submit all popjym Easy task sbatch scripts (each runs seeds 0,1,2 in parallel as an array).
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
