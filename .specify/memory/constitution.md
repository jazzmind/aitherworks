<!--
Sync Impact Report - Constitution Update
=========================================
Version Change: 1.0.0 → 1.1.0
Rationale: MINOR version bump - Added Principle VI (Public Documentation & Process Chronicle)

Principles Modified:
- Added VI. Public Documentation & Process Chronicle - New principle for Substack chronicle and open development

Added Sections:
- Documentation as Content section under Quality Standards
- Substack guidelines under Development Workflow

Templates Status:
✅ plan-template.md - Constitution Check section updated with new principle (line 48)
✅ spec-template.md - No updates needed (functional spec focused)
✅ tasks-template.md - No updates needed (task execution focused)
✅ agent-file-template.md - Compatible with constitution principles

Follow-up Items:
- Consider creating substack/templates/ for post templates based on plan.md structure
- Potential TODO item: Create workflow for generating Substack posts from milestone commits

Files Requiring Manual Review:
- substack/plan.md - Existing strategy aligns with new principle
- docs/about.md - Already exemplifies public-facing documentation quality
- docs/todo.md - Should be referenced when creating "Dev Update" posts

Previous Sync Report (v1.0.0):
Version Change: INITIAL → 1.0.0
Rationale: Initial constitution creation for AItherworks project
Principles Established: I-V (Data-Driven Design, Godot 4 Native, Plugin Integrity, Scene-Based Architecture, Narrative Integration)
-->

# AItherworks Constitution

## Core Principles

### I. Data-Driven Design
All level design, puzzle specifications, and machine part definitions MUST be expressed as YAML or JSON data files under `data/specs/` and `data/parts/`. The Steamfitter editor plugin generates Godot scenes from these specifications at design time. Runtime game logic resides in GDScript, but design constants and configuration belong in data files, not hardcoded in scripts.

**Rationale**: Separating content from code enables AI-assisted level generation, simplifies iteration on puzzle design, and maintains a clean boundary between game mechanics (code) and game content (data). This architecture is foundational to the project's vision.

### II. Godot 4 Native
All code MUST target the Godot 4.x API and follow idiomatic Godot patterns: signal-based event handling, node hierarchies, scene inheritance, `_ready()` and `_process()` lifecycle methods. GDScript is the primary language for game logic due to its dynamic typing, tight Godot integration, and ease of authoring.

**Rationale**: Godot 4 provides the cross-platform foundation and scene-based architecture that fits the project's modular part system. Deviating from Godot idioms creates friction in development and breaks assumptions throughout the codebase.

**Non-Negotiable**: Platform-specific code is forbidden except where Godot explicitly requires it (e.g., `OS.has_feature()` checks for web/mobile differences). All contributions must be cross-platform by default.

### III. Plugin Integrity
The Steamfitter editor plugin (`addons/steamfitter/`) is responsible for ingesting YAML specifications and generating game scenes. Changes to the plugin MUST preserve backward compatibility with existing spec files. New features should be exposed through clearly named public API functions, and any schema changes MUST be accompanied by updated examples (`example_puzzle.yaml`, `example_part.yaml`) that remain valid.

**Rationale**: The plugin is the bridge between data-driven design and the game runtime. Breaking the plugin or introducing schema incompatibilities disrupts the entire content pipeline and invalidates existing levels.

**Non-Negotiable**: Generated scenes and temporary files MUST NOT be committed to version control unless deliberately curated. The plugin generates content into Godot's cache or a separate build folder.

### IV. Scene-Based Architecture
Every reusable machine part MUST be a self-contained Godot scene (`.tscn`) with an accompanying GDScript file (`.gd`) under `game/parts/`. Each part encapsulates both visual representation and simulation behavior. Parts expose inputs/outputs through clearly defined "ports" that connect in the simulation layer.

**Rationale**: Godot's scene system provides natural modularity and reusability. Self-contained parts can be composed into complex machines without tight coupling. This mirrors the in-game mechanic of assembling parts on a workbench.

**Requirements**:
- Scenes MUST use lowercase names with underscores (e.g., `weight_wheel.tscn`)
- Scripts MUST match scene base names (e.g., `weight_wheel.gd`)
- Parts MUST document their port configuration and simulation interface

### V. Narrative Integration
All game content—tutorials, part descriptions, level narratives—MUST maintain thematic consistency with the steampunk Aetherford universe. Technical AI concepts (transformers, embeddings, attention mechanisms) MUST be translated into steampunk metaphors (gears, aether, pneumatic systems) without sacrificing conceptual accuracy.

**Rationale**: The game's educational value depends on making abstract AI concepts tangible through a cohesive fictional framework. Breaking thematic immersion undermines player engagement and learning effectiveness.

**Requirements**:
- Use the established lexicon (see `docs/lexicon.md`) for technical terms
- AI-generated narrative content MUST be reviewed for thematic fit
- Avoid modern technical jargon in player-facing text

### VI. Public Documentation & Process Chronicle
The development process MUST be documented publicly via Substack posts chronicling design decisions, technical implementations, and learning experiences. Major milestones, architectural choices, and AI-assisted development techniques SHOULD be captured as educational content that serves both as project history and teaching material for the community.

**Rationale**: AItherworks is simultaneously a game about teaching AI and a demonstration of AI-assisted game development. Documenting the journey publicly creates accountability, builds community engagement, and provides meta-educational value—showing how modern AI tools can accelerate creative work. This transparency aligns with the project's open-source mission and educational goals.

**Non-Negotiable**: The project is developed in public. Design decisions of substance (new principles, major features, architectural changes) MUST be documented in `substack/` for eventual publication. This is not optional marketing—it is part of the project's educational mission.

**Requirements**:
- Maintain weekly publishing cadence (target: Tuesdays per `substack/plan.md`)
- Post types MUST alternate: dev updates (70%), AI explainers (20%), narrative/story (10%)
- Technical posts MUST balance accessibility (for AI/game dev audience) with depth (showing real implementation)
- Substack posts SHOULD reference concrete artifacts: YAML specs, GDScript snippets, design docs
- Major features (e.g., "spec-driven development") MUST have corresponding Substack posts explaining rationale and implementation
- Keep posts 800-1500 words with visuals (screenshots, diagrams, code snippets)
- End every post with engagement hooks (questions, calls to action)

**Content Sources**:
- `docs/todo.md` → Dev Update posts (weekly progress)
- `data/specs/` and `data/parts/` → Technical deep-dives on data-driven design
- `.specify/` directory and templates → Posts on spec-driven development methodology
- `docs/act-*.md` → Narrative/story posts linking game design to AI pedagogy
- Constitution amendments → Process posts on governance and decision-making

## Quality Standards

### Testing and Validation
- **Spec Validation**: All YAML specs MUST validate against the documented schema before being committed. Use schema checkers or the plugin's validation features.
- **Scene Integrity**: Generated scenes MUST load without errors in Godot editor. Test scene loading before committing spec changes.
- **Manual Testing**: New parts and puzzles MUST be manually playtested to ensure they demonstrate the intended AI concept correctly.

### Performance
- **Editor Performance**: Plugin operations (spec parsing, scene generation) MUST complete in under 5 seconds for typical level specs.
- **Runtime Performance**: Game MUST maintain 60 FPS on target hardware (desktop: mid-range laptop, web: modern browsers).
- **Asset Size**: Individual scene files SHOULD be under 100 KB; total project size MUST remain under 500 MB to support web deployment.

### Documentation
- **Spec Examples**: `data/specs/example_puzzle.yaml` and `data/parts/example_part.yaml` MUST remain valid and up-to-date with current schema.
- **Code Comments**: Plugin code MUST include clear comments explaining non-obvious logic, especially schema parsing and scene generation.
- **Design Documentation**: Major features or mechanics MUST be documented in `docs/` with rationale and usage examples.

### Documentation as Content
Documentation serves dual purposes: internal reference and public education. This creates higher quality standards:

- **Technical Accuracy**: All documentation (internal and Substack) MUST be technically accurate. Do not oversimplify to the point of incorrectness.
- **Reproducibility**: Technical posts SHOULD include enough detail that readers could reproduce the implementation.
- **Narrative Clarity**: Write for intelligent non-experts. Assume AI/game dev literacy but explain project-specific concepts.
- **Visual Support**: Include screenshots, diagrams, or code snippets to make abstract concepts concrete.
- **Source Control**: Draft Substack posts in `substack/` directory as markdown files before publishing. This maintains project history and enables review.

## Development Workflow

### Version Control
- **Commit Scope**: Commits SHOULD be small and self-contained, focusing on a single feature or fix.
- **Commit Messages**: Use descriptive messages summarizing the change (e.g., "Add convolution drum part and corresponding spec fields").
- **Branch Strategy**: Feature development occurs in branches; main branch MUST always be stable and playable.
- **No Generated Files**: Do not commit auto-generated scenes, build artifacts, or cache files unless they are deliberately curated content.

### AI Assistance Guidelines
When using AI assistants (Cursor, Claude, etc.) for code generation:

1. **Review Generated Code**: Always read AI-generated code before committing. Verify it adheres to project standards and Godot idioms.
2. **Stay Within Scope**: AI changes MUST be focused on the intended component. Unrelated modifications or global config changes require explicit justification.
3. **Licensing**: Only include third-party content compatible with MIT license. Attribute sources in comments.
4. **Relative Paths**: Use Godot resource paths (`res://`) for all asset references. Never hardcode absolute filesystem paths.
5. **Incremental Commits**: Commit AI-generated changes in small batches to enable easy review and rollback.
6. **Respect Rules**: AI MUST follow the guidelines in `CLAUDE.md` and `.cursorrules` (or equivalent). Do not override safety constraints.

**Non-Negotiable**: AI tools MUST NOT:
- Remove functionality or "simplify" working code without explicit instruction
- Generate extremely long hashes, binary data, or non-textual code
- Mock AI calls or create fake data (game simulation must be deterministic and real)

### Code Style
- **GDScript**: Four spaces for indentation. Use snake_case for variables/functions, PascalCase for class names.
- **YAML**: Use lowercase with underscores for keys. Avoid abbreviations or ambiguous names. Include descriptive comments at file top.
- **File Naming**: Lowercase with underscores for all files (scenes, scripts, specs).

### Substack Publishing Workflow
To maintain quality and consistency in public documentation:

1. **Draft Phase**: Write posts in `substack/` as markdown files. Use descriptive names (e.g., `implementing_spec_driven_development.md`).
2. **Technical Review**: Ensure code snippets compile, YAML validates, and technical claims are accurate.
3. **Narrative Review**: Check for thematic consistency (steampunk metaphors), engagement hooks, and clarity.
4. **Milestone Alignment**: Time posts to coincide with feature completion or significant commits.
5. **Cross-Reference**: Link to GitHub commits, PRs, or specific files when discussing implementations.
6. **Post-Publication**: Move published posts to `substack/published/` with publication date in filename for archival purposes.

**Cadence Discipline**: Weekly publishing (Tuesdays) is non-negotiable. If development stalls, write reflective posts about challenges, design decisions, or AI concepts being explored. The chronicle continues regardless of implementation pace.

## Governance

### Amendment Process
This constitution governs all code and content contributions to AItherworks. Amendments require:

1. **Proposal**: Document proposed change with rationale and impact analysis.
2. **Review**: Core maintainers review for consistency with project vision and technical feasibility.
3. **Version Bump**: Update `CONSTITUTION_VERSION` according to semantic versioning:
   - **MAJOR**: Backward-incompatible changes (removing/redefining principles)
   - **MINOR**: New principles or materially expanded guidance
   - **PATCH**: Clarifications, wording fixes, non-semantic refinements
4. **Migration Plan**: If amendment affects existing code/data, provide migration instructions.
5. **Documentation Update**: Update all dependent templates and documentation to reflect changes.

### Compliance and Review
- All contributions (PRs, commits) MUST align with constitutional principles.
- Deviations require explicit justification in commit messages or PR descriptions.
- Complexity that violates principles (e.g., hardcoding design values) must be justified or simplified.
- Periodic constitution reviews occur quarterly to ensure relevance as project evolves.

### Version History
This constitution uses semantic versioning to track governance changes:

- **MAJOR**: Breaking changes to development philosophy or architecture
- **MINOR**: New principles or significant expansions of existing ones
- **PATCH**: Editorial clarifications, formatting, minor wording improvements

**Version**: 1.1.0 | **Ratified**: 2025-10-03 | **Last Amended**: 2025-10-03
