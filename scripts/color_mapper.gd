# The ColorMapper class works pretty simple.
# One can add an array of colors, and give this a name.
# When calling exchange, the class scans for any color of the
# given list names. For example:
#
# cm.exchange(image, "base_dave", "clerk_ginger")
#
# The above would now have turned dave, into the clerk_ginger
# pallette wise.
class ColorMapper:
	# Lists.
	var _palette_list = {}
	
	func _init():
		_palette_list = {}
		pass
	
	func _ready():
		pass
	
	# Simply adds a list of colors, returns false if it exists already.
	func add_color_array(name, colors):
		# Error check.
		if (_palette_list.has(name)):
			return false
		
		# Add and return.
		_palette_list[name] = colors
		return true
		
	# Simply removes a list of colors, returns false if it did not exist.
	func remove_color_array(name):
		# Error check.
		if (!_palette_list.has(name)):
			return false
		
		# Add and return.
		_palette_list.erase(name)
		return true
	
	# img = Image, can be retreived from ImageTexture also.
	# name_source = the palette used to read RGBA data from.
	# name_dest = the palette used to write RGBA data from.
	# 
	# Returns the modified Image, can be reassigned using ImageTexture also.
	func exchange(img, name_source, name_dest):
		# Default result is an empty Image.
		var result = Image(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA)
		
		# Error check.
		if (!_palette_list.has(name_source) or !_palette_list.has(name_dest)):
			return false
		
		var palette_source = _palette_list[name_source]
		var palette_dest = _palette_list[name_dest]
		
		printt(_palette_list)
		# Scan and replace.
		for x in range(0, img.get_width()):
			for y in range(0, img.get_height()):
				# Retreive current pixel color.
				var img_color = img.get_pixel(x, y, 0)
				
				# Copy it over to the result image.
				result.put_pixel(x, y, img_color)
				
				# NOTE: The following below, will override the color put
				# previously if it does match...
					
				# Determine whether the color matches any in name_source.
				# If the color matches, store the index, and use set_pixel
				# to retreive the according color in name_dest.
				
				# TODO: Make sure that the size can not exceed each other, since we read source...
				#       we set it to source size so we do not exceed any buffers.
				##var size = palette_source.size()
				##if (size > palette_dest.size()):
				##	size = palette_dest.size()
					
				for cs_i in range(0, palette_source.size()):
					if (Color(palette_source[cs_i]) == img_color):
						if cs_i < palette_dest.size():
							result.put_pixel(x, y, Color(palette_dest[cs_i]))
						 
		return result