shader_type canvas_item;

uniform float u_darkness;

void fragment() {
	COLOR -= u_darkness;
}