import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const payload = (file) => JSON.parse(fs.readFileSync(path.join(root, file), "utf8"));
const originals = payload("baseline_original_locks.json").procedures;
const additions = payload("procedures_additions.json");
const manifest = payload("art_manifest.json");
const validKinds = new Set(["F", "L", "P", "S"]);
const validRoles = new Set([
  "lead_surgeon", "assistant_1", "assistant_2", "scrub_primary", "scrub_secondary",
  "circulating_primary", "circulating_secondary", "anesthesia", "system", "acting_surgeon"
]);
const check = (ok, message) => { if (!ok) throw new Error(message); };
const eq = (a, b) => JSON.stringify(a) === JSON.stringify(b);
const trackedOldStageKeys = ["id", "name", "name_en", "kind", "hp_base", "difficulty", "specialty_tag", "hp_failed_extra"];
const numericEffects = ["elapsed_time", "visibility", "bleeding", "blood_loss", "stability"];
const seenIds = new Set();
let totalSteps = 0;
let totalP = 0;
let totalEntry = 0;
let totalFailure = 0;
let totalStoryLines = 0;

check(additions.length === 3, "Expected exactly three additional/updated procedures.");
check(!additions.some(p => p.id === "surgery_open_whipple"), "Whipple must not be included as a replacement.");
check(manifest.procedures.length === 3, "Art manifest does not match procedure count.");

for (const p of additions) {
  check(!seenIds.has(p.id), `Duplicate procedure ID ${p.id}`);
  seenIds.add(p.id);
  check(Array.isArray(p.steps) && p.steps.length >= 11 && p.steps.length <= 13, `${p.id}: invalid stage count`);
  check(p.physiology_tuning_status === "P0_TUNING_PENDING_GAMEPLAY_APPROVAL", `${p.id}: missing tuning marker`);
  check(p.failure_condition.metric === "stability" && p.failure_condition.operator === "<=" && p.failure_condition.value === 0, `${p.id}: unexpected failure semantics`);
  check(p.success_condition.metric === "progress" && p.success_condition.operator === ">=" && p.success_condition.value === 100, `${p.id}: unexpected success semantics`);
  check(p.crisis_checkpoints.length === p.crisis_chances.length, `${p.id}: crisis arrays mismatch`);
  check(p.crisis_checkpoints.every(n => Number.isInteger(n) && n >= 1 && n <= p.steps.length), `${p.id}: crisis index out of range`);
  check(p.crisis_chances.every(n => typeof n === "number" && n >= 0 && n <= 1), `${p.id}: invalid HP-only crisis probability`);
  const original = originals.find(x => x.id === p.id);
  if (original) {
    check(eq(p.crisis_checkpoints, original.crisis_checkpoints), `${p.id}: old crisis checkpoints changed`);
    check(eq(p.crisis_chances, original.crisis_chances), `${p.id}: old crisis chances changed`);
    check(p.steps.length === original.steps.length, `${p.id}: old stage count changed`);
    for (let i = 0; i < p.steps.length; i++) {
      for (const key of trackedOldStageKeys)
        check(eq(p.steps[i][key], original.steps[i][key]), `${p.id} ${p.steps[i].id}: original ${key} changed`);
    }
  } else {
    check(p.id === "surgery_adv_ebstein_cone_reconstruction", `${p.id}: unexpected new procedure`);
  }

  const seenStages = new Set();
  let baseMinutes = 0;
  const pStages = new Set();
  for (const step of p.steps) {
    check(!seenStages.has(step.id), `${p.id}: duplicate stage ${step.id}`);
    seenStages.add(step.id);
    check(validKinds.has(step.kind), `${step.id}: invalid kind`);
    check(["medium", "high"].includes(step.physio_stress), `${step.id}: invalid physio stress`);
    check(numericEffects.every(k => typeof step.strategic_effects[k] === "number"), `${step.id}: nonnumeric/missing base effect`);
    baseMinutes += step.strategic_effects.elapsed_time;
    if (step.kind === "P") pStages.add(step.id);
    if (step.kind === "S") {
      check(Array.isArray(step.options) && step.options.length === 2, `${step.id}: expected two strategies`);
      check(new Set(step.options.map(o => o.id)).size === 2, `${step.id}: duplicate strategy IDs`);
      for (const option of step.options)
        check(["id", "label", "label_en", "description", "description_en", "strategic_effects"].every(k => option[k] !== undefined), `${step.id}: incomplete strategy`);
    } else check(!step.options, `${step.id}: non-S options are unsupported`);
    for (const condition of step.conditional_effects || []) {
      check(["gte", "lt"].includes(condition.when.op), `${step.id}: unsupported condition operator`);
      check(Object.values(condition.strategic_effects).every(v => typeof v === "number"), `${step.id}: invalid conditional effect`);
    }
  }
  totalSteps += p.steps.length;
  totalP += pStages.size;
  check(baseMinutes === p.duration_minutes, `${p.id}: stage base minutes ${baseMinutes} != fallback ${p.duration_minutes}`);

  const dialogue = payload(`dialogue/${p.id}.json`);
  check(dialogue.schema_version === "advanced_day2_dialogue_v1", `${p.id}: dialogue schema`);
  check(dialogue.procedure_id === p.id, `${p.id}: dialogue procedure mismatch`);
  check(eq(Object.keys(dialogue.stages).sort(), [...seenStages].sort()), `${p.id}: missing or extraneous dialogue stage`);
  const usedLineIds = new Set();
  for (const step of p.steps) {
    const lines = dialogue.stages[step.id];
    check(lines.stage_entry.length >= 2 && lines.stage_entry.length <= 3, `${step.id}: stage variants must be 2-3`);
    check(step.kind === "P" ? lines.precision_failed?.length >= 2 : !lines.precision_failed, `${step.id}: precision failure variants mismatch`);
    totalEntry += lines.stage_entry.length;
    totalFailure += lines.precision_failed?.length || 0;
    for (const [kind, group] of [["entry", lines.stage_entry], ["failed", lines.precision_failed || []]]) {
      for (const line of group) {
        check(validRoles.has(line.speaker_role), `${step.id}: illegal role ${line.speaker_role}`);
        check(kind === "failed" ? line.speaker_role === "acting_surgeon" : line.speaker_role !== "acting_surgeon", `${step.id}: bad role for ${kind}`);
        check(["id", "speaker_role", "text", "text_en"].every(k => typeof line[k] === "string" && line[k].trim()), `${step.id}: incomplete dialogue line`);
        check(Object.keys(line).length === 4, `${step.id}: dialogue contains forbidden gameplay field`);
        check(!usedLineIds.has(line.id), `${step.id}: duplicate line id ${line.id}`);
        usedLineIds.add(line.id);
      }
    }
  }

  const story = payload(`stories/${p.id}.json`);
  check(story.procedure_id === p.id, `${p.id}: story procedure mismatch`);
  check(story.patient.setting === "adult_medical_AU", `${p.id}: patient is not explicitly adult AU`);
  check(Object.keys(story.patient.visuals.portraits).length === 0, `${p.id}: unexpectedly claims art is available`);
  check(story.runtime_case_id === `advanced_first_${p.id}`, `${p.id}: runtime case ID mismatch`);
  for (const day of ["day1", "day3"]) {
    check(story[day].title && story[day].title_en, `${p.id}: incomplete bilingual story title`);
    check(story[day].portrait === (day === "day1" ? "ward" : "postop"), `${p.id}: portrait-slot mismatch`);
    check(story[day].lines.length >= 6, `${p.id}: story too short`);
    for (const line of story[day].lines) {
      check(["patient", "PLAYER"].includes(line.speaker), `${p.id}: unsupported story speaker ${line.speaker}`);
      check(line.text.startsWith("「") && line.text.endsWith("」"), `${p.id}: malformed CN quotation`);
      check(line.text_en.startsWith("“") && line.text_en.endsWith("”"), `${p.id}: malformed EN quotation`);
      totalStoryLines++;
    }
  }
  const art = manifest.procedures.find(a => a.procedure_id === p.id);
  check(art && art.field_window.after_stage === p.steps[0].id && art.field_window.before_stage === p.steps.at(-1).id, `${p.id}: stage/art boundary mismatch`);
  check(["path", "incision_path", "closure_path"].every(k => art.field_window[k] === null), `${p.id}: nonexistent art path was registered`);
  console.log(`PASS ${p.id}: stages=${p.steps.length} P=${pStages.size}, base_minutes=${baseMinutes}`);
}
console.log(`PASS TOTAL: procedures=${additions.length}, stages=${totalSteps}, P=${totalP}, stage_entry_variants=${totalEntry}, precision_failure_variants=${totalFailure}, story_lines=${totalStoryLines}`);
console.log("Medical tuning, Godot integration, character approval, and images are NOT validated by this script.");
