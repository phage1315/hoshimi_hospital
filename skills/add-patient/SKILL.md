---
name: add-patient
description: Route ordinary Hoshimi Hospital patient work to pure patient-data import, required SFW portrait generation, or supplied-art import for an existing patient. Use when a request spans multiple patient stages or its scope is not yet clear.
metadata:
  short-description: Route patient import workflows
---

# Patient workflow router

Use the narrowest workflow skill that matches the user's current request. Do not treat a multi-stage new-patient project as authorization to perform every stage in one pass. Read [workflow boundaries and handoffs](references/patient-workflow-boundaries.md) when selecting or sequencing stages.

- **Create or update patient data only:** use [import-patient-data](../import-patient-data/SKILL.md). This authors and indexes the patient bundle; it does not create or import images.
- **Generate the required SFW portrait set for a patient whose bundle already exists:** use [generate-patient-portraits](../generate-patient-portraits/SKILL.md).
- **Import images supplied by the user for a patient whose bundle already exists:** use [import-patient-assets](../import-patient-assets/SKILL.md). This includes portrait art, transparent examination art, and optional full-screen CGs. Full-nudity illustrations and NSFW CGs are always this existing-patient asset-import workflow, never part of new-patient creation or SFW generation.

If a request spans stages, complete only the requested stage, then state what remains and whether the next stage can proceed. A patient bundle may exist before its required images are complete; do not report the whole patient as game-ready until its requested stages pass their own acceptance checks.

All workflows use the shared [patient bundle data contract](references/patient-data-contract.md) and [patient workflow test matrix](references/patient-testing-matrix.md). For patient text or enum fields, also follow [localization and enum rules](references/patient-text-and-enum-rules.md). For supplied CGs, consult the verified [natural-language-to-runtime-node map](references/patient-cg-node-map.md). Do not hand-edit generated encounter/preop collections; the loader builds them from templates and patient-owned data.
