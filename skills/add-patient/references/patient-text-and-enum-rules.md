# Patient text localization and enum confirmation

Apply these rules to patient bundle creation or changes, including text added to CG labels/captions and patient-specific profile overrides.

## English text requirement

- Every user-visible text value introduced or changed for a patient must have a complete English version. This includes patient display names as shown in UI, outpatient lines, patient reactions/variants, encounter title/prompt/responses, preop title/stage prompts/action responses, diagnosis reactions, and patient CG labels/captions. Shared profile strings must also resolve in English when used by the patient.
- Preserve the user's Chinese source text verbatim; add English localization separately. Do not replace, shorten, rewrite, or move source dialogue to make it easier to translate. If the user supplies only English text, preserve it as authored; do not invent Chinese source prose.
- For Chinese strings stored in a bundle/profile, add the matching key under `data/localization/en.json` using the runtime key namespace (`patient_bundles.<patient_id>...` or `patient_dialogue_profiles.<profile_id>...`). Confirm the exact path from the existing localization/runtime loader rather than guessing it.
- Run `python3 tools/patient_bundle_localization_test.py` after any patient bundle/profile/patient-pool text changes. This test walks the indexed patient bundles and dialogue profiles for Chinese leaves unresolved in English and validates patient CG labels/captions and runtime pool integration. A failure blocks the patient-text completion claim; do not waive it as unrelated without proving the exact failure is pre-existing and outside the changed scope.
- Schema validation and `tools/localization_audit.py` do not replace this focused patient-bundle localization test. For broader localization changes, run the broader audit too and report results separately.

## Invalid enum/reference values

- Before writing any enum-valued source field, compare it with the live field definition in `data/schemas/content.schema.json` or the relevant narrower schema. Examples include patient voice style, admission status, visual state, stress response, response speaker, CG presentation, procedure group, surgery region/stage, and role category.
- If the supplied value is not allowed, do **not** write it to the runtime bundle and do not normalize it to the closest-looking value. Stop the write for that field. Present the source path and raw value, the relevant context/meaning, and the exact allowed values; ask the user which mapping to use or whether the schema should be deliberately expanded.
- Do not silently change other source fields to compensate. If unresolved enum meaning affects identity, game behavior, or required cross-field consistency, pause the dependent import. Unrelated fields/workflows may proceed only when they remain valid and can be cleanly separated.
- Record an approved source→runtime mapping and its reason in the import evidence. Do not treat a one-off user-approved mapping as permission to alter the global enum/schema.
- A patterned ID or external reference that is syntactically valid but does not resolve (for example, a dialogue profile, case, surgery, trigger or pool ID) is a reference-resolution issue, not an enum. Do not invent a replacement; show candidates/context and ask when the intended target is ambiguous.
