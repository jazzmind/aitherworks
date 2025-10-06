# AItherworks Code Style Guide

This document defines coding standards for the AItherworks project to ensure consistency and maintainability.

## GDScript Style

### General Principles
- Follow [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- Prioritize readability over cleverness
- Use typed GDScript for performance and clarity
- Keep functions small and focused (< 50 lines ideally)

### Naming Conventions

#### Variables and Functions
```gdscript
# snake_case for variables and functions
var player_health: int = 100
var max_epochs: int = 50

func calculate_forward_pass(input_data: Array) -> Array:
    pass

func _on_button_pressed() -> void:
    pass
```

#### Classes and Types
```gdscript
# PascalCase for class names
class_name WeightWheel extends Node2D

class_name TrainingState extends RefCounted
```

#### Constants
```gdscript
# UPPER_SNAKE_CASE for constants
const MAX_PARTS: int = 33
const SIMULATION_BUDGET_MS: float = 16.0
const DEFAULT_LEARNING_RATE: float = 0.1
```

#### Signals
```gdscript
# snake_case with past tense verb
signal training_completed(accuracy: float, loss: float)
signal part_connected(from_port: String, to_port: String)
signal level_loaded(level_id: String)
```

#### Private/Internal
```gdscript
# Prefix with _ for internal/private
var _internal_state: Dictionary = {}

func _update_gradients() -> void:
    # Internal helper, not part of public API
    pass
```

### Indentation and Whitespace

```gdscript
# Use tabs for indentation (indent_size = 4 in .editorconfig)
# One statement per line
# Blank line between function definitions

class_name ExamplePart extends Node2D

var health: int = 100
var damage: float = 25.5

func _ready() -> void:
	print("Part initialized")
	_setup_connections()

func _setup_connections() -> void:
	# Implementation here
	pass
```

### Type Hints

**Always use type hints** for variables, parameters, and return types:

```gdscript
# Good: Explicit types
var loss_history: Array[float] = []
var part_id: String = "weight_wheel"
var is_training: bool = false

func forward_pass(input: Array[float]) -> Array[float]:
	var output: Array[float] = []
	return output

# Avoid: Untyped (only use if type cannot be known)
var data = some_function()  # Avoid if possible
```

### Comments and Documentation

```gdscript
## Documentation comment for class (double ##)
## This part represents a learnable weight matrix.
class_name WeightWheel extends Node2D

## Calculate forward pass through the weight wheel.
## 
## Takes input vector and multiplies by spoke weights.
## 
## @param input: Input vector (must match spoke count)
## @return: Output vector (same size as input)
func forward_pass(input: Array[float]) -> Array[float]:
	# Implementation comment (single #)
	var output: Array[float] = []
	
	# Multiply each input by corresponding spoke weight
	for i in range(input.size()):
		output.append(input[i] * _spokes[i])
	
	return output
```

### Error Handling

```gdscript
# Use assert() for development-time checks
assert(input.size() == _spokes.size(), "Input size must match spoke count")

# Use push_error() for runtime errors
if not FileAccess.file_exists(yaml_path):
	push_error("Level YAML not found: %s" % yaml_path)
	return null

# Use push_warning() for non-critical issues
if training_epochs > 1000:
	push_warning("Very high epoch count (%d) may cause performance issues" % training_epochs)
```

### Signals and Callbacks

```gdscript
# Connect signals in _ready()
func _ready() -> void:
	train_button.pressed.connect(_on_train_button_pressed)
	simulation_engine.training_completed.connect(_on_training_completed)

# Callback naming: _on_<source>_<signal_name>
func _on_train_button_pressed() -> void:
	start_training()

func _on_training_completed(accuracy: float, loss: float) -> void:
	display_results(accuracy, loss)
```

## YAML Style

### General

```yaml
# Use 2-space indentation (per .editorconfig)
# Lowercase with underscores for keys
# Use descriptive, unabbreviated names
# Include file-level comment

# Act I Level 1: Dawn in Dock-Ward
# Teaches basic vector operations and Weight Wheel usage

id: act_I_l1_dawn_in_dock_ward
name: "Dawn in Dock-Ward"
description: "Build your first Signal Loom and learn vector operations."

budget:
  mass: 1000
  pressure: "Low"
  brass: 100

allowed_parts:
  - steam_source
  - signal_loom
  - weight_wheel
  - adder_manifold
```

### Multiline Text

```yaml
story:
  title: "A Humble Beginning"
  text: |
    Fresh from the Dock-Ward, you have one day to prove yourself.
    The Guild will repossess your foundry if you cannot add two numbers.
    
    Show them what you're made of.
```

## File Organization

### GDScript Files

```gdscript
# 1. Class declaration and documentation
class_name WeightWheel extends Node2D
## Learnable weight matrix part.

# 2. Signals
signal weights_updated(new_weights: Array[float])

# 3. Constants
const DEFAULT_SPOKE_COUNT: int = 3

# 4. Exported variables (inspector-editable)
@export var trainable: bool = true

# 5. Public variables
var spokes: Array[float] = []

# 6. Private variables
var _gradient_cache: Array[float] = []

# 7. Godot lifecycle methods (_ready, _process, etc.)
func _ready() -> void:
	_initialize_spokes()

# 8. Public methods (API)
func forward_pass(input: Array[float]) -> Array[float]:
	pass

func backward_pass(gradient: Array[float]) -> void:
	pass

# 9. Private/helper methods
func _initialize_spokes() -> void:
	pass

func _apply_gradients(learning_rate: float) -> void:
	pass
```

### Project Structure

```
aitherworks/
├── addons/                 # Third-party plugins (gdyaml, gut)
├── assets/                 # Art, audio, fonts
├── data/
│   ├── specs/             # Level YAML files
│   ├── parts/             # Part YAML definitions
│   └── traces/            # Transformer trace JSONs
├── docs/                  # Documentation (markdown)
├── game/
│   ├── parts/             # Part scenes + scripts (33 total)
│   ├── sim/               # Simulation engine
│   └── ui/                # UI components
├── tests/                 # GUT tests
│   ├── unit/
│   ├── integration/
│   ├── validation/
│   └── performance/
└── specs/                 # Feature specifications (spec-driven dev)
```

## Version Control

### Commit Messages

Follow conventional commits style:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature (e.g., "feat(parts): Add Weight Wheel implementation")
- `fix`: Bug fix
- `test`: Adding or updating tests
- `docs`: Documentation changes
- `style`: Code style/formatting (no logic change)
- `refactor`: Code refactoring (no feature change)
- `perf`: Performance improvement
- `chore`: Tooling, dependencies, config

**Examples**:
```
feat(plugin): Implement YAML spec loader with schema validation

- Parse level specs from data/specs/
- Validate against contracts/level_schema.yaml
- Report errors with file name and line number
- Cache parsed specs for hot-reload

Resolves: T018

---

test(unit): Add Weight Wheel forward/backward pass tests

- Test spoke multiplication in forward pass
- Test gradient accumulation in backward pass
- Expected to FAIL until T031 implementation

Part of: T030 (TDD strict)

---

docs: Add code style guide

Documents GDScript naming conventions, type hints, and
file organization per Constitution v1.1.0 quality standards.

Resolves: T004
```

### Branching

- `main` - Always stable and playable
- `001-go-through-the` - Current feature branch (complete core system)
- Short-lived feature branches for sub-tasks if needed

## Performance Guidelines

### Critical Paths (60 FPS = 16ms budget)

```gdscript
# Avoid in _process() or simulation loop:
# - String operations (concatenation, formatting)
# - File I/O
# - Complex calculations without caching

# Good: Cache expensive computations
var _topological_order: Array[Node2D] = []

func _ready() -> void:
	_topological_order = _compute_topological_sort()

func _process(delta: float) -> void:
	# Use cached order, don't recompute
	for part in _topological_order:
		part.update_state(delta)

# Good: Use typed arrays for performance
var loss_history: Array[float] = []  # PackedFloat32Array alternative

# Good: Batch operations
func update_all_weights(gradients: Dictionary) -> void:
	for part_id in gradients:
		_parts[part_id].apply_gradient(gradients[part_id])
```

### Profiling

```gdscript
# Use Time.get_ticks_msec() for critical sections
var start_time: int = Time.get_ticks_msec()
_run_forward_pass()
var elapsed: int = Time.get_ticks_msec() - start_time

if elapsed > SIMULATION_BUDGET_MS:
	push_warning("Forward pass exceeded budget: %dms" % elapsed)
```

## AI Assistance Guidelines

When using AI tools (Cursor, Claude, etc.):

1. **Review Generated Code**: Always read and understand AI-generated code before committing
2. **Verify Style Compliance**: Ensure generated code follows this style guide
3. **Add Context Comments**: AI may generate correct code but omit "why" comments
4. **Test Generated Code**: Don't trust AI—run tests and manual validation
5. **Respect Constitution**: AI must follow Constitution v1.1.0 principles (data-driven, Godot 4 native, etc.)

## Formatting Tools

### GDFormat (Recommended)
- Install: https://github.com/Scony/godot-gdscript-toolkit
- Run: `gdformat game/ addons/steamfitter/ tests/`
- Integrates with `.editorconfig`

### Manual Formatting
- Use Godot's built-in script editor formatter (Script → Format Code)
- Configure editor to use tabs (4-space width) for GDScript

## References

- [GDScript Style Guide (Official)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [EditorConfig](https://editorconfig.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- Constitution v1.1.0 (`/memory/constitution.md`)

---

**Last Updated**: 2025-10-03 (T004 implementation)

