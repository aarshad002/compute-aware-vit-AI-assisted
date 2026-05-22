# Project Context

This is a Master's thesis project on compute-aware adaptive inference
in Vision Transformers. The goal is to reduce Vision Transformer
inference cost while maintaining competitive accuracy on CIFAR-100.

# Your Task

I want you to think about the best way to implement this system.
Do not follow a prescribed structure. Instead:

1. Analyse the problem: Vision Transformers process all tokens equally
   regardless of image difficulty. This is wasteful.

2. Propose the best architecture you can think of for adaptive
   token budget selection in a ViT. Consider alternatives to simple
   confidence thresholding if you think something better exists.

3. Implement your proposed solution. It must include:
   - A dense baseline for reference
   - At least one static pruning baseline
   - An adaptive inference mechanism that allocates compute per image
   - A way to measure the accuracy-FLOPs trade-off

4. Justify your design choices in comments and a DESIGN.md file.

# Technical Constraints

- Framework: PyTorch
- Model: deit_tiny_patch16_224 from timm library
- Dataset: CIFAR-100, images resized to 224x224
- FLOPs measurement: use fvcore
- Results must include Top-1 accuracy and FLOPs per configuration

# What I will do

I will run your code on a GPU cluster. Focus on producing the best
possible solution, not the most familiar one.