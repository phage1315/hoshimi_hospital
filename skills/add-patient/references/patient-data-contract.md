# Patient bundle data contract

This reference records the repository contract observed in `data/schemas/patient_bundle.schema.json`, `data/schemas/content.schema.json`, `data/manifest.json`, `data/patients/index.json`, and `tools/patient_bundles.py`. The schemas and loader are authoritative; re-check them when the project changes.

## Storage and runtime flow

- One ordinary patient bundle lives at `data/patients/<patient_id>/patient.json` and is enabled exactly once by a relative path in `data/patients/index.json`.
- `data/manifest.json` identifies the index, shared encounter/preop templates, and dialogue-profile source used by the loader.
- `tools/patient_bundles.py` reads each indexed bundle, merges its `dialogue_profile` with patient overrides, substitutes patient tokens into the shared templates, applies the bundle's encounter/preop overrides, and contributes patient-owned CG pools and diagnosis reactions to runtime collections.
- Do not author generated encounter/preop collection JSON as though it were the source of truth. Do not copy a whole profile or template into each patient bundle.
- Preserve an existing patient ID when updating that patient's data. Do not register a duplicate identity to work around an asset or bundle problem.

## Bundle structure

The root schema is `data/schemas/patient_bundle.schema.json`; canonical patient and pool fields are `$defs` in `data/schemas/content.schema.json`. The current bundle requires:

- `schema_version: 1`;
- `patient`: identity (`id`, `name`, `age`), `case_id`, `visuals` (`state`, `portraits`), admission and voice style, personality, traits, fear profile, and outpatient lines; optional fields include dialogue profile, patient-specific reaction lines/variants, and selected medical-history flags;
- `fallback`: valid fallback `case_id` and `surgery_id` (not a fixed identity/case assignment);
- `encounter`: title and full-undress prompt/responses; `visual_pool_id` may be empty when no full-screen examination CG is in scope;
- `preop`: title, initial anxiety/interaction values, stage prompts and incision responses; optional final response override;
- `exclusive_cg_pools`: all three arrays (`examination`, `ward_preparation`, `surgery`), which may be empty when no corresponding patient-owned assets are in scope;
- `diagnosis_reactions`: an array, empty when none are authored.

Required schema containers can be present but empty where the schema permits it. In particular, `patient.visuals.portraits` is required as an object but has no minimum entry count. Therefore data creation and image completion are separate acceptance stages; an empty portrait map is not proof of a complete playable patient.

## Patient content and asset boundaries

- The patient bundle is the source for identity, patient-specific numeric traits, profile selection/overrides, outpatient lines, encounter/preop text overrides, diagnosis reactions, portrait-path mapping, and patient-owned CG pool definitions.
- Shared dialogue profiles and shared encounter/preop templates remain shared. Reuse them and add only needed patient-specific overrides.
- `patient.visuals.portraits` maps runtime keys (for example `outpatient/neutral`, `ward/neutral`, `operating_table/awake`, `intraoperative/tense`, `splash/general_anesthesia`, and `examination/shy`) to project-relative asset paths. The required SFW generated matrix and its exact acceptance criteria belong to `generate-patient-portraits`; supplied images belong to `import-patient-assets`.
- The transparent `examination/shy` character portrait and a full-screen examination CG are different assets and different runtime integrations. A portrait entry alone does not connect a full-screen CG.
- Full-screen CGs are represented by patient-owned pools in `exclusive_cg_pools` and, for completed full-undress responses, the matching `encounter.full_undress.visual_pool_id`. A copied file or portrait path alone is not a completed CG integration.
- Runtime asset references in JSON are repository-relative. Source originals and import evidence may live under `research/`, but runtime JSON must not point there.

## User-visible text fields to account for

Patient-sourced text can occur in `patient.name`, `patient.reaction_lines`, `patient.reaction_variants`, `patient.outpatient_lines`, encounter title/prompt/responses, preop title/stage prompts/final and incision responses, diagnosis reactions, and pool labels/captions. Shared dialogue profiles may also provide visible patient text. When updating the workflow, include every relevant field in its localization acceptance; do not assume that storing Chinese source text alone makes it usable in English mode.

The repository provides `tools/patient_bundle_localization_test.py` for English resolution of bundle/profile strings and pool integration checks, alongside schema/loader tests. Select focused checks appropriate to the workflow stage; do not claim image or runtime acceptance from schema validity alone.
