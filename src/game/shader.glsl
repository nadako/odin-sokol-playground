@header package game
@header import sg "shared:sokol/gfx"

@ctype mat4 Mat4

@vs vs
in vec3 pos;

void main() {
    gl_Position = vec4(pos,1);
}
@end

@fs fs
out vec4 frag_color;

void main() {
    frag_color = vec4(1,0,0,1);
}
@end

@program sample vs fs
