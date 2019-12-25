return 
" \
\n#ifdef GL_ES\n \
varying lowp vec4 v_fragmentColor; \
varying mediump vec2 v_texCoord; \
\n#else\n \
varying vec4 v_fragmentColor; \
varying vec2 v_texCoord; \
\n#endif\n \
void main() \
{ \
    vec4 pixColor = texture2D(CC_Texture0, v_texCoord);\
    vec4 gray = vec4(0.299, 0.587, 0.114,0.0);\
    float grey = dot(pixColor.rgba, gray);\
    gl_FragColor = vec4(vec3(grey), pixColor.a); \
} \
"
