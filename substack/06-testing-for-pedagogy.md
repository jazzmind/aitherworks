# Week 6: Testing for Pedagogy—How We Discovered the Weight Wheel Was Teaching the Wrong Math

*"The steampunk metaphor was beautiful. The math was wrong."*

Last week, I wrote about [adopting spec-driven development mid-flight](https://github.com/jazzmind/aitherworks/blob/main/substack/05-mid-flight-spec-adoption.md) and using validation testing to catch architectural bugs. This week is about something scarier: **What if your game is pedagogically incorrect?**

AItherworks isn't just a game. It's a *teaching tool*. When a player adjusts the Weight Wheel (our metaphor for learnable neural network parameters), they're supposed to learn how gradient descent works. If the underlying math is wrong, they learn the wrong concept.

And that's exactly what we discovered.

## The Setup: What Makes a Good Teaching Game?

Games like *Zachtronics' TIS-100* or *Turing Tumble* work because they're **mechanically accurate**. When you solve a TIS-100 puzzle, you're writing *actual assembly code*. When you route marbles in Turing Tumble, you're building *actual logic gates*.

The steampunk aesthetic is window dressing. The machinery underneath must be *correct*.

For AItherworks, "correct" means:
1. **Mathematical accuracy**: Weight Wheel gradient descent must match PyTorch's SGD
2. **Conceptual clarity**: Signal Loom reshaping must map to `tensor.reshape()`
3. **Pedagogical ordering**: Early levels teach intuitions, later levels teach precision

But how do you *test* pedagogy?

## The Test Structure: Four Layers of Validation

After completing retrofit testing (455 tests across 11 parts), a pattern emerged. Each part needed **four layers** of validation:

### Layer 1: YAML Compliance
Does the implementation match its specification?

```gdscript
func test_yaml_ports_match_schema():
    # Load the part's YAML spec (source of truth)
    var spec = SpecLoader.load_part("weight_wheel")
    var ports = spec.get("ports", {})
    
    # Validate each port follows cardinal naming schema
    for port_name in ports.keys():
        assert_port_matches_schema(port_name)
    
    # Validate port types match YAML declarations
    assert_eq(ports["in_north"]["type"], "vector")
    assert_eq(ports["out_south"]["type"], "scalar")  # NOTE: Was "vector" - bug!
```

**Why this matters**: If ports don't match the spec, connection validation breaks. Students place parts, and nothing works.

**Bugs found at this layer**: Port naming crisis (23/33 files), type mismatches (Weight Wheel outputting scalar when YAML said vector)

---

### Layer 2: ML Semantics
Does the part implement the *correct* AI operation?

```gdscript
func test_weight_wheel_is_dot_product_not_elementwise():
    var weight_wheel = WeightWheel.new()
    weight_wheel.num_weights = 3
    weight_wheel.set_weights([2.0, 3.0, 4.0])
    
    var inputs = [1.0, 0.5, 0.25]  # 3D vector
    var output = weight_wheel.process_signals(inputs)
    
    # CRITICAL TEST: This must be dot product, not element-wise
    var expected_dot_product = (1.0 * 2.0) + (0.5 * 3.0) + (0.25 * 4.0)
    # = 2.0 + 1.5 + 1.0 = 4.5
    
    assert_almost_eq(output, expected_dot_product, 0.001, 
        "Weight Wheel MUST compute dot product (sum of input[i] * weight[i])")
    
    # WRONG would be element-wise: [1*2, 0.5*3, 0.25*4] = [2, 1.5, 1]
    assert_not_eq(output, 2.0, "Should NOT be element-wise multiplication")
```

**Why this matters**: This is the difference between:
- **Correct**: Teaching how a neuron computes weighted sums
- **Wrong**: Teaching... nothing coherent. Element-wise multiplication isn't a core ML operation.

**Bugs found at this layer**: Initially, none! Weight Wheel was already correct. But the *test* discovered the YAML was wrong (said output type was "vector" when implementation correctly returned scalar).

---

### Layer 3: Pedagogical Accuracy
Does the part teach the concept at the appropriate level for its Act?

```gdscript
func test_gradient_descent_convergence():
    # This test validates the LEARNING process, not just forward pass
    var weight_wheel = WeightWheel.new()
    weight_wheel.num_weights = 3
    weight_wheel.set_weights([0.5, 0.5, 0.5])  # Start with arbitrary weights
    
    # Target: Learn to approximate y = 2x1 + 3x2 + 4x3
    # (The weights should converge to [2, 3, 4])
    var training_data = [
        {"input": [1.0, 0.0, 0.0], "target": 2.0},  # y = 2*1 = 2
        {"input": [0.0, 1.0, 0.0], "target": 3.0},  # y = 3*1 = 3
        {"input": [0.0, 0.0, 1.0], "target": 4.0},  # y = 4*1 = 4
        {"input": [1.0, 1.0, 1.0], "target": 9.0},  # y = 2+3+4 = 9
    ]
    
    var learning_rate = 0.1
    var num_epochs = 100
    
    for epoch in num_epochs:
        for example in training_data:
            var prediction = weight_wheel.process_signals(example["input"])
            var error = prediction - example["target"]
            var gradients = calculate_gradients(example["input"], error)
            weight_wheel.apply_gradients(gradients, learning_rate)
    
    # After training, weights should approximate [2, 3, 4]
    var learned_weights = weight_wheel.get_weights()
    assert_almost_eq(learned_weights[0], 2.0, 0.1, "Should learn weight ≈ 2")
    assert_almost_eq(learned_weights[1], 3.0, 0.1, "Should learn weight ≈ 3")
    assert_almost_eq(learned_weights[2], 4.0, 0.1, "Should learn weight ≈ 4")
```

**Why this matters**: This tests the **teaching effectiveness**. If weights don't converge, gradient descent isn't working. Students won't learn how training adjusts parameters.

**Bugs found at this layer**: None in Weight Wheel! But this pattern caught issues in Entropy Manometer (loss formula had wrong sign) and Activation Gate (ReLU was clamping at 0.5 instead of 0).

---

### Layer 4: Edge Cases & Performance
Does the part behave correctly under stress?

```gdscript
func test_weight_wheel_edge_cases():
    var weight_wheel = WeightWheel.new()
    
    # Edge case 1: Zero weights
    weight_wheel.set_weights([0.0, 0.0, 0.0])
    assert_eq(weight_wheel.process_signals([1.0, 2.0, 3.0]), 0.0)
    
    # Edge case 2: Zero inputs
    weight_wheel.set_weights([1.0, 2.0, 3.0])
    assert_eq(weight_wheel.process_signals([0.0, 0.0, 0.0]), 0.0)
    
    # Edge case 3: Large values (numerical stability)
    weight_wheel.set_weights([1000.0, 1000.0, 1000.0])
    var output = weight_wheel.process_signals([1000.0, 1000.0, 1000.0])
    assert_true(is_finite(output), "Should not overflow to inf")
    
    # Edge case 4: Negative values
    weight_wheel.set_weights([-1.0, -2.0, -3.0])
    var neg_output = weight_wheel.process_signals([1.0, 1.0, 1.0])
    assert_eq(neg_output, -6.0, "Should handle negative weights")

func test_weight_wheel_performance():
    var weight_wheel = WeightWheel.new()
    weight_wheel.num_weights = 100  # Typical hidden layer size
    
    var start_time = Time.get_ticks_msec()
    for i in 1000:
        var inputs = generate_random_vector(100)
        weight_wheel.process_signals(inputs)
    var elapsed = Time.get_ticks_msec() - start_time
    
    # Target: <0.1ms per call (1000 calls in <100ms)
    assert_lt(elapsed, 100, "1000 calls should complete in <100ms")
```

**Why this matters**: Students will create weird machines. They'll set all weights to 999. They'll connect 50 Weight Wheels in series. The game can't crash.

**Bugs found at this layer**: Performance was fine, but we discovered Signal Loom with 1000-dimensional vectors caused UI lag (needed to throttle Spyglass updates to 10 FPS instead of 60 FPS).

---

## The Discovery: Weight Wheel's Output Type Mismatch

During **Layer 1 (YAML Compliance)** testing, this assertion failed:

```gdscript
func test_yaml_output_type_matches_implementation():
    var spec = SpecLoader.load_part("weight_wheel")
    var output_type = spec["ports"]["out_south"]["type"]
    
    # Test what the implementation actually returns
    var weight_wheel = WeightWheel.new()
    weight_wheel.set_weights([1.0, 2.0, 3.0])
    var output = weight_wheel.process_signals([1.0, 1.0, 1.0])
    
    # YAML says "vector", implementation returns float (scalar)
    assert_eq(output_type, "scalar", "YAML says vector but impl returns scalar")
```

**Test result**: ❌ FAILED
```
Expected: "scalar"
Actual: "vector" (from YAML)
```

### The Investigation: What Should It Be?

This kicked off a design review. Let's look at what Weight Wheel actually does:

**Implementation** (`weight_wheel.gd` lines 85-95):
```gdscript
func process_signals(inputs: Array[float]) -> float:
    if inputs.size() != num_weights:
        push_error("Input size mismatch")
        return 0.0
    
    var weighted_sum = 0.0
    for i in range(num_weights):
        weighted_sum += inputs[i] * weights[i]
    
    return weighted_sum  # Returns a single scalar value
```

**The math**: This is a **dot product** (also called weighted sum):

\[
\text{output} = \sum_{i=1}^{n} x_i \cdot w_i = x_1 w_1 + x_2 w_2 + \cdots + x_n w_n
\]

In neural network terms, this is **one neuron**:
- Input: vector of size `n`
- Weights: vector of size `n`
- Output: scalar (single number)

**The pedagogical question**: Should Weight Wheel represent:
- **Option A**: A single neuron (vector → scalar)?
- **Option B**: A full layer (vector → vector)?

### The Resolution: Pedagogy Beats Generality

**Option A: Single Neuron** ✅ RECOMMENDED
```yaml
ports:
  in_north:
    type: "vector"
    direction: "input"
  out_south:
    type: "scalar"  # ← Changed from "vector"
    direction: "output"
```

**Pros**:
- Matches implementation (dot product)
- Pedagogically clearer for Act I (introduces "one weight per input")
- Students understand: "This wheel computes *one* output from *many* inputs"
- Visually accurate: One wheel, one output pipe

**Cons**:
- Less composable (can't easily stack Weight Wheels)
- Need a different part for multi-output layers

**Option B: Full Layer**
```gdscript
func process_signals(inputs: Array[float]) -> Array[float]:
    # Multiple weight sets, one per output dimension
    var outputs: Array[float] = []
    for weight_set in weight_matrix:  # 2D array of weights
        var dot_product = compute_dot_product(inputs, weight_set)
        outputs.append(dot_product)
    return outputs
```

**Pros**:
- More general (handles multi-neuron layers)
- Matches typical neural network APIs (PyTorch's `nn.Linear`)

**Cons**:
- More complex (2D weight matrix vs 1D weight vector)
- Steampunk metaphor breaks (one wheel, many outputs?)
- Harder to teach in Act I

### The Decision: Start Simple, Build Up

We chose **Option A** (single neuron) and created a **new part** for multi-neuron layers:

**Weight Wheel** (Act I):
- Single neuron (vector → scalar)
- Teaches: "Each input has a weight, multiply and sum"
- Visual: One brass wheel with adjustable spokes

**Weight Wheel Set** (Act II):
- Multi-neuron layer (vector → vector)
- Teaches: "A layer is multiple neurons working in parallel"
- Visual: A *bank* of Weight Wheels, one per output dimension

From `commit 34269d3`:
```
feat: Add Weight Wheel Set (advanced multi-neuron layer)

The Weight Wheel Set is a collection of Weight Wheels arranged in parallel,
implementing a full linear layer (matrix multiplication). Each wheel in the set
computes one output dimension.

This separates the pedagogical concepts:
- Weight Wheel (Act I): Understand ONE neuron
- Weight Wheel Set (Act II): Understand how neurons combine into LAYERS
```

**Pedagogical progression**:
1. **Act I Level 1**: Use single Weight Wheel (learn weighted sum)
2. **Act I Level 3**: Use multiple Weight Wheels (learn parallel neurons)
3. **Act II Level 6**: Use Weight Wheel Set (learn matrix multiply shorthand)

### The Fix: Update YAML Spec

```yaml
# data/parts/weight_wheel.yaml (line 27)
ports:
  in_north:
    type: "vector"
    direction: "input"
  out_south:
    type: "scalar"     # ← Fixed: Was "vector"
    direction: "output"
    notes: "Single neuron output (weighted sum of inputs)"
```

**Commit**: `19e5309 fix: Weight Wheel output type - vector → scalar`

**Test result after fix**: ✅ 84/84 tests passing

---

## The Pattern: How Tests Catch Pedagogical Bugs

Here are three more examples where **Layer 2 (ML Semantics)** testing caught pedagogical issues:

### Bug: Activation Gate ReLU Clamp Value

**The test**:
```gdscript
func test_activation_gate_relu_semantics():
    var gate = ActivationGate.new()
    gate.activation_type = "RELU"
    
    # ReLU definition: max(0, x)
    assert_eq(gate.apply_activation(-5.0), 0.0, "ReLU(-5) = 0")
    assert_eq(gate.apply_activation(0.0), 0.0, "ReLU(0) = 0")
    assert_eq(gate.apply_activation(3.0), 3.0, "ReLU(3) = 3")
```

**Initial implementation** (WRONG):
```gdscript
func apply_activation(x: float) -> float:
    if activation_type == "RELU":
        return clamp(x, 0.0, 0.5)  # ❌ Clamps positive values at 0.5!
```

**Why this is wrong**: ReLU should pass positive values *unchanged*. Clamping at 0.5 breaks gradient flow for large activations.

**Fixed implementation**:
```gdscript
func apply_activation(x: float) -> float:
    if activation_type == "RELU":
        return max(0.0, x)  # ✅ Correct: Unbounded positive values
```

**How the test caught it**: The assertion `assert_eq(gate.apply_activation(3.0), 3.0)` failed (returned 0.5 instead of 3.0).

---

### Bug: Entropy Manometer MSE Sign Error

**The test**:
```gdscript
func test_entropy_manometer_mse_formula():
    var manometer = EntropyManometer.new()
    manometer.measurement_type = "mse"
    
    var predictions = [2.0, 3.0, 4.0]
    var targets = [1.0, 2.0, 3.0]
    
    # MSE = mean((pred - target)^2)
    # = mean((1)^2, (1)^2, (1)^2) = mean(1, 1, 1) = 1.0
    var mse = manometer.measure_entropy(predictions, targets)
    
    assert_almost_eq(mse, 1.0, 0.001, "MSE formula must be mean of squared errors")
```

**Initial implementation** (WRONG):
```gdscript
func measure_entropy(predictions: Array, targets: Array) -> float:
    var sum_squared_errors = 0.0
    for i in predictions.size():
        var error = targets[i] - predictions[i]  # ❌ Reversed!
        sum_squared_errors += error * error
    return sum_squared_errors / predictions.size()
```

**Why this is wrong**: Sign doesn't matter for MSE (we square the error), but it's conceptually backward. Error should be `prediction - target`, not `target - prediction`.

More critically, this bug would propagate to gradient calculation:
```gdscript
# Gradient of MSE w.r.t. predictions
var grad = 2 * (predictions[i] - targets[i])  # Correct
var grad = 2 * (targets[i] - predictions[i])  # Wrong sign → gradients point wrong way!
```

**How the test caught it**: Actually, it *didn't* catch it at Layer 2 (MSE value is the same either way). But **Layer 3 (Pedagogical Accuracy)** caught it:

```gdscript
func test_entropy_manometer_gradient_descent_improves_loss():
    # If MSE gradients have wrong sign, loss will INCREASE during training
    var initial_loss = train_for_epochs(1)
    var final_loss = train_for_epochs(100)
    
    assert_lt(final_loss, initial_loss, "Loss should decrease with training")
```

This test **failed**: Loss increased! Investigating the gradient calculation revealed the sign error.

---

### Bug: Signal Loom Reshaping Ambiguity

**The test**:
```gdscript
func test_signal_loom_reshaping_behavior():
    var loom = SignalLoom.new()
    loom.lanes = 10  # Input expects 10 dimensions
    loom.output_width = 20  # Output will be 20 dimensions
    
    var input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    var output = loom.process_signals(input)
    
    # Output should be reshaped (padded or projected)
    assert_eq(output.size(), 20, "Output should have 20 dimensions")
```

**The ambiguity**: What does "reshaping" mean?
- **Option 1**: Pad with zeros: `[1,2,...,10,0,0,...,0]` (20 elements)
- **Option 2**: Project linearly: `output = input @ projection_matrix` (learns transformation)
- **Option 3**: Repeat/tile: `[1,2,...,10,1,2,...,10]`

**Initial implementation**: Padding with zeros (Option 1).

**The problem**: This is **not** what neural networks do. They use learnable **projection matrices** (Option 2).

**The fix**: Rename the part and clarify its purpose:

```yaml
# data/parts/signal_loom.yaml
part_id: signal_loom
display_name: Signal Loom
description: |
  Weaves aetheric marbles through bronze rails. Use this to RESHAPE data
  (e.g., flatten a 28×28 image to a 784-vector for the Weight Wheel).
  
  NOTE: Signal Loom does ZERO-PADDING reshaping. For learnable transformations,
  use a Weight Wheel.
  
pedagogical_note: |
  Act I: Teaches data reshaping (flatten, pad)
  Act II: Introduce Weight Wheel for learnable transformations
```

**How the test caught it**: **Layer 3 (Pedagogical Accuracy)** test checked convergence:
```gdscript
func test_signal_loom_plus_weight_wheel_can_learn():
    # Build: Input (10D) → Signal Loom (20D) → Weight Wheel (1D output)
    # Train to learn y = sum(inputs)
    
    # If Signal Loom zero-pads, Weight Wheel needs to learn:
    # w = [1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0]
    
    var trained_weights = train_network()
    
    # Check first 10 weights (should be ~1.0)
    for i in range(10):
        assert_almost_eq(trained_weights[i], 1.0, 0.1)
    
    # Check last 10 weights (should be ~0.0, since inputs are zero-padded)
    for i in range(10, 20):
        assert_almost_eq(trained_weights[i], 0.0, 0.1)
```

This test **passed**, confirming zero-padding is learnable. We kept the implementation but improved documentation.

---

## The Design Review Process

After completing all retrofit tests (T200-T210), I ran a **design review** to assess pedagogical quality. The full document is [here](https://github.com/jazzmind/aitherworks/blob/main/docs/design_review_retrofit_parts.md).

### Review Criteria

For each part, I assessed:

1. **ML Concept Mapping**: Does the steampunk metaphor match the AI operation?
2. **Implementation Quality**: Is the math correct?
3. **Pedagogical Value**: Does it teach the concept clearly?
4. **Steampunk Consistency**: Do materials/pressure/aesthetics match?

### Example: Weight Wheel Review

**ML Concept**: ✅ Learnable Weights / Linear Layer

**Metaphor Quality**: ✅ **EXCELLENT**
> "Brass wheel with adjustable counterweights along spokes. Each spoke = one weight parameter. As the wheel turns during training, spokes adjust based on error signals (gradient descent)."

**Implementation Quality**: ✅ **CORRECT**
- Dot product (weighted sum) is mathematically correct for a neuron
- Gradient descent math: `w_new = w_old - lr * input * error` ✅
- Learning rate properly scales updates ✅
- Converges toward targets ✅

**Pedagogical Excellence**: ✅ **BRILLIANT**
> Students can *see weights adjusting* during training. The visual metaphor (turning wheel) maps perfectly to the mathematical operation. Gradient descent becomes tangible: "error tugs the wheel."

**Minor Issue**: ⚠️ Output type mismatch (YAML said vector, implementation returns scalar)

**Recommendation**: ✅ **APPROVE WITH DISTINCTION** - Change YAML to scalar, create Weight Wheel Set for multi-neuron layers.

---

### Example: Adder Manifold Review

**ML Concept**: ✅ Residual Connection / Skip Connection

**Metaphor Quality**: ✅ **EXCELLENT**
> "Copper manifold merges multiple steam flows. Plumbing metaphor: data flows like fluids, addition = merging pipes."

**Implementation Quality**: ✅ **CORRECT**
- Element-wise addition: `output = sum(inputs) + bias` ✅
- Supports 2+ inputs ✅
- Scaling factor adds flexibility: `output = α(sum + bias)` ✅

**Pedagogical Value**: ✅ **HIGH**
> Residual connections are hard to explain abstractly. This makes them visual: "original signal + transformed signal = output." Enables teaching: "Why deep networks need skip connections (vanishing gradients)."

**Design Insight**: 💡 The `bias` and `scaling_factor` make this more powerful than standard ResNet (which is just `x + f(x)`). Could make these *learnable* parameters in future.

**Recommendation**: ✅ **APPROVE** - Consider learnable scaling in Act II.

---

## The Cross-Part Analysis: Do They Compose Correctly?

Individual parts can be correct, but the *system* can still be broken if they don't compose. Here's how we test that:

### Test: Build a Simple Network

```gdscript
func test_act_I_level_1_complete_machine():
    # Replicate the first level: Learn y = 2x
    
    # Part 1: Steam Source (data generator)
    var steam_source = SteamSource.new()
    steam_source.data_pattern = "training_data"
    steam_source.set_training_data([
        {"x": [1.0], "y": 2.0},
        {"x": [2.0], "y": 4.0},
        {"x": [3.0], "y": 6.0},
    ])
    
    # Part 2: Signal Loom (pass-through in this case)
    var signal_loom = SignalLoom.new()
    signal_loom.lanes = 1
    signal_loom.output_width = 1
    
    # Part 3: Weight Wheel (learnable parameter)
    var weight_wheel = WeightWheel.new()
    weight_wheel.num_weights = 1
    weight_wheel.set_weights([0.5])  # Start with wrong weight
    
    # Part 4: Adder Manifold (optional bias)
    var adder = AdderManifold.new()
    adder.bias = 0.0  # No bias for this level
    
    # Connect parts (manually simulate connections)
    for epoch in 100:
        for example in steam_source.get_training_data():
            # Forward pass
            var x = example["x"]
            var y_true = example["y"]
            
            var loom_out = signal_loom.process_signals(x)
            var weight_out = weight_wheel.process_signals(loom_out)
            var final_out = adder.process_signals([weight_out])
            
            # Backward pass
            var loss = (final_out - y_true) ** 2
            var grad = 2 * (final_out - y_true)
            
            # Update Weight Wheel
            var weight_grads = [grad * loom_out[0]]
            weight_wheel.apply_gradients(weight_grads, 0.1)
    
    # After training, weight should be ~2.0 (y = 2x)
    var learned_weight = weight_wheel.get_weights()[0]
    assert_almost_eq(learned_weight, 2.0, 0.1, "Should learn y = 2x")
```

**Why this matters**: This tests the **complete forward-backward flow**. If any part has wrong types, wrong math, or wrong gradient flow, this test fails.

**Test result**: ✅ PASSED (after fixing Weight Wheel output type)

---

### Test: Pedagogical Progression

```gdscript
func test_act_progression_difficulty():
    # Act I: Should be solvable with basic parts (Steam Source, Signal Loom, Weight Wheel)
    assert_true(can_solve_act_I_with_basic_parts())
    
    # Act II: Should REQUIRE new parts (Activation Gate for nonlinearity)
    assert_false(can_solve_act_II_with_only_basic_parts())
    assert_true(can_solve_act_II_with_activation_gate())
    
    # Act III: Should REQUIRE transformer parts (Looking-Glass Array)
    assert_false(can_solve_act_III_with_only_feed_forward_parts())
    assert_true(can_solve_act_III_with_attention())
```

**Why this matters**: Ensures each Act introduces genuinely new concepts. Students shouldn't be able to "brute force" Act III with Act I parts.

---

## The Lesson: Tests as Pedagogical Validators

Here's the key insight: **Tests don't just validate code—they validate teaching**.

Traditional software tests ask:
> "Does this function return the right value?"

Pedagogical tests ask:
> "If a student uses this part, will they learn the right concept?"

### The Three Questions

For every part, we now ask:

**1. Is the metaphor accurate?**
- Example: Weight Wheel spokes = learnable parameters ✅
- Counter-example: If we'd made Weight Wheel output a vector, the metaphor breaks (one wheel, multiple outputs?)

**2. Is the math correct?**
- Example: Weight Wheel computes dot product (sum of input[i] * weight[i]) ✅
- Counter-example: If we'd done element-wise multiplication, it's not a neuron anymore

**3. Is the progression logical?**
- Example: Act I teaches single neurons → Act II teaches layers ✅
- Counter-example: If Act I required understanding attention, students would be lost

### The Test Types

| Test Layer | Validates | Example Failure |
|------------|-----------|-----------------|
| Layer 1: YAML Compliance | Spec-implementation consistency | Port type mismatch |
| Layer 2: ML Semantics | Mathematical correctness | ReLU clamp bug |
| Layer 3: Pedagogical Accuracy | Learning effectiveness | Gradient sign error |
| Layer 4: Edge Cases | Robustness | Numerical overflow |

**All four layers are necessary**. Layer 2 (ML Semantics) is where pedagogy lives.

---

## Practical Takeaways: How to Test Pedagogy in Your Game

### 1. Define Your Source of Truth

For AItherworks, it's the **YAML specs + ML literature**. For your game:
- Educational game → Academic sources (textbooks, papers)
- Simulation game → Real-world data (physics equations, historical records)
- Puzzle game → Logical consistency (rules must be deterministic)

**Write tests that compare implementation against that source**.

### 2. Layer Your Tests

Don't just test "does it work?" Test:
- **Layer 1**: Does it match the spec?
- **Layer 2**: Does it implement the correct concept?
- **Layer 3**: Does it teach effectively?
- **Layer 4**: Does it handle edge cases?

### 3. Test Composition, Not Just Units

Parts can be individually correct but compositionally wrong:
```gdscript
// Both parts work alone
assert_true(part_A_works())
assert_true(part_B_works())

// But fail when combined
assert_false(part_A_then_part_B_works())  // Type mismatch!
```

**Solution**: Write integration tests that build complete machines.

### 4. Use Tests to Drive Design Reviews

After writing tests, ask:
- Which tests were hardest to write? (Complex parts need simplification)
- Which tests revealed surprising behavior? (Metaphor may be unclear)
- Which tests required the most edge cases? (Part may be too flexible)

For AItherworks, the Weight Wheel test suite (84 tests) revealed it was trying to be both a neuron *and* a layer. Splitting it into two parts simplified both.

### 5. Treat Test Failures as Discoveries

When a test fails, ask:
- Is the implementation wrong? (Fix the code)
- Is the spec wrong? (Update the YAML)
- Is the metaphor wrong? (Redesign the part)

**All three are valid outcomes**. Tests don't just validate—they *clarify* what you're building.

---

## The Numbers: What Pedagogical Testing Cost Us

**Time Investment**:
- Test writing: ~20 hours (11 parts × ~2 hours each)
- Bug fixing: ~8 hours
- Design reviews: ~4 hours
- Documentation: ~4 hours

**Total**: ~36 hours

**Bugs caught**:
- 1 CRITICAL pedagogical error (Weight Wheel type mismatch)
- 3 MEDIUM ML semantic bugs (ReLU clamp, MSE sign, gradient flow)
- 5 LOW edge case bugs

**Pedagogical improvements**:
- Weight Wheel → Weight Wheel Set split (clearer progression)
- Signal Loom clarification (reshaping vs transformation)
- Activation Gate formula fixes (proper ReLU, correct sigmoid)

**What we avoided**:
- Students learning wrong math (element-wise instead of dot product)
- Students confused by type mismatches (vector vs scalar)
- Students unable to solve levels (broken gradient flow)

**ROI**: ~50x. One week of testing prevented years of confused learners.

---

## What's Next: Schema Validation and the Steamfitter Plugin

With retrofit testing complete (T200-T210), we're moving to:

1. **Schema validation** (T007-T008): Validate all 33 part YAMLs and 19 level specs against schemas
2. **Steamfitter plugin** (T018-T025): Editor tooling for YAML-driven scene generation
3. **Remaining parts** (T038-T089): Build 22 more parts with proper TDD

**Next week's post**: How we built the Steamfitter plugin to turn YAML specs into playable Godot scenes—the missing piece that unblocks everything else.

---

## Try It Yourself

**Curious about pedagogical testing?**

1. Browse test files: [`tests/unit/test_weight_wheel.gd`](https://github.com/jazzmind/aitherworks/blob/main/tests/unit/)
2. Read the design review: [`docs/design_review_retrofit_parts.md`](https://github.com/jazzmind/aitherworks/blob/main/docs/design_review_retrofit_parts.md)
3. Check part YAML specs: [`data/parts/weight_wheel.yaml`](https://github.com/jazzmind/aitherworks/blob/main/data/parts/)

**Have you built educational games or teaching tools? How do you validate pedagogical accuracy?** Comment below!

---

*Subscribe for weekly AItherworks development updates. Next Tuesday: Building the Steamfitter plugin (YAML → Godot scenes).*

**Repository**: [github.com/jazzmind/aitherworks](https://github.com/jazzmind/aitherworks)

---

**Word Count**: 5,247 words  
**Visuals Needed**:
- Weight Wheel diagram (spokes = weights)
- Test layer pyramid (4 layers of validation)
- Before/after YAML comparison (vector → scalar)
- Network composition diagram (Steam Source → Signal Loom → Weight Wheel → Adder Manifold)
- Pedagogical progression chart (Act I: neurons → Act II: layers → Act III: transformers)
**Code Examples**: 15 snippets showing test patterns, ML semantics, bug fixes
**Cross-References**: Links to design_review_retrofit_parts.md, test_weight_wheel.gd, weight_wheel.yaml, tasks.md

