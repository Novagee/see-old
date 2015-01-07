/*
 *  Created by Grigori Jlavyan on 01/16/12.
 *  Copyright 2012 BeInteractive. All rights reserved.
 */



#ifdef GL_ES
precision mediump float;
#endif
uniform sampler2D Texture;

uniform sampler2D t_texture_y;
uniform sampler2D t_texture_u;
uniform sampler2D t_texture_v;
varying vec2 uvVarying;


void main(void) {
    highp float y = texture2D(t_texture_y, uvVarying).r;
    highp float u = texture2D(t_texture_u, uvVarying).r - 0.5;
    highp float v = texture2D(t_texture_v, uvVarying).r - 0.5;
    
    highp float r = y +             1.402 * v;
    highp float g = y - 0.344 * u - 0.714 * v;
    highp float b = y + 1.772 * u;
    
    gl_FragColor = vec4(r,g,b,1.0);
}
