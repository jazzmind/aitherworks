## Act I — Cinders & Sums (Vectors, Loss, Backprop)

Tone: Oil-lamp mornings and ledger dust. Simple parts, honest math. The act teaches vectors, scaling, addition, loss, and a first taste of backprop with SGD.

—

L1 — Dawn in Dock‑Ward
- Goal: Build a Signal Loom and Weight Wheels to match a 3‑lane target pattern.
- Teach: vectors, scaling, lane intuition.
- New parts: Signal Loom, Weight Wheel, Adder Manifold (optional), Activation Gate (optional).
- Budget: mass 500, pressure 6, brass 30.
- Win: accuracy ≥ 0.95 on a simple held‑out set.
- UX notes: palette on left, graph board center, inspector on right. Live lane readouts as tiny gauges on wires.

L2 — Two Hands Make a Sum
- Goal: Take two 3‑lane inputs and produce their sum via an Adder Manifold.
- Teach: element‑wise addition, multiple inputs, compositional thinking.
- New parts: Adder Manifold (primary), second Signal Loom.
- Budget: mass 700, pressure 7, brass 40.
- Win: match target vector within tolerance; unlock “merge” tutorial hint.
- UX notes: teach wiring order and port labels (north/west = inputs, south = output). Show red halos for dangling inputs.

L3 — The Manometer Hisses
- Goal: Add an Entropy Manometer and Stochastic Sal (SGD). Watch dye flow back and reduce loss.
- Teach: loss, gradients, the idea of backprop; learning rate as chain tension.
- New parts: Entropy Manometer, Apprentice (SGD).
- Budget: mass 800, pressure 8, brass 40.
- Win: reach accuracy ≥ 0.97 after training for N epochs.
- UX notes: add Train/Infer lever; show loss needle and a simple train/val trace. LR slider with safe bounds.

L4 — Room to Breathe
- Goal: Tune learning rate and stabilize training (avoid overshoot) to hit a tighter target.
- Teach: LR sensitivity, basic normalization/activation intuition; introduce ReLU gate as a safe ramp.
- New parts: Activation Gate (ReLU).
- Budget: mass 900, pressure 8, brass 50.
- Win: converge within steps budget; no oscillation beyond threshold.
- UX notes: annotate steps that increase loss; tooltip explains too‑high LR. Add Reset Weights button.

L5 — The Debt Collector’s Demo (Setpiece)
- Goal: Combine wheels and adders; train live to spec in front of the Inspectorate.
- Teach: assembling a small pipeline, hidden validation, reproducibility (seed).
- New parts: none (mastery challenge).
- Budget: mass 1200, pressure 10, brass 60.
- Win: accuracy ≥ 0.95 on hidden set; ≤ 1 spike in pressure during training.
- UX notes: one‑click “Demo” runs a fixed script: build → simulate → train → validate; publish a score card.

—

2D Workbench UX (Act I scope)
- Board: node‑and‑wire graph with lane badges; zoom/pan; snap grid.
- Palette: allowed parts from level spec; drag to board.
- Inspector: edit parameters (weight, activation); LR slider; epoch count.
- Overlays: Flow (forward values), Error (backward dye), Loss trace dock.
- Controls: Train/Infer toggle, Step, Run N epochs, Reset Weights, Export Blueprint.

Teaching Prompts
- “Vector lanes show as brass badges. Click a wire to read values per lane.”
- “ReLU gates clip negatives; add after an Adder if your needle rattles.”
- “Too much chain tension (LR) makes the wheel overshoot—listen to the hiss.”