# Mobile movement controls

2026-11-05: After testing on S23 Ultra, the user reported that the movement stick was too close to the bottom-left corner. The floating stick previously adopted the exact touch position, including edge touches.

The default center is now x=185 logical pixels. Touch-created centers are constrained to x=150–260 and a safe vertical band below the arena, with at least 125 pixels above the bottom safe inset. Movement measures drag from the original touch, independent of the constrained visual center, so edge touches do not jump. Release restores the comfortable default and clears movement, including releases consumed by GUI. Deflect remains in its existing right-side safe zone; arena geometry is preserved.

Validated with Godot 4.6.3 tests/admin_mobile.gd, including constrained edge positions, arena separation, safe inset bounds and reset. Physical-device comfort needs user confirmation after pull.
