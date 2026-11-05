# Audio provenance

Reused local resources from the user's repository:
https://github.com/tai23082004l02-svg/Game-create/tree/main/audio/library

Source snapshot tree: `aead6d9d2a0f790d02765144ee3bdea4c04e499f`.

Nine samples: ui_click, xp_pickup, level_up, player_hit, enemy_hit, enemy_death, boss_warning, defeat, lightning. Lightning supplies the deflect event, pitched differently for normal/Perfect. Original generation provider is ElevenLabs Sound Effects v3 according to Game-create's `audio/library_source.json`; the selected original profiles are preserved in `source.json`.

No audio-generation API was called for this update, and no credentials are included. Game playback is entirely local. The quiet wall bounce ping is synthesized from a short decaying sine wave in `scripts/audio.gd`.

Audio system follows the local-pool, per-event cooldown and limiter approach in Game-create's `systems/audio_director.gd`, adapted to LAST BULLET. Eight total players: five routine effects and three priority feedback/UI effects.
