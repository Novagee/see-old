/*
 *
 *  Created by Grigori Jlavyan on 01/16/12.
 *  Copyright 2012 BeInteractive. All rights reserved.
 *
 */

attribute vec4 position;
attribute vec2 uv;

varying vec2 uvVarying;

void main(void) {
    gl_Position =  position;
    uvVarying =uv;
}