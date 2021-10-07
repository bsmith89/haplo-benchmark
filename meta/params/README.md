Parameters for StrainFacts in a tree format:

```
params/
├── README.md
├── complex_fit
│   └── simple
│       └── default.txt
├── simple_fit
│   └── simple
│       └── default.txt
└── simulate
    └── base
        ├── diversity
        │   ├── high_diversity.txt
        │   ├── low_diversity.txt
        │   └── medium_diversity.txt
        ├── fidelity
        │   ├── low_fidelity.txt
        │   ├── medium_fidelity.txt
        │   └── very_high_fidelity.txt
        ├── missing
        │   └── no_missing.txt
        └── shape
            ├── big_1.txt
            ├── long_1.txt
            ├── medium_1.txt
            ├── small_1.txt
            └── wide_1.txt

10 directories, 15 files

```

The hierarchy is:

1. Tool (e.g. simulate, complex_fit, etc.)
2. Model (e.g. simple, base, etc.)
3. (If simulate) the type of simulation parameters: e.g shape, diversity, fidelity, missing

Presumably, for any simulation, for a given model, one file from each
subdirectory of `params/simulate/<model>/` should be chosen to make an
interesting simulation.
