---
name: import-patient-data
description: Create or update only the data bundle for an ordinary Hoshimi Hospital patient from supplied patient data or a source bundle. Does not generate or import image assets or full-screen CGs.
metadata:
  short-description: Import patient data only
---

# Import ordinary patient data

Use this workflow when the requested work is patient identity, traits, profile selection, patient-specific text, or bundle/index integration—not artwork. Read the shared [patient bundle data contract](../add-patient/references/patient-data-contract.md) and [workflow boundaries](../add-patient/references/patient-workflow-boundaries.md); apply [patient text localization and enum confirmation rules](../add-patient/references/patient-text-and-enum-rules.md). Verify the contract against current schemas and loader before editing.

## Scope

- Create or update `data/patients/<patient_id>/patient.json` and, for a new patient, add its bundle path exactly once to `data/patients/index.json`.
- Keep source bundle meaning and user-provided patient text intact. Do not rewrite story/dialogue content unless specifically authorized; if a source-data/schema conflict prevents faithful import, stop and report it.
- Do not generate, copy, rename, remove, or claim acceptance of images in this workflow. Preserve supplied asset references as source notes if needed, but leave their runtime integration to the relevant asset workflow.
- Do not create patient-specific CG pools or claim that full-screen CGs are connected as part of pure data import. Empty pool arrays and an unbound optional CG are acceptable only when they are outside the requested scope.
- Do not add runtime code or duplicate shared encounter/preop templates or dialogue profiles to make a patient fit.

## Workflow

1. Confirm the repository root and inspect the worktree before changes. Treat existing unrelated edits as user work and leave them untouched.
2. Read the supplied data and identify the intended patient identity. Search the patient index and existing bundles for the same character/ID before creating a new entry. Preserve IDs for updates; do not create a duplicate. Confirm the patient is an adult before authoring an ordinary patient record.
3. Compare the source fields with `data/schemas/patient_bundle.schema.json` and `data/schemas/content.schema.json`. Use an existing bundle as a structural reference, not as text or identity to copy blindly. Keep random-pool patients' diagnosis and procedure assignment randomized; fallback data is only a fallback.
4. Reuse an existing dialogue profile where it matches. Store only justified patient-specific overrides in the bundle. Prefer an existing personality/profile plus patient-specific reaction lines over a finer-grained personality category. Do not add a category for a single patient; propose one only when it represents a reusable, meaningfully distinct response pattern, and seek user confirmation before changing the supported category set. Keep source personality prose separate from runtime profile/enums; never silently invent a category or coerce an unsupported value.
5. Preserve the authored bundle shape and required containers. Add only content supported by the source/request; do not fill unspecified story, medical history, or narrative fields by invention.
6. Follow the shared [patient workflow test matrix](../add-patient/references/patient-testing-matrix.md): run T0/T1 for this patient, and T2 for authored patient/profile text. Use the patient-ID-focused `python3 tools/patient_data_import_test.py <patient_id>`; use the repository schema/cross-reference validator when bundle/index/schema references change. Do not run image/CG acceptance or broad gameplay suites for this data-only stage.
7. Record exactly what data was imported and any deferred asset stages. Report “patient data bundle imported,” not “complete/game-ready patient,” unless the separate requested asset stages are also verified.

## Completion boundary

This workflow completes only the patient-data stage. It does not imply that required SFW portraits exist, supplied character art is connected, CGs can trigger, or the patient has passed in-game visual QA. Route those requests to their separate skills. Stop and ask about an invalid enum instead of writing a guessed replacement; see the shared rules for the exact confirmation format.
