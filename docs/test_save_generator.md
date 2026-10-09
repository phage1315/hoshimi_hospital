# Test Save Generator

Debug builds expose **DEBUG: Test Save Generator** on the title screen. The generator writes a normal game save into a selected empty slot. It never overwrites an occupied slot and never starts the target event inside the save, so the resulting file remains compatible with ordinary load flow.

## Event presets

The preset list includes special events, ordinary character events, and relationship Gate checkpoints whose scripts are still planned.

- **Requirements ready on load** prepares the earliest valid day and time, required staff introductions, relationship level/familiarity, player attributes, prerequisite events, cooldown completion days, surgery totals, and boolean flags. Competing automatic events are temporarily suppressed until the selected event completes.
- **Trigger after the next surgery** prepares the same state but adds a saved one-surgery latch. The target remains unavailable until `completed_surgeries_total` increases once, regardless of the selected operation's duration. The latch is removed when the target event completes.

For location-based character events, “ready” means that the event is available at its authored location and time. Mandatory/automatic events can prompt as soon as the loaded game returns to the map.

The list also includes every `planned` relationship milestone that has a finalized Gate but no authored event yet. These presets can place Familiarity one point below the threshold, exactly at it, or one point above it. Other requirements are synthesized at their exact passing values. Relationship-gate presets remain idle at the hospital and never create or start placeholder events.

## Time override

`Day` accepts 1–365. `Time` accepts `HH:MM` and is clamped to the playable 09:00–16:59 work shift. Leaving either field blank keeps the preset's calculated value.

## Advanced JSON overrides

All sections are optional. Unknown character IDs, player attributes, relationship fields, or special-event IDs are rejected rather than silently ignored.

```json
{
  "player_attributes": {
    "skill": 63,
    "leadership": 61,
    "charm": 33,
    "reputation": 120,
    "presence": -25
  },
  "relationships": {
    "nurse_satsuki": {
      "met": true,
      "level": 2,
      "affection": 41,
      "familiarity": 48,
      "route": "colleague",
      "flags": []
    }
  },
  "story_flags": {
    "example_gate": true
  },
  "progress": {
    "completed_surgeries_total": 12,
    "completed_surgeries_by_group": {
      "general_abdominal": 4
    },
    "completed_surgeries_by_procedure": {
      "surgery_appendix": 2
    },
    "character_counters": {
      "global": {
        "gynecology_case_count": 15
      },
      "pharmacist_manami": {
        "completed_no_anesthesia_surgeries_as_assistant_surgeon": 1
      }
    },
    "staff_skills": {
      "pharmacist_manami": {
        "surgery": 60
      }
    }
  },
  "special_events": {
    "satsuki_lv1_real_patient_test": {
      "count": 1,
      "day": 2
    }
  }
}
```

Valid player attributes are `skill`, `leadership`, `charm`, `reputation`, and `presence`. Relationship overrides accept `met`, `level`, `affection`, `familiarity`, `route`, and `flags`. `story_flags` values must be booleans.
