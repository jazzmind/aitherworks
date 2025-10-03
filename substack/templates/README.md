# Substack Post Templates

This directory contains templates for the four main post types used in the AItherworks Substack chronicle, as mandated by Constitution v1.1.0, Principle VI (Public Documentation & Process Chronicle).

## Constitutional Requirement

Weekly publishing (Tuesdays) is **non-negotiable**. These templates help maintain quality and consistency while meeting the constitutional mandate.

## Post Type Mix

Per `substack/plan.md` and the constitution:
- **70%**: Dev Updates (weekly progress)
- **20%**: AI Explainers (concepts via game mechanics)
- **10%**: Narrative/Story (world-building, character arcs)
- **Occasional**: Community Reflection (every 4-6 weeks)

## Templates

### 1. Dev Update Template (`dev_update_template.md`)
**Use for**: Weekly progress reports, feature implementations, technical challenges

**Structure**:
- Hook (problem or win from this week)
- What I built (technical details + code/YAML)
- Visuals (2+ screenshots/diagrams required)
- AI concept connection
- Challenges & solutions
- Next week preview

**Word Count**: 800-1200 words  
**Frequency**: Most weeks (70% of posts)

**Content Sources**:
- `docs/todo.md` (completed items)
- Recent commits/PRs
- `game/parts/*.gd` and `game/sim/*.gd` implementations
- `data/specs/*.yaml` and `data/parts/*.yaml` changes

---

### 2. AI Explainer Template (`ai_explainer_template.md`)
**Use for**: Deep-dives on AI concepts taught through game mechanics

**Structure**:
- Real-world hook (everyday AI examples)
- Problem this solves
- Steampunk translation (AI concept → game mechanic)
- Step-by-step walkthrough (game + neural network parallel)
- The puzzle (actual level that teaches this)
- Why this metaphor works

**Word Count**: 1000-1500 words  
**Frequency**: ~2-3 per month (20% of posts)

**Content Sources**:
- `docs/lexicon.md` (steampunk metaphors)
- `docs/act-*.md` (level designs)
- `data/specs/*.yaml` (puzzle specifications)
- Technical AI documentation

---

### 3. Narrative/Story Template (`narrative_story_template.md`)
**Use for**: Story beats, character development, world-building

**Structure**:
- Story beat hook (immersive narrative)
- Setting and stakes
- Characters (rivals, mentors, inspectors)
- Challenge (puzzle design + narrative)
- AI mirror (real-world parallel)
- Story beats (beginning → resolution)
- Dialog snippets

**Word Count**: 800-1200 words  
**Frequency**: ~1 per month (10% of posts)

**Content Sources**:
- `docs/about.md` (world overview)
- `docs/act-*.md` (narrative arcs)
- `docs/backstory_system.md` and `docs/backstory1.md`
- `data/specs/*.yaml` (level story fields)

---

### 4. Community Reflection Template (`community_reflection_template.md`)
**Use for**: Reader feedback, polls, design decisions based on community input

**Structure**:
- Acknowledge engagement (quote comments/questions)
- Cluster themes from feedback
- Respond to each theme (depth + honesty)
- How feedback changed the plan
- Poll results (if applicable)
- Next question for readers

**Word Count**: 800-1200 words  
**Frequency**: Every 4-6 weeks (avoid overuse)

**Content Sources**:
- Substack comments
- GitHub issues/discussions
- Social media responses (LinkedIn, Twitter, Reddit)

---

## Usage Workflow

Per Constitution v1.1.0, Development Workflow → Substack Publishing Workflow:

1. **Draft Phase**: Copy template to `substack/[descriptive_name].md`
2. **Technical Review**: Validate code snippets, YAML, technical claims
3. **Narrative Review**: Check thematic consistency, engagement hooks
4. **Milestone Alignment**: Time post with feature completion or significant commits
5. **Cross-Reference**: Add GitHub links to commits, files, PRs
6. **Post-Publication**: Move to `substack/published/[YYYY-MM-DD]_[title].md`

## Template Maintenance

- Update templates when post format evolves
- Add new templates if new content types emerge
- Keep meta sections (marked "Delete Before Publishing") up-to-date
- Reference constitution version in templates when relevant

## Cadence Discipline

From Constitution v1.1.0, Principle VI:

> Weekly publishing (Tuesdays) is non-negotiable. If development stalls, write reflective posts about challenges, design decisions, or AI concepts being explored. The chronicle continues regardless of implementation pace.

**Translation**: Always have a post ready. When in doubt, use Dev Update template to reflect on progress, blockers, or learning.

## SEO & Cross-Posting

Each template includes:
- SEO keyword suggestions (hashtags)
- Cross-posting guidance (LinkedIn, Twitter, Reddit)
- Optimal timing (evenings for LinkedIn)

Refer to `substack/plan.md` for detailed cross-promotion strategy.

---

**Questions?** See `.specify/memory/constitution.md` (Principle VI) or `substack/plan.md` (section 2)

