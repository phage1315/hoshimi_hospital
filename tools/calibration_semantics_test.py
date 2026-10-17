#!/usr/bin/env python3
"""Regression tests for V2 semantic validation; does not edit runtime data."""
import copy
import json
from pathlib import Path
import unittest

from jsonschema import Draft202012Validator

from calibration_semantics import IdentityMismatch, canonical_branch, canonical_condition, match_conditions


class SemanticGateTests(unittest.TestCase):
    def setUp(self):
        self.branch = {
            "when": {"field": "bleeding", "op": "gte", "value": 32},
            "strategic_effects": {"blood_loss": 10, "stability": -5, "add_complications": [{"id": "closure_rework", "severity": "minor"}]},
        }

    def test_godot_sorted_keys_and_cosmetic_role(self):
        runtime = copy.deepcopy(self.branch)
        runtime["when"] = {"all": [runtime["when"]]}
        runtime["response"] = "Unchanged original feedback"
        runtime["response_role"] = "assistant_surgeon"
        runtime["strategic_effects"] = dict(reversed(list(runtime["strategic_effects"].items())))
        self.assertEqual(match_conditions([self.branch], [runtime], "actual Godot JSON"), {0: 0})

    def test_commutative_boolean_predicates(self):
        leaf = self.branch["when"]
        other = {"field": "visibility", "op": "<", "value": 50}
        self.assertEqual(canonical_condition({"all": [leaf, other]}), canonical_condition({"all": [other, {"all": [leaf]}]}))
        self.assertNotEqual(canonical_condition({"all": [leaf, other]}), canonical_condition({"any": [leaf, other]}))

    def test_missing_duplicate_and_reordered_branches_block(self):
        for actual in [[], [self.branch, self.branch]]:
            with self.assertRaises(IdentityMismatch):
                match_conditions([self.branch], actual, "count")
        other = copy.deepcopy(self.branch)
        other["when"]["value"] = 33
        with self.assertRaises(IdentityMismatch):
            match_conditions([self.branch, other], [other, self.branch], "sequential conditions")

    def test_every_semantic_change_blocks(self):
        mutations = [
            lambda b: b["when"].update(value=33),
            lambda b: b["when"].update(op="gt"),
            lambda b: b["strategic_effects"].update(blood_loss=11),
            lambda b: b["strategic_effects"].update(stability=-6),
            lambda b: b["strategic_effects"].update(set_flags=["new_flag"]),
            lambda b: b["strategic_effects"]["add_complications"][0].update(severity="major"),
            lambda b: b["strategic_effects"]["add_complications"][0].update(id="different"),
        ]
        for mutate in mutations:
            runtime = copy.deepcopy(self.branch)
            mutate(runtime)
            with self.subTest(runtime=runtime), self.assertRaises(IdentityMismatch):
                match_conditions([self.branch], [runtime], "semantic mutation")

    def test_unknown_keys_block_even_on_both_sides(self):
        for place in ["branch", "when", "strategic_effects", "complication"]:
            branch = copy.deepcopy(self.branch)
            target = branch if place == "branch" else branch["strategic_effects"]["add_complications"][0] if place == "complication" else branch[place]
            target["unknown_gameplay_field"] = 99
            with self.subTest(place=place), self.assertRaises(IdentityMismatch):
                canonical_branch(branch)

    def conditional_validator(self):
        schema = json.loads((Path(__file__).resolve().parents[1] / "data/schemas/content.schema.json").read_text())
        branch_schema = schema["$defs"]["surgery_flow_option"]["properties"]["conditional_effects"]["items"]
        return Draft202012Validator({**branch_schema, "$defs": schema["$defs"]})

    def test_silent_effect_condition_matches_existing_runner(self):
        validator = self.conditional_validator()
        self.assertTrue(validator.is_valid(self.branch))
        legacy = copy.deepcopy(self.branch)
        legacy["effects"] = legacy.pop("strategic_effects")
        self.assertTrue(validator.is_valid(legacy))

    def test_spoken_condition_still_requires_both_presentation_fields(self):
        validator = self.conditional_validator()
        spoken = {**self.branch, "response": "Existing feedback", "response_role": "assistant_surgeon"}
        self.assertTrue(validator.is_valid(spoken))
        for field in ["response", "response_role"]:
            invalid = copy.deepcopy(spoken)
            del invalid[field]
            self.assertFalse(validator.is_valid(invalid))
        spoken["response"] = ""
        self.assertFalse(validator.is_valid(spoken))

    def test_empty_or_unknown_conditional_payload_rejected(self):
        validator = self.conditional_validator()
        self.assertFalse(validator.is_valid({"when": self.branch["when"]}))
        self.assertFalse(validator.is_valid({**self.branch, "unknown": 1}))


if __name__ == "__main__":
    unittest.main()
