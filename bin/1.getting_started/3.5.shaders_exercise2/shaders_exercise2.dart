// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/3.5.shaders_exercise2/shaders_exercise2.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'package:sdl3_learnopengl/sdl3_learnopengl.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;

const gVertexShaderSource = '''
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 ourColor;
uniform float xOffset;

void main()
{
  // just add a - to the y position
  gl_Position = vec4(aPos.x + xOffset, aPos.y, aPos.z, 1.0);
  ourColor = aColor;
}
''';

int main() {
  // sdl: Initialize adnd configure
  // ------------------------------
  if (!sdlInit(SdlkInit.video)) {
    return -1;
  }
  sdlGlSetAttribute(SdlkGl.contextMajorVersion, 3);
  sdlGlSetAttribute(SdlkGl.contextMinorVersion, 3);
  sdlGlSetAttribute(SdlkGl.contextProfileMask, SdlkGl.contextProfileCore);
  sdlGlSetAttribute(SdlkGl.doublebuffer, 1);
  // sdl window creation
  // -------------------
  final window = sdlCreateWindow(
    'LearnOpenGL',
    gScreenWidth,
    gScreenHeight,
    SdlkWindow.opengl | SdlkWindow.resizable,
  );
  if (window == nullptr) {
    print('Failed to create SDL window');
    sdlQuit();
    return -1;
  }
  final context = sdlGlCreateContext(window);
  if (context == nullptr) {
    print('Failed to create GL context');
    sdlDestroyWindow(window);
    sdlQuit();
    return -1;
  }
  // sdl: load all OpenGL function pointers
  // ---------------------------------------
  sdlGlLoader();
  // build and compile our shader program
  // ------------------------------------
  final ourShader = Shader(
    vertexShaderSource: gVertexShaderSource,
    fragmentFilePath:
        'assets/shaders/1.getting_started/3.3.shaders_class/shader.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final vertices = [
    // positins  // colors
    -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, // bottom left
    0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // bottom right
    0.0, 0.5, 0.0, 0.0, 0.0, 1.0, // top
  ];
  final vao = glexGenVertexArrays(1)[0];
  final vbo = glexGenBuffers(1)[0];
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glexBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glexVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    6 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // color attribute
  glexVertexAttribPointer(
    1,
    3,
    GL_FLOAT,
    GL_FALSE,
    6 * sizeOf<Float>(),
    3 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(1);
  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  //glBindVertexArray(0);
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  void draw() {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // render the triangle
    ourShader.use();
    const offset = 0.5;
    ourShader.setFloat('xOffset', offset);
    glBindVertexArray(vao);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // no need to unbind it every time
    //glBindVertexArray(0);
    sdlGlSwapWindow(window);
  }

  while (!quit) {
    // render
    // ------
    draw();
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    while (sdlPollEvent(event)) {
      switch (event.type) {
        case SdlkEvent.quit:
          quit = true;
        case SdlkEvent.windowResized:
          // make sure the viewport matches the new window dimensions; note that width and
          // height will be significantly larger than specified on retina displays.
          glViewport(0, 0, event.window.ref.data1, event.window.ref.data2);
        case SdlkEvent.keyDown:
          switch (event.key.ref.key) {
            case Sdlk.escape:
              quit = true;
          }
      }
    }
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  glexDeleteVertexArrays([vao]);
  glexDeleteBuffers([vbo]);
  ourShader.delete();
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  event.callocFree();
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
