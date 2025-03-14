class_name WaveDisplay
extends WavePanel


func _on_wave_changed()->void:
	wave = wave_count_resource.value + 1
	label.text = "Wave: %d" % wave
	tweened_node.rotation = randf_range(-PI *0.1, PI * 0.1)
	tweened_node.scale = Vector2(1.2, 1.2)
	if tween != null:
		tween.kill
	tween = create_tween()
	tween.tween_property(tweened_node, "rotation", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(tweened_node, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
