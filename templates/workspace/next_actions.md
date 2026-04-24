# Next Actions

- Add or remove sources in `manual_data_sources.yaml`.
- If task-specific data already exists, place it in `datasets/`.
- Set `execution.base_model_preset`, `execution.commands.train`, and `execution.commands.eval` in `pipeline.yaml`.
- If the shipped presets do not fit, set `execution.base_model` to override them.
- If API-backed ideation is desired, set `idea_generation.llm.provider` in `pipeline.yaml` and export the matching API key.
- If IDE agents are preferred, keep provider=`none` and use `agent_bootstrap.md`.
- Edit `data_recipes.yaml` whenever the structure, style, or evidence surface of ingested data needs to change.
