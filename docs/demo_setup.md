# AItherworks Demo Setup Guide - Act I Level 1

## Dawn in Dock-Ward Demo

This guide shows how to set up the first level to demonstrate the game's core mechanics.

### Objective
Build a Signal Loom and use Weight Wheels to match a target 3-lane pattern: [0.5, 1.0, -0.5]

### Part Setup

1. **Steam Source** (Input)
   - Generates the input data for your contraption
   - Has one output port: `steam_out`
   - Configure to generate appropriate test patterns

2. **Signal Loom** (Processing)
   - Processes raw input into structured signals
   - Has one input port: `signal_in` and one output: `signal_out`
   - Connect Steam Source output to Signal Loom input

3. **Weight Wheel** (Processing)
   - Scales the signals by adjustable weights
   - Has one input port: `signal_in` and one output: `weighted_out`
   - Connect Signal Loom output to Weight Wheel input
   - Adjust weights to match target pattern

4. **Display Glass** (Output)
   - Shows the final output values
   - Has one input port: `signal_in`
   - Connect Weight Wheel output to see results
   - Can switch between numeric, gauge, and waveform display modes

5. **Evaluator** (Output)
   - Compares output against expected values
   - Has one input port: `actual_in`
   - Shows green light when output matches expected (within tolerance)
   - Shows red light when output is incorrect
   - Configure expected values to match target pattern

### Connection Flow
```
Steam Source → Signal Loom → Weight Wheel → Display Glass
                                          ↘
                                            Evaluator
```

### Demo Tips

1. Start by placing all components from the part palette
2. Connect them in order using the node graph interface
3. Double-click components to inspect and adjust parameters
4. Run forward pass to see data flow through the system
5. Adjust Weight Wheel values to match target pattern
6. Watch Evaluator light turn green when successful
7. Use Display Glass to visualize the output in different modes

### Success Criteria
- Evaluator shows green light (output matches target within tolerance)
- Display Glass shows values close to [0.5, 1.0, -0.5]
- All connections are properly established

This demonstrates:
- Visual programming interface
- Data flow through neural network components
- Real-time parameter adjustment
- Success/failure feedback
- Steampunk aesthetic and theming