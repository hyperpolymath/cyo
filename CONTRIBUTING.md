<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Contributing to `cyo`

`cyo` is a choose-your-own-adventure map of routes through the craft. Contributions
that keep that spirit are welcome; the spirit is the spec.

## The voice (this is the part that matters)

A chapter must:

- **Address the reader in the second person.** "You enjoy X." Not "developers
  who use X."
- **Assume the reader enjoys coding.** Never deficit-framed. No "infamous,"
  "notoriously," "a mess." A route is chosen, not prescribed as a remedy.
- **Use no levels, tiers, or ladders.** Routes are peers. Numbered hierarchies
  are explicitly out of scope — they alienate the people we are writing for.
- **State the stakes honestly.** Every route names *what the code can now
  survive*, its *cost*, and how *reversible* it is. An adventure with no stated
  stakes is a sales pitch.
- **Invent nothing.** Every command, claim, and link must be checkable. If
  something is young or unproven, the chapter says so.
- **Cross-link.** End with "This route opens onto …" pointing at adjacent
  chapters, so the map stays an adventure rather than a list.

Light RPG flavour (a class, an epigraph) is encouraged. Heavy-handed cosplay is
not — keep it tasteful enough that a working engineer is not embarrassed to
share it.

## Mechanics

- Chapters are AsciiDoc (`.adoc`) under `modules/`. Only files GitHub
  special-cases by name (this one, `README.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`) stay Markdown.
- Every file carries SPDX headers (REUSE). Run `reuse lint` before opening a PR.
- `./cyo.sh <route>` must still render your chapter; `./welcome.sh` lists routes.

## CI

CI workflows should be wired from the `hyperpolymath/standards` templates, not
hand-rolled here. They are intentionally absent until adopted from that source
rather than invented locally.
