# Project Context

This is a Master's thesis project on compute-aware adaptive inference
in Vision Transformers. The goal is to reduce inference cost by
dynamically pruning visual tokens based on image difficulty.

# Your Task

Design and implement a modular pipeline with clean separation of concerns.
I want the following independent modules, each in its own file:

- `src/datasets/cifar.py` — CIFAR-100 loader with augmentation
- `src/models/vit_dense.py` — Dense DeiT-Tiny baseline
- `src/models/vit_static.py` — Static token pruning wrapper
- `src/models/vit_dynamic.py` — Dynamic fixed-budget model
- `src/models/controller.py` — Token budget controller (confidence-based)
- `src/models/cascade.py` — Cascade inference system
- `src/training/trainer.py` — Training loop
- `src/training/evaluator.py` — Evaluation and metrics
- `src/utils/flops.py` — FLOPs measurement utilities
- `src/utils/metrics.py` — Logging and results saving

Each module must be independently importable and testable.
Each model must be runnable via its own YAML config file.

# Technical Constraints

- Framework: PyTorch
- Model: deit_tiny_patch16_224 from timm library
- Dataset: CIFAR-100, images resized to 224x224
- FLOPs measurement: use fvcore
- Config system: YAML files in configs/
- Save best model checkpoint and metrics.json per run
- All experiments reproducible with fixed seed
- Every function must have a docstring and type hints

# What I will do

I will run your code on a GPU cluster (SLURM). Focus on modularity,
readability, and clean interfaces between components.