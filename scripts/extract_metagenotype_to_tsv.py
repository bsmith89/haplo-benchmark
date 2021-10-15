#!/usr/bin/env python3

import sys
import sfacts as sf
import numpy as np

if __name__ == "__main__":
    world_path = sys.argv[1]
    num_samples = int(sys.argv[2])
    num_positions = int(sys.argv[3])

    world = sf.data.World.load(world_path)
    world_ss = world.isel(sample=slice(0, num_samples), position=slice(0, num_positions))
    world_ss.metagenotypes.to_csv(sys.stdout, sep='\t')
