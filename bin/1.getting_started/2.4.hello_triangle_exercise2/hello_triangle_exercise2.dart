// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.4.hello_triangle_exercise2/hello_triangle_exercise2.cpp
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
void main()
{
  gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
''';

const gFragmentShaderSource = '''
#version 330 core
out vec4 FragColor;
void main()
{
  FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
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
  // vertext shader
  final vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glexShaderSource(vertexShader, gVertexShaderSource);
  glCompileShader(vertexShader);
  if (glexGetShaderiv(vertexShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::VERTEX::COMPILATIN_FALED');
    final bufSize = glexGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glexGetShaderInfoLog(vertexShader, bufSize));
    }
  }
  // fragment shader
  final fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glexShaderSource(fragmentShader, gFragmentShaderSource);
  glCompileShader(fragmentShader);
  if (glexGetShaderiv(fragmentShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    final bufSize = glexGetShaderiv(fragmentShader, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glexGetShaderInfoLog(fragmentShader, bufSize));
    }
  }
  // link shaders
  final shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  // check for linking errors
  if (glexGetProgramiv(shaderProgram, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PROGRAM::LINKING_FAILED');
    final bufSize = glexGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glexGetProgramInfoLog(shaderProgram, bufSize));
    }
  }
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final firstTriangle = [
    -0.9, -0.5, 0.0, // left
    -0.0, -0.5, 0.0, // right
    -0.45, 0.5, 0.0, // top
  ];
  final secondTriangle = [
    0.0, -0.5, 0.0, // left
    0.9, -0.5, 0.0, // right
    0.45, 0.5, 0.0, // top
  ];
  // we can also generate multiple VAOs or buffers at the same time
  final vaos = glexGenVertexArrays(2);
  final vbos = glexGenBuffers(2);
  // first triangle setup
  // --------------------
  glBindVertexArray(vaos[0]);
  glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
  glexBufferFloat(GL_ARRAY_BUFFER, firstTriangle, GL_STATIC_DRAW);
  glexVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    3 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // no need to unbind at all as we directly bind a different VAO the next few lines
  //glBindVertexArray(0);
  // second triangle setup
  // ---------------------
  // note that we bind to a different VAO now
  glBindVertexArray(vaos[1]);
  // and a different VBO
  glBindBuffer(GL_ARRAY_BUFFER, vbos[1]);
  glexBufferFloat(GL_ARRAY_BUFFER, secondTriangle, GL_STATIC_DRAW);
  glexVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    3 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // not really necessary as well, but beware of calls that could affect VAOs while this one is bound (like binding element buffer objects, or enabling/disabling vertex attributes)
  //glBindVertexArray(0);
  // uncomment this call to draw in wireframe polygons.
  //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  void draw() {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(shaderProgram);
    // draw first triangle using the data from the first VAO
    glBindVertexArray(vaos[0]);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // then we draw the second triangle using the data from the second VAO
    glBindVertexArray(vaos[1]);
    glDrawArrays(GL_TRIANGLES, 0, 3);
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
  glexDeleteVertexArrays(vaos);
  glexDeleteBuffers(vbos);
  glDeleteProgram(shaderProgram);
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  event.callocFree();
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
