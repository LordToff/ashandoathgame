# Validation — v0.38.1 fullscreen Settings

13 November 2026 · Godot 4.6.3 · software-rendered Chromium.

Passed actual browser fullscreen checks at **1440×900, 390×844, 360×640 and 844×390**. Mouse/touch input enters fullscreen from Options, the fullscreen element covers the whole viewport, the button becomes Exit fullscreen and leaves fullscreen, and a browser-owned exit updates the caption without reopening Settings. The Trial Settings toggle also works, preserving HP, rolled results, run phase and combat RNG. No console/page errors in passing checks. Screenshots of normal and Trial fullscreen Settings were inspected.

Reproduce with `tools/make_essence_fixture.py` and `tools/verify_fullscreen_browser.py`; the fixture and its callbacks are excluded from shipping exports. The landscape main menu is scrolled to reach Options. Fullscreen entry itself uses real mouse/touch input, not JavaScript to invoke the toggle.

Native regressions: `mobile_flow_v33_test.gd` (55 checks) and `mobile_v31_test.gd` (17 checks), both zero failures and no script errors. Existing headless exit-time resource warnings remain separate from failures. Godot Web export succeeds.

The shipping build is also checked without fixture callbacks: displayed version, Options button, actual fullscreen entry, viewport coverage and button exit. Pages release verification checks the versioned pack, source commit and SHA-256 manifest after deployment.

This update changes presentation only; v0.38 gameplay rules and PDF remain current. Physical phone hardware and Windows artifacts were not tested/rebuilt. Browsers which withhold fullscreen support show an unavailable control.
