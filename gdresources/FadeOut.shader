shader_type canvas_item;

uniform int u_timeoffset;

void fragment() {
	if (u_timeoffset > 0) {
		float color_offset = float((int(TIME)*1000)-u_timeoffset)/0.001;
		COLOR -= color_offset;
	}
}