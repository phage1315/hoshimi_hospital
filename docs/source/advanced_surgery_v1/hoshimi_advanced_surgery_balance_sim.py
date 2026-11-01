#!/usr/bin/env python3
"""Advanced Referral HP/precision balance prototype for Hoshimi Hospital.

This is an intentionally small, reproducible Monte Carlo *design harness*,
NOT a port of the full Godot Surgery Runner. Existing stability/blood-loss/
visibility/quality systems are outside this harness. All skill values are
TEST FIXTURES, not canonical character data.

Usage:
    python3 hoshimi_advanced_surgery_balance_sim.py --runs 20000 --seed 20261030
    python3 hoshimi_advanced_surgery_balance_sim.py --runs 20000 --json
"""

from __future__ import annotations

import argparse
import json
import math
import random
from dataclasses import dataclass
from functools import lru_cache
from statistics import mean


@dataclass(frozen=True)
class Step:
    code: str
    name: str
    kind: str  # F=flow, L=low risk, S=old strategic, P=precision
    hp: int
    difficulty: int = 0
    tag: str = ""
    fail_hp: int = 0


@dataclass(frozen=True)
class Case:
    code: str
    name: str
    steps: tuple[Step, ...]
    crisis_checkpoints: tuple[int, int]
    crisis_chances: tuple[float, float]


@dataclass(frozen=True)
class Surgeon:
    name: str
    skill: int
    specialties: tuple[str, ...] = ()
    universal_expert: bool = False

    def expert_match(self, tag: str) -> bool:
        return self.skill >= 90 and (
            self.universal_expert or tag in self.specialties
        )


@dataclass(frozen=True)
class Team:
    name: str
    player: int
    first: Surgeon
    second: Surgeon
    primary_scrub: int
    secondary_scrub: int
    primary_circ: int
    secondary_circ: int


def st(code: str, name: str, kind: str, hp: int,
       difficulty: int = 0, tag: str = "", fail_hp: int = 0) -> Step:
    return Step(code, name, kind, hp, difficulty, tag, fail_hp)


CASES = (
    Case(
        "surgery_open_whipple", "胰十二指肠切除 / Whipple",
        (
            st("W01", "切口与进入", "F", 2),
            st("W02", "腹腔探查、建立暴露", "L", 2),
            st("W03", "复杂粘连分离", "P", 4, 88, "adhesion", 12),
            st("W04", "主要血管关系与切除路径评估", "S", 2),
            st("W05", "门静脉周围组织分离", "P", 5, 94, "vascular", 15),
            st("W06", "胰头深部精细分离", "P", 5, 96, "microdissection", 16),
            st("W07", "标本取出、整理术野", "F", 2),
            st("W08", "胰肠重建", "P", 6, 97, "reconstruction", 16),
            st("W09", "胆肠重建", "P", 4, 92, "reconstruction", 13),
            st("W10", "胃肠重建", "P", 4, 90, "reconstruction", 12),
            st("W11", "重建区复核及止血", "S", 2),
            st("W12", "最终清点与评估", "L", 1),
            st("W13", "关闭", "F", 2),
        ), (5, 10), (0.27, 0.18),
    ),
    Case(
        "surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction",
        "盆壁肿瘤切除（髂血管重建）",
        (
            st("P01", "切口与进入", "F", 2),
            st("P02", "盆壁暴露", "L", 2),
            st("P03", "广泛盆腔粘连分离", "P", 4, 90, "adhesion", 13),
            st("P04", "神经与输尿管邻近关系辨认", "P", 5, 95, "neural", 15),
            st("P05", "血管处理策略确认", "S", 2),
            st("P06", "髂血管周围精细分离", "P", 5, 96, "vascular", 16),
            st("P07", "肿瘤深部边界分离", "P", 5, 94, "microdissection", 15),
            st("P08", "完整切除、整理术野", "F", 2),
            st("P09", "髂血管重建", "P", 6, 98, "reconstruction", 18),
            st("P10", "盆壁神经与固定点复核", "P", 4, 92, "pelvic", 13),
            st("P11", "灌注与最终止血评估", "S", 2),
            st("P12", "关闭", "F", 2),
        ), (6, 9), (0.29, 0.20),
    ),
    Case(
        "surgery_adv_sleeve_lobectomy", "开胸袖式肺叶切除",
        (
            st("T01", "开胸与进入", "F", 2),
            st("T02", "肺门区域暴露", "L", 2),
            st("T03", "肺动脉分支解剖", "P", 5, 94, "vascular", 15),
            st("T04", "支气管周围精细分离", "P", 4, 91, "thoracic", 12),
            st("T05", "病变切除范围确认", "S", 2),
            st("T06", "保留结构与切缘处理", "P", 4, 93, "microdissection", 13),
            st("T07", "完成肺叶切除", "F", 2),
            st("T08", "支气管重建吻合", "P", 6, 97, "airway", 17),
            st("T09", "血管重建及复核", "P", 5, 96, "reconstruction", 16),
            st("T10", "通气与灌注复查", "S", 2),
            st("T11", "关闭", "F", 2),
        ), (7, 9), (0.25, 0.23),
    ),
)


def make_teams(case: Case) -> tuple[Team, ...]:
    expert_second = {
        "surgery_open_whipple": Surgeon(
            "精细解剖专家（武见型）", 94, ("microdissection", "adhesion")
        ),
        "surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction": Surgeon(
            "盆腔专家（阿库娅型）", 94, ("pelvic", "neural")
        ),
        "surgery_adv_sleeve_lobectomy": Surgeon(
            "复杂重建专家（Saber型）", 94, ("airway", "reconstruction", "vascular")
        ),
    }[case.code]
    return (
        Team("入门阵容", 82,
             Surgeon("第一助手", 82, ("vascular",)),
             Surgeon("第二助手", 76, ("pelvic",)), 65, 60, 65, 60),
        Team("入门主刀＋强援", 82,
             Surgeon("全科专家（御堂型）", 97, universal_expert=True),
             Surgeon("第二助手", 80, ("pelvic",)), 80, 78, 77, 72),
        Team("均衡阵容", 88,
             Surgeon("第一助手", 90, ("vascular", "reconstruction")),
             Surgeon("第二助手", 84, ("microdissection", "pelvic", "airway")),
             80, 76, 78, 75),
        Team("顶级专家阵容", 93,
             Surgeon("全科专家（御堂型）", 97, universal_expert=True),
             expert_second, 92, 88, 88, 85),
    )


def nurse_bonus(team: Team, tag: str) -> float:
    # Small support (0–5 percentage points), no nurse delegation.
    main = min(.035, max(0, team.primary_scrub - 65) * .0013)
    secondary = min(.015, max(0, team.secondary_scrub - 70) * .0007)
    if tag in ("adhesion", "pelvic", "neural"):
        secondary *= .6
    return min(.05, main + secondary)


def p_success(skill: int, step: Step, team: Team, variant: bool) -> float:
    # Sim-only curve. One difficult variant increases difficulty for two nodes.
    effective_difficulty = step.difficulty + (
        3 if variant and step.difficulty >= 95 else 0
    )
    return min(.985, max(.08,
        .78 + .028 * (skill - effective_difficulty) + nurse_bonus(team, step.tag)))


def success_cost(skill: int, step: Step) -> int:
    # Technique matters mostly through probability; HP surcharge is modest.
    shortfall = max(0, step.difficulty - skill)
    return step.hp + min(3, math.ceil(shortfall / 12))


def can_use(assistant: Surgeon, used: int, step: Step) -> bool:
    if used == 0:
        return True
    return used == 1 and assistant.expert_match(step.tag)


def expected_loss(skill: int, step: Step, team: Team) -> float:
    return success_cost(skill, step) + (
        1 - p_success(skill, step, team, variant=False)) * step.fail_hp


@lru_cache(maxsize=None)
def planned_assignment(case_id: str, team: Team) -> tuple[int, ...]:
    """Solve pre-op expected HP allocation, without revealing random variant.

    0: player, 1: first assistant, 2: second assistant. An expert's
    second use is legal only at a matching specialty-tagged stage.
    """
    case = next(c for c in CASES if c.code == case_id)
    challenges = [s for s in case.steps if s.kind == "P"]

    @lru_cache(maxsize=None)
    def solve(i: int, used_first: int, used_second: int):
        if i == len(challenges):
            return (0., ())
        node = challenges[i]
        candidates = [(0, team.player, used_first, used_second)]
        if can_use(team.first, used_first, node):
            candidates.append((1, team.first.skill, used_first + 1, used_second))
        if can_use(team.second, used_second, node):
            candidates.append((2, team.second.skill, used_first, used_second + 1))
        best = (float("inf"), ())
        for who, skill, f, s in candidates:
            rest, choices = solve(i + 1, f, s)
            result = (expected_loss(skill, node, team) + rest, (who,) + choices)
            if result[0] < best[0]:
                best = result
        return best

    return solve(0, 0, 0)[1]


def pick_greedy(node: Step, team: Team, used: list[int]) -> int:
    best = (expected_loss(team.player, node, team), 0)
    for idx, staff in enumerate((team.first, team.second)):
        if can_use(staff, used[idx], node):
            cost = expected_loss(staff.skill, node, team)
            if cost + .1 < best[0]:
                best = (cost, idx + 1)
    return best[1]


def pick_rescue(node: Step, team: Team, used: list[int]) -> int:
    """A rescue can reduce, but never erase, the initial failed dissection."""
    candidates = []
    for i, staff in enumerate((team.first, team.second)):
        if not can_use(staff, used[i], node):
            continue
        p = p_success(staff.skill, node, team, variant=False)
        if p < .55:
            continue
        # Full unresolved cost vs. rescue success at 42% +2 HP,
        # or rescue failure at full cost +3 HP.
        on_success = math.ceil(node.fail_hp * .42) + 2
        on_failure = node.fail_hp + 3
        expected = p * on_success + (1-p) * on_failure
        if expected + 1 < node.fail_hp:
            candidates.append((expected, i+1))
    return min(candidates)[1] if candidates else 0


def run_one(case: Case, team: Team, policy: str, rng: random.Random) -> dict:
    hp = 100
    used = [0, 0]
    precision_failures = 0
    rescue_attempts = 0
    crises = 0
    specialist_actions = 0
    variant = rng.random() < .25
    plan = planned_assignment(case.code, team) if policy == "planned" else ()
    challenge_idx = 0
    for i, node in enumerate(case.steps, start=1):
        if node.kind != "P":
            hp -= node.hp
        else:
            who = 0
            if policy == "planned":
                who = plan[challenge_idx]
            elif policy == "greedy":
                who = pick_greedy(node, team, used)
            # "solo" and "reactive" start with player action.
            challenge_idx += 1
            skill = team.player
            if who:
                index = who - 1
                staff = (team.first, team.second)[index]
                if can_use(staff, used[index], node):
                    used[index] += 1
                    specialist_actions += 1
                    skill = staff.skill
                else:
                    who = 0
            hp -= success_cost(skill, node)
            if rng.random() >= p_success(skill, node, team, variant):
                precision_failures += 1
                extra = node.fail_hp
                if policy == "reactive" and who == 0:
                    rescue = pick_rescue(node, team, used)
                    if rescue:
                        index = rescue - 1
                        staff = (team.first, team.second)[index]
                        used[index] += 1
                        specialist_actions += 1
                        rescue_attempts += 1
                        if rng.random() < p_success(staff.skill, node, team, variant):
                            extra = math.ceil(node.fail_hp * .42) + 2
                        else:
                            extra = node.fail_hp + 3
                hp -= extra
        # A difficult anatomy variant costs additional time/handling reserve.
        if variant and i == 2:
            hp -= 4
        if i in case.crisis_checkpoints:
            idx = case.crisis_checkpoints.index(i)
            if rng.random() < case.crisis_chances[idx]:
                crises += 1
                nurse_reduction = min(4, max(0, team.primary_circ - 65)//12
                                      + max(0, team.secondary_circ - 70)//25)
                hp -= max(3, rng.randint(8, 13) - nurse_reduction)
        if hp <= 0:
            return {"clear": False, "hp": 0, "failures": precision_failures,
                    "crises": crises, "assist_uses": specialist_actions,
                    "rescues": rescue_attempts, "variant": variant}
    return {"clear": True, "hp": hp, "failures": precision_failures,
            "crises": crises, "assist_uses": specialist_actions,
            "rescues": rescue_attempts, "variant": variant}


def simulate(case: Case, team: Team, policy: str, n: int, seed: int) -> dict:
    rng = random.Random(seed)
    results = [run_one(case, team, policy, rng) for _ in range(n)]
    clears = [r for r in results if r["clear"]]
    return {
        "case_id": case.code,
        "team": team.name,
        "policy": policy,
        "runs": n,
        "clear_rate": round(len(clears) / n, 4),
        "mean_clear_hp": round(mean(r["hp"] for r in clears), 2) if clears else None,
        "mean_precision_failures": round(mean(r["failures"] for r in results), 2),
        "mean_assist_uses": round(mean(r["assist_uses"] for r in results), 2),
        "mean_crises": round(mean(r["crises"] for r in results), 2),
        "p_low_hp_on_clear": round(sum(r["hp"] <= 15 for r in clears) / len(clears), 4)
                             if clears else None,
    }


def rotation_test(n: int, seed: int) -> list[dict]:
    """Three first-time cases across the calendar; 14-day Grand OR assistant cooldown.

    A doctor is placed on cooldown for *participating* in an advanced case,
    regardless of whether her precision intervention was used. A week-2 rush
    cannot select Mido (week-1 involvement); delaying to week 3 can.
    """
    configurations = {
        "连续接诊，轮换助手": (2, 9, 16),
        "等待强援，每两周开一台": (2, 16, 30),
    }
    results = []
    for label, days in configurations.items():
        rng = random.Random(seed + 7231)
        clear_counts, mido_appearances = [], []
        for _ in range(n):
            next_mido_day = -1
            clears = 0
            expert_count = 0
            for case, day in zip(CASES, days):
                mido_available = day >= next_mido_day
                first = (Surgeon("全科专家（御堂型）", 97, universal_expert=True)
                         if mido_available else Surgeon("轮换医生", 86, ("vascular",)))
                if mido_available:
                    expert_count += 1
                    next_mido_day = day + 14
                second = {
                    "surgery_open_whipple": Surgeon("武见型", 94, ("microdissection", "adhesion")),
                    "surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction":
                        Surgeon("阿库娅型", 94, ("pelvic", "neural")),
                    "surgery_adv_sleeve_lobectomy":
                        Surgeon("Saber型", 94, ("airway", "reconstruction", "vascular")),
                }[case.code]
                team = Team("轮换测试阵容", 88, first, second, 88, 82, 82, 78)
                clears += int(run_one(case, team, "planned", rng)["clear"])
            clear_counts.append(clears)
            mido_appearances.append(expert_count)
        results.append({
            "schedule": label,
            "day2_dates": days,
            "last_day3": days[-1] + 1,
            "mean_unique_first_clears": round(mean(clear_counts), 3),
            "p_all_three_first_clear": round(sum(x == 3 for x in clear_counts) / n, 4),
            "p_at_least_two_first_clears": round(sum(x >= 2 for x in clear_counts) / n, 4),
            "mido_assignments": round(mean(mido_appearances), 2),
        })
    return results


def nurse_sensitivity(n: int, seed: int) -> list[dict]:
    """Hold all other surgical stats constant and vary only nurse skills."""
    case = CASES[0]
    rows = []
    for i, (label, scrub1, scrub2, circ1, circ2) in enumerate((
        ("新护士", 60, 60, 60, 60),
        ("熟练护士", 80, 76, 78, 75),
        ("优秀护士", 94, 90, 92, 88),
    )):
        team = Team(label, 88,
                    Surgeon("第一助手", 90, ("vascular", "reconstruction")),
                    Surgeon("第二助手", 84, ("microdissection",)),
                    scrub1, scrub2, circ1, circ2)
        result = simulate(case, team, "planned", n, seed + i * 1000)
        rows.append({"nurse_level": label, "clear_rate": result["clear_rate"],
                     "mean_clear_hp": result["mean_clear_hp"],
                     "nurse_success_bonus_vascular": round(nurse_bonus(team, "vascular"), 4)})
    return rows


def validate():
    assert len(CASES) == 3
    for case in CASES:
        ids = [s.code for s in case.steps]
        assert len(ids) == len(set(ids))
        assert len([s for s in case.steps if s.kind == "P"]) in (5, 6)
        assert sum(s.hp for s in case.steps) < 100
        assert all(s.fail_hp >= 10 for s in case.steps if s.kind == "P")
        assert all(s.difficulty >= 80 for s in case.steps if s.kind == "P")
        for team in make_teams(case):
            plan = planned_assignment(case.code, team)
            used = [0, 0]
            for node, who in zip((s for s in case.steps if s.kind == "P"), plan):
                if who:
                    idx = who - 1
                    staff = (team.first, team.second)[idx]
                    assert can_use(staff, used[idx], node)
                    used[idx] += 1
            assert all(u <= 2 for u in used)
    # Independent expert second chance is specialty-gated.
    normal = Surgeon("normal", 89, ("vascular",))
    expert = Surgeon("expert", 95, ("vascular",))
    example_v = st("X", "", "P", 1, 95, "vascular", 15)
    example_n = st("Y", "", "P", 1, 95, "neural", 15)
    assert not can_use(normal, 1, example_v)
    assert can_use(expert, 1, example_v)
    assert not can_use(expert, 1, example_n)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=20000)
    parser.add_argument("--seed", type=int, default=20261030)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    validate()
    policies = ("solo", "greedy", "planned", "reactive")
    rows = []
    for ci, case in enumerate(CASES):
        for ti, team in enumerate(make_teams(case)):
            for pi, policy in enumerate(policies):
                seed = args.seed + 1000000 * ci + 10000 * ti + 100 * pi
                rows.append(simulate(case, team, policy, args.runs, seed))
    rotation = rotation_test(args.runs, args.seed)
    nurse_effect = nurse_sensitivity(args.runs, args.seed)
    if args.json:
        print(json.dumps({"seed": args.seed, "runs_per_scenario": args.runs,
                          "results": rows, "rotation": rotation,
                          "nurse_sensitivity": nurse_effect},
                         ensure_ascii=False, indent=2))
    else:
        print("seed", args.seed, "runs/scenario", args.runs)
        print(f"{'case':<24} {'team':<18} {'policy':<10} {'clear%':>7} "
              f"{'clear_HP':>8} {'fails':>6} {'assists':>7} {'lowHP%':>7}")
        for x in rows:
            print(f"{x['case_id'].replace('surgery_adv_', '').replace('surgery_', '')[:24]:<24} "
                  f"{x['team']:<18} {x['policy']:<10} {100*x['clear_rate']:>6.1f}% "
                  f"{x['mean_clear_hp'] if x['mean_clear_hp'] is not None else 0:>8.1f} "
                  f"{x['mean_precision_failures']:>6.2f} "
                  f"{x['mean_assist_uses']:>7.2f} "
                  f"{100*x['p_low_hp_on_clear'] if x['p_low_hp_on_clear'] is not None else 0:>6.1f}%")
        print("\nGrand OR 14-day assistant cooldown, three first attempts:")
        for x in rotation:
            print(x)
        print("\nNurse-only skill sensitivity, Whipple, balanced surgeons:")
        for x in nurse_effect:
            print(x)


if __name__ == "__main__":
    main()
