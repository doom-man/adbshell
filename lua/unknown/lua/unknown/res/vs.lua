return
" \
attribute vec4 a_position; \
attribute vec4 a_color; \
attribute vec2 a_texCoord; \
uniform float CC_R; \
uniform float CC_G; \
uniform float CC_B; \
\n#ifdef GL_ES\n \
varying lowp vec4 v_fragmentColor; \
varying mediump vec2 v_texCoord; \
\n#else\n \
varying vec4 v_fragmentColor; \
varying vec2 v_texCoord; \
\n#endif\n \
void main() \
{ \
    gl_Position = CC_PMatrix * a_position; \
    v_fragmentColor = vec4(a_color.r*CC_R,a_color.g*CC_G,a_color.b*CC_B,a_color.a);\
    v_texCoord = a_texCoord;\
} \
"
