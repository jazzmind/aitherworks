## AItherworks: Brass & Steam Edition

A steampunk puzzle-sim where rivalling Guilds race to forge the first true “Steam-Mind.” You build it—gears, glass, and aether—learning real ML along the way.

⸻

### 1) World, Tone & Story Spine

Setting — The City of Aetherford (1899-ish):
Sky-rails hiss. Pneumatic tubes thump. Printing presses clatter out scandal sheets. The Guild of Ingeniators announces a Grand Exposition: the first mind of steam and aetheric logic. Houses (rival workshops) compete to win the Charter and power the Century.

You: a rising Mechanist inheriting a rundown Foundry-Barge moored on the Aetherford canal.

Rivals:
	•	House Voltaic (industrialists): fast, wasteful, rumor of coal bribery.
	•	Lady Kessington’s Atelier (aristocratic precision): immaculate but slow, allergic to risk.
	•	The Inspectorate (Guild examiners): gatekeepers of standards and ethics.
	•	The Penny Clarion (newspaper): crowns legends, ruins pretenders.

The Stakes (mirrors today):
	•	Energy scarcity → steam rationing, rolling brownouts.
	•	Bias → Guild dataset skew (apprentice ledgers ignoring workers).
	•	Alignment → “Ethical Governor” required to pass the Charter.
	•	Data poisoning → forged ledgers, mildew-mottled tomes.
	•	Safety → runaway pressure, flammable phlogiston.

Story Beat per Act (campaign):
	1.	Spark: save your Foundry from creditors; build the first “Signal Loom.”
	2.	Proof: pass the Inspectorate’s trials (generalize beyond training cards).
	3.	Exposition: public demo; rivals sabotage your pipes; you counter.
	4.	Crisis: citywide coal shortage; optimize, compress, and align.
	5.	Reckoning: a Steam-Mind mishap in the city—ethics & safety on trial.
	6.	Charter: the Grand Finale—ship a reliable, aligned Steam-Mind under harsh constraints.

Between levels: hand-inked comic panels, teleprinter news flashes, and rumor snippets.


⸻

### 2) Core Loop (Same great game, fully brass)
	1.	Design: Slot Frames, Gates, and Drums on a hex grid; route aether marbles.
	2.	Simulate: Pull the Steam Lever; watch forward flow.
	3.	Train: Open the Manometer; phlogiston backflows; Apprentices apply gradients.
	4.	Validate: Inspectorate stamps or snubs; hidden cards catch overfit contraptions.
	5.	Ship: Meet specs under Pressure (energy), Mass (params), and Brass (cost).

⸻

### 3) Resources & Constraints (mapped to real tradeoffs)
	•	Steam Pressure (energy/latency): high pressure = fast steps, low efficiency. Brownouts force clever routing.
	•	Aether Charge (compute): caps concurrent attention arrays / heads.
	•	Brass & Coal (budget): limits how many Frames/Drums you place.
	•	Reputation (social capital): unlocks patronage, but plummets on safety incidents.
	•	Charter-Law (alignment rules): missions require Ethical Governor thresholds to pass.

⸻

### 4) Campaign, Acts & Levels (story + pedagogy)

Act I — Cinders & Sums (Vectors, Loss, Backprop)
	•	L1 “Dawn in Dock-Ward”: Build a Signal Loom; match a target pattern with Weight Wheels.
	•	Teach: vectors, scaling.
	•	L3 “The Manometer Hisses”: Install Entropy Manometer; see Phlogiston Dye flow back; attach Stochastic Sal (SGD).
	•	Teach: forward/back, loss, learning rate.
	•	Setpiece: Debt Collector arrives; you win a reprieve by demoing a trained contraption.

Act II — Stamp & See (Conv, Overfitting, Regularization)
	•	L6 “Stamp the Cog”: A Convolution Drum finds cogs in parchment rubbings.
	•	Teach: kernels/filters.
	•	L8 “Mildew in the Archives”: Overfit trap; fix with Drop Valves & Augmentor Arms (crop/tilt).
	•	Teach: generalization, augmentation.
	•	Setpiece: The Penny Clarion hails your “self-correcting press.”

Act III — Attention at the Exposition (Transformers)
	•	L11 “The Looking-Glass”: Wire Q, K, V into the Looking-Glass Array; the Heat Lens shows focus weights.
	•	Teach: attention weights, softmax.
	•	L14 “Mini-Transformer”: Residual rails + Layer Tonic + MLP; beat rival on sequence copying with fewer cogs.
	•	Teach: block structure, parameter efficiency.
	•	Setpiece: House Voltaic sabotages your steam main; you reroute via Aether Battery (scheduler).

Act IV — Forgeries & Fog (GANs, Stability)
	•	L16 “Forger vs Examiner”: Two-board view—Athanor on left (G), Inspectorate Bench on right (D); balance cadence.
	•	Teach: GAN dynamics.
	•	L17 “Mode Collapse Clinic”: Add Mini-Batch Gauge and noise; the Examiner stops being gullible.
	•	Teach: collapse remedies.
	•	Optional L19 “Fog Condenser”: Diffusion teaser via fog-in/fog-out stages.

Act V — Compress, Align, Endure (Distillation, Quantization, Alignment)
	•	L20 “Teacher’s Whisper”: Distill a big press into a nimble apprentice via Athanor Still (temperature spigot).
	•	Teach: teacher-student training.
	•	L21 “Press to Fit”: Use Cog-Ratchet Press to 8-bit & 4-bit; run calibration cards to keep the needle green.
	•	Teach: quantization & calibration.
	•	L22 “The Ethical Governor”: Missions fail if Harm Limiters exceed thresholds on hidden edge-cases; install Ledger Filters for fairness.
	•	Teach: alignment objectives & bias mitigation.

Act VI — The Charter Trial (Integration & Responsibility)
	•	L26 “Citywide Dispatch”: Rolling brownouts + poisoned ledgers + safety audits, all at once.
	•	Teach: robust training & monitoring.
	•	L28 “The Charter”: Build a specialized Steam-Mind under strict Mass/Pressure/Ethics limits.
	•	Scoreboard: Accuracy, Energy, Params, Safety Incidents, Fairness Index.

⸻

### 5) Modern Issues, Steampunked (and how you fix them)
	•	Not enough energy → Steam rationing events; schedule runs with Aether Battery (LR schedulers), compress with Cog-Ratchet Press, distill heavy rigs into small ones.
	•	Bias → Guild ledgers undercount dock-workers; Ledger Filters rebalance; Inspectorate tests hidden cohorts.
	•	Alignment → Run “Harm Probes” on edge datasets; tune Ethical Governor (extra loss head) and validate.
	•	Data poisoning → “Mildewed Tomes” leak phlogiston; install Archivist Crow (data hygiene bot) and Outlier Whistle on the Manometer.

⸻

### 6) Sandbox: The Foundry (Endgame Workbench)

Unlock every part in a sprawling Clockwork Hall:
	•	Load image scrolls, tabular ledgers, or toy languages via Pneumail Librarium.
	•	Drag contraptions, wire flows, flip Train/Infer levers.
	•	Blueprint Export: JSON graph + optional PyTorch scaffold (node-by-node mapping).
	•	Lab Notebook: pressure curves (loss), phlogiston trails (grad norms), fairness dials, latency traces.
	•	Challenge Seals: publish foundry seeds; friends fight for efficiency crowns.

⸻

### 7) UI / Art / Sound Direction
	•	Visuals: burnished brass, smoked glass, riveted frames; animated gauges and needle-plots.
	•	Overlays:
	•	Flow (forward marbles), Error (backward dye), Compute (hot pipes), Ethics (purple warning halos).
	•	Accessibility: high-contrast lane glyphs; captions for every hiss & clank; math overlay toggles.
	•	Audio: piston thumps = training ticks; faint chimes when gradients settle; a rising whistle when loss spikes.
	•	Narrative Delivery: letterpress cards, pneumatic memos, tabloids, and rival telegrams.

⸻

### 8) Three Fully-Specced Levels

Level 12 — “Keys in the Looking-Glass” (Attention Basics)

Goal: From 6-token inputs, output token #3.
Parts: Looking-Glass Array (Q,K,V ports), Heat Lens, Matrix Frames, Adder Manifold, Softmax Gate, Residual Rail, Layer Tonic.
Constraints: Mass ≤ 6k cogs (params), Pressure ≤ Medium, Accuracy ≥ 99% on hidden set.
Teach: projections, dot-product attention, softmax distribution.
Twist: A coal puff limits simultaneous heads unless you add an Aether Battery (scheduler).
Hints:
	•	Use shared projection Frames for Q/K; keep Value path uninhibited.
	•	Watch Heat Lens: if it smears evenly, scale queries (temperature).

⸻

Level 21 — “Press to Fit” (Quantization & Calibration)

Goal: Maintain ≥95% Inspectorate score after compressing to 4-bit.
Parts: Cog-Ratchet Press (4 detents), Calibration Feeder, Entropy Manometer.
Constraints: Mass reduced by ≥60%; Pressure budget halved.
Teach: post-training quantization + calibration batch.
Twist: Some layers (attention output, first/last) resist 4-bit—leave at 8-bit (mixed precision).
Scoring:
	•	★ Accuracy ≥95%
	•	★ Mass ↓ ≥60%
	•	★ Pressure spikes ≤ 1 during inference.

⸻

Level 24 — “The Conclave of Cogs” (Reasoning Chain w/ RAG)

Goal: Answer city-law queries grounded in Archive pages.
Parts: Plan Table (3 boards), Pneumail Librarium (RAG), Embedder Drum, Looking-Glass, Ethical Governor.
Flow:
A) Parse query → B) Retrieve top-k pages → C) Attend to retrieved text → D) Answer head w/ Governor penalty.
Constraints: Brownouts every third batch; you must cache embeddings (Downspout + Valve).
Teach: multi-stage plans, grounding to suppress hallucinations, alignment penalty.
Win: ≤1 safety flag on adversarial “trick” questions.

⸻

### 9) Teaching Is Real (How We Ensure Depth)
	•	Every part shows its math under Overlay (vectors, matrices, gradients, logits).
	•	Manometer supports Cross-Entropy, MSE, Hinge; Governor adds aux loss.
	•	Apprentices expose η, β, β1/β2, ε; watch moment buffers as tiny gauges.
	•	Hidden validation draws from held-out generators (no memorizing the parade).
	•	Leaderboards per Accuracy, Mass, Pressure, Fairness, Incidents.

⸻

### 10) Production Notes
	•	Engine: Unity/Godot with deterministic float sim; fp32/fp16 toggle to match quantization puzzles.
	•	Authoring: JSON level specs (parts whitelist, budgets, target metrics, story card).
	•	Modding: Steam Workshop for blueprints/datasets; derby events (“One-Boiler Challenge”).
	•	Safety Mode: optional content filter for younger players; ethics puzzles still taught via contraptions.

⸻

### 11) Sample Story Beats & Dialog
	•	The Penny Clarion: “House Voltaic’s boilers roar like lions; the Dock-Ward sleeps in darkness.”
	•	Inspector Brass: “Your Manometer sings, Mechanist. But show me its song on unseen ledgers.”
	•	Lady Kessington: “Elegance is economy. Your machine sweats.”
	•	You, at the Charter: “A mind that serves the city serves all its citizens—workers and guildmasters alike.”

