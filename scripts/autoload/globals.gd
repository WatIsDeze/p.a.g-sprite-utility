# Extends Node.
extends Node

################################################################################
# Preloaded external classes.                                                  #
################################################################################
# None.

################################################################################
# Global Node Variables.                                                       #
################################################################################
###### 
# Main Scene Node Globals.
######
# Current active image texture.
var cur_image_texture = null

###### 
# Edit Palette Dialog Globals.
######
# Current active edit palette index and name.
var cur_edit_selected_palette_idx = 0
var cur_edit_selected_palette_name = "default"

# Current palette selected color index.
var cur_edit_selected_palette_color_idx = -1

###### 
# Map Color Dialog globals.
######
# Selected source map palette index and name.
var cur_source_selected_palette_idx = 0
var cur_source_selected_palette_name = "default"
# Destination source map palette index and name.
var cur_destination_selected_palette_idx = 0
var cur_destination_selected_palette_name = "default"