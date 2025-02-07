package game

import "base:runtime"
import "core:log"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import sapp "shared:sokol/app"
import shelpers "shared:sokol/helpers"
import sg "shared:sokol/gfx"
import "shared:imgui"
import "shared:simgui"

default_context: runtime.Context

@(export)
game_init :: proc() {
	default_context = context

	sg.setup({
		environment = shelpers.glue_environment(),
		logger = sg.Logger(shelpers.logger(&default_context)),
		allocator = sg.Allocator(shelpers.allocator(&default_context)),
	})

	g = new(Globals)
	g.imgui_context = simgui.setup()

	init()

	game_reloaded(g)
}

@(export)
game_cleanup :: proc() {
	cleanup()
	simgui.shutdown()
	sg.shutdown()
	free(g)
}

@(export)
game_reloaded :: proc(mem: rawptr) {
	g = transmute(^Globals)mem

	simgui.set_context(g.imgui_context)

	on_start_or_reload()
}

@(export)
game_should_quit :: proc() -> bool {
	return g.should_quit
}

@(export)
game_get_mem :: proc() -> rawptr {
	return g
}

@(export)
game_get_checksum :: proc() -> int {
	return size_of(Globals)
}

@(export)
game_frame :: proc() {
	frame_duration := sapp.frame_duration()

    simgui.new_frame({
		width = sapp.width(),
		height = sapp.height(),
		delta_time = frame_duration,
		dpi_scale = sapp.dpi_scale(),
	})

	dt := f32(frame_duration)
	update(dt)

	sg.begin_pass({ swapchain = shelpers.glue_swapchain() })
	draw()
	simgui.render()
	sg.end_pass()

	sg.commit()
}

key_down: #sparse[sapp.Keycode]bool

@(export)
game_event :: proc(e: ^sapp.Event) {
	if simgui.handle_event(e) {
		return
	}

	#partial switch e.type {
		case .KEY_DOWN:
			key_down[e.key_code] = true

		case .KEY_UP:
			key_down[e.key_code] = false
	}
}

@(export)
game_should_reload :: proc() -> bool {
	return key_down[.F5]
}

@(export)
game_should_restart :: proc() -> bool {
	return key_down[.F6]
}
