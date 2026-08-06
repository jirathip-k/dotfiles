---
name: distill
description: Run a Dreams-shaped consolidation pass over a memory file — CLAUDE.md, AGENTS.md, or MEMORY.md — merging duplicates, replacing stale entries, and demoting rationale into plan docs while keeping every operative directive. Produces a proposal file plus a per-cut ledger; never edits the original. Use when a CLAUDE.md has grown large, when asked to "distill", "consolidate", "compact", "trim", or "dream over" memory, or on a scheduled memory-hygiene run.
---

# Distill a memory file

Anthropic's **Dreams** (Managed Agents, research preview, May 2026) consolidates a
memory store against session transcripts and emits a **new** store. It is an API
feature and is **not available in Claude Code** — there is no native dream over
`CLAUDE.md`. This skill is the manual equivalent, and it borrows the one rule that
makes Dreams safe:

> **The input is never modified.** Consolidation is a proposal, not a write.

## The rule that governs everything below

For each paragraph ask: **would an agent do the wrong thing if this weren't in
context?**

- **Yes** → keep it. Tighten the prose, never the rule.
- **No, it's explaining *why*** → demote to the plan doc that owns that topic.
- **No, it's already said elsewhere** → drop it, and record that in the ledger.

Keep the directive, demote the story:

- **KEEP** — "Never add a column to the explicit auth-time select list; the query
  uses `*` deliberately." One line, prevents a full user lockout.
- **DEMOTE** — the multi-paragraph account of *how* that lockout happened.

**When uncertain, keep.** A wrongly-kept line is mild clutter; a wrongly-cut
directive is a guardrail removed from every future session, and it fails silently
— not at distill time, but months later, in the incident it existed to prevent.

**Merging near-duplicates is where directives die.** Rules that look redundant
usually differ in scope. "Never force-push to `main`" plus "never force-push a
shared branch" merged into one rule leaves `main` covered only by implication.
The result is shorter, cleaner, and quietly weaker. Merge only verbatim
duplicates; when two rules overlap partially, keep both.

## Procedure

### 1. Measure, and verify claims before restating them

`wc -c -l` the target. Then check every factual assertion you plan to carry
forward or cite as stale — line counts, repo names, file paths, issue numbers.

**Do not trust a prior session's findings, including your own handoff notes.**
In the pass this skill came from, two of three reported "stale" findings were
wrong: a repo rename flagged as self-contradicting was accurate (`git remote -v`
confirmed it), and only one of four drifted line counts had actually drifted.
Correcting a number is cheap; deleting a correct rule because a note said it was
stale is not.

### 2. Find the real structure

Byte-count the sections before deciding where to cut:

```sh
awk '/^#{2,3} /{if(h)printf "%6d  %s\n",c,h; h=$0; c=0} {c+=length($0)+1} END{printf "%6d  %s\n",c,h}' FILE | sort -rn
```

The largest sections are frequently the *most* directive-dense — operational
rules about migrations, deploys, and secrets. Those are the ones whose failure
mode is an outage. Descriptive architecture prose is usually the cheaper cut,
because an agent re-derives it by opening the file; it does not re-derive
"don't promote this module into a shared package."

### 3. Write the proposal to a new file

`CLAUDE.distilled.md` alongside the original. **Leave the original untouched**
so the human can `git diff` and veto.

### 4. Actually write the demoted text into its target doc

If a passage is demoted to a plan doc, append it there in the same pass, as real
prose under a real heading. Do not write a pointer to content that does not
exist — a dangling pointer is worse than the paragraph you removed, because it
reads as though the knowledge was preserved.

Be honest that demotion has a cost even when done right: the destination is a
document no agent reads at session start. Knowledge moved there is formally
preserved and operationally gone. That is the correct trade for pure history and
the wrong one for a rule whose failure mode is an outage.

Then verify it landed:

```sh
rg -c 'DISTINCTIVE_STRING' TARGET_DOC.md
```

### 5. Prove no directive was lost

Two checks, both cheap:

```sh
# every distinctive token that must survive — build this list from the
# original: config flags, function names, secret names, allowlist markers
for s in "TOKEN_A" "TOKEN_B" "TOKEN_C"; do
  rg -q -- "$s" FILE.distilled.md || echo "LOST: $s"
done

# directive density should not fall
rg -oi '\b(never|must|do not|don.t|always|deliberate)\b' FILE.md | wc -l
rg -oi '\b(never|must|do not|don.t|always|deliberate)\b' FILE.distilled.md | wc -l
```

Anything reported LOST must be either present in a plan doc or named in the
ledger. Density often *rises*, because compression forces implicit rules to
become explicit.

### 6. Deliver the ledger

For every removed passage, state where it went — which doc, which section — or
that it was dropped as redundant/stale and why. **Nothing is silently dropped.**
A table is fine.

## Report the honest number

State the before/after size and the tradeoff. **Do not delete directives to hit
a target.**

The pass this skill came from was estimated at 34 KB → 13–15 KB. The honest floor
turned out to be ~30 KB, because the premise was wrong: the file held no
multi-paragraph narratives, only directives with a clause of rationale embedded
in each. Reporting 11% with every rule intact is the correct outcome. Reporting
55% by deleting one outage-preventing rule would not have been.

Say plainly what the cut costs. A pointer is only followed if the agent follows
it, and some narratives are load-bearing precisely because their failure mode is
a hard outage rather than a degradation. When a rule is in that class, keeping it
at full length in the memory file **and** writing the post-mortem to a plan doc is
a legitimate choice — deliberate duplication, not an oversight.

## Keep AGENTS.md a symlink

Never maintain two copies. Verify, and fix if it drifted into a real file:

```sh
ls -la AGENTS.md                        # expect: AGENTS.md -> CLAUDE.md
ln -sf CLAUDE.md AGENTS.md              # only after confirming no unique content
```

Before replacing a real `AGENTS.md`, diff it against `CLAUDE.md` — if it has
content of its own, that content must be merged first, not overwritten.

## MEMORY.md is a different job

`MEMORY.md` is **not** the same target as `CLAUDE.md`. Claude Code already caps
the index at 25 KB / 200 lines, errors on a write that would exceed the read
limit rather than truncating silently, and reminds the agent to compact near the
limit. **Size is handled; do not build size tooling for it.**

What it needs is a *quality* pass — the genuinely Dreams-shaped part:

- Merge entries saying the same thing in different words.
- Replace contradicted entries with the latest value; a superseded fact is worse
  than a missing one.
- Surface patterns that recur across sessions but were never written down.
- Drop one-off debugging notes with no future value.

This pass is lighter than the `CLAUDE.md` one and still writes a proposal, never
an in-place edit.

## Boundary between the two stores

Do not let them overlap — overlap is what produces contradictory memory with no
authority between the copies.

| | `CLAUDE.md` / `AGENTS.md` | `MEMORY.md` |
|---|---|---|
| Scope | What must be true in this repo | What I learned working here |
| Audience | The team, and every future agent session | You |
| Lifecycle | Committed, PR-reviewed | Local, gitignored, never committed |
| Distill trigger | Size and drift | Contradiction and duplication |

If a fact belongs to the repo's contract, it goes in `CLAUDE.md` through a PR —
not into auto-memory.
