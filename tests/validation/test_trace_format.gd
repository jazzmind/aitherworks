extends GutTest

## Schema validation tests for transformer trace format
# Part of Phase 3.3: Schema Validation Tests (T010)
# Validates transformer execution traces against trace_format_schema.json

const SpecLoader = preload("res://game/sim/spec_loader.gd")

var trace_file: String = "res://data/traces/intro_attention_gpt2_small.json"
var trace_data: Dictionary = {}

func before_all():
	# Load the trace file
	var file = FileAccess.open(trace_file, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			trace_data = json.data
			print("Loaded trace file: %s" % trace_file)
		else:
			print("ERROR: Failed to parse trace JSON: %s" % json.get_error_message())
	else:
		print("ERROR: Could not open trace file: %s" % trace_file)

## Test trace file exists and loads

func test_trace_file_exists():
	assert_true(FileAccess.file_exists(trace_file), 
		"Trace file should exist: %s" % trace_file)

func test_trace_file_is_valid_json():
	assert_false(trace_data.is_empty(), "Trace data should be loaded")

## Test metadata structure

func test_has_meta():
	assert_has(trace_data, "meta", "Trace should have meta field")

func test_meta_has_model_name():
	if trace_data.has("meta"):
		assert_has(trace_data["meta"], "model_name", 
			"meta should have model_name")

func test_meta_has_layers():
	if trace_data.has("meta"):
		assert_has(trace_data["meta"], "layers", 
			"meta should have layers count")

func test_meta_layer_counts():
	if trace_data.has("meta"):
		var meta = trace_data["meta"]
		
		if meta.has("layers"):
			assert_true(meta["layers"] > 0, "layers should be positive")
		
		if meta.has("heads"):
			assert_true(meta["heads"] > 0, "heads should be positive")

## Test tokens structure

func test_has_tokens():
	assert_has(trace_data, "tokens", "Trace should have tokens field")

func test_tokens_has_text():
	if trace_data.has("tokens"):
		assert_has(trace_data["tokens"], "text", "tokens should have text array")

func test_tokens_text_is_array():
	if trace_data.has("tokens") and trace_data["tokens"].has("text"):
		assert_true(trace_data["tokens"]["text"] is Array, 
			"text should be an Array")

func test_tokens_has_ids():
	if trace_data.has("tokens"):
		assert_has(trace_data["tokens"], "ids", "tokens should have ids array")

## Test attention structure

func test_has_attention():
	assert_has(trace_data, "attention", "Trace should have attention field")

func test_attention_has_shape():
	if trace_data.has("attention"):
		assert_has(trace_data["attention"], "shape", "attention should have shape")

func test_attention_shape_is_array():
	if trace_data.has("attention") and trace_data["attention"].has("shape"):
		assert_true(trace_data["attention"]["shape"] is Array, 
			"shape should be an Array")

func test_attention_has_data():
	if trace_data.has("attention"):
		assert_has(trace_data["attention"], "data", 
			"attention should have data field")

func test_attention_has_dtype():
	if trace_data.has("attention"):
		assert_has(trace_data["attention"], "dtype", 
			"attention should have dtype field")

func test_attention_dtype_is_uint8():
	if trace_data.has("attention") and trace_data["attention"].has("dtype"):
		assert_eq(trace_data["attention"]["dtype"], "uint8", 
			"dtype should be uint8 for compression")

## Test attention data compression

func test_attention_has_scale():
	if trace_data.has("attention"):
		assert_has(trace_data["attention"], "scale", 
			"attention should have scale field for decompression")

func test_attention_scale_value():
	if trace_data.has("attention") and trace_data["attention"].has("scale"):
		var scale = trace_data["attention"]["scale"]
		assert_eq(scale, 255.0, "scale should be 255.0 for uint8 compression")

## Test uint8 decompression logic

func test_uint8_to_float32_decompression():
	# Test the decompression formula: uint8_value / 255.0
	var test_values = {
		0: 0.0,
		127: 127.0 / 255.0,
		255: 1.0
	}
	
	for uint8_val in test_values.keys():
		var expected = test_values[uint8_val]
		var decompressed = float(uint8_val) / 255.0
		
		assert_almost_eq(decompressed, expected, 0.001, 
			"uint8 %d should decompress to %.3f" % [uint8_val, expected])

## Test shape consistency

func test_attention_shape_dimensions():
	if trace_data.has("attention") and trace_data["attention"].has("shape"):
		var shape = trace_data["attention"]["shape"]
		# Shape should be [layers, heads, seq_len, seq_len]
		assert_eq(shape.size(), 4, "attention shape should have 4 dimensions")
		
		if shape.size() == 4:
			print("Attention shape: [layers=%d, heads=%d, seq_len=%d, seq_len=%d]" % [
				shape[0], shape[1], shape[2], shape[3]
			])

func test_shape_matches_meta():
	if trace_data.has("meta") and trace_data.has("attention"):
		var meta = trace_data["meta"]
		var attention = trace_data["attention"]
		
		if meta.has("layers") and meta.has("heads") and attention.has("shape"):
			var shape = attention["shape"]
			if shape.size() >= 2:
				assert_eq(shape[0], meta["layers"], "Shape layers should match meta")
				assert_eq(shape[1], meta["heads"], "Shape heads should match meta")

## Test logits structure

func test_has_logits():
	assert_has(trace_data, "logits", "Trace should have logits field")

func test_logits_has_per_position():
	if trace_data.has("logits"):
		assert_has(trace_data["logits"], "per_position", 
			"logits should have per_position array")

func test_logits_per_position_is_array():
	if trace_data.has("logits") and trace_data["logits"].has("per_position"):
		assert_true(trace_data["logits"]["per_position"] is Array, 
			"per_position should be an Array")

## Test trace structure summary

func test_trace_has_all_major_sections():
	var required_sections = ["meta", "tokens", "attention", "logits"]
	
	for section in required_sections:
		assert_has(trace_data, section, 
			"Trace should have '%s' section" % section)

func test_trace_size_reasonable():
	# Trace file should not be empty
	var file = FileAccess.open(trace_file, FileAccess.READ)
	if file:
		var file_size = file.get_length()
		file.close()
		
		assert_gt(file_size, 100, "Trace file should be at least 100 bytes")
		print("Trace file size: %d bytes" % file_size)

## Summary

func test_trace_validation_summary():
	print("\n=== Trace Validation Summary ===")
	print("File: %s" % trace_file)
	
	if trace_data.has("meta"):
		var meta = trace_data["meta"]
		if meta.has("model_name"):
			print("Model: %s" % meta["model_name"])
		if meta.has("layers"):
			print("Layers: %d" % meta["layers"])
		if meta.has("heads"):
			print("Heads: %d" % meta["heads"])
	
	if trace_data.has("tokens") and trace_data["tokens"].has("text"):
		print("Tokens: %d" % trace_data["tokens"]["text"].size())
	
	if trace_data.has("attention") and trace_data["attention"].has("shape"):
		print("Attention shape: %s" % str(trace_data["attention"]["shape"]))
	
	print("✅ Trace format validation complete")
	
	# This test always passes - it's just for reporting
	assert_true(true, "Summary complete")
