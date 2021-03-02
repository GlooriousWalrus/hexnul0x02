extends Panel

func _physics_process(delta):
	$HBoxContainer/VBoxContainer/Stat1.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
	$HBoxContainer/VBoxContainer/Stat2.text = "Memory Static: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC)/1024/1024)) + " MB"
#	$HBoxContainer/VBoxContainer/Stat3.text = "Memory Dynamic: " + str(round(Performance.get_monitor(Performance.MEMORY_DYNAMIC)/1024/1024)) + " MB"
	$HBoxContainer/VBoxContainer/Stat4.text = "VRAM: " + str(round(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)/1024/1024)) + " MB"
	$HBoxContainer/VBoxContainer/Stat5.text = "Draw Calls: " + str(Performance.get_monitor(Performance.RENDER_DRAW_CALLS_IN_FRAME))
	$HBoxContainer/VBoxContainer/Stat6.text = "Render Objects: " + str(Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME))
	$HBoxContainer/VBoxContainer/Stat3.text = "Shader Changes: " + str(Performance.get_monitor(Performance.RENDER_SHADER_CHANGES_IN_FRAME))
#
func _ready():
	update_size()
	get_viewport().connect("size_changed", self, "update_size")

func update_size():
	var vport_rect = get_viewport_rect()
	self.rect_position = vport_rect.position + Vector2(8,8)
	#+ vport_rect.size - self.rect_size 
