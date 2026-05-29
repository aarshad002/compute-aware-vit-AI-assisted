# Variant B Log

## Session 1 — 2026-05-28 [time] start
Prompt given: "Please read the CLAUDE.md file in this directory 
and implement the complete pipeline..."
Strategy: Modular specification

# Variant B Log

## Session 1 — 2026-05-28 [time] start
Prompt given: "Please read the CLAUDE.md file in this directory and 
implement the complete pipeline. Implement everything in one session — 
all modules, all configs, all scripts. Verify each module as you go. 
Stop when everything is implemented and verified."
Strategy: Modular specification

---

### Full Implementation
Total time: 10 minutes 25 seconds
Human interventions: 4 permission approvals, 0 corrections
Bugs encountered: 0
Files created: 14 Python modules + 9 configs + 10 scripts = 33 files

### Verification results
- All syntax checks: PASSED
- All module imports: PASSED
- All model forward passes: PASSED
- Trainer/Evaluator integration: PASSED
- FLOPs for dense: 1.0794 GFLOPs ✓
- metrics save/load round-trip: PASSED

### Architectural Differences — Variant B vs Variant A

1. FILE STRUCTURE
   Variant A: flat src/ (dataset.py, model.py, utils.py)
   Variant B: nested src/datasets/, src/models/, src/training/, src/utils/
   Assessment: Variant B more modular and organised ✓

2. ENTRY POINT
   Variant A: separate train_baseline.py, train_static_pruning.py etc per step
   Variant B: single src/train.py handles all model types via config
   Assessment: Variant B cleaner — one entry point, config-driven ✓

3. STATIC PRUNING LAYER
   Variant A: prune_layer=6 for all models
   Variant B: prune_layer=3 for static, prune_layer=6 for dynamic/controller
   Assessment: Interesting — Claude split static and dynamic pruning layers
   This creates a direct ablation pair (layer 3 vs layer 6)

4. CASCADE
   Variant A: single threshold across all stages (7 combinations)
   Variant B: per-stage thresholds (343 combinations) ✓
   Assessment: Variant B correctly implements per-stage thresholds
   as specified in improved CLAUDE.md

5. CONTROLLER
   Variant A: forward_with_confidence() method
   Variant B: separate forward_train() and forward_inference() methods
   Assessment: Variant B cleaner interface separation ✓

6. CASCADE EFFICIENCY
   Variant B pre-caches all stage logits and sweeps 343 combinations
   in vectorized form — more efficient than Variant A sequential approach

7. VERIFICATION DEPTH
   Variant A: basic import + shape checks
   Variant B: full integration tests including Trainer/Evaluator loop,
   metrics round-trip, config loading, all model variants
   Assessment: Variant B more thorough autonomous testing ✓

### Design Improvement — Deterministic Checkpoint Paths
Variant B used deterministic paths for ALL models including dense:
checkpoints/dense/best_model.pt
checkpoints/static_25/best_model.pt etc.

Variant A used timestamped path for dense baseline which required 
manual update in cascade.yaml before running cascade.

Root cause: Variant B CLAUDE.md had Environment Notes including 
practical lessons. Better prompt = better design decision.

### Human Intervention — Learning Rate Scheduler
Issue: Claude used CosineAnnealingLR which decayed lr to 0 
by epoch 20. Result: 46.73% accuracy vs expected ~80%.
Phase 1 used constant lr=0.0001 throughout.
Correction: Asked Claude to remove scheduler, use constant lr.
Time to identify: ~5 minutes reviewing training output.

### Human Intervention 2 — Missing pretrained: true
Issue: All configs missing pretrained: true
Result: Model trained from scratch, 48.79% vs expected ~80%
Phase 1 and Variant A both used pretrained=True
Correction: Asked Claude to add pretrained: true to all configs
  and verify model builder uses it
Time to identify: reviewing training output, epoch 1 accuracy ~7%
  indicated random initialization not pretrained weights

### Human Intervention 3 — pretrained not passed to model builder
Issue: build_model() in train.py not passing pretrained=True 
to model constructors despite configs having pretrained: true
Result: 48.79% accuracy (training from scratch)
Fix: Claude updated build_model() to read cfg.get('pretrained', True)
Time to identify: reviewing epoch 1 train_acc (~7% = random init)

### Variant B — All Training Results

|    Model    |  FLOPs | Best val_acc | Phase 1 | Variant A |
|-------------|--------|--------------|---------|-----------|
|    Dense    | 1.079G |    81.02%    |  79.28% |  80.40%   |
|  Static 25% | 0.491G |    73.81%    |  75.83% |  75.04%   |
|  Static 50% | 0.687G |    77.83%    |  78.18% |  79.19%   |
|  Static 75% | 0.883G |    79.73%    |  79.16% |  79.89%   |
| Dynamic 25% | 0.687G |    76.80%    |  75.83% |  75.04%   |
| Dynamic 50% | 0.818G |    78.85%    |  78.18% |  79.19%   |
| Dynamic 75% | 0.949G |    80.20%    |  79.16% |  79.62%   |
|  Controller | 0.949G |    78.48%    |  FAILED |  78.37%   |

### Step 5 — Cascade Results (343 combinations)
Run completed: 2026-05-28
Total combinations evaluated: 343

Top 5 results by accuracy:
| t_25 | t_50 | t_75 | Accuracy | Avg FLOPs |  25%  |  50%  |  75%  | Dense |
|------|------|------|----------|-----------|-------|-------|-------|-------|
|  0.9 |  0.9 |  0.9 |  82.22%  |   1.127G  | 58.5% | 19.7% |  7.2% | 14.6% |
|  0.9 |  0.9 |  0.8 |  82.18%  |   1.096G  | 58.5% | 19.7% | 10.1% | 11.7% |
|  0.9 |  0.9 |  0.7 |  82.11%  |   1.069G  | 58.5% | 19.7% | 12.6% |  9.2% |
|  0.9 |  0.9 |  0.6 |  81.88%  |   1.039G  | 58.5% | 19.7% | 15.4% |  6.4% |
|  0.9 |  0.8 |  0.9 |  81.83%  |   1.049G  | 58.5% | 24.8% |  5.2% | 11.5% |

Best efficiency point:
|  0.3 |  0.3 |  0.3 |  74.38%  |   0.510G  | 97.5% |  2.3% | 0 .1% |  0.1% |

Best trade-off (accuracy ≥ dense baseline 81.02%):
|  0.9 |  0.9 |  0.9 |  82.22%  |   1.127G  | — beats dense by +1.2% |
|  0.9 |  0.8 |  0.6 |  81.60%  |   0.981G  | — beats dense, saves 9% FLOPs |

### Cascade Comparison Finding

Variant B implemented per-stage threshold search (343 combinations)
as specified in the improved CLAUDE.md, matching Phase 1's approach.
Variant A only implemented single-threshold search (7 combinations)
due to prompt ambiguity.

Best accuracy: Variant B (82.22%) > Phase 1 (81.82%) > Variant A (82.12%)
Note: Variant B's higher accuracy comes at higher FLOPs cost (1.127G vs 0.763G)

Root cause: Variant B's static models pruned at layer 3 are less 
accurate than Phase 1's fixed-budget models pruned at layer 6, 
causing more images to escalate to the dense model.

At matched FLOPs (~0.76G): Phase 1 wins (81.82% vs ~80.19% Variant B)

Key insight: Pruning layer choice (3 vs 6) significantly affects 
cascade behaviour — earlier pruning reduces individual stage FLOPs 
but hurts accuracy, causing more escalations and higher average FLOPs 
at the accuracy-optimal operating point.