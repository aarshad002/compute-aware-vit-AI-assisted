# Project Context

This is a Master's thesis project on compute-aware adaptive inference 
in Vision Transformers. The goal is to reduce inference cost by 
dynamically pruning visual tokens based on image difficulty.

# Your Task

Implement the full pipeline step by step in this order:

1. Dense ViT baseline — DeiT-Tiny on CIFAR-100, 20 epochs, report Top-1 accuracy and FLOPs
2. Static pruning — same model but prune lowest L2-norm tokens after layer 6, implement for 25%, 50%, and 75% token retention
3. Dynamic fixed-budget models — same architecture but using keep ratio instead of absolute count, for 25%, 50%, 75%
4. Dynamic controller — confidence-based routing that selects token budget per image
5. Cascade inference — sequential evaluation from cheapest to most expensive model, stop when confidence threshold met

# Technical Constraints

- Framework: PyTorch
- Model: deit_tiny_patch16_224 from timm library
- Dataset: CIFAR-100, images resized to 224x224
- FLOPs measurement: use fvcore
- Config system: YAML files in configs/
- Each model type must be runnable independently via its own config
- Save best model checkpoint and metrics.json per run
- All experiments must be reproducible with a fixed seed

# What I will do

I will run your code on a GPU cluster (SLURM). You do not need to write 
SLURM scripts. Focus on clean, modular, well-documented Python code.