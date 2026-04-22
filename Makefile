PYTHON ?= python3
GPU_PROFILE ?=
GPU_COUNT ?=
GPU_RESERVE ?= 1
CHECKPOINT_MESSAGE ?= Checkpoint: $(shell date -u +%Y-%m-%dT%H:%MZ)

.PHONY: setup validate test preflight kickoff gpu-status gpu-allocate checkpoint

setup:
	$(PYTHON) -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip setuptools wheel && pip install -e ".[dev]"

validate:
	$(PYTHON) scripts/validate_strategy_matrix.py

test:
	$(PYTHON) -m pytest -q

preflight:
	$(PYTHON) scripts/preflight_check.py --root . $(if $(CHECK_GPU),--check-gpu,)

kickoff: validate
	$(MAKE) CHECK_GPU=1 preflight
	$(MAKE) gpu-status

gpu-status:
	$(PYTHON) scripts/gpu_status.py $(if $(GPU_PROFILE),--profile $(GPU_PROFILE),)

gpu-allocate:
	$(PYTHON) scripts/gpu_status.py $(if $(GPU_PROFILE),--profile $(GPU_PROFILE),) --allocate $(if $(GPU_COUNT),--count $(GPU_COUNT),) --reserve $(GPU_RESERVE)

checkpoint:
	bash scripts/checkpoint_commit_push.sh --message "$(CHECKPOINT_MESSAGE)"
