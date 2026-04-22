# Dependencies And Sources

This document exists so the orchestrator can work from a fresh GPU template without access to the original BOTCOIN system.

Everything needed to understand the run is either:

- included in this repository, or
- listed here as an external dependency with its purpose

## Included In This Repository

These are self-contained in the handoff repo:

- experiment framing
- prior experiment findings
- strategy rationale
- setup instructions
- measurement and gate rules
- run-repo templates
- bootstrap and validation scripts

## External Dependencies

These are not bundled because they are large, authoritative, or need to stay source-of-truth from upstream.

### 1. Base model

- `tomg-group-umd/huginn-0125`

Purpose:

- recurrent-depth base model for the first-wave probe strategies

### 2. BOTCOIN/DACR training data

- `botcoinmoney/domain-agnostic-causal-reasoning-tuning`

Purpose:

- structured multi-hop training traces
- source for SFT, GRPO, PRM, and DPO-style variants

### 3. DACR benchmark

- `github.com/botcoinmoney/dacr-bench`

Purpose:

- secondary behavior benchmark once prompt/output alignment is validated

### 4. Synthetic-to-real training/eval code

- `github.com/botcoinmoney/synthetic-to-real-reasoning`

Purpose:

- reference implementation path for DACR data usage and evaluation patterns if needed

### 5. Standard benchmark sources

Use your standard internal or public access path for:

- HotpotQA
- MuSiQue
- DROP
- CausalQA or COPA if available
- StrategyQA-style causal plausibility checks if available

Purpose:

- primary first-wave external behavior checks for multi-hop and causal transfer

## Paper Sources

These papers are not mirrored here, but their relevant conclusions are already distilled into `docs/RESEARCH_SYNTHESIS.md`.

Key references:

- `Geiping et al. 2025`, "Scaling up Test-Time Compute with Latent Reasoning: A Recurrent Depth Approach" (arXiv:2502.05171)
- `Wei et al. 2025`, "SIM-CoT: Supervised Implicit Chain-of-Thought" (arXiv:2509.20317)
- `Koishekenov et al. 2025`, "Encode, Think, Decode: Scaling test-time reasoning with recursive latent thoughts" (arXiv:2510.07358)
- `Kohli et al. 2026`, "Loop, Think, & Generalize: Implicit Reasoning in Recurrent-Depth Transformers" (arXiv:2604.07822)
- `Jeddi et al. 2026`, "LoopFormer: Elastic-Depth Looped Transformers for Latent Reasoning via Shortcut Modulation" (arXiv:2602.11451)
- `Prairie et al. 2026`, "Parcae: Scaling Laws For Stable Looped Language Models" (arXiv:2604.12946)
- `Yu et al. 2025`, "Causal Sufficiency and Necessity Improves Chain-of-Thought Reasoning" (arXiv:2506.09853)
- `Rewarding Latent Thought Trajectories` 2026, "Prioritize the Process, Not Just the Outcome: Rewarding Latent Thought Trajectories Improves Reasoning in Looped Language Models" (trajectory-level latent credit assignment)
- `Wang 2026`, "LLM Reasoning Is Latent, Not the Chain of Thought" (position paper for latent-state-centric evaluation)

For a dated, April 22, 2026 refresh with exact paper framing and transfer implications, see `docs/RESEARCH_REFRESH_2026.md`.

## Fresh-System Rule

If the orchestrator is missing information and cannot access the original BOTCOIN machine, it should rely on:

1. the distilled documents in this handoff repo
2. the external sources listed here

It should **not** assume any hidden local files exist elsewhere.
