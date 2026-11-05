# Mobile floating joystick

Updated 2026-11-05 after user feedback on S23 Ultra: replace the always-visible bottom-left stick with a hidden floating joystick, similar to the requested Archer Hunter interaction.

When idle, the movement ring is hidden. Touch and drag anywhere in the left half below the HUD to move; a ring appears near the touch and disappears on release. The visual center is constrained to safe edges. Drag is measured from the actual initial touch, so clamping does not introduce movement jumps. The right half remains available for Deflect and UI. A second finger cannot take over the active movement gesture. Release is handled even when a GUI consumes it. Keyboard movement remains available.

Supersedes the earlier bottom-only comfortable thumb-zone change. Arena dimensions and gameplay remain unchanged.

Godot 4.6.3 tests/admin_mobile.gd passes: safe layout, movement-zone bounds, touch/drag direction, second-finger ownership, release/reset and existing admin/profile checks. Comfort and simultaneous Deflect on physical Android still require user testing after pull.

## Correction: full-screen movement gestures

The user clarified that movement must start anywhere on the screen, not just the left half. All blank screen space inside the safe area can now start the hidden floating joystick. Pause and Deflect explicitly exclude their button rectangles, and GUI buttons keep their normal event handling. Passive progress bars ignore pointer input. The ring follows touches on either side; initial touch remains the movement anchor. Existing multi-touch ownership and release behavior are preserved. Automated tests now exercise a right-side drag, both button exclusions and safe-area bounds. This supersedes left-half-only descriptions above; physical-device feel awaits user confirmation.
