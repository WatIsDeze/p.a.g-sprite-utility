# Extends Control.
extends Control

################################################################################
# Initialize globals node.                                                     #
################################################################################
onready var globals = get_node("/root/globals")

################################################################################
# Preloaded external classes.                                                  #
################################################################################
var ColorMapper = load("res://scripts/color_mapper.gd").ColorMapper

################################################################################
# Global Node Variables.                                                       #
################################################################################
################################################################################
## TODO: Move most of the code to where it belongs, possibly make use of the  ##
## easy singleton method to at least get certain global data appropriately    ##
## throughout the applications.                                               ##
################################################################################
## Palette list.
var palette_list = {"default" : []}
	
###### 
# Current global state variables.
######
# Current image texture.
var cur_image_texture = null

# Current Palette index and name.
var cur_selected_palette_idx = 0
var cur_selected_palette_name = "default"

# Current Palette selected color index.
var cur_selected_palette_color_idx = -1

###### 
# Map Color dialogue globals.
######
# Selected source map palette index and name.
var cur_source_selected_palette_idx = 0
var cur_source_selected_palette_name = "default"
# Destination source map palette index and name.
var cur_destination_selected_palette_idx = 0
var cur_destination_selected_palette_name = "default"

##############
# TODO: Remove colors for test palettes in case bugs arrise for the test sprite.
# Source: Shirt: { #2F3F56, #273243, #1E2734 }, Haircut: { #455C60, #304245, #293537, #202B2E }
# Destination: Shirt: { #C9BD20, #AA9F07, #534D00 }, Haircut: { #E26E23, #C45107, #A54100, #863500 }
##############

# Ready function.
func _ready():
	# Initialize the base image.
	cur_image_texture = null
	
	# Setup the sprite node to apply this texture.
	var node_background_sprite = get_node("ui/panel_content/container_scroll_area/background_sprite")
	get_node("ui/panel_content/container_scroll_area/background_sprite").set_texture(cur_image_texture)
	
	# Setup the UI data.
	ui_load_palette_list_data()
	
	# Setup the UI signals.
	ui_connect_signals()
	
	# Add the .png files to the filed dialog manager.
	get_node("ui/panel_content/dialog_filemanager").add_filter("*.png")
	
	# TODO: Find a simpler solution for the TODO below, because the problem
	#       is that the indices otherwise do not match.
	# TODO: This code does thus not belong here. But it fixes it... ? LOL.
	# Retreive the current selected index from the key list for default.
	cur_selected_palette_idx = palette_list.keys().find("default")
	cur_source_selected_palette_idx = palette_list.keys().find("default")
	cur_destination_selected_palette_idx = palette_list.keys().find("default")
	
	# Setup the scroll container properties.
	var node_container_scroll_area = get_node("ui/panel_content/container_scroll_area")

	# Update the UI palette.
	ui_update_palette_list()
	
	# Update the UI color list.
	ui_update_palette_color_list()

# Handle application notification callbacks.
func _notification(what):
	# OnResize event.
	if (what == NOTIFICATION_RESIZED):
		# Retrieve the viewport rectangle size.
		var viewport_size = get_viewport_rect().size
		
		# Calculate the center position for the background grid and position it.
		var center_pos = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		var node_background_sprite = get_node("ui/panel_content/container_scroll_area/background_sprite")
		var node_background_grid = get_node("ui/panel_content/container_scroll_area/background_grid")
		
		# Calculate the center position for the background sprite and position it.
		node_background_sprite.set_pos(center_pos)
		
		#if (get_node("background_sprite").get_texture() != null):
		#	node_background_grid.set_pos(center_pos + (get_node("background_sprite").get_texture().get_size() / 2))
		# Center position the background grid.
		node_background_grid.set_pos(node_background_sprite.get_pos() - (node_background_grid.get_size() / 2))

		# Resize the main UI to our viewport size.
		set_size(Vector2(viewport_size.width, viewport_size.height))
		
################################################################################
# Image Manipulation Functionality.                                            #
################################################################################
func map_selected_palettes():
	if (cur_image_texture == null):
		# TODO: SHOW ERROR.
		print("Error: No cur_image")
		return
	
	# TODO: Remove.
	printt("cur_source_selected_palette_name = " + cur_source_selected_palette_name)
	printt("cur_destination_selected_palette_name = " + cur_destination_selected_palette_name)
	printt(palette_list)

	# TODO: Report error if not there, otherwise, map colors and assign a new image.
	if (palette_list.has_all([cur_source_selected_palette_name, cur_destination_selected_palette_name])):
		# Now that the image is loaded, we will try and make use of the colormapper.
		var cm = ColorMapper.new()
		cm.add_color_array(cur_source_selected_palette_name, palette_list[cur_source_selected_palette_name])
		cm.add_color_array(cur_destination_selected_palette_name, palette_list[cur_destination_selected_palette_name])
		var new_img = cm.exchange(cur_image_texture.get_data(), cur_source_selected_palette_name, cur_destination_selected_palette_name)
	
		# Assign it to a new texture.
		cur_image_texture = ImageTexture.new()
		cur_image_texture.create_from_image(new_img)
	
	# Setup the sprite node to apply this texture.
	var node_background_sprite = get_node("ui/panel_content/container_scroll_area/background_sprite")
	node_background_sprite.set_texture(cur_image_texture)

################################################################################
# Palette Functionality.                                                       #
################################################################################
# Adds a palette with the given name to the list in case it does not exist.
# Returns false on failure.
func sort_palette_list(a, b):
	# Quicksort.
	if (a < b or b > a):
		return true
	else:
		return false
	
# Create a new palette in case it doesn't exist yet.
func new_palette(palette_name):
	# No duplicates allowed.
	if (palette_list.has(palette_name)):
		printt("ERROR: No duplicate palette names are allowed.") # TODO: Display kindly.
		return false
	
	# Add an empty color array to the list.
	palette_list[palette_name] = []
	
	# Resort the list.
	palette_list.keys().sort_custom(self, "sort_palette_list")

	# Retreive the name of the selected palette, and its current index in the map.
	cur_selected_palette_idx = palette_list.keys().find(palette_name)
	cur_selected_palette_name = palette_name
	
	# Update the ui palette list.
	ui_update_palette_list()
	
	# Return true.
	return true
	
################################################################################
# UI Base Functionality.                                                       #
################################################################################
# Connect all base UI signals.
func ui_connect_signals():
	## File Menu.
	# Retreive the file menu item and connect the corresponding signal.
	get_node("ui/PanelContainer/panel_main_menu/menu_file").get_child(0).connect("item_pressed", self, "ui_signal_pressed_file")
	
	## Palette Menu.
	# Retreive the palette menu item and connect the corresponding signal.
	get_node("ui/PanelContainer/panel_main_menu/menu_palettes").get_child(0).connect("item_pressed", self, "ui_signal_pressed_palettes")
	
	## Edit Palette Dialogue signals.
	get_node("ui/panel_content/dialog_edit_palettes/button_new_palette").connect("pressed", self, "ui_signal_button_new_palette")
	get_node("ui/panel_content/dialog_edit_palettes/button_delete_palette").connect("pressed", self, "ui_signal_button_delete_palette")
	get_node("ui/panel_content/dialog_edit_palettes/button_cancel_palette").connect("pressed", self, "ui_signal_button_cancel_palette")
	get_node("ui/panel_content/dialog_edit_palettes/button_save_palette").connect("pressed", self, "ui_signal_button_save_palette")
	get_node("ui/panel_content/dialog_edit_palettes/palette_name").connect("item_selected", self, "ui_signal_palette_name_selected")
	get_node("ui/panel_content/dialog_edit_palettes/list_colors").connect("item_selected", self, "ui_signal_list_color_selected")
	get_node("ui/panel_content/dialog_edit_palettes/button_add_color").connect("pressed", self, "ui_signal_button_add_color")
	get_node("ui/panel_content/dialog_edit_palettes/button_remove_color").connect("pressed", self, "ui_signal_button_remove_color")
	
	## Confirm Palette add dialogue signal.
	get_node("ui/panel_content/dialog_add_palette").connect("confirmed", self, "ui_signal_button_confirm_new_palette")
	
	## Map Color Dialogue signals.
	get_node("ui/panel_content/dialog_map_palettes/source_palette_name").connect("item_selected", self, "ui_signal_source_palette_name_selected")
	get_node("ui/panel_content/dialog_map_palettes/destination_palette_name").connect("item_selected", self, "ui_signal_destination_palette_name_selected")
	get_node("ui/panel_content/dialog_map_palettes").connect("confirmed", self, "ui_signal_button_confirm_map_palettes")
	
	## Update the ui palette list for the edit palettes dialogue.
	ui_update_palette_list()
	ui_update_palette_color_list()
	
# Update the UI palette dialogue list.
func ui_update_palette_list():
	##
	### TODO: Make a single function for every list in the app instead.
	##
	### Clear the list-(s).
	# Edit Palette dialogue name list.
	var node_edit_palettes_palette_name = get_node("ui/panel_content/dialog_edit_palettes/palette_name")
	node_edit_palettes_palette_name.clear()
	
	## Map Color - Source Palette name list.
	var node_map_palettes_source_palette_name = get_node("ui/panel_content/dialog_map_palettes/source_palette_name")
	node_map_palettes_source_palette_name.clear()
	
	## Map Color - Destination Palette name list.
	var node_map_palettes_destination_palette_name = get_node("ui/panel_content/dialog_map_palettes/destination_palette_name")
	node_map_palettes_destination_palette_name.clear()
	
	var name_index = 0
	
	# Add to list while incrementing index.
	for name in palette_list:
		# Edit Palette dialogue name list.
		node_edit_palettes_palette_name.add_item(name, name_index)
		
		## Map Color - Source Palette name list.
		node_map_palettes_source_palette_name.add_item(name, name_index)
		
		## Map Color - Destination Palette name list.
		node_map_palettes_destination_palette_name.add_item(name, name_index)
		
		# Increment Index ID.
		name_index += 1
		
	# Auto select the cur_selected_palette_IDX
	node_edit_palettes_palette_name.select(cur_selected_palette_idx)
	node_map_palettes_source_palette_name.select(cur_source_selected_palette_idx)
	node_map_palettes_destination_palette_name.select(cur_destination_selected_palette_idx)

# Update the palette color list using the selected palette.
# Returns false on failure.
func ui_update_palette_color_list():
	if (!palette_list.has(cur_selected_palette_name)):
		# TODO: ERROR
		print("ERROR: The palette chosen is non existent at this time.")
		return false
	
	# Retreive node.
	var node_list_colors = get_node("ui/panel_content/dialog_edit_palettes/list_colors")
	
	# Clear node list.
	node_list_colors.clear()
	
	# Refill node list with appropriate items.
	for i in palette_list[cur_selected_palette_name]:
		# Retreive he color to store.
		var img_color = Image(16, 16, false, Image.FORMAT_RGBA)
		
		# TODO: Solve this to be more efficient.
		# idk how, but will render it by pixel per pixel for cheapskate
		for x in range(0, 16):
			for y in range(0, 16):
				img_color.put_pixel(x, y, Color(i))
		
		# Allocate a texture for it.
		var tex_color_icon = ImageTexture.new()
		tex_color_icon.create_from_image(img_color)
		
		# Retreive list node and add it.
		node_list_colors.add_item(Color(i).to_html(), tex_color_icon, true)
	
	# Reset the selected current color index value.
	cur_selected_palette_color_idx = -1
	
	return true
	
# Save the palette list data.
func ui_save_palette_list_data():
	# Allocate file for write access, whether there or not.
	var file_palette_list = File.new()
	file_palette_list.open("res://palette_list.json", File.WRITE)
	
	# Conver the palette list to JSON, and store it.
	var json_str = palette_list.to_json()
	file_palette_list.store_string(json_str)
	
	# Close the file_palette_list file.
	file_palette_list.close()
	return true

## Take NOTE of the NOTE below. NOTEs might then not overflow.
# Load the palette list data. (NOTE: This does NOT, update the UI data lists).
func ui_load_palette_list_data():
	# Allocate file for write access, whether there or not.
	var file_palette_list = File.new()
	file_palette_list.open("res://palette_list.json", File.READ)
	
	# Make sure it exists.
	if (!file_palette_list.is_open()):
		return false
		
	# Retreive the file as text.
	var file_data_str = file_palette_list.get_as_text()
	
	# Close the file_palette_list file.
	file_palette_list.close()
	
	# Convert the file_data_str to json and assign it to the palette dictionary.
	palette_list.parse_json(file_data_str)
	
	return true
	
################################################################################
# UI Signal Functionality.                                                     #
################################################################################	
# File signal menu handler.
func ui_signal_pressed_file(index):
	## Import Image.
	if (index == 0):
		# Retreive node and setup the dialogue for file importing.
		var dialog_file_import = get_node("ui/panel_content/dialog_filemanager")
		
		# File OPEN dialog mode.
		dialog_file_import.set_mode(FileDialog.MODE_OPEN_FILE)
		dialog_file_import.set_access(FileDialog.ACCESS_FILESYSTEM)
		
		# Connect the signal for opening a file just ONCE.
		dialog_file_import.connect("file_selected", self, "ui_signal_file_import_confirmed", [], CONNECT_ONESHOT)
		
		# Modal show.
		dialog_file_import.popup_centered()
	## Export Image.
	elif (index == 1):
		# Retreive node and setup the dialogue for file exporting.
		var dialog_file_export = get_node("ui/panel_content/dialog_filemanager")
		
		# File SAVE dialog mode.
		dialog_file_export.set_mode(FileDialog.MODE_SAVE_FILE)
		dialog_file_export.set_access(FileDialog.ACCESS_FILESYSTEM)
		
		# Connect the signal for opening a file just ONCE.
		dialog_file_export.connect("file_selected", self, "ui_signal_file_export_confirmed", [], CONNECT_ONESHOT)
		
		# Modal show.
		dialog_file_export.popup_centered()
	elif (index == 3):
		# Show the palette selectional dialogue.
		ui_signal_pressed_map_palettes()
		#map_selected_palettes()
	elif (index == 5):
		# TODO: FFS THIS IS SELF-EXPLANATORY IS IT NOT!?
		get_tree().quit()
	
# File -> Menu Map Colors -> Confirm(OK) button signal.
func ui_signal_button_confirm_map_palettes():
	# Map the selected palettes.
	map_selected_palettes()
	
# File Menu -> Map Palettes signal handler.
func ui_signal_pressed_map_palettes():
		# Update the palette list data so it matches the current .json file.
		ui_load_palette_list_data()
		
		# Show the modal dialogue.
		var dialog_map_palettes = get_node("ui/panel_content/dialog_map_palettes")
		dialog_map_palettes.popup_centered()
		
# Palettes -> Show Palettes signal handler.
func ui_signal_pressed_palettes(index):
	if (index == 0):
		# Update the palette list data so it matches the current .json file.
		ui_load_palette_list_data()
		
		# Show the modal dialogue.
		var dialog_edit_palettes = get_node("ui/panel_content/dialog_edit_palettes")
		dialog_edit_palettes.popup_centered()
	
# File Menu -> File Import confirmed signal handler.
func ui_signal_file_import_confirmed(path):
	# Initialize the loaded image.
	cur_image_texture = ImageTexture.new()
	cur_image_texture.load(path)

	# Reposition ui elements....
	# Reposition it.
	# TODO: POSSIBLE ERROR HERE
	printt("Possible issue is in line 397 main.gd")
	#node_background_grid.update_grid_texture()
#	node_background_grid.update()
	
	# Setup the sprite node to apply this texture.
	var node_background_sprite = get_node("ui/panel_content/container_scroll_area/background_sprite")
	node_background_sprite.set_texture(cur_image_texture)
	node_background_sprite.set_custom_minimum_size(cur_image_texture.get_size())
	# Resize the background grid to the new texture size.
	var node_background_grid = get_node("ui/panel_content/container_scroll_area/background_grid")
	node_background_grid.set_size(cur_image_texture.get_size())
	node_background_grid.set_custom_minimum_size(cur_image_texture.get_size())
	# Center position the background grid.
	node_background_grid.set_pos(node_background_sprite.get_pos() - (node_background_grid.get_size() / 2))
	
	# Show the background grid.
	node_background_grid.show()
	
# File Menu -> File export confirmed signal handler.
func ui_signal_file_export_confirmed(path):
	# Create a temporary image from the texture of the cur_img_texture.
	var img = Image(cur_image_texture.get_width(), cur_image_texture.get_height(), false, Image.FORMAT_RGBA)
	
	# Blit the cur_image_teture data onto the temp image.
	img.blit_rect(cur_image_texture.get_data(), Rect2(Vector2(0, 0), cur_image_texture.get_size()), Vector2(0, 0))
	
	# Last but not least, save it.
	img.save_png(path)
	
# Edit Palette Dialog -> Add Color Button -> signal handler.
func ui_signal_button_add_color():
	# Retreive color.
	var clr_selected = get_node("ui/panel_content/container_scroll_area/dialog_edit_palettes/button_colorpicker").get_color()
	
	# Append to the list.	
	palette_list[cur_selected_palette_name].push_front(clr_selected.to_html())
	
	# Update the ui palette color list.
	ui_update_palette_color_list()
	
# Edit Palette Dialog -> Remove Color Button -> signal handler.
func ui_signal_button_remove_color():
	# Retreive the selected color index.
	var node_list_colors = get_node("ui/panel_content/dialog_edit_palettes/list_colors")
	
	# Make sure the index is even there in the list.
	var color_item_count = node_list_colors.get_item_count()
	
	# Make sure the selected index is appriate.
	if (cur_selected_palette_color_idx < 0 or cur_selected_palette_color_idx > color_item_count):
		# TODO: Proper reporting.
		printt("ERROR: Invalid color selected")
		return false
		
	# Make sure there is a selected color in the currently active palette.
	if (node_list_colors.is_selected(cur_selected_palette_color_idx)):
		node_list_colors.remove_item(cur_selected_palette_color_idx)
		palette_list[cur_selected_palette_name].remove(cur_selected_palette_color_idx)
	
	printt(cur_selected_palette_color_idx)
	# Update the currently renewed selected UI color lis.
	ui_update_palette_color_list()
	
# Edit Palette Dialog -> Palette Name Selected -> signal handler.
func ui_signal_palette_name_selected(idx):
	# Set the current palette.
	cur_selected_palette_idx = idx
	
	# Get selected palette.
	var node_palette_name = get_node("ui/panel_content/dialog_edit_palettes/palette_name")
	cur_selected_palette_name = node_palette_name.get_item_text(cur_selected_palette_idx)
	
	# Update ui color list.
	ui_update_palette_color_list()
	
# Edit Palette Dialog -> Color Selected -> signal handler.
func ui_signal_list_color_selected(idx):
	# Update the currently selected color idx.
	cur_selected_palette_color_idx = idx
	
	# Retreive the selected color index.
	var node_list_colors = get_node("ui/panel_content/dialog_edit_palettes/list_colors")
	
	# Make sure the index is even there in the list.
	var color_item_count = node_list_colors.get_item_count()
	
	# Retreive the current color button node.
	var node_button_colorpicker = get_node("ui/panel_content/dialog_edit_palettes/button_colorpicker")
	
	# TODO: Can we assume that the palette is selected for sure?
	# Make sure the selected index is appriate.
	if (cur_selected_palette_color_idx < 0 or cur_selected_palette_color_idx > color_item_count):
		# TODO: Proper reporting.
		printt("ERROR: Invalid color selected")
		return false
		
	# Adjust its color to the matched idx in case it exists.
	node_button_colorpicker.set_color(palette_list[cur_selected_palette_name][cur_selected_palette_color_idx])
	
# Map Palette Dialog -> Source Palette Name Selected -> signal handler.
func ui_signal_source_palette_name_selected(idx):
	# Set the current palette.
	cur_source_selected_palette_idx = idx
	
	# Get selected palette.
	var node_source_palette_name = get_node("ui/panel_content/dialog_map_palettes/source_palette_name")
	cur_source_selected_palette_name = node_source_palette_name.get_item_text(cur_source_selected_palette_idx)
	
# Map Palette Dialog -> Destination Palette Name Selected -> signal handler.
func ui_signal_destination_palette_name_selected(idx):
	# Set the destination palette.
	cur_destination_selected_palette_idx = idx
	
	# Get selected palette.
	var node_destination_palette_name = get_node("ui/panel_content/dialog_map_palettes/destination_palette_name")
	cur_destination_selected_palette_name = node_destination_palette_name.get_item_text(cur_destination_selected_palette_idx)
	
# Edit Palette Dialog -> New Palette Button -> signal handler.
func ui_signal_button_new_palette():
	# Show the new palette dialog.
	get_node("ui/panel_content/dialog_add_palette").popup_centered()
	
# Edit Palette Dialog -> Delete Palette Button -> signal handler.
func ui_signal_button_delete_palette():
	# TODO: Add error displaying in case the name is default.
	# TODO: Add a yes/no are you sure to delete dialogue.
	if (cur_selected_palette_name == "default"):
		return false
		
	# Remove from palette list if it has it.
	if (palette_list.has(cur_selected_palette_name)):
		palette_list.erase(cur_selected_palette_name)
		palette_list.keys().remove(cur_selected_palette_name)
	else:
		return false
	
	# Retreive the default palette IDX and name.
	# Make sure the current selected id is reset as selected.
	# Retreive the current selected index from the key list for default.
	cur_selected_palette_idx = palette_list.keys().find("default")
	cur_selected_palette_name = "default"
	
	# Update the UI Palette Dialogue palette list.
	ui_update_palette_list()
	
	# Update the currently renewed selected UI color lis.
	ui_update_palette_color_list()
	
# Edit Palette Dialog -> Save Palette Button -> signal handler.
func ui_signal_button_save_palette():
	# Make sure the current palette exists.
	if (palette_list.has(cur_selected_palette_name)):
		var new_list = []
		
		# Rearange coor list.
		for i in range(0, get_node("ui/panel_content/dialog_edit_palettes/list_colors").get_item_count()):
			# Retreive the name from the dialogue (as hex code. NOTE: RGBA not RGB!).
			var color = get_node("ui/panel_content/dialog_edit_palettes/list_colors").get_item_text(i)
			
			# Append it to our color list.
			new_list.append(color)
			
		# Save colors to the list.
		palette_list[cur_selected_palette_name] = new_list
	else:
		# TODO: Error?
		print("# TODO")
	
	# Update the palette json file.
	ui_save_palette_list_data()
	
	# Hide the dialogue.
	get_node("ui/panel_content/dialog_edit_palettes").hide()
	
# Edit Palette Dialog -> Cancel Palette Button -> signal handler.
func ui_signal_button_cancel_palette():
	get_node("ui/panel_content/dialog_edit_palettes").hide()
	
# Add Palette Dialog -> Confirm Button -> signal handler.
func ui_signal_button_confirm_new_palette():
	# Get name.
	var palette_name = get_node("ui/panel_content/dialog_add_palette/input_palette_name").get_text()
	
	# Add the palette to the list.
	new_palette(palette_name)
	
	# Update the lists.
	ui_update_palette_list()
	ui_update_palette_color_list()
	
	# Make sure the current selected id is reset as selected.
	var node_palette_name = get_node("ui/panel_content/dialog_edit_palettes/palette_name")
	node_palette_name.select(node_palette_name.get_item_ID(cur_selected_palette_idx))
	
	# TODO: Possibly not hide on error, get to it later.
	get_node("ui/panel_content/dialog_add_palette").hide()