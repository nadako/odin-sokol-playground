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
	vertices := []Vec3 {
		{-0.5, -0.5, 0},
		{   0,  0.5, 0},
		{ 0.5, -0.5, 0},
	}
	g.vertex_buffer = sg.make_buffer({
		data = sg_range(vertices)
	})

	g.shader = sg.alloc_shader()
	g.pipeline = sg.alloc_pipeline()
}

on_start_or_reload :: proc() {
	// also hot-reload shader/pipeline
	if sg.query_pipeline_state(g.pipeline) != .ALLOC do sg.uninit_pipeline(g.pipeline)
	if sg.query_shader_state(g.shader) != .ALLOC do sg.uninit_shader(g.shader)

	sg.init_shader(g.shader, sample_shader_desc(sg.query_backend()))
	sg.init_pipeline(g.pipeline, {
		shader = g.shader,
		layout = {
			attrs = {
				ATTR_sample_pos = { format = .FLOAT3 }
			}
		}
	})
}

cleanup :: proc() {
	sg.destroy_buffer(g.vertex_buffer)
	sg.destroy_pipeline(g.pipeline)
	sg.destroy_shader(g.shader)
}

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