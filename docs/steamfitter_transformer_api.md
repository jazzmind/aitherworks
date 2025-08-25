# Steamfitter Transformer API Stubs

These editor/runtime helpers should be added to `addons/steamfitter` as the transformer visualization features are implemented.

## Loading a trace
```
load_transformer_trace(path: String) -> TransformerTrace
```
- Input: `res://data/traces/*.json`
- Output: object with tokens, attention (decoded), logits (top‑k)

## Building scenes from specs
```
build_attention_scene(trace: TransformerTrace, ui_config: Dictionary) -> Node
build_logits_scene(trace: TransformerTrace, ui_config: Dictionary) -> Node
build_sampling_scene(trace: TransformerTrace, defaults: Dictionary) -> Node
build_layer_navigator(trace: TransformerTrace) -> Node
```

## Sampling application
```
apply_sampling(logits_topk: Dictionary, params: Dictionary) -> Dictionary
```
- Returns `{ chosen_token_id: int }`

## Win checks
```
check_reach_target_token(tokens: PoolStringArray, target: String) -> bool
check_attention_head_focus(attn: PackedFloat32Array, layer: int, head: int, span: Vector2i, threshold: float) -> bool
```

Implementation notes:
- Decode attention weights from uint8 to float once and cache per layer/head.
- Expose head masks for ablation in `layer_navigator`.
- Keep all UI parameters in spec `transformer_explainer` block.