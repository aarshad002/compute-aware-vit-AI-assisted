# Variant A Log

## Session 1 — 2026-05-26 [time] start
Prompt given: "Please read /home/arooba/.../variant_a/CLAUDE.md and 
implement Step 1 only: dense ViT baseline. Do not run training. 
Stop after Step 1 and wait for confirmation."

---

### Step 1 — Dense ViT Baseline
Time taken: 1 minute 47 seconds
Human interventions: 2 (permission approvals for bash commands)
Corrections needed: 0

Files created by Claude:
- configs/baseline.yaml
- src/dataset.py (66 lines)
- src/model.py (23 lines)
- src/utils.py (52 lines)
- train_baseline.py (177 lines)

Verification by Claude:
- All imports OK
- Parameters: 5,543,716 ✓ (matches Phase 1: 5.54M)
- FLOPs: 1.079 GFLOPs ✓ (matches Phase 1: 1.0794 GFLOPs)
- GPU: available

Architectural differences from Phase 1:
- Claude used a flat structure (train_baseline.py at root) vs 
  Phase 1 used src/train.py
- Claude created single src/utils.py vs Phase 1 had separate 
  FLOPs logging in train.py
- [note any other differences you spot]

### Design Decision — File Structure
Question asked: "Why train_baseline.py at root instead of src/?"

Claude's reasoning: Entry points (runnable scripts) at root level, 
reusable library modules inside src/. Each step will get its own 
root-level script. Standard Python convention.

Comparison with Phase 1: Phase 1 used src/train.py as the entry point,
mixing entry point with library code. Claude's structure is arguably 
cleaner and more consistent.

Assessment: BETTER than Phase 1 — clearer separation of concerns.

### Step 2 — Static Pruning
Time taken: 3 minutes 56 seconds
Human interventions: 1 correction needed (fvcore tracing bug)

Bug encountered: fvcore symbolic tensor error in measure_flops
- Claude hit error on first verification run
- Claude diagnosed and fixed autonomously (int() cast on shape[1])
- Zero human input needed for the fix

Files created:
- src/pruning.py (108 lines)
- configs/pruning_25.yaml, pruning_50.yaml, pruning_75.yaml
- train_static_pruning.py (207 lines)

Verified FLOPs:
- 25% retention: 49/196 tokens, 0.687 GFLOPs
- 50% retention: 98/196 tokens, 0.818 GFLOPs  
- 75% retention: 147/196 tokens, 0.949 GFLOPs
- Baseline: 1.079 GFLOPs ✓ matches Phase 1

Key observation: Claude encountered a bug, diagnosed it, 
and fixed it autonomously without any human intervention.
This is important — in Phase 1 this exact same fvcore 
symbolic tensor issue took you time to debug manually.

### Step 3 — Dynamic Fixed-Budget Models
Time taken: 2 minutes 42 seconds
Human interventions: 0
Corrections needed: 0
Bugs encountered: 0

Files created:
- configs/fixed_budget_25.yaml (29 lines)
- configs/fixed_budget_50.yaml (26 lines)
- configs/fixed_budget_75.yaml (26 lines)
- train_dynamic_fixed.py (214 lines)

Files modified:
- src/pruning.py — added forward_with_confidence() method (+17 lines)

Verified results:
- keep_ratio=0.25: 49/196 tokens, 0.687 GFLOPs ✓
- keep_ratio=0.50: 98/196 tokens, 0.818 GFLOPs ✓
- keep_ratio=0.75: 147/196 tokens, 0.949 GFLOPs ✓
- forward_with_confidence() tested and passing for all ratios ✓

Key observations:
1. PROACTIVE PLANNING — Claude added forward_with_confidence() 
   anticipating Step 5 cascade needs without being explicitly asked.
2. SMARTER CHECKPOINTING — Used deterministic output paths 
   (outputs/fixed_budget_25/) instead of timestamped folders. 
   Phase 1 used timestamped folders which required manual path 
   lookup for cascade loading.
3. DEFENSIVE PROGRAMMING — Added controller=false guard that 
   fails immediately if wrong config is passed. Not present in 
   Phase 1.

Methodological note:
Variant A CLAUDE.md listed all 5 steps including cascade upfront.
Claude's proactive behaviour may be influenced by reading the full 
roadmap. Variant C (open-ended prompt) will test whether Claude 
arrives at cascade independently without being told about it.

### Step 4 — Dynamic Controller
Time taken: 4 minutes 39 seconds
Human interventions: 0
Corrections needed: 0
Bugs encountered: 0

Files created:
- src/controller.py (187 lines)
- configs/controller.yaml (39 lines)
- train_controller.py (325 lines)

Verified:
- Training forward pass: main + ctrl logits both correct shape ✓
- Dynamic inference routing working ✓
- Loss computation + backward pass ✓
- All imports clean ✓

Key observations:
1. SMART ARCHITECTURE — Claude computed shared blocks 0-5 once 
   and reused across all budget groups. Phase 1 did not do this.
2. AUXILIARY CLASSIFIER — Controller head trained as auxiliary 
   classifier rather than binary predictor. No pseudo-labels needed.
   More elegant than Phase 1 approach.
3. SELF-EXPLAINING — Claude explained why all images routed to 
   75% during verification (untrained weights give uniform softmax 
   ~0.01 confidence). Correct diagnosis, no human needed to explain.
4. THRESHOLD SWEEP BUILT IN — train_controller.py includes 
   post-training threshold evaluation automatically. Phase 1 
   required a separate script for this.

Comparison with Phase 1:
- Phase 1 MLP controller collapsed to budget 0 and required 
  4 failed training attempts + 2000-image diagnostic analysis
- Claude's approach avoids this by using auxiliary classification 
  loss instead of budget prediction loss — fundamentally different 
  and more robust design

### Step 5 — Cascade Inference
Time taken: 3 minutes 59 seconds
Human interventions: 0
Corrections needed: 0
Bugs encountered: 0

Files created:
- src/cascade.py (243 lines)
- configs/cascade.yaml (30 lines)
- eval_cascade.py (131 lines)

Verified:
- Forward pass shapes correct for all 4 stage models ✓
- Confidence values in [0,1] range ✓
- Cumulative FLOPs arithmetic correct ✓
  - Stop at 25%: 0.687 GFLOPs
  - Stop at 50%: 1.505 GFLOPs
  - Stop at 75%: 2.454 GFLOPs
  - Stop at dense: 3.533 GFLOPs

Key observations:
1. Pending-mask batch cascade — processes all images in parallel 
   rather than one by one. More efficient than Phase 1 approach.
2. Cumulative FLOPs accounting — correctly accounts for cost of 
   ALL stages an image passes through, not just the final stage.
3. Single threshold across all stages — simpler than Phase 1 which 
   used separate thresholds per stage (343 combinations). 
   Trade-off: less flexible but faster to evaluate.



---
## Variant A — Complete Session Summary

Total implementation time: ~17 minutes
(Step 1: 1m47s, Step 2: 3m56s, Step 3: 2m42s, 
 Step 4: 4m39s, Step 5: 3m59s)

Total files created: 15
Total lines of code: ~1,500

Human interventions:
- Permission approvals: ~8
- Corrections required: 0
- Bugs fixed by human: 0
- Bugs fixed by Claude autonomously: 1 (fvcore symbolic tensor)

Phase 1 comparison (same pipeline):
- Phase 1 implementation time: several weeks
- Phase 1 bugs requiring human diagnosis: multiple
- Phase 1 MLP controller: failed completely, 4 attempts
- Claude controller: different architecture, passed verification

Architectural differences from Phase 1:
1. Flat entry point structure vs src/train.py
2. Deterministic checkpoint paths vs timestamped
3. Auxiliary classifier controller vs MLP budget predictor
4. Shared block computation in controller
5. Pending-mask batch cascade vs sequential
6. Single threshold cascade vs 343-combination grid search
7. Cumulative FLOPs accounting vs per-stage only


### Dataset Path Update
Time taken: 1 minute 16 seconds
Human interventions: 0

Actions taken by Claude:
- Inspected existing CIFAR-100 data format
- Confirmed 32x32 PIL images, 50k train / 10k val
- Confirmed torchvision loads it natively, no conversion needed
- Updated data_dir in all 9 configs automatically
- Verified end-to-end data loading: batch shape (4, 3, 224, 224) ✓
- Confirmed resize 32→224 handled by dataset.py transforms

Key insight from Claude: upsampling actually helps pruning because 
flat regions produce genuinely low-norm tokens — redundancy is real.