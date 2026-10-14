# Patient workflow test matrix

Use the smallest test set that proves the current workflow's completion claim. Tests marked **conditional** run only when that kind of data or asset changed. Do not run unrelated narrative, relationship, surgery-system or full-game suites for a patient-bundle-only change.

## Test layers

| Layer | What it proves | Check |
|---|---|---|
| **T0 — changed artifact** | The edited bundle/index is valid JSON; enum/reference values have been checked against the live schema; only intended patient files changed. | Parse the changed JSON and inspect the scoped diff. Use `python3 tools/validate_data.py` for schema and repository cross-reference validation when patient bundle/index/schema data changes. It scans the whole project; classify pre-existing unrelated failures instead of attributing them to this patient. |
| **T1 — patient bundle loader** | The target bundle is indexed once; its dialogue profile merges; the shared templates produce the target encounter and preop with correct IDs/links. | `python3 tools/patient_data_import_test.py <patient_id>`. This focused test intentionally does not require any images or CG pools. |
| **T2 — patient text localization** | Patient-visible Chinese fields resolve to English; current patient CG labels/captions, paths and pool/action IDs satisfy the focused data integration assertions. | `python3 tools/patient_bundle_localization_test.py` after any patient bundle/profile/pool visible-text change (including a new patient's authored text). It scans all indexed patients and profiles, so record whether any failure is pre-existing and outside the changed scope. |
| **T3 — image/artifact acceptance** | Each requested image is visually correct, technically valid and stored at the intended key/path. | Per-image review record: inspect identity, pose, class framing, expression differences, size/mode, alpha and light/dark composite as applicable; verify hash and actual path. The image acceptance record is mandatory; a test command cannot replace it. |
| **T4 — consumer/runtime integration** | The game's actual UI/action resolver selects and displays the exact patient asset on the intended branch, with correct patient isolation. | Run only the focused consumer test for changed asset classes (matrix below); if no existing test exercises the target patient/key/action, add a target-specific assertion or perform a documented in-game trigger test before claiming runtime-verified. Static JSON/path presence is not T4. |

## Per-workflow minimum

| Workflow | Required layers | Conditional checks | Do not run by default |
|---|---|---|---|
| **Pure patient-data import** | T0 + T1. Add T2 because new/changed patient text is part of the data deliverable. | `tools/validate_data.py` when bundle/index/schema/reference data changes; T2 whenever visible patient/profile text changes. | Image inspection, `portrait_test.gd`, CG resolver tests, `preop_test.gd`, and broad gameplay suites. No image key-count gate applies to this stage. |
| **Required SFW portrait generation** | T3 for every included key. If bundle portrait mappings change, also T0 + T1. | Run T2 only if patient-visible text or labels changed. After a complete portrait batch, run `godot --headless --path . --editor --import --quit`, then `godot --headless --path . --script res://tools/portrait_test.gd` for engine texture/UI smoke coverage. | `preop_test.gd`, ward-CG resolver tests, full CG pool tests, and unrelated narrative/gameplay suites. Do not run the whole portrait test once per generated image; do per-image inspection each time and the test once per integrated batch. |
| **Supplied portrait only** | T3; T0 + T1 if mapping/path changed. | Import resources with the editor and run `portrait_test.gd` after the portrait batch. T2 only if visible text changed. | Preop/CG resolver tests. |
| **Supplied full-screen CG** | T3 + T0 + T1; T2 if a caption/label or other patient-visible field changed; T4 for every requested trigger. | Examination, ward/preparation and surgery pools require different resolver/branch checks; use the matching section below. | Portrait matrix generation tests, unless portrait files/mappings were also changed. Do not treat the generic `preop_test.gd` suite as patient-specific proof without a target-specific assertion. |

## Existing test coverage and limits

- `tools/patient_data_import_test.py` is the focused T1 test. It proves bundle index uniqueness, shared-loader profile merge, generated encounter/preop identity/linkage and nonempty template stages/prompts. It deliberately does not assert portrait count, image files, CG pools or runtime UI.
- `tools/patient_bundle_test.gd` is a broader integration test, not the T1 test: it requires at least 17 portrait slots per patient and currently hard-codes a seven-patient ID/count roster plus named legacy CG assertions. Do not use it to gate a pure-data phase before the patient's art exists. When running it after adding a patient, update the explicit cohort count/ID fixture as part of test maintenance; passing it proves more than this patient alone.
- `tools/patient_bundle_localization_test.py` is the focused patient-text / bundle-CG structural sweep. It checks English resolution and registered pool/path/action consistency across patient bundles, but it is not a Godot UI trigger test.
- `tools/portrait_test.gd` loops over all loaded staff and patient portrait keys, checking texture loading, UI selection and selected alpha/canvas properties. Run it after a complete portrait integration batch, not for data-only changes. A failure on another patient's pre-existing art is outside the target patient's acceptance and must be reported separately.
- `tools/preparation_asset_regression_test.gd` tests real ward/preparation resolver/render paths and patient isolation for its declared `EXPECTED_OR_POOLS` entries, plus Comoli's current table/splash assets. It does not automatically test a newly added patient; add the target patient's expected pool prefixes and supported actions before treating this test as coverage for that patient.
- `tools/preop_test.gd` covers broad workflow behavior and several named existing patients/pools. Use it when a runtime flow/resolver changed or when its relevant assertions were extended for the target asset. It is not a mandatory regression for patient JSON or image-only work, and its existing named-patient assertions do not alone verify a new patient's CG.
- There is no generic dedicated examination-CG end-to-end test parameterized by patient ID. The localization test checks the examination mapping structurally. For a runtime-verified claim, add a target-specific UI/action assertion or manually trigger all in-scope completed undress branches and confirm the abandon branch does not display the CG.

## CG-specific T4 checks

- **Examination full-undress CG:** verify `encounter.full_undress.visual_pool_id`, patient examination pool and path; ensure exactly the three completed-undressing actions resolve and `abandon_full_undress` does not. The current localization sweep checks this structural chain; runtime display needs the target-specific/manual test noted above.
- **Ward/preop CG:** run the focused preparation regression after adding the target to its expected fixture. Exercise each requested action in its actual required/unnecessary branch and applicable procedure group; test no cross-patient or cross-procedure leakage and inspect the rendered fullscreen/splash node.
- **Surgery-stage CG:** confirm target surgery ID, stage, patient-scoped resolver result and UI caller for every requested stage. If the stage lacks a reachable caller, report it as structurally registered but not runtime-triggerable; do not expand to the full surgery suite unless runtime code changed.
- **Anesthesia splash portrait key:** test the exact dispatch action (`choose_general`, `induction_reassure`/`induction_brief`, or `choose_epidural`) and inspect the displayed texture. Use `tools/rie_anesthesia_test.gd` only for the Rie-specific pre-induction contract; it is not a generic new-patient test.

## Reporting

Report test layers separately (for example, “T0/T1/T2 passed; T3 visually passed; T4 not run”). Do not compress a partial result into “patient complete” or “CG works.” State unavailable tools and unrelated legacy failures precisely. A workflow is complete only when its required layers pass; later-stage tests are not prerequisites for earlier-stage claims.
