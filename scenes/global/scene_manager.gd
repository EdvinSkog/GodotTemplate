extends CanvasLayer

func switch_scene(target: String, fade_multiplier: float = 1) -> void:
	$AnimationPlayer.speed_scale = fade_multiplier
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play_backwards("dissolve")

func quit_game():
	#await $AnimationPlayer.play("quit")
	get_tree().quit()
