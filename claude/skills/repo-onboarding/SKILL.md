---
name: repo-onboarding
description: Explore an unfamiliar git repository and produce a REPO_OVERVIEW.md that gets someone productive fast - stack and tooling, high-level architecture, data model, feature inventory, setup/install steps, test tooling and coverage, code patterns, per-area deep dives, documentation map, ongoing work, tech debt, change-frequency hotspots, and a quality/improvement assessment. Use this whenever the user opens a new repo and asks to "get familiar with", "explore", "onboard me to", "give me an overview of", "understand the codebase/architecture of", or asks "what does this repo do" / "how is this structured" / "where do I start reading this code". Also trigger it proactively when a user who just cloned or cd'd into an unfamiliar project asks broad orientation questions, even if they don't name the skill directly.
---

# Repo Onboarding

Produce a REPO_OVERVIEW.md that lets someone go from "never seen this code" to
"knows where things live and can start contributing" in one read. The goal is
breadth with real signal, not a shallow README rewrite and not a line-by-line
audit. Every claim in the report should be traceable to something you actually
read - code, config, or existing docs - not inferred from the repo name or
common conventions.

## Preliminary checks

Confirm scope with the user only if it's ambiguous (e.g. a monorepo where they
might only care about one package). Otherwise proceed - this skill is meant to
run with minimal back-and-forth. Tell the user you're about to explore and
roughly how long it'll take (bigger repos = more subagents = a bit longer).

## Preparing data gathering (Phase 0)

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

## Data Gathering

The phases below collect the raw material for the report, one phase per
template section (noted after each title as `Group > Section`). Run them
roughly in order - later phases lean on earlier ones (Phase 3 needs Phase 2's
map, Phase 4 needs Phase 2 and Phase 3, Phase 11 needs Phase 4's and Phase 9's
findings, Phase 12 leans on Phase 0's git history and Phase 4's duplication
findings).

### Phase 1: Stack & tooling (Tooling > Stack & Tooling)

From Phase 0 plus a quick look at lockfiles and CI config
(`.github/workflows/`, `.gitlab-ci.yml`, `Makefile`, `Justfile`,
`Dockerfile`), determine:

- Primary language(s) and version constraints.
- Package manager and dependency list (just the notable/direct ones - don't
  transcribe a whole lockfile).
- Build tooling, linters, formatters, type checkers.
- CI: what runs on push/PR, and whether it matches what you find in Phase 6's
  setup investigation or Phase 7's test investigation (a mismatch is worth
  flagging).
- Runtime/deploy target if evident (containerized? serverless? a library
  published to a registry?).

### Phase 2: High-level architecture map (Code > Architecture)

Map how the code is organized before zooming into any one part. For each
top-level directory (and one level deeper where a directory is just a
container, e.g. `src/`), determine in one or two sentences what it's for and
how it relates to the others. Identify entry points (main files, servers,
CLI bin, exported public API) and trace, at a glance, how a request/command
flows through the major layers.

Don't describe compilation or build steps here beyond noting that they exist
if it affects how the map reads (e.g. a monorepo with a generated `dist/`).
The detail belongs in Phase 8: Build process, and the report's Architecture
section should point there instead of repeating it.

This map is what lets you split Phase 4 sensibly - the "big areas" you deep
dive into in Phase 4 are usually the directories you name here.

While you're mapping entry points, also settle **Environment integration**:
how the repo is meant to be consumed.

- If it's a library: check for a package registry entry (`package.json`
  `main`/`exports`, `pyproject.toml` build-system metadata, README install
  badges) and note who imports it, if that's discoverable.
- If it's a backend: identify the API shape (REST/GraphQL/RPC) and look for
  hints of what calls it - a paired frontend directory, API docs, CORS config
  naming allowed origins.
- If it's a frontend: find the backend API base URL it targets (env vars,
  config files, a proxy setup) and where it's deployed (static host config,
  `vercel.json`, `netlify.toml`, a Dockerfile).

Don't force an answer if the repo doesn't cleanly fit one category - some
repos are genuinely a library with no discoverable consumer; say so rather
than inventing one.

### Phase 3: Data model (Code > Data Model)

Determine what data the software stores and manipulates, separate from how
the code is organized (Phase 2):

- Find where persisted data is defined: an ORM models directory, a
  `schema.prisma`/`schema.sql`, a migrations folder, protobuf/GraphQL schema
  files, or a `docs/erd.*`.
- List the main entities/data types in a sentence each - what they represent,
  not their fields.
- Note where each lives: a specific database (name the engine if evident -
  Postgres, MongoDB, SQLite), flat files, an external service/API, or purely
  in-memory/transient state.
- If entities relate to each other in a way that isn't obvious from their
  names (e.g. a join table, an event log referencing multiple types), note
  the relationship in one line.

This phase is usually inline, not delegated - persisted data models tend to
live in one or two places rather than being spread across every area. If a
repo genuinely has no persisted data (a pure CLI tool, a stateless proxy),
say so in the report rather than forcing a section. If this phase turns up
signs that data ownership is decentralized (e.g. a microservices repo where
each service defines its own schema), flag that for Phase 4 - each area's
subagent should report its own local entities instead of one being asked to
cover all of them.

### Phase 4: Parallel deep dive by area (Code > Area Deep Dives)

Once you have the map, dispatch one subagent per major area to go deeper in
parallel - this is what keeps a large-repo exploration fast and keeps your
own context clean (you don't want the full contents of every module sitting
in your context, just each subagent's summary of it).

Use the `Explore` or `general-purpose` agent type, one call per area, all in
the same message so they run in parallel. Each area's prompt should be
self-contained (a fresh agent has no memory of Phase 0-3), so include:

- The repo root path and the specific directory/directories this agent owns.
- One or two sentences of what you already believe this area does (from
  Phase 2), so the agent can confirm/correct rather than start blind.
- What to report back: the area's purpose, its own internal structure
  (submodules/key files), notable patterns or conventions used specifically
  here, its main dependencies/collaborators (what it calls into, what calls
  it), and anything that looks inconsistent, overly complex, or duplicated
  relative to the rest of the codebase.
- Ask it to also assess the dimensions that go into the area's summary table
  (see Report synthesis): scope, size/complexity, quality, how actively
  developed it is, and concerns/notable elements. For activity, have it run
  `git log --oneline -20 -- <path>` and/or `git log -1 --format=%cr -- <path>`
  on its own directory rather than guessing from code alone. For scope, have
  it state what's inside the area versus what's deliberately handled
  elsewhere.
- If Phase 3 found data ownership is decentralized, ask it to also report the
  area's own entities and storage, the same way Phase 3 does globally - main
  types and where they're stored - so the Data Model section can describe
  this per area instead of presenting one misleading global picture.
- Ask it to flag whether its area's internal structure is non-obvious enough
  to be worth a small ascii diagram or file-tree sketch in the report -
  useful signal for whether that area's deep dive should include one.
- A length cap ("under 300 words") so summaries stay synthesizable.

Don't split too finely - 4-8 areas is typical even for a large repo. A small
repo may not need any subagents at all; just read it yourself and skip to
Phase 5.

### Phase 5: Feature inventory (Functional > Features)

Separately from architecture (which is about code structure), enumerate what
the software actually does from a user/API-consumer point of view - the
capabilities someone would list if describing the product, not the classes
that implement it. Keep each feature to a line or two. Exhaustive but high
level: better to list 20 features in a sentence each than deep-dive 3.
Sources: routes/endpoints, CLI commands, exported public API, UI screens/
routes, background jobs/schedulers.

### Phase 6: Setup & dependencies (Tooling > Setup)

Determine what someone needs installed and configured to get this running
locally: language/runtime version, package manager, required services
(database, cache, queues - check `docker-compose.yml` for these), environment
variables (check `.env.example` or equivalent, and note ones referenced in
code but never documented), and the actual install/run commands. Verify
commands against what's actually defined in `package.json` scripts,
`Makefile` targets, etc. rather than guessing conventional ones - a `make
setup` you invented because it's common is worse than not mentioning it.

This phase covers the local dev loop. Production build steps and artifacts
belong in Phase 8: Build process.

### Phase 7: Tests (Tooling > Tests)

Identify the test framework(s), where tests live relative to the code they
cover, and the exact command(s) to run them locally (unit vs integration vs
e2e if they're distinct). For coverage, don't just report a percentage if a
coverage tool spits one out - look at whether the areas you explored in
Phase 4 actually have tests alongside them, and call out any big area that
appears untested. If there's a coverage config/threshold enforced in CI,
mention it.

Note if a compile/codegen step has to run before tests will work, but leave
the detail of that step to Phase 8: Build process.

### Phase 8: Build process (Tooling > Build Process)

Determine how the code turns into something runnable, separate from getting a
local dev loop going (Phase 6) or running tests (Phase 7). Cover:

- **Build tooling**: the bundler, compiler, or transpiler in use (webpack,
  esbuild, tsc, a Makefile, etc.) and where its config lives.
- **Build for tests**: whether tests depend on a compile/transpile step,
  whether the repo provides a helper or script for it, and whether there's a
  watch mode for fast iteration.
- **Build for production**: what the build command actually produces
  (binary, Docker image, bundle, published package) and how that artifact
  gets used afterward (deployed, published, containerized). Keep detail on
  what's repo-specific; point to external docs (a Dockerfile, a release
  workflow) instead of re-explaining generic tooling.

The Architecture section of the report should not re-describe build steps -
it should point here instead.

### Phase 9: Patterns (Code > Patterns)

Note recurring conventions worth knowing before writing new code here:
architectural patterns (layered, hexagonal, MVC, event-driven...), error
handling approach, how state/config is threaded through, naming conventions,
how the codebase tends to structure new features (e.g. "each feature gets a
folder with a controller, service, and test file"). Pull these from what the
Phase 4 subagents actually observed repeating across areas, not from
first-principles guessing about what a codebase like this "should" do.

### Phase 10: Documentation map (Human Follow Up > Documentation map)

Enumerate the repo's own help and documentation resources:

- Human-facing docs at the root: `README`, `CONTRIBUTING`, `DEV.md`,
  `BUILD.md`, `INSTALL.md`, etc. - you've already read most of these in
  Phase 0; just note which exist.
- Agent-facing docs: `CLAUDE.md`, `AGENT.md`, or equivalent.
- A `docs/` directory or similar, and roughly what it covers in one line -
  not a full read-through, unless a claim elsewhere needs verifying against
  it.
- Links to external resources noticed along the way: an online docs site, a
  Notion/Confluence page, an internal wiki - mentioned in the README or
  elsewhere. Don't go hunting for these separately; just collect what
  surfaced naturally during earlier phases.

This is a cheap inline pass, not a subagent dispatch.

### Phase 11: Quality & improvement areas (Repo High Level Analysis > Quality & Improvement Areas)

This is an assessment of shape, not a bug hunt - don't go looking for hidden
defects or do a security review. Comment on: simplicity/readability, whether
separation of concerns is clean or areas are tangled, whether similar
problems are solved consistently across the codebase or reinvented per-area
(a strong signal from Phase 4's cross-area comparison), how well
architecture/module boundaries match what the code actually does, and
anything about setup/test/docs from earlier phases that would trip up a
newcomer. Where you flag a problem, say briefly why it matters and, if
obvious, what direction a fix would take - but don't spec out the fix in
detail, that's a separate task.

Alongside problems, also note what's notably stable, well-tested, or
well-designed. Pull this from the Quality and Activity dimensions the Phase 4
subagents already reported, rather than treating this phase as purely
fault-finding - a codebase can be both mostly solid and worth flagging a few
issues in.

Large-scale work in flight and already-known-but-unfixed pain points belong
in Phase 12 and Phase 13 respectively, not here - this phase is about the
codebase's current shape, not about what's changing, what's already been
flagged as broken, or where change/bug-fix activity clusters (Phase 14).

### Phase 12: Ongoing work (Repo High Level Analysis > Ongoing Work)

Look for signs of large changes currently underway, separate from Phase 11's
assessment of the code as it stands today:

- Grep for TODO/FIXME comments that reference a migration, a ticket number,
  or "remove after X" - these often point at in-flight efforts, as opposed to
  Phase 13's plain leftovers.
- Check recent commits (`git log --oneline -30`) and branch names
  (`git branch -a`) for messages describing a multi-step effort, not a
  one-off fix.
- Look for two implementations of the same concern coexisting (an old and
  new auth system, a v1 and v2 API) - a strong signal of a migration in
  progress. Phase 4's area deep dives are a good source for this if a
  subagent already flagged duplication.
- Check for feature flags or config gating code that looks unfinished.

If nothing points to ongoing large-scale work, say so rather than inventing
something - not every repo has a migration in flight.

### Phase 13: Tech debt (Repo High Level Analysis > Tech Debt)

Distinct from Phase 12 (active efforts) and Phase 11 (a shape assessment),
this phase collects concrete, already-identified pain points that haven't
been fixed:

- Grep for TODO/FIXME/HACK comments describing a known shortcut, not a
  migration in progress.
- Deprecated code paths, dead code, or disabled/skipped tests (`.skip`,
  `@Disabled`, commented-out test blocks) still present.
- Workarounds explained in code comments, commit messages, or docs, and why
  they exist.
- Known limitations documented in issues, ARCHITECTURE.md, or similar, that
  are still open.

Note whether each item is acknowledged (tracked in an issue, explained in a
comment) or just silently accumulated - that distinction matters more than
the raw count.

### Phase 14: Change frequency & hotspots (Repo High Level Analysis > Change Frequency & Hotspots)

Run three git commands to find recurring pain points, distinct from Phase 12
(active efforts) and Phase 13 (known-but-unfixed debt) - this phase is about
where the codebase itself shows friction over time:

- `git log --format=format: --name-only --since="1 year ago" | sort | uniq -c
  | sort -nr | head -20` - the most-changed files in the last year.
- `git shortlog -sn --no-merges` for overall contributor activity; repeat
  scoped to one path (`git shortlog -sn --no-merges -- <path>`) when you want
  to know who's driving changes in a specific hotspot rather than the repo
  as a whole.
- `git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort |
  uniq -c | sort -nr | head -20` - the files most often touched by
  bug-fix-flavored commits.

Cross-reference the three: map the top-changed files to the Phase 4 area
they belong to, note which contributor(s) are active there, and check
whether the same files also appear in the bug-fix list. A file or area
appearing in both the change-frequency and bug-fix lists is a stronger
signal than either alone - that's what's worth flagging as a recurring pain
point, not raw change counts by themselves.

This phase is inline - it's a handful of git commands, not something to
delegate. If the repo's history is too thin for the `1 year ago` window to
mean anything (a young repo, a recent history rewrite), say so rather than
force a reading from sparse data.

## Report synthesis

Write `REPO_OVERVIEW.md` at the repo root. This section covers the general
principles behind the writing (General guidelines), how to phrase things
(Writing style), and what the document itself looks like (Document
structure).

### General guidelines

- Anchor claims to concrete locations: file paths, function/class names, or
  config keys. Say "auth is handled in `src/middleware/auth.ts`" not "there's
  an authentication layer." A claim without a path or name is a claim the
  reader can't go verify or find later.
- Target a document a newcomer can skim top-to-bottom in 10-15 minutes.
  Treat that as a budget: if a section is growing past what that allows, cut
  detail rather than let the doc run long. Area Deep Dives are the exception
  - they're reference material someone comes back to per-area, not part of
  the first read.
- Before writing, scan for findings that show up in more than one phase -
  Phase 4 area summaries and Phase 9 patterns commonly surface the same
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

### Writing style

- Short sentences. One idea per sentence.
- Simple grammar. Avoid parentheticals and sidetracking clauses - if a detail
  needs a parenthesis, it's usually either important enough for its own line
  or not important enough to include.
- Prefer nested bullets over parenthetical-dense paragraphs. When an item
  needs several qualifiers - reasons, exceptions, sub-items - break them into
  a short lead line plus nested bullets instead of stacking clauses and
  parentheses into one sentence:

  BAD: `emersion/go-smtp (pinned to v0.17.0 due to a breaking change, see go.mod line 26)`

  GOOD:
  ```
  - emersion/go-smtp
      - pinned to v0.17.0 due to a breaking change ([go.mod](go.mod) line 26)
  ```
- Write in plain declarative statements. Say "The API layer calls the service
  layer, which calls the repository layer" not "the API layer, which is
  responsible for handling incoming requests, in turn calls into the service
  layer before eventually reaching the repository layer."
- Write present tense, third person, throughout. No "we" or "I". This applies
  even when transcribing a Phase 4 subagent's summary - normalize its voice
  to match the rest of the document rather than pasting it in as-is.

Diagrams:

- Use a small ASCII diagram or a mermaid diagram only when a relationship or
  a data flow is genuinely hard to describe in one or two sentences of text.
  A three-line component chain like `CLI -> Service -> DB` is often clearer
  as text than as a diagram - don't add a diagram just to have one.
- Good candidates: request/data flow across several layers, a directory
  structure that doesn't map cleanly to prose, a non-obvious dependency
  graph between areas found in Phase 4.
- Keep diagrams small. A diagram that needs its own explanation defeats the
  purpose - it should be scannable in a few seconds.
- ASCII is fine for simple linear or tree shapes. Reach for mermaid only when
  the shape is genuinely graph-like (branches, cycles, multiple inbound/
  outbound edges).

### Document structure

Check @./REPO_OVERVIEW_template.md
The template contains the structure of the report to create with indications
that you must follow for each section


## Proofreading

Before calling the report done, do one pass over the full draft to check
consistency and formatting - not to re-derive content.

Check:

- **File paths as links.** Anywhere the report mentions a file by name or
  path, it should be a markdown link into the repo, not bare text:
  `main.ts` -> `` [`main.ts`](./main.ts) ``, `src/main.ts` -> `` [`src/main.ts`](src/main.ts) ``.
  Sweep the document for filenames and paths in prose and bullets and wrap
  them.
- **Internal consistency.** Look for contradictions between sections - e.g.
  an area's Quality row says "clean" while Quality & Improvement Areas flags
  it as tangled, or Patterns describes a convention an Area Deep Dive says
  isn't followed there. Reconcile the claims, or explain the discrepancy,
  rather than leaving both standing.
- **Style compliance.** Spot-check against the Writing style rules above -
  tense/voice consistency, parenthetical-heavy sentences that should be
  nested bullets, diagrams that don't earn their place.

After the proofreading pass, tell the user where the report is and give a
two- or three-sentence spoken summary of the biggest things they should know
before diving in (not a repeat of the whole document).
