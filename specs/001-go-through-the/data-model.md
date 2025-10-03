# Data Model: Complete AItherworks Core System

**Feature**: 001-go-through-the  
**Date**: 2025-10-03  
**Phase**: 1 (Design)

## Overview

This document defines the data entities, relationships, and schemas for the AItherworks core system. All data follows the Data-Driven Design principle (Constitution I) with YAML/JSON as the single source of truth.

---

## Core Entities

### 1. Level

**Purpose**: Represents a single puzzle/level in the campaign.

**Storage**: YAML files in `data/specs/` (e.g., `act_I_l1_dawn_in_dock_ward.yaml`)

**Schema**:
```yaml
id: string (unique identifier, e.g., "act_I_l1_dawn_in_dock_ward")
name: string (display name, e.g., "Dawn in Dock-Ward")
description: string (level objective explanation)

story:
  title: string
  text: string (multiline narrative)

budget:
  mass: integer (parameter count limit, e.g., 6000)
  pressure: string (energy constraint: "Low", "Medium", "High")
  brass: integer (cost limit, e.g., 500)

allowed_parts: array<string> (part IDs, e.g., ["steam_source", "weight_wheel"])

win_conditions:
  accuracy: float (0.0-1.0, e.g., 0.95)
  # Optional:
  max_mass: integer (if different from budget.mass)
  max_pressure: string
  fairness_threshold: float (for alignment levels)

# Optional training configuration:
training:
  optimizer: string ("sgd", "adam", etc.)
  learning_rate: float (e.g., 0.1)
  max_epochs: integer (e.g., 100)
  convergence_hints:
    divergence: string (hint text)
    oscillation: string (hint text)
    stagnation: string (hint text)

# Optional simulation configuration:
simulation:
  max_recurrent_iterations: integer (default: 10)
  recurrent_convergence_epsilon: float (default: 0.001)
  allow_feedback_loops: boolean (default: false)
```

**Relationships**:
- `allowed_parts` → references Part entities by `part_id`
- Levels are organized into Acts (I-VI) by filename convention

**Validation Rules**:
- `id` must be unique across all levels
- `allowed_parts` must reference existing part definitions
- `budget` values must be positive integers
- `win_conditions.accuracy` must be between 0.0 and 1.0

---

### 2. Part

**Purpose**: Defines a machine component (visual, behavior, ports, costs).

**Storage**: YAML files in `data/parts/` (e.g., `weight_wheel.yaml`)

**Schema**:
```yaml
part_id: string (unique, e.g., "weight_wheel")
display_name: string (e.g., "Weight Wheel")
category: string ("input", "transformation", "training", "output", "visualization")
description: string (steampunk-themed explanation)

ports:
  # Each port has a name and type
  in_north:
    type: string ("scalar", "vector", "matrix", "tensor", "attention_weights", "logits", "gradient", "signal")
    direction: string ("input", "output")
  out_south:
    type: string
    direction: string

costs:
  brass: integer (placement cost)
  mass: integer (parameter count)
  pressure: string ("None", "Low", "Medium", "High")

# Optional behavior configuration:
behavior:
  # Part-specific parameters (e.g., for Weight Wheel)
  default_spokes: integer (e.g., 3)
  trainable: boolean (default: false)
  
visual:
  icon: string (path to icon, e.g., "res://assets/icons/weight_wheel.svg")
  scene: string (path to scene, e.g., "res://game/parts/weight_wheel.tscn")
```

**Relationships**:
- Referenced by Level's `allowed_parts`
- `scene` path points to Godot `.tscn` file

**Validation Rules**:
- `part_id` must be unique across all parts
- Port names must follow `{direction}_{cardinal}` pattern (e.g., `in_north`, `out_south`)
- Port `type` must be one of 8 defined types (see research.md)
- `category` must be one of 5 defined categories
- `scene` path must exist in `game/parts/`

---

### 3. PlayerProgress

**Purpose**: Tracks player's campaign progress and unlocks.

**Storage**: Local save file (`user://save_data.json` for web, OS-specific for desktop)

**Schema**:
```json
{
  "player_id": "string (UUID)",
  "created_date": "ISO 8601 timestamp",
  "last_played": "ISO 8601 timestamp",
  
  "completed_levels": ["array of level IDs"],
  "current_level": "string (level ID)",
  "unlocked_parts": ["array of part IDs"],
  "sandbox_unlocked": "boolean",
  
  "tutorial_status": {
    "completed": "boolean",
    "skipped": "boolean",
    "current_step": "integer (if in progress)"
  },
  
  "stats": {
    "total_playtime_seconds": "integer",
    "levels_completed": "integer",
    "machines_built": "integer",
    "training_runs": "integer"
  }
}
```

**Relationships**:
- `completed_levels` references Level entities
- `unlocked_parts` references Part entities
- `current_level` references active Level

**Validation Rules**:
- `completed_levels` must only contain valid level IDs
- `unlocked_parts` must only contain valid part IDs
- Level gating logic: Act I L1 → L2 → L3, etc.

---

### 4. MachineConfiguration

**Purpose**: Player's current part placement and connections for a level (saved per level).

**Storage**: Embedded in PlayerProgress or separate per-level saves

**Schema**:
```json
{
  "level_id": "string",
  "created_date": "ISO 8601 timestamp",
  "modified_date": "ISO 8601 timestamp",
  
  "parts": [
    {
      "instance_id": "string (UUID for this placement)",
      "part_id": "string (e.g., 'weight_wheel')",
      "position": {"x": "float", "y": "float"},
      "parameters": {
        "// part-specific params": "e.g., spoke values for Weight Wheel"
      }
    }
  ],
  
  "connections": [
    {
      "from": "string (instance_id.port_name)",
      "to": "string (instance_id.port_name)"
    }
  ],
  
  "budget_used": {
    "mass": "integer",
    "pressure": "string",
    "brass": "integer"
  }
}
```

**Relationships**:
- `level_id` references Level
- `parts[].part_id` references Part
- `connections` form a directed graph

**Validation Rules**:
- All `part_id` values must exist in Level's `allowed_parts`
- `budget_used` must not exceed Level's `budget`
- Connections must match port types (from.type == to.type)
- No dangling connections (both endpoints must exist)

---

### 5. TrainingState

**Purpose**: Runtime state during training (not persisted, ephemeral).

**Storage**: In-memory only (GDScript variables)

**Schema**:
```gdscript
class_name TrainingState extends RefCounted

var current_epoch: int = 0
var loss_history: Array[float] = []
var weight_snapshots: Dictionary = {}  # part_instance_id -> weight values
var gradient_flows: Dictionary = {}     # connection_id -> gradient value
var validation_metrics: Dictionary = {
    "accuracy": 0.0,
    "loss": 0.0
}
var convergence_status: String = "running"  # "running", "converged", "diverged", "oscillating", "stagnant"
```

**Relationships**:
- References MachineConfiguration (current machine being trained)
- Updates in real-time during simulation loop

**Lifecycle**:
- Created when "Train" button clicked
- Updated each epoch
- Destroyed when training stops or level exits

---

### 6. TransformerTrace

**Purpose**: Pre-generated transformer execution data for visualization levels.

**Storage**: JSON files in `data/traces/` (e.g., `intro_attention_gpt2_small.json`)

**Schema**:
```json
{
  "trace_version": "1.0",
  "model": "string (e.g., 'gpt2-small')",
  "prompt": "string",
  "tokens": ["array of token strings"],
  
  "layers": [
    {
      "layer_idx": "integer",
      "attention": {
        "heads": [
          {
            "head_idx": "integer",
            "weights_compressed": "array<uint8> (attention matrix flattened, 0-255 encoding)"
          }
        ]
      },
      "logits_topk": [
        {
          "position": "integer (token position)",
          "top_tokens": [
            {"token_id": "integer", "probability": "float"}
          ]
        }
      ]
    }
  ],
  
  "metadata": {
    "generated_date": "ISO 8601 timestamp",
    "generator_version": "string",
    "model_config": {
      "n_layers": "integer",
      "n_heads": "integer",
      "d_model": "integer"
    }
  }
}
```

**Relationships**:
- Referenced by transformer visualization levels (Acts III-IV)
- Loaded by Looking-Glass Array and Heat Lens parts

**Validation Rules**:
- `weights_compressed` length must equal (sequence_length * sequence_length)
- `layers` array length must match `model_config.n_layers`
- `heads` array length must match `model_config.n_heads`
- `top_tokens` probability values must sum to ≤1.0

---

### 7. ChallengeSeal

**Purpose**: Shareable machine configuration for competitive play (Phase 1: local export).

**Storage**: Exported JSON files (`*.aitherworks_seal`)

**Schema**:
```json
{
  "seal_version": "1.0",
  "level_id": "string",
  "created_date": "ISO 8601 timestamp",
  "creator": "string (player name or 'Anonymous')",
  
  "parts": [
    {
      "part_id": "string",
      "position": {"x": "float", "y": "float"},
      "parameters": {}
    }
  ],
  
  "connections": [
    {"from": "string", "to": "string"}
  ],
  
  "performance_metrics": {
    "accuracy": "float",
    "mass_used": "integer",
    "pressure_used": "string",
    "brass_used": "integer",
    "training_epochs": "integer"
  }
}
```

**Relationships**:
- Similar to MachineConfiguration but with metadata for sharing
- `level_id` must match when importing

**Validation Rules**:
- Import validates `level_id` exists
- All `part_id` values must be in target level's `allowed_parts`
- Budget constraints must be satisfied
- No cheating detection (parameter tampering)

---

## Entity Relationships Diagram

```
┌──────────┐       allowed_parts      ┌──────────┐
│  Level   │ ────────────────────────> │   Part   │
└──────────┘                           └──────────┘
      ^                                      ^
      │                                      │
      │ references                           │ references
      │                                      │
┌───────────────────┐                       │
│ PlayerProgress    │                       │
│                   │                       │
│ - completed_levels│───────────────────────┘
│ - unlocked_parts  │
│ - current_level   │
└───────────────────┘
      │
      │ contains
      v
┌──────────────────────┐
│ MachineConfiguration │
│                      │
│ - parts[]            │───> references Part by part_id
│ - connections[]      │
│ - budget_used        │
└──────────────────────┘
      ^
      │ active during training
      │
┌──────────────────┐
│  TrainingState   │
│  (ephemeral)     │
└──────────────────┘

┌──────────────────────┐
│  TransformerTrace    │
│  (read-only data)    │
└──────────────────────┘
      ^
      │ loaded by
      │
   transformer levels

┌──────────────────┐
│  ChallengeSeal   │
│  (export/import) │
└──────────────────┘
      │
      └───> similar structure to MachineConfiguration
```

---

## Data Flow

### Level Loading Flow
1. Player selects level from Level Select UI
2. System loads Level YAML from `data/specs/{level_id}.yaml`
3. System validates Level schema
4. System loads all parts referenced in `allowed_parts`
5. System creates empty MachineConfiguration for level
6. If saved progress exists, load previous MachineConfiguration
7. Display Workbench with allowed parts in Component Drawers

### Training Flow
1. Player clicks "Train" button
2. System creates TrainingState
3. For each epoch (0 to max_epochs):
   a. Run forward pass through MachineConfiguration graph
   b. Calculate loss against win_conditions
   c. Run backward pass to compute gradients
   d. Update part parameters (Weight Wheels, etc.)
   e. Store loss in TrainingState.loss_history
4. Check convergence status (success/divergence/oscillation/stagnation)
5. If success: Mark level complete, unlock next level
6. If failure: Display adaptive hints from Level.training.convergence_hints
7. Update PlayerProgress with results

### Save Flow
1. Serialize MachineConfiguration to JSON
2. Embed in PlayerProgress.{level_id}_save
3. Write PlayerProgress to `user://save_data.json`
4. On next load, restore from save

---

## Schema Validation

All schemas will be validated using:
- **YAML schemas**: Custom validator in `addons/steamfitter/validators/`
- **JSON schemas**: JSON Schema standard (Draft 7)
- **Runtime assertions**: GDScript `assert()` for type checks

See `contracts/` directory for formal schema definitions.

---

## Next Steps

With data model defined, proceed to:
1. Create formal schema files in `contracts/`
2. Implement validators in `addons/steamfitter/validators/`
3. Create quickstart.md with first playable level test
4. Update CLAUDE.md with new technical context

