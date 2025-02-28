extends Node3D

var showing_menu := false

func _enter_tree():
	AudioServer.set_bus_volume_db(0, -24)
	%MainMenu.modulate.a = 0.0


func _ready():	
	$WorldEnvironment.environment.adjustment_brightness = 0.01
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var tween = get_tree().create_tween()
	tween.tween_property($WorldEnvironment.environment, "adjustment_brightness", 1, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.4)
	tween.parallel().tween_method(func(v):AudioServer.set_bus_volume_db(0, v), -24, 0, 3)
	
	%MSAAOptionButton.add_item("Disabled", 0)
	%MSAAOptionButton.add_item("2x", 1)
	%MSAAOptionButton.add_item("4x", 2)
	%MSAAOptionButton.add_item("8x", 3)
	%MSAAOptionButton.select(0)
	%GeneralQualityOptionButton.add_item("Low", 0)
	%GeneralQualityOptionButton.add_item("Medium", 1)
	%GeneralQualityOptionButton.add_item("High", 2)
	%GeneralQualityOptionButton.add_item("Ultra", 3)
	%GeneralQualityOptionButton.select(2)
	_on_general_quality_option_button_item_selected(2)
	
	get_tree().get_nodes_in_group("player_camera")[0].make_current()
	get_tree().get_nodes_in_group("player")[0].is_active = true
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _physics_process(delta):
	%FPSLabel.text = "FPS: %s" % Engine.get_frames_per_second()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_menu(!showing_menu)


var menu_tween : Tween
func show_menu(_show:bool):
	showing_menu = _show
	if not showing_menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if menu_tween:
			menu_tween.kill()
		menu_tween = get_tree().create_tween()
		menu_tween.tween_property(%MainMenu, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		menu_tween.tween_callback(%MainMenu.hide).set_delay(0.2)
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		%UI.show()
		%Settings.hide()
		%MainMenu.show()
		%ResumeButton.grab_focus()
		if menu_tween:
			menu_tween.kill()
		menu_tween = get_tree().create_tween()
		menu_tween.tween_property(%MainMenu, "modulate:a", 1, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)



func _on_resume_button_pressed():
	show_menu(false)

func _on_quit_button_pressed():
	var tween = get_tree().create_tween()
	tween.tween_property($WorldEnvironment.environment, "adjustment_brightness", 0.01, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(%MainMenu, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_method(func(v):AudioServer.set_bus_volume_db(0, v), 0, -24, 0.5)
	tween.finished.connect(func():get_tree().quit())


func _on_w_full_screen_check_box_pressed():
	if %FullScreenCheckBox.button_pressed:
		%FullScreenCheckBox.button_pressed = false
	if %WFullScreenCheckBox.button_pressed:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_full_screen_check_box_pressed():
	if %WFullScreenCheckBox.button_pressed:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		%WFullScreenCheckBox.button_pressed = false
	if %FullScreenCheckBox.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fps_check_box_pressed():
	%FPSLabel.visible = %FPSCheckBox.button_pressed


func _on_fxaa_button_pressed():
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if %FXAAButton.button_pressed else Viewport.SCREEN_SPACE_AA_DISABLED


func _on_temporal_button_pressed():
	get_viewport().use_taa = %TemporalButton.button_pressed


func _on_render_resolution_slider_value_changed(value):
	%RenderResolutionLabel.text = "Render Scale: %s%%" % str(round(value*100))
	get_viewport().scaling_3d_scale = value
	%FXAAButton.disabled = value > 1.0


func _on_msaa_option_button_item_selected(index):
	get_viewport().msaa_3d = index


var settings := {
	"positional_shadow_atlas_size": [1024, 2048, 4096, 8192],
	"pos_soft_shadow_filter_quality": [1, 2, 4, 4],
	"directional_shadow_atlas_size": [2048, 2048, 4096, 8192],
	"dir_soft_shadow_filter_quality": [1, 2, 4, 4],
	"ray_count": [
		RenderingServer.ENV_SDFGI_RAY_COUNT_16,
		RenderingServer.ENV_SDFGI_RAY_COUNT_32,
		RenderingServer.ENV_SDFGI_RAY_COUNT_64,
		RenderingServer.ENV_SDFGI_RAY_COUNT_128],
	"voxel_gi": [
		RenderingServer.VOXEL_GI_QUALITY_LOW,
		RenderingServer.VOXEL_GI_QUALITY_LOW,
		RenderingServer.VOXEL_GI_QUALITY_HIGH,
		RenderingServer.VOXEL_GI_QUALITY_HIGH
	],
	"gi_half_res": [
		true,
		true,
		false,
		false,
	]
}

func _on_general_quality_option_button_item_selected(index):
	RenderingServer.positional_soft_shadow_filter_set_quality(settings.pos_soft_shadow_filter_quality[index])
	RenderingServer.directional_soft_shadow_filter_set_quality(settings.dir_soft_shadow_filter_quality[index])
	RenderingServer.gi_set_use_half_resolution(settings.gi_half_res[index])
	RenderingServer.directional_shadow_atlas_set_size(settings.directional_shadow_atlas_size[index], true)
	RenderingServer.environment_set_sdfgi_ray_count(settings.ray_count[index])
	RenderingServer.voxel_gi_set_quality(settings.voxel_gi[index])
	get_viewport().positional_shadow_atlas_size = settings.positional_shadow_atlas_size[index]


func _on_settings_button_pressed():
	%UI.hide()
	%Settings.show()
	%WFullScreenCheckBox.grab_focus()


func _on_close_settings_button_pressed():
	%UI.show()
	%Settings.hide()
	%ResumeButton.grab_focus()


func _on_volumentric_fog_checkbox_pressed():
	$WorldEnvironment.environment.volumetric_fog_enabled = %VolumentricFogCheckbox.button_pressed
	$WorldEnvironment.environment.adjustment_saturation = 1.02 if %VolumentricFogCheckbox.button_pressed else 0.95
	$WorldEnvironment.environment.adjustment_contrast = 1.02 if %VolumentricFogCheckbox.button_pressed else 0.95


func _on_v_sync_enable_check_box_pressed():
	var vsync_mode = DisplayServer.VSYNC_DISABLED if not %VSyncEnableCheckBox.button_pressed else DisplayServer.VSYNC_ENABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)


func _on_ssao_checkbox_pressed():
	$WorldEnvironment.environment.ssao_enabled = %SSAOCheckbox.button_pressed
