# v0.31 phone UI validation

Godot **4.6.3** exported the normal browser game and a separate deterministic fixture. The fixture and all test callbacks are excluded from the shipping export.

**322 native checks passed:** mobile UI 17, hub/equipment 55, Wilds 66, Essence 115 and usability 69. Mobile checks exercise model/reward preservation, portrait and landscape geometry, board coordinate conversion, an actual Step and Guard, help text height, full log, equipment and all 18 Fracture slot buttons with the original mutation callback. The existing suites retain their historical ObjectDB/resource warnings at shutdown; no script/parse errors or assertion failures occurred.

The saved desktop hub, Wilds and Essence Chromium verifiers passed with no browser errors. The Essence verifier now waits for the complete recorded action-roll presentation before opening enemy cards; the former 1.5-second wait could click a disabled Menu button.

The phone verifier uses real touchscreen taps and drags in Chromium at **390×844**, **360×640** and **844×390**, at device pixel ratio 2. It checks automatic phone layout, board movement, untargeted Blank abilities, ability details without hover, Action Reroll selection and notice, equipment popup, readable Reaction explanations, enemy cards, full log, scrolling over buttons, rotation without losing battle state and a saved desktop preference surviving immediate reload. The complete bonus-selection → required-event → boss route is also exercised at 390×844. No browser console/page errors remain. These are browser emulations; physical iOS/Android hardware has not been tested.

Review screenshots include narrow portrait combat, landscape combat after rotation, Camp equipment, enemy cards, Reactions and the full log. Phone controls scroll below the board on short portrait screens. Landscape places them alongside the board. Advanced balance and Ability Lab tools are available in Desktop mode.

Current HTML, Markdown and PDF rules include phone controls. Gameplay, reward prices, owned copies, per-hero Soul restrictions and local rewards are unchanged. No balance claim or new Windows validation is made.
