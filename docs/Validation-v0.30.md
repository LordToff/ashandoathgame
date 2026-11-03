# v0.30 art validation

The existing equipment and Wilds native UI suites passed **121 checks** (55 + 66), with no script errors. The two saved Chromium verifiers also passed without console/page errors. Reviewed screenshots show the new human-authored 16-pixel sprites in creature selection, equipment’s two Soul galleries and combat. Encounter launching, paid Soul binding, equipment persistence, actual Soul abilities, Dagger and the existing boss route remain usable.

The adapter verifies native 16×16 cells, no more than 16 visible colours per sprite and alpha values restricted to 0/255. Atlas coordinates select the new cells. UI and world sprites use nearest-neighbour sampling and integer enlargement. Original Kenney tiles, CC0 licence, pinned source mirror and file SHA-256 are preserved in prototype/assets/vendor/kenney_tiny_dungeon.

This is an art-only change. Gameplay rules, prices, ownership and saves remain v0.29; the prior gameplay rulebook stays current. No additional model-test count or human balance claim is made. Windows was not rebuilt. Existing native UI resource warnings at shutdown remain.
