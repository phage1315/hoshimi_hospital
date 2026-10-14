"""Cross-file staff idle-chat requirements; record shape lives in JSON Schema."""

SOCIAL_LOCATIONS = {"lounge", "rooftop"}


def staff_social_locations(profile):
    presence = profile.get("presence", {})
    locations = set(presence.get("fixed_locations", [])) | set(presence.get("random_locations", []))
    required = locations & {"lounge"}
    if presence.get("rooftop_enabled", True):
        required.add("rooftop")
    return required


def staff_idle_chat_errors(profile, bundle, events):
    actor_id = profile["id"]
    required = staff_social_locations(profile)
    errors = []
    if required and not bundle.get("time_events"):
        errors.append(f"{actor_id}: social presence requires bundle.time_events registration")
    covered = set()
    for event in events:
        event_id = event.get("id", "<unknown>")
        if event.get("actor_id") != actor_id:
            errors.append(f"{actor_id}/{event_id}: idle chat must belong to its staff bundle owner")
            continue
        location = event.get("location_id")
        if location in SOCIAL_LOCATIONS and location not in required:
            errors.append(f"{actor_id}/{event_id}: idle-chat location {location} is absent from presence")
        covered.add(location)
    for location in sorted(required - covered):
        errors.append(f"{actor_id}: missing {location} idle chat in registered staff bundle")
    return errors
