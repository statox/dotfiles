---
name: repo-onboarding
description: Explore an unfamiliar git repository and produce a REPO_OVERVIEW.md that gets someone productive fast - stack and tooling, high-level architecture, feature inventory, setup/install steps, test tooling and coverage, code patterns, per-area deep dives, and a quality/improvement assessment. Use this whenever the user opens a new repo and asks to "get familiar with", "explore", "onboard me to", "give me an overview of", "understand the codebase/architecture of", or asks "what does this repo do" / "how is this structured" / "where do I start reading this code". Also trigger it proactively when a user who just cloned or cd'd into an unfamiliar project asks broad orientation questions, even if they don't name the skill directly.
---

# Repo Onboarding

Produce a REPO_OVERVIEW.md that lets someone go from "never seen this code" to
"knows where things live and can start contributing" in one read. The goal is
breadth with real signal, not a shallow README rewrite and not a line-by-line
audit. Every claim in the report should be traceable to something you actually
read - code, config, or existing docs - not inferred from the repo name or
common conventions.

## Before you start

Confirm scope with the user only if it's ambiguous (e.g. a monorepo where they
might only care about one package). Otherwise proceed - this skill is meant to
run with minimal back-and-forth. Tell the user you're about to explore and
roughly how long it'll take (bigger repos = more subagents = a bit longer).

## Phase 0: Orient

Before diving into code, gather cheap signal that shapes everything else:

- `git log --oneline -20`, `git shorthand for age/activity` (first commit date,
  commit frequency, contributor count) - tells you if this is a mature,
  actively-maintained project or an early/abandoned one.
- Root-level manifests: `package.json`, `pyproject.toml`/`setup.py`,
  `go.mod`, `Cargo.toml`, `pom.xml`/`build.gradle`, `Gemfile`, `composer.json`,
  `*.csproj`/`*.sln`, `mix.exs`, etc. These usually name the language,
  package manager, and top-level dependencies in one file.
- Root-level docs: `README`, `CONTRIBUTING`, `ARCHITECTURE.md`, `docs/adr/*`,
  `.github/`. Read them - they're a head start, not ground truth. Note
  anything that looks stale (references to files/dirs that no longer exist,
  outdated commands) so you can flag it later rather than repeat it as fact.
- Top-level directory listing (`ls`, or `git ls-tree` for a repo-tracked view)
  to get the shape of the tree before deciding how to split up deeper work.

This phase is inline, not delegated - it's fast and it's what tells you how to
split Phase 2 across subagents.

## Phase 1: Stack & tooling

From Phase 0 plus a quick look at lockfiles and CI config
(`.github/workflows/`, `.gitlab-ci.yml`, `Makefile`, `Justfile`,
`Dockerfile`), determine:

- Primary language(s) and version constraints.
- Package manager and dependency list (just the notable/direct ones - don't
  transcribe a whole lockfile).
- Build tooling, linters, formatters, type checkers.
- CI: what runs on push/PR, and whether it matches what you find in Phase 5's
  test/setup investigation (a mismatch is worth flagging).
- Runtime/deploy target if evident (containerized? serverless? a library
  published to a registry?).

## Phase 2: High-level architecture map

Map how the code is organized before zooming into any one part. For each
top-level directory (and one level deeper where a directory is just a
container, e.g. `src/`), determine in one or two sentences what it's for and
how it relates to the others. Identify entry points (main files, servers,
CLI bin, exported public API) and trace, at a glance, how a request/command
flows through the major layers.

This map is what lets you split Phase 3 sensibly - the "big areas" you deep
dive into in Phase 3 are usually the directories you name here.

## Phase 3: Parallel deep dive by area

Once you have the map, dispatch one subagent per major area to go deeper in
parallel - this is what keeps a large-repo exploration fast and keeps your
own context clean (you don't want the full contents of every module sitting
in your context, just each subagent's summary of it).

Use the `Explore` or `general-purpose` agent type, one call per area, all in
the same message so they run in parallel. Each area's prompt should be
self-contained (a fresh agent has no memory of Phase 0-2), so include:

- The repo root path and the specific directory/directories this agent owns.
- One or two sentences of what you already believe this area does (from
  Phase 2), so the agent can confirm/correct rather than start blind.
- What to report back: the area's purpose, its own internal structure
  (submodules/key files), notable patterns or conventions used specifically
  here, its main dependencies/collaborators (what it calls into, what calls
  it), and anything that looks inconsistent, overly complex, or duplicated
  relative to the rest of the codebase.
- Ask it to also assess the four dimensions that go into the area's summary
  table (see Synthesize the report): size/complexity, quality, how actively
  developed it is, and concerns/notable elements. For activity, have it run
  `git log --oneline -20 -- <path>` and/or `git log -1 --format=%cr -- <path>`
  on its own directory rather than guessing from code alone.
- A length cap ("under 300 words") so summaries stay synthesizable.

Don't split too finely - 4-8 areas is typical even for a large repo. A small
repo may not need any subagents at all; just read it yourself and skip to
Phase 4.

## Phase 4: Feature inventory

Separately from architecture (which is about code structure), enumerate what
the software actually does from a user/API-consumer point of view - the
capabilities someone would list if describing the product, not the classes
that implement it. Keep each feature to a line or two. Exhaustive but high
level: better to list 20 features in a sentence each than deep-dive 3.
Sources: routes/endpoints, CLI commands, exported public API, UI screens/
routes, background jobs/schedulers.

## Phase 5: Setup & dependencies

Determine what someone needs installed and configured to get this running
locally: language/runtime version, package manager, required services
(database, cache, queues - check `docker-compose.yml` for these), environment
variables (check `.env.example` or equivalent, and note ones referenced in
code but never documented), and the actual install/run commands. Verify
commands against what's actually defined in `package.json` scripts,
`Makefile` targets, etc. rather than guessing conventional ones - a `make
setup` you invented because it's common is worse than not mentioning it.

## Phase 6: Tests

Identify the test framework(s), where tests live relative to the code they
cover, and the exact command(s) to run them locally (unit vs integration vs
e2e if they're distinct). For coverage, don't just report a percentage if a
coverage tool spits one out - look at whether the areas you explored in
Phase 3 actually have tests alongside them, and call out any big area that
appears untested. If there's a coverage config/threshold enforced in CI,
mention it.

## Phase 7: Patterns

Note recurring conventions worth knowing before writing new code here:
architectural patterns (layered, hexagonal, MVC, event-driven...), error
handling approach, how state/config is threaded through, naming conventions,
how the codebase tends to structure new features (e.g. "each feature gets a
folder with a controller, service, and test file"). Pull these from what the
Phase 3 subagents actually observed repeating across areas, not from
first-principles guessing about what a codebase like this "should" do.

## Phase 8: Quality & improvement areas

This is an assessment of shape, not a bug hunt - don't go looking for hidden
defects or do a security review. Comment on: simplicity/readability, whether
separation of concerns is clean or areas are tangled, whether similar
problems are solved consistently across the codebase or reinvented per-area
(a strong signal from Phase 3's cross-area comparison), how well
architecture/module boundaries match what the code actually does, and
anything about setup/test/docs from earlier phases that would trip up a
newcomer. Where you flag a problem, say briefly why it matters and, if
obvious, what direction a fix would take - but don't spec out the fix in
detail, that's a separate task.

## Synthesize the report

Write `REPO_OVERVIEW.md` at the repo root using this structure:

```markdown
# <Repo Name> Overview

## Stack & Tooling
## Architecture
(include a directory-by-directory map; a simple indented tree or table is fine)
## Features
## Setup
## Tests
## Patterns
## Area Deep Dives
(one subsection per Phase 3 area)
## Quality & Improvement Areas
```

Each Area Deep Dive subsection opens with a summary table, before the prose,
using the same four rows for every area so they're comparable at a glance:

```markdown
### <Area name>

| | |
|---|---|
| Size / complexity | ... |
| Quality | ... |
| Activity | ... |
| Concerns | ... |

<prose: purpose, structure, patterns, dependencies>
```

- **Size / complexity**: rough scale (small/medium/large, or a file/LOC count
  if it's cheap to get) plus a word on how complex it is to work in, not just
  how big.
- **Quality**: a short call, not a paragraph - e.g. "clean, consistent" or
  "works but tangled" - consistent with what you write in Quality &
  Improvement Areas so the two don't contradict each other.
- **Activity**: based on the git history the Phase 3 subagent pulled for that
  path - e.g. "actively developed, 12 commits in the last month" or
  "stable, untouched for 8 months." Say what you observed, not what you
  assume from the code alone.
- **Concerns**: the one or two things worth flagging about this area
  specifically - inconsistency, missing tests, high complexity, tight
  coupling. If there's nothing notable, say "none" rather than omitting the
  row or padding it.

Keep prose tight - this document is meant to be read start to finish in one
sitting, with the deep-dive sections as the part someone skims back to later
when they're about to touch that specific area.

Writing style:

- Short sentences. One idea per sentence.
- Simple grammar. Avoid parentheticals and sidetracking clauses - if a detail
  needs a parenthesis, it's usually either important enough for its own
  sentence or not important enough to include.
- Use bullet points for lists of facts (dependencies, commands, conventions)
  instead of folding them into a paragraph.
- Write in plain declarative statements. Say "The API layer calls the service
  layer, which calls the repository layer" not "the API layer, which is
  responsible for handling incoming requests, in turn calls into the service
  layer before eventually reaching the repository layer."
- Anchor claims to concrete locations: file paths, function/class names, or
  config keys. Say "auth is handled in `src/middleware/auth.ts`" not "there's
  an authentication layer." A claim without a path or name is a claim the
  reader can't go verify or find later.
- Write present tense, third person, throughout. No "we" or "I". This applies
  even when transcribing a Phase 3 subagent's summary - normalize its voice
  to match the rest of the document rather than pasting it in as-is.
- Target a document a newcomer can skim top-to-bottom in 10-15 minutes.
  Treat that as a budget: if a section is growing past what that allows,
  cut detail rather than let the doc run long. Area Deep Dives are the
  exception - they're reference material someone comes back to per-area,
  not part of the first read.
- Before writing, scan for findings that show up in more than one phase -
  Phase 3 area summaries and Phase 7 patterns commonly surface the same
  observation from different angles (e.g. inconsistent error handling
  noticed in two areas). Consolidate these into a single mention in the
  most relevant section - Patterns for cross-cutting observations, the
  specific Area Deep Dive for something local to one area - and cross-
  reference from the other spot instead of restating it.
- Mark low-confidence claims instead of stating them flatly. If something
  comes from a doc you couldn't verify against code (per Phase 0's staleness
  check), say so: "README describes a `/health` endpoint; not confirmed in
  code." Don't present unverified and verified claims with the same
  certainty.

Diagrams:

- Use a small ASCII diagram or a mermaid diagram only when a relationship or
  a data flow is genuinely hard to describe in one or two sentences of text.
  A three-line component chain like `CLI -> Service -> DB` is often clearer
  as text than as a diagram - don't add a diagram just to have one.
- Good candidates: request/data flow across several layers, a directory
  structure that doesn't map cleanly to prose, a non-obvious dependency
  graph between areas found in Phase 3.
- Keep diagrams small. A diagram that needs its own explanation defeats the
  purpose - it should be scannable in a few seconds.
- ASCII is fine for simple linear or tree shapes. Reach for mermaid only when
  the shape is genuinely graph-like (branches, cycles, multiple inbound/
  outbound edges).

After writing it, tell the user where it is and give a two- or three-sentence
spoken summary of the biggest things they should know before diving in (not
a repeat of the whole document).
