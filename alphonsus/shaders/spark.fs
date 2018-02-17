vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
	vec4 c = Texel(texture, texture_coords); // This reads a color from our texture at the coordinates LOVE gave us (0-1, 0-1)

	if(c.a !=  0){
		return vec4(1, 1, 1, 1);
	}
	else{
		return c;
	}
}