# Extends Control.
extends TextureFrame

################################################################################
# Export properties.                                                           #
################################################################################
export(Color, RGB) var Tile_Color_A = Color("#DBC6A8")
export(Color, RGB) var Tile_Color_B = Color("#C0A67E")
export(int) var Tile_Size_X = 32
export(int) var Tile_Size_Y = 32

################################################################################
# Global variables.                                                            #
################################################################################
# Tile images.
var img_tile_a = null
var img_tile_b = null

# Grid image.
var img_tile_grid = null

# Control size.
var ctrl_size = Vector2(128, 128)

################################################################################
# TextureGrid notifications.                                                   #
################################################################################
# Initialize control
func _init():
	pass
	
# Initialize control
func _ready():
	# Tile images.
	img_tile_a = Image(Tile_Size_X, Tile_Size_Y, false, Image.FORMAT_RGBA)
	img_tile_b = Image(Tile_Size_X, Tile_Size_Y, false, Image.FORMAT_RGBA)
	
	# Grid image.
	img_tile_grid = Image(ctrl_size.x, ctrl_size.y, false, Image.FORMAT_RGBA)
	
	# By default update the grid texture.
	update_grid_texture()
	update()
	pass
	
# Draw
func _draw():
	#upgrade_grid_texture()
	pass
	
# Update the grid texture and reassing it to the TextureFrame control.
func update_grid_texture():
	# Retreive control size.
	ctrl_size = get_size()
	
	# Calculate the amount of tiles to render.
	var max_tiles_x = ctrl_size.x / Tile_Size_X
	var max_tiles_y = ctrl_size.y / Tile_Size_Y
	
	for i in range(0, 32):
		for j in range(0, 32):
			img_tile_a.put_pixel(i, j, Tile_Color_A)
			img_tile_b.put_pixel(i, j, Tile_Color_B)
	
	# Draw the tiles to the image(use lazy set_pixel method).
	var tile_img = 0
	
	for i in range(0, max_tiles_x):
		# TODO: Try to find any simpler method (Possibly using modulation operator.)
		# Calculate tile image to blit.
		if (tile_img == 0):
			tile_img = 1
		else:
			tile_img = 0
		
		for j in range(0, max_tiles_y):
			# TODO: Try to find any simpler method (Possibly using modulation operator.)
			if (tile_img == 0):
				tile_img = 1
			else:
				tile_img = 0
			
			# Calculate source blit rectangle.
			var src_rect = Rect2(0, 0, Tile_Size_X, Tile_Size_Y)
			
			# Blit.
			if (tile_img == 0):
				# Tile A (By default settings the light colored tile).
				img_tile_grid.blit_rect(img_tile_a, src_rect, Vector2(int(i * Tile_Size_X), int(j * Tile_Size_Y)))
			elif (tile_img == 1):
				# Tile B (By default settings the dark colored tile).
				img_tile_grid.blit_rect(img_tile_b, src_rect, Vector2(int(i * Tile_Size_X), int(j * Tile_Size_Y)))
			
	# Create the new grid texture.
	var tex_tile_grid = ImageTexture.new()
	tex_tile_grid.create_from_image(img_tile_grid)
	
	# Reassign the grid texture.
	set_texture(tex_tile_grid)
	
# Fetch textureframe control events.
func _notification(what):
	# Redraw(update) the grid texture in case the control is resized.
	if (what == NOTIFICATION_RESIZED):
		if (get_texture() == null):
			return
			
		# Retreive control size.
		ctrl_size = get_size()
		
		# Create the new image for the grid texture.
		img_tile_grid = Image(ctrl_size.x, ctrl_size.y, false, Image.FORMAT_RGBA)
		
		# Render a new grid with the given size.
		update_grid_texture()
		
		# Update it.
		update()