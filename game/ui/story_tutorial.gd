
func start_level_chapter(level_id: String) -> void:
	if level_id == "act_I_l1_dawn_in_dock_ward":
		_add_chat_message("master_cogwright", "Master Cogwright", "For this trial, keep steam modest and inference quick. When ready, press Evaluate.")
	elif level_id == "act_I_l3_the_manometer_hisses":
		_add_chat_message("aether_sage", "Aether Sage", "Watch dye flow back. Tune LR, then Evaluate to convince the Inspectorate.")