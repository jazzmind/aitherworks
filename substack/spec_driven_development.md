# Spec-Driven Development: Building AItherworks with Constitutional Governance

Week 4 of building AItherworks, and I've hit an inflection point. What started as "I'll just start coding" evolved into a **spec-driven development system** with constitutional governance. This post chronicles why, how, and what it means for an open-source game teaching AI concepts.

## The Problem: Scope Creep Meets AI Assistance

When you're building with AI coding assistants (I use Cursor with Claude), you can move *fast*. Too fast. I'd ask Claude to "add a new machine part," and minutes later I'd have GDScript files, scene definitions, and YAML specs. But three problems emerged:

1. **Consistency drift**: New parts didn't follow the same patterns as older ones.
2. **Lost decisions**: Why did I structure the plugin this way? What constraints matter?
3. **Educational debt**: I'm building a game to teach AI—but I wasn't documenting my own process.

The irony: A game about systematic thinking was being built unsystematically.

## The Solution: Constitutional Principles + Spec Templates

I created a **constitution** ([see `.specify/memory/constitution.md` on GitHub](https://github.com/wessonnenreich/aitherworks)) defining six core principles:

### I. Data-Driven Design
All puzzle levels and machine parts live as YAML files under `data/specs/` and `data/parts/`. Game logic stays in GDScript, but design constants belong in data. Why? Because the endgame is a **visual AI design environment**—players need to export their contraptions as specs.

**Example**: Here's a simplified part definition for the Signal Loom:
```yaml
part_id: signal_loom
display_name: Signal Loom
category: input
description: "Weaves input patterns into aetheric vectors."
ports:
  out_north: vector_stream
cost_brass: 50
cost_steam: 10
```

### II-V. Godot 4 Native, Plugin Integrity, Scene-Based Architecture, Narrative Integration
(See the [full constitution](link) for details—each principle has rationale and non-negotiable requirements.)

### VI. Public Documentation & Process Chronicle
This one's new: **Major design decisions MUST be documented publicly** via this Substack. It's not marketing—it's part of the educational mission. AItherworks teaches AI *and* demonstrates AI-assisted development.

## How It Works: The Spec → Plan → Tasks Flow

When I want to add a feature (e.g., "quantization puzzle mechanics"), I now follow a three-command workflow:

### 1. `/spec` Command
Write a **functional specification** (no tech details, just *what* users need and *why*). Example:
> "Players MUST be able to compress trained models to 4-bit precision while maintaining >95% accuracy. This teaches post-training quantization and calibration techniques."

The spec marks ambiguities as `[NEEDS CLARIFICATION]` and defines acceptance scenarios ("Given a trained model, when compressed to 4-bit, then accuracy degrades by <5%").

### 2. `/plan` Command
Generates an **implementation plan** with:
- **Constitution Check**: Does this violate any principle? (E.g., am I hardcoding puzzle parameters instead of using YAML?)
- **Technical Context**: What dependencies, constraints, and scale?
- **Research Phase**: What unknowns need investigation?
- **Design Phase**: What entities, contracts, and data models?

The plan stops before writing code. It's a thinking tool.

### 3. `/tasks` Command
Breaks the plan into **numbered, executable tasks** following TDD order:
```
T004 [P] Contract test POST /api/users in tests/contract/test_users_post.py
T005 [P] Contract test GET /api/users/{id} in tests/contract/test_users_get.py
T008 [P] User model in src/models/user.py
```

(The `[P]` marks tasks that can run in parallel—different files, no dependencies.)

## Why This Matters for AI Game Dev

This isn't bureaucracy—it's **guardrails for AI velocity**. Without specs, Claude and I were coding in circles. With them:

- **Claude stays on-rails**: "Follow the plan in `specs/021-quantization-puzzle/plan.md`" is way better than "add quantization mechanics."
- **Decisions persist**: Six months from now, I (or a contributor) can read *why* the plugin works this way.
- **Quality gates**: The constitution check catches violations (e.g., "You're hardcoding brass costs—move them to YAML").

## The Meta-Lesson: Teaching What You Practice

AItherworks teaches players to build AI systems with **constraints** (steam pressure = compute budget, brass cost = parameter count). The spec-driven workflow is the same discipline: work within constitutional constraints, justify deviations, document choices.

It's recursive: The game teaches systematic thinking by being built systematically.

## What's Next?

- **This week**: Implementing the Cog-Ratchet Press (quantization part) following the spec → plan → tasks flow.
- **Next post**: How I'm using Godot's scene inheritance to make reusable parts without boilerplate.

If you're building with AI assistants and feeling the chaos, try this: Write a constitution. Make your AI follow it. You'll slow down upfront—but ship 10x faster long-term.

---

**What's your experience with AI-assisted development? Do you have guardrails, or are you coding YOLO? Let me know in the comments!**

*Subscribe (it's free!) to follow the full AItherworks journey. Next Tuesday: Godot scene architecture and steampunk part design.*

---

## Technical Appendix (for the curious)

**File structure**:
```
.specify/
├── memory/
│   └── constitution.md       # Six principles + governance rules
├── templates/
│   ├── spec-template.md      # Functional requirements format
│   ├── plan-template.md      # Implementation plan format
│   └── tasks-template.md     # Task breakdown format
└── scripts/
    └── bash/
        └── update-agent-context.sh  # Syncs changes to CLAUDE.md
```

**Constitution version**: 1.1.0 (ratified 2025-10-03)
**Latest amendment**: Added Principle VI (Public Documentation) to mandate this chronicle.

Full constitution: [GitHub link]  
Current spec-in-progress: [Link to quantization puzzle spec if available]

---

*Draft Status: Ready for technical review. Check YAML examples for validity. Add GitHub links before publish.*


