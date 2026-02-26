# TRAVEO II Entry Family Starter (CYTVII-B-E-1M-SK)

This repository contains a step-by-step starter workflow for:

- Environment setup
- Compile
- Flash

Use the full guide in `TRAVEO2_STEP_BY_STEP.md`.

Start here:

1. Open `TRAVEO2_STEP_BY_STEP.md`
2. Run `./scripts/build_traveo2.ps1`
3. Run `./scripts/flash_traveo2.ps1`

## Docs (Sphinx)

Documentation for the CYTVII-B-E-1M-SK board (MCU name, pinout) is located in the `docs/` folder.

Build HTML:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r docs/requirements.txt
python -m sphinx -b html docs docs/_build/html
```

Open `docs/_build/html/index.html` to view the documentation.
