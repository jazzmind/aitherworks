# Transformer Trace Format

This document defines a compact, deterministic trace format for transformer visualization puzzles. Traces are generated offline and consumed by Godot parts via the Steamfitter plugin.

## Goals
- Deterministic playback for puzzle win checks
- Compact enough to load quickly
- Sufficient to render tokens, attention, and logits

## Top-level schema (JSON)
```json
{
  "meta": {
    "model_name": "gpt2-small",
    "layers": 12,
    "heads": 12,
    "vocab_subset": [1996, 3290, 345, 50256],
    "tokenizer": "gpt2",
    "sequence_max": 64
  },
  "tokens": {
    "ids": [464, 3290, 318, 257, 1234],
    "text": ["The", "bridge", "is", "the", "…"],
    "offsets": [[0,3],[4,10],[11,13],[14,17],[18,21]]
  },
  "attention": {
    "shape": [12, 12, 5, 5],
    "dtype": "uint8",
    "scale": 255,
    "data": "<base64 of L*H*S*S uint8>"
  },
  "logits": {
    "per_position": [
      {"topk_ids": [1996, 3290, 262], "topk_logits": [7.2, 6.9, 6.3]},
      {"topk_ids": [318, 389, 262], "topk_logits": [6.8, 6.1, 5.9]}
    ],
    "temperature_default": 1.0
  },
  "extras": {
    "positional_encoding": null,
    "hidden_state_norms": null
  }
}
```

Notes:
- `attention.data` stores normalized weights as uint8 to reduce size. Recover by `weights = data / scale`.
- `logits.per_position` is truncated to top‑k candidates for UI and win checks.
- `vocab_subset` lists any vocab ids referenced in logits to resolve to strings.

## Binary considerations
- Use base64 for portability. For larger traces, consider msgpack or .npz with a small index JSON.

## Versioning
Add `meta.version` if we evolve fields. Consumers should soft‑fail on unknown keys.