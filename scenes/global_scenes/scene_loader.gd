extends Node

# script global để load scenes
@onready var loading_screen_scene = preload("res://scenes/loading/loading_scene.tscn")

var scene_to_load_path
var loading_screen_scene_instance
var loading = false
var load_start_time = 0.0
var min_loading_time = 1.0 # thời gian tối thiểu 1 giây cho loading_scene

func load_scene(path):
	var current_scene = get_tree().current_scene

	loading_screen_scene_instance = loading_screen_scene.instantiate()
	get_tree().root.call_deferred("add_child", loading_screen_scene_instance)

	if ResourceLoader.has_cached(path):
		ResourceLoader.load_threaded_get(path)
	else:
		ResourceLoader.load_threaded_request(path)

	current_scene.queue_free()
	loading = true
	scene_to_load_path = path
	load_start_time = Time.get_ticks_msec() / 1000.0 # Ghi lại thời điểm bắt đầu bằng mili giây

func _process(delta):
	if not loading:
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(scene_to_load_path, progress)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var progress_bar = loading_screen_scene_instance.get_node("ProgressBar")
		progress_bar.value = clamp(progress[0] * 100, 0, 99) # Giới hạn progress từ 0 đến 99%
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		# Đảm bảo loading_scene hiển thị ít nhất 1 giây
		if (Time.get_ticks_msec() / 1000.0) - load_start_time >= min_loading_time:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_to_load_path))
			loading_screen_scene_instance.queue_free()
			loading = false
		else:
			# Chờ thêm để đạt thời gian tối thiểu
			var progress_bar = loading_screen_scene_instance.get_node("ProgressBar")
			progress_bar.value = 99
	else:
		print("Loading went wrong...")
