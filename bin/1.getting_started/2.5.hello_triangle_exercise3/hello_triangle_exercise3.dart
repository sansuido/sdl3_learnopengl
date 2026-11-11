// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.5.hello_triangle_exercise3/hello_triangle_exercise3.cpp
import 'dart:ffi';

import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';

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

const gFragmentShader2Source = '''
#version 330 core
out vec4 FragColor;
void main()
{
   FragColor = vec4(1.0f, 1.0f, 0.0f, 1.0f);
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
  glxShaderSource(vertexShader, gVertexShaderSource);
  glCompileShader(vertexShader);
  if (glxGetShaderiv(vertexShader, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::VERTEX::COMPILATIN_FALED');
    final bufSize = glxGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glxGetShaderInfoLog(vertexShader, bufSize));
    }
  }
  // fragment shader
  final fragmentShaderOrange = glCreateShader(GL_FRAGMENT_SHADER);
  glxShaderSource(fragmentShaderOrange, gFragmentShaderSource);
  glCompileShader(fragmentShaderOrange);
  if (glxGetShaderiv(fragmentShaderOrange, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    final bufSize = glxGetShaderiv(fragmentShaderOrange, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glxGetShaderInfoLog(fragmentShaderOrange, bufSize));
    }
  }
  final fragmentShaderYellow = glCreateShader(GL_FRAGMENT_SHADER);
  glxShaderSource(fragmentShaderYellow, gFragmentShader2Source);
  glCompileShader(fragmentShaderYellow);
  if (glxGetShaderiv(fragmentShaderYellow, GL_COMPILE_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::FRAGMENT::COMPILATION_FAILED');
    final bufSize = glxGetShaderiv(fragmentShaderYellow, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glxGetShaderInfoLog(fragmentShaderYellow, bufSize));
    }
  }
  // link shaders
  final shaderProgramOrange = glCreateProgram();
  glAttachShader(shaderProgramOrange, vertexShader);
  glAttachShader(shaderProgramOrange, fragmentShaderOrange);
  glLinkProgram(shaderProgramOrange);
  // check for linking errors
  if (glxGetProgramiv(shaderProgramOrange, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PROGRAM::LINKING_FAILED');
    final bufSize = glxGetProgramiv(shaderProgramOrange, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glxGetProgramInfoLog(shaderProgramOrange, bufSize));
    }
  }
  final shaderProgramYellow = glCreateProgram();
  glAttachShader(shaderProgramYellow, vertexShader);
  glAttachShader(shaderProgramYellow, fragmentShaderYellow);
  glLinkProgram(shaderProgramYellow);
  // check linking errors
  if (glxGetProgramiv(shaderProgramYellow, GL_LINK_STATUS) != GL_TRUE) {
    print('ERROR::SHADER::PRGRAM::LINKING_FAILED');
    final bufSize = glxGetProgramiv(shaderProgramYellow, GL_INFO_LOG_LENGTH);
    if (bufSize > 1) {
      print(glxGetProgramInfoLog(shaderProgramYellow, bufSize));
    }
  }
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShaderOrange);
  glDeleteShader(fragmentShaderYellow);
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
  final vaos = glxGenVertexArrays(2);
  final vbos = glxGenBuffers(2);
  // first triangle setup
  // --------------------
  glBindVertexArray(vaos[0]);
  glBindBuffer(GL_ARRAY_BUFFER, vbos[0]);
  glxBufferFloat(GL_ARRAY_BUFFER, firstTriangle, GL_STATIC_DRAW);
  glxVertexAttribPointer(
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
  glxBufferFloat(GL_ARRAY_BUFFER, secondTriangle, GL_STATIC_DRAW);
  glxVertexAttribPointer(
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
  void draw() {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // now when we draw the triangle we first use the vertex and orange fragment shader from the first program
    glUseProgram(shaderProgramOrange);
    // draw first triangle using the data from the first VAO
    glBindVertexArray(vaos[0]);
    // this call should output an orange triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // when we draw the second triangle we want to use a different shader program so we switch to the shader program with our yellow fragment shader.
    glUseProgram(shaderProgramYellow);
    // then we draw the second triangle using the data from the second VAO
    glBindVertexArray(vaos[1]);
    // this call should output a yellow triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    // glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // -------------------------------------------------------------------------------
    sdlGlSwapWindow(window);
  }

  while (!quit) {
    // render
    // ------
    draw();
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    SdlxEvent? event;
    while ((event = sdlxPollEvent()) != null) {
      if (event is SdlxQuitEvent) {
        quit = true;
      }
      if (event is SdlxKeyboardEvent && event.type == SdlkEvent.keyDown) {
        if (event.scancode == Sdlk.escape) {
          quit = true;
        }
      }
      if (event is SdlxWindowEvent && event.type == SdlkEvent.windowResized) {
        glViewport(0, 0, event.data1, event.data2);
      }
    }
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  glxDeleteVertexArrays(vaos);
  glxDeleteBuffers(vbos);
  glDeleteProgram(shaderProgramOrange);
  glDeleteProgram(shaderProgramYellow);
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
