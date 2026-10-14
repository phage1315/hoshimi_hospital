---
name: import-patient-assets
description: Import user-supplied portrait art or patient-specific CGs for an already-existing Hoshimi Hospital patient. Includes transparent examination art, full-nudity illustrations, and optional NSFW/full-screen CGs; excludes new-patient creation and SFW ImageGen.
metadata:
  short-description: Import supplied art for an existing patient
---

# Import supplied assets for an existing patient

Use this workflow when the patient already has a registered bundle and the user supplies images to connect. Read the shared [patient bundle data contract](../add-patient/references/patient-data-contract.md), [workflow boundaries](../add-patient/references/patient-workflow-boundaries.md), [patient workflow test matrix](../add-patient/references/patient-testing-matrix.md), and [natural-language-to-runtime-node map](../add-patient/references/patient-cg-node-map.md); apply [patient text localization and enum rules](../add-patient/references/patient-text-and-enum-rules.md). Then inspect the current loaders, asset conventions, schema, and relevant UI resolver. This includes portrait replacement/addition, transparent examination illustrations, full-nudity illustrations, and optional full-screen CGs.

## Scope and prerequisites

- Confirm the patient ID exists exactly once in `data/patients/index.json` and its bundle exists before importing. If the patient does not yet exist, complete patient-data creation first; do not silently create a patient in this workflow.
- Import only user-supplied assets in scope. Do not generate substitute art or make unrelated patient assets appear complete.
- Preserve source originals. Keep runtime paths repository-relative and patient-specific where the project's resolver expects them. Record source path, runtime path, and SHA-256.
- Keep character portrait slots (`patient.visuals.portraits`) distinct from full-screen CG pools. A transparent `examination/shy` portrait does not replace a full-screen examination CG and vice versa.
- Full-screen CG acceptance requires the actual runtime integration chain, not just a copied file: source → runtime path → patient-owned pool/reference → real runtime trigger/stage → English-visible labels where used → UI resolver. Do not mark a CG complete while any requested link is missing or unverified.
- Do not broaden the batch. User-provided CGs may be a later optional stage after baseline patient assets have been imported and tested; an optional missing CG does not block a separate baseline-asset result unless the user includes it in the current scope.

## Workflow

1. Confirm repository root and inspect `git status`; preserve unrelated user changes.
2. Inventory every supplied image against the user's natural-language descriptions using the shared node map. Capture source path, intended asset class, target patient, proposed runtime destination/node/pool/presentation, and unresolved interpretation. Respect user-defined aliases: “下刀” means the incision CG; “划线” is reserved for `incision_marking` and does not imply a current CG exists. If an image can plausibly correspond to multiple runtime situations, ask before writing the mapping.
3. Inspect the patient's current bundle and actual runtime loaders/resolvers. Never invent a key, pool ID, action ID, stage ID, or path based on a Chinese label alone. Match to the live project contract; surface ambiguity before integration.
4. Inspect source image dimensions, format, color mode, and alpha. For supplied transparent art, distinguish actual alpha from a viewer's black/white preview; do not reject a file solely because the preview background looks dark. Preserve the user's original unless a necessary, authorized format conversion is documented.
5. Copy/prepare only the accepted assets and update only the patient bundle/runtime metadata required for their intended use. Add source and asset provenance to the import record and `docs/asset_sources.md` where applicable.
6. Apply the matrix's T3/T4 checks for each supplied asset class. Run `python3 tools/patient_bundle_localization_test.py` after patient bundle/pool text changes. Use focused portrait tests for portraits and target-specific resolver/trigger tests for CGs; broad preop/gameplay tests are conditional on runtime logic changes, not automatic for every asset import. If an existing test does not cover this patient's exact trigger, add a target-specific assertion or document a manual trigger test before claiming runtime verification.
7. Report each supplied image as integrated, not integrated, or blocked, with evidence. Do not claim “all CG connected” from file presence, a matching pool alone, or an import report alone.

## Pool and runtime integration notes

- **Character portrait:** update only the intended key under `patient.visuals.portraits`; verify the resolved project-relative path exists and is actually consumed by the relevant UI.
- **Full-screen examination CG:** store it in a patient-owned `exclusive_cg_pools.examination` entry with the schema's examination fields (including `test_ids`, `surgery_ids`, and `paths`) and connect the pool through `encounter.full_undress.visual_pool_id` when that is the requested examination. The completed-undressing actions may show it; the abandon action must not. Do not use ward `action_ids` for an examination pool.
- **Ward/preparation CG:** use `exclusive_cg_pools.ward_preparation`, with a unique ID, patient-specific priority/selection contract, `presentation: "fullscreen"` when replacing the normal preparation view, real `action_ids`, the exact patient in `patient_ids`, valid `paths`, and patient-specific label/caption as required by the schema/UI. The ward-preparation category also handles operating-room preparation actions; category name alone does not imply a ward-only scene.
- **Surgery-stage CG:** use `exclusive_cg_pools.surgery` only when the live resolver selects it by surgery/stage. Do not put preparation-action CGs in this pool merely because the scene is in the operating room.
- For every requested CG, test the specific action/stage through the same resolver the game UI uses, and test patient isolation so another patient cannot select it. Check locale does not change the selected pool/image.
- Localize every new/changed visible patient or CG label/caption into English and pass the patient-bundle localization test. If an enum-valued field is invalid, stop writing that field and obtain the user's explicit mapping before integration; do not normalize it silently.

The project has used preparation action IDs such as `ward_enema`, `ward_enema_unnecessary`, `ward_surgical_cap`, `urinary_catheterization`, `ack_disinfection`, and `request_scalpel`. A pre-incision “下刀” CG belongs to `request_scalpel`, after the scalpel handoff. `incise_epidural`, `incise_local`, `incise_none`, and `incise_general` are incision actions/video triggers, not pre-incision CG triggers. Verify all IDs against the current runtime and shared node map; never derive an ID from a label.

Typical project-relative destinations include:

```text
assets/examinations/patient_<id>/<asset>.png
assets/events/ward_preparation_v1/patient_<id>/<asset>.png
assets/events/surgery_v1/patient_<id>/<asset>.png
```

Use the existing project conventions and inspect the live resolver before choosing a path; examples do not override current schema/runtime behavior.

## Completion boundary

This skill does not generate the new-patient SFW portrait matrix and does not author the patient's base data bundle. It may update existing bundle path/pool references only as required to integrate the supplied assets. Avoid editing patient dialogue or narrative text unless explicitly requested.
