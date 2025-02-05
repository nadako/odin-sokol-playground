package game

import "core:log"
import "shared:simgui"
import im "shared:imgui"
import sg "shared:sokol/gfx"

Globals :: struct {
	imgui_context: ^simgui.Context,

	should_quit: bool,

	shader: sg.Shader,
	pipeline: sg.Pipeline,
	vertex_buffer: sg.Buffer,
}

g: ^Globals

init :: proc() {
	g.shader = sg.make_shader(sample_shader_desc(sg.query_backend()))
	g.pipeline = sg.make_pipeline({
		shader = g.shader,
		layout = {
			attrs = {
				ATTR_sample_pos = { format = .FLOAT3 }
			}
		}
	})
	vertices := []Vec3 {
		{-0.5, -0.5, 0},
		{   0,  0.5, 0},
		{ 0.5, -0.5, 0},
	}
	g.vertex_buffer = sg.make_buffer({
		data = sg_range(vertices)
	})
}

cleanup :: proc() {
	sg.destroy_buffer(g.vertex_buffer)
	sg.destroy_pipeline(g.pipeline)
	sg.destroy_shader(g.shader)
}

on_reload :: proc() {}

update :: proc(dt: f32) {
	if key_down[.ESCAPE] {
		g.should_quit = true
		return
	}

	if im.Begin("Inspector", flags = {.AlwaysAutoResize}) {
		if im.Button("Press me") do log.debug("Button pressed!")
	}
	im.End()
}

draw :: proc() {
	sg.apply_pipeline(g.pipeline)
	sg.apply_bindings({
		vertex_buffers = { 0 = g.vertex_buffer }
	})
	sg.draw(0, 3, 1)
}