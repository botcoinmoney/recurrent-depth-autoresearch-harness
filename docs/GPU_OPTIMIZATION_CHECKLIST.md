# GPU Optimization Checklist

This checklist exists to stop the orchestrator from wasting H100 time on a run that is technically correct but operationally under-optimized.

Use it for either:

- `4xH100`
- `8xH100`

The exact GPU map may differ, but the readiness criteria do not.

## Rule

Do not begin the main first-wave training/eval schedule until this checklist passes.

If the checklist fails, fix the bottleneck first.

## Optimization Goal

The goal is **not** to drive utilization to 100% at every second.

The goal is:

- high sustained GPU productivity
- minimal idle time after baseline gates pass
- no blocked output gates
- no avoidable data/cache stalls
- no duplicate or conflicting jobs
- enough spare evaluation capacity that completed jobs do not sit waiting

## Part 1: Hardware Readiness

Pass only if all are true:

- visible GPUs match the rented machine (`4` or `8`)
- no unexplained VRAM usage before the run starts
- BF16/CUDA path works
- no thermal/power throttling signals are obvious from `nvidia-smi`

Minimum evidence:

- `nvidia-smi`
- a tiny torch CUDA check

## Part 2: Environment Readiness

Pass only if all are true:

- Python environment is installed and activated
- `gh auth status` passes
- `huggingface-cli whoami` passes
- `HF_HOME` and related cache vars point to a stable local disk
- base model access works
- benchmark/dataset access works

If model or dataset pulls are still happening during the main run, the environment is not ready enough.

## Part 3: Throughput Readiness

Before committing to the main schedule, run at least one short smoke job that proves the machine is not bottlenecked by something obvious.

Examples:

- short benchmark smoke
- short extraction smoke
- short train-step smoke

Pass only if:

- the process actually uses the intended GPU(s)
- throughput is stable after warmup
- there is no repeated stall pattern from disk, auth, or cache misses

## Part 4: Occupancy Readiness

### For `4xH100`

After baseline gates pass, the orchestrator should aim for:

- `3` GPUs doing productive first-wave work
- `1` GPU available for output gates, probes, or benchmarks when needed

Pass if:

- the post-baseline plan has no obvious long idle gaps
- completed training jobs do not have to wait a long time for output-gate capacity

### For `8xH100`

After baseline gates pass, the orchestrator should aim for:

- `6-7` GPUs on active training / extraction / evaluation work
- `1` GPU worth of slack for output gates, probe fan-out, or fast-turn eval work

Pass if:

- the schedule uses parallelism intentionally
- output gates and eval are not blocked behind long-running training jobs
- completed jobs can hand off into evaluation without a long queue

## Part 5: No-Ambiguity Scheduling Check

Pass only if all are true:

- every active GPU has an assigned purpose
- no two jobs are accidentally competing for the same visible device
- the orchestrator can explain what each GPU is doing right now
- the orchestrator knows which GPU(s) are reserved for fast-turn gates/eval

If the answer to “what is GPU 3 for right now?” is vague, scheduling is not ready enough.

## Part 6: Data Path Readiness

Pass only if:

- the probe dataset path is finalized for the current code path
- the training dataset path is finalized for the current code path
- no stale artifacts are being reused after a measurement-path change
- any special-token additions or format variants are fully materialized before training starts

The orchestrator should not spend H100 wallclock on data preprocessing that could have been finished first, unless the data build itself is the gated step.

## Part 7: Output-Gate Protection

Pass only if:

- there is a pre-decided path for running output gates immediately after each checkpoint finishes
- the output gate is not queued behind unrelated long jobs
- failed checkpoints are removed from downstream scheduling immediately

If a checkpoint can finish and sit for a long time without validation, the run is not optimized enough.

## Part 8: Probe / Eval Fan-Out Protection

Pass only if:

- the orchestrator already knows how completed variants will move into probes and external evals
- probes are split into independent artifact-producing jobs where possible
- a single monolithic evaluation job is not unnecessarily serializing the entire end of the run

Goal:

- avoid a long “tail” where training finished quickly but result collection drags on for hours

## Part 9: Commit / Logging Protection

Pass only if:

- `findings.md` exists
- the live run repo is initialized and pushed
- major decisions are written down as they happen
- the orchestrator has a cadence for commits and pushes

If the machine dies mid-run, the result should be recoverable from the run repo and findings log.

## Part 10: Optimization Stop Conditions

The orchestrator should stop and fix optimization issues before the main run if any of these are true:

- GPUs are mostly idle after baseline gates pass and there is no deliberate reason
- output gates are blocked behind long jobs
- model downloads or dataset pulls are still the main bottleneck
- duplicate jobs are running
- the eval path is serialized in a way that obviously creates a long tail
- the orchestrator cannot clearly explain the GPU allocation

## Minimal Readiness Summary

Before the main run, the orchestrator should be able to state:

1. how many GPUs are available
2. which GPUs are assigned to which jobs
3. which capacity is reserved for output gates / eval
4. what the expected throughput bottleneck is
5. what would cause an immediate stop and reschedule

If it cannot answer those five questions clearly, the schedule is not ready.

