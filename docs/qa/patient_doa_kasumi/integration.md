# Kasumi patient import and neutral portrait pass

Date: 2026-10-25

## Imported sources

- Original patient bundle: `research/character_references/patient_doa_kasumi/user_bundle_v1.json`
- Seed images: `research/character_references/patient_doa_kasumi/user_seeds/`
- Runtime profile: `data/patients/patient_doa_kasumi/patient.json`
- Patient index entry: `data/patients/index.json`

The source bundle's authored Chinese text was preserved. Only the four requested portrait path mappings were added to the runtime copy.

## Requested neutral/base portraits

| Runtime key | Asset | Canvas | Alpha |
|---|---|---:|---|
| `outpatient/neutral` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/outpatient/neutral.png` | 1024×1536 | yes |
| `ward/neutral` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/ward/neutral.png` | 1024×1536 | yes |
| `operating_table/awake` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/operating_table/awake_v2.png` | 941×1672 | no |
| `intraoperative/tense` | `assets/characters/patient_doa_kasumi_v1/patient_doa_kasumi/intraoperative/tense.png` | 1672×941 | yes |

The operating-table and intraoperative keys above are the project's existing runtime slots for the requested base images. The intraoperative image uses the established `tense` slot; it is not registered as an additional `neutral` key. The original landscape operating-table image remains at `operating_table/awake.png`; the corrected vertical composition is saved as `awake_v2.png` and is the mapped runtime asset.

## Scope and remaining coverage

This pass generated the four specifically requested images only. The project-wide patient validator additionally requires `intraoperative/pain`, `intraoperative/near_collapse`, and `intraoperative/anesthetized`; these were not generated or pointed at duplicate neutral art.

The imported bundle has 101 Chinese text fields with no English localization entries yet. No translation was authored in this import pass. The bundle localization test therefore remains a completion gate for English runtime coverage.

## Checks

- `python3 tools/patient_data_import_test.py patient_doa_kasumi`: passed.
- `python3 tools/validate_data.py`: reports only the three additional missing intraoperative expression portraits for this patient; schema and resource paths for the four registered images are valid.
- `python3 tools/patient_bundle_localization_test.py`: 101 unresolved English fields for this new patient; existing English entries outside it remain intact.
- `python3 tools/localization_audit.py`: ran; authored coverage is 22227/22328, with the 101 new patient fields unresolved. UI coverage is 738/738.
- Image metadata verified with `sips`; all four PNGs are readable and all mapped assets exist. Transparent canvases are used for the outpatient, ward, and intraoperative portraits.
- Runtime/Godot validation was not run; no Godot executable was available in this environment.

## SHA-256

- Outpatient: `c483fd4ccc1f7f55ce131a31099ca2ead4f6a3f987c47aa349bc59fec2f6dc4e`
- Ward: `89b91958e5040a141b13bacba54f55d29523c227d8307f9023d65cac88dc5a02`
- Operating table, original landscape: `47bc0d2e36d09bcbe19baa35604f84d0187cac3e29108b3b8ebd7ea7567fbe18`
- Operating table, corrected vertical v2: `26754eab0e3f2eb0c9023e720a6b58fa73727f8e89f0a42cf85ba87c6f55097b`
- Intraoperative: `5c960da735a3fff72c296e714880f44ab3913c994e2af311be42d803731dc1a0`
