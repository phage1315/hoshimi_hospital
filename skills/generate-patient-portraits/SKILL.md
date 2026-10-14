---
name: generate-patient-portraits
description: Generate and validate runtime-consumed SFW portrait assets for an already-defined ordinary Hoshimi Hospital patient, deriving keys from reachable consumers. Excludes supplied art, nudity, and full-screen CGs.
metadata:
  short-description: Generate runtime-derived SFW patient portraits
---

# Generate required SFW patient portraits

Use only after the patient bundle and identity exist. Read the shared [patient bundle data contract](../add-patient/references/patient-data-contract.md), [workflow boundaries](../add-patient/references/patient-workflow-boundaries.md), [patient workflow test matrix](../add-patient/references/patient-testing-matrix.md), and this skill's [runtime-derived portrait inventory and visual acceptance reference](references/portrait-matrix.md); then inspect the live portrait references and current patient schema. Generate only the keys justified by the patient's reachable consumers; this workflow does not create a patient, import user-supplied assets, or generate full-screen CGs.

## Runtime-derived checklist

Use 高卷杏's actual 20 generated keys as the reference inventory, not as a universal fixed quota. The exact keys, each current purpose/consumer, class specifications, difference rules, acceptance method and inclusion guidance are in the linked portrait-matrix reference. Before generation, inspect the target patient's reachable runtime consumers and contract (including assigned positioning and anesthesia branches), then record a per-key checklist with status: available/accepted, generate, supplied separately, not needed with evidence, or missing/blocked. Strongly prefer retaining every expression/pose variant needed by a reachable consumer so later states do not fall back to a generic or mismatched portrait. Omit a reference key only when its consumer is genuinely absent/unreachable for that patient type, or the user explicitly narrows scope; document the evidence/reason. If the live runtime has changed, use it over the historical matrix and resolve discrepancies before broad generation.

`splash/general_anesthesia_pre_induction` and `splash/epidural_anesthesia` are strictly optional patient-specific full-screen splash CGs, outside the required SFW portrait set. Their runtime branches may display them only when explicitly configured, but branch reachability alone never makes either image required. Do not generate them, add them to the portrait completeness checklist, or report them as missing unless the user explicitly requests those CGs. The separately supplied `examination/shy` portrait is not generated here and is not a full-screen examination CG.

## Image requirements

- When using ImageGen, follow the available `imagegen` skill and current image-generation tool instructions. The patient portrait skill supplies the project's asset-specific criteria; it does not override tool requirements.
- Use the actual corresponding patient-ann reference images for camera, crop, pose, draping, clothing, scale, and expression. Use the new patient's approved seed/reference for character identity and art style. Open the reference images before generation; a text-only mention is not equivalent.
- Generate each runtime key as one standalone image. Never use a grid, contact sheet, sprite sheet, or copied/renamed expression as production output.
- All generated images are SFW: clothed outpatient/ward states, or opaque surgical draping that fully covers chest, abdomen, pelvis, and thighs. No intimate anatomy, open wounds, or blood. Surgical table images retain the established shoulder/collarbone framing; intraoperative portraits are head/shoulders only. A mask is used only for the general-anesthesia splash where the reference calls for it.
- Follow the reference-specific framing and final specifications in the linked portrait-matrix reference; before generating, verify those details against actual patient-ann assets. Do not infer actual transparency or dimensions from a prompt or file extension.
- Among the keys actually included in this patient's checklist, first generate the independent base images (normally outpatient neutral, ward neutral, supine-table awake, lithotomy-table awake when needed, intraoperative tense, and each included anesthesia splash). Prepare each real reference and prompt; submit as a parallel batch when tool limits allow, while each call still produces one key/image. Review the base set and wait for the user's approval before producing dependent expression variants. Then create the included variants from accepted same-class bases, locking all non-expression content. If any base fails, repair only that class before making its variants. The number of outputs is determined by the patient-specific checklist, not a fixed “20” count.
- If the image tool rejects a request, do not count the result as complete or blindly replay identical input. If the user asks for retry, assess the specific returned restriction and make substantive, policy-compliant adjustments; record outcomes truthfully. Do not convert the scene into a materially different substitute and report it as the requested asset.

## Acceptance and integration

For each image, verify the returned image itself and record its reference inputs, prompt, final path, dimensions, mode, alpha findings (when applicable), SHA-256, and visual pass/fail. Inspect visual identity, expression distinction, framing, clothes/drape coverage, and the appropriate light/dark compositing for alpha edges. Preserve originals; do not stretch or crop away required content to force dimensions.

Only accepted files may be placed at runtime paths and mapped to their matching keys in `patient.visuals.portraits`. Check that each path exists and loads. If any generated label/caption or patient-visible text is added/changed, apply the shared [English localization and enum rules](../add-patient/references/patient-text-and-enum-rules.md) and run `python3 tools/patient_bundle_localization_test.py`. This stage does not validate patient-specific full-screen CG triggers. If Godot is unavailable, state that live UI display was not tested.

Apply T3 per image and the matrix's T0/T1 checks when portrait mappings change. Run the complete `portrait_test.gd` once after the integrated portrait batch, not once per generated key. Do not run unrelated CG resolver tests unless this change also touched CG integration.
