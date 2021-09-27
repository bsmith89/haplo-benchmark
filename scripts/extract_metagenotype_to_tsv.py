#!/usr/bin/env python3

import sys
import sfacts as sf

if __name__ == "__main__":
    world = sf.data.World.load(sys.argv[1])
    world.metagenotypes.to_csv(sys.stdout, sep='\t')
