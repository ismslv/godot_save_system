# © 2023 Ilya S <ilya.s@fmlht.com>
# https://github.com/ismslv/

extends Node

# Use ".tres" if you want human readable file
# File paths are described in:
# https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
var file_template = "user://%s.res"
var file_config = "res://config.cfg"
var file_config_default = "res://configs_default.cfg"
var loaded_data: SaveGame = null
var config = ConfigFile.new()


## SAVES
# You can easily implement multiple files system
# or custom file names by supplying different file_name.
# It can also be used to implement autosave or quicksave
# by naming files accordingly.
# For example, save files can be named 2023-10-03-12-58-00-(auto)save.tres,
# whereas single quicksave file will be quicksave.tres

func game_save(file_name):
	# Show overlay
	get_node("/root/main/Overlay").show()
	get_node("/root/main/Overlay/Back/Label").text = "SAVING..."
	
	# Create a new resource
	var save_data = SaveGame.new()
	# Fill it with data
	# You can Fill it from here or send to several other classes
	save_data = get_node("/root/main").save_data(save_data)
	
	# You can use ResourceSaver.FLAG_COMPRESS as a third argument
	var result = ResourceSaver.save(save_data, file_template % file_name)
	if result == OK:
		print("Saved game to " + file_template % file_name + "!")
	else:
		print("Error saving file!")
	
	# Hide overlay
	await get_tree().create_timer(0.5).timeout
	get_node("/root/main/Overlay").hide()


func game_load(file_name):
	# Check if file exists
	if ResourceLoader.exists(file_template % file_name):
		# Show overlay
		get_node("/root/main/Overlay").show()
		get_node("/root/main/Overlay/Back/Label").text = "LOADING..."
		
		# Load file
		var save_data = ResourceLoader.load(file_template % file_name)
		# Check if file is loaded correctly as a resource of a needed type
		if save_data is SaveGame:
			print("Loaded game!")
			
			# Put loaded data into persistent static variable
			loaded_data = save_data
			
			# Reload scene (it will load all the data on ready)
			await get_tree().create_timer(0.5).timeout
			get_tree().reload_current_scene()
		else:
			print("Error loading!")
	else:
		print("File not found!")


## CONFIGS
# Config file is not saved with the game,
# because it is normally saved each time you change settings
# in the game's menu.


func config_save():
	# Just saving config file
	var result = config.save(file_config)
	if result != OK:
		print("Config saving error!")
	
	
func config_load(file = file_config):
	# Load config file
	var result = config.load(file)
	if result == OK:
		# Call scene root node to apply loaded configs
		get_node("/root/main").configs_load()
	return result
