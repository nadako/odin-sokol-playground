package game

import sg "shared:sokol/gfx"

sg_range :: proc(s:[]$T) -> sg.Range {
	return {
		ptr = raw_data(s),
		size = len(s) * size_of(s[0])
	}
}
