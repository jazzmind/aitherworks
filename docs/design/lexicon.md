## Port Key Conventions

- Prefer explicit direction values in part `ports` maps: values must be `input` or `output`.
- Port keys may be descriptive (e.g., `steam_out`, `data_in`). Cardinal keys (`north/east/south/west`) are allowed but should be paired with clear values.
- Existing parts mixing cardinal keys will still load; the validator warns and suggests converging on descriptive keys.

Examples:

```yaml
ports:
  in-1: input
  out-1: output
```

Legacy (allowed, but consider migrating):

```yaml
ports:
  north: input
  south: output
```

## Steampunk Component Lexicon (1:1 to ML)

This lexicon maps in-world contraptions to the ML concepts they teach. Use it when writing levels, designing UI overlays, or explaining pedagogy.

| Steampunk Part | What it looks like | ML concept | Notes |
| --- | --- | --- | --- |
| Signal Loom | Beads (aether marbles) running multi-lane bronze rails | Vector/tensor signals | Forward flow shows activations by lane; overlay shows shapes. |
| Weight Wheels | Knurled brass dials per lane | Scalar weights (multiply) | Learnable knobs; Governor Chains apply gradient tugs. |
| Matrix Frame | Gear lattice; input rods driving output rods | Matrix multiply / linear layer | Shares shafts across lanes; mass correlates with parameter count. |
| Adder Manifold | Copper manifold merging flows | Add / residual | Enables skip connections and residual rails. |
| Activation Gates | Mechanical valves labeled ReLU / Sigmoid / Softmax | Nonlinearities | Per-lane gating; Softmax plate is temperature-sensitive. |
| Entropy Manometer | Needle gauge with target stencil | Loss function & metrics | Supports CE/MSE/Hinge; shows train/val traces. |
| Phlogiston Dye | Magenta vapor flowing backwards | Gradients in backprop | Visual-only overlay indicating dL/dW magnitude. |
| Governor Chains | Reversal chains tugging Weight Wheels | Gradient application | Learning rate = chain tension; momentum adds flywheels. |
| Clockwork Apprentices | Little bots: Stochastic Sal, Momentum Max, Adam Automaton | Optimizers (SGD/Momentum/Adam) | Swap bots to change update rule and hyperparameters. |
| Convolution Drum | Rolling stencil drum | Convolution / kernels | Kernel size, stride, padding shown as drum stencils. |
| Downspout | Step reduction with grates | Pooling / stride | Average/Max selectable grate; reduces lane count or resolution. |
| Looking-Glass Array | Crystal prism with three ports (Q,K,V) + Heat Lens | Attention + softmax | Heat Lens overlay shows alignment weights. |
| Layer Tonic | Tuning vials with self-leveling float | LayerNorm | Learnable gain/bias vials; stabilizes pressure spikes. |
| Drop Valves | Randomly chattering valves | Dropout | Valve probability slider; disabled during validation. |
| Weight-Decay Spring | Spring pulling knobs to center | L2 regularization | Constant pull proportional to weight magnitude. |
| Athanor Still | Copper still fed by Teacher pipe | Knowledge distillation | Temperature spigot; student sips softened logits. |
| Cog-Ratchet Press | Detented arbor press with gauges | Quantization (8b/4b) | Per-layer detents; calibration batch required. |
| Pneumail Librarium | Tube network to Archive stacks | RAG retrieval | Embeds, retrieves, and caches scrolls; shows top‑k slots. |
| Plan Table | Three linked drafting boards | Multi-step reasoning | Stages A→B→C are explicit boards; cache carries between. |
| Ethical Governor | Flyball governor with “Harm Limiters” | Alignment constraints | Adds auxiliary loss and threshold checks. |
| Aether Battery | Pressure accumulator; gauge + relief | Energy/latency budget | Schedules bursts; prevents brownout penalties. |
| Ledger Filters | Mesh screens by guild | Dataset filters / fairness | Rebalances cohorts; logs inclusion/exclusion. |

Toggle Math Overlay to reveal actual tensors, dL/dW, and logits—so learning is real.