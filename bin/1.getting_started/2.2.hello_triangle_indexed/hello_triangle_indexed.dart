// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.2.hello_triangle_indexed/hello_triangle_indexed.cpp
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
  final vertices = [
    0.5, 0.5, 0.0, // top right
    0.5, -0.5, 0.0, // bottom right
    -0.5, -0.5, 0.0, // bottom left
    -0.5, 0.5, 0.0, // top left
  ];
  // note that we start from 0!
  final indices = [
    0, 1, 3, // first Triangle
    1, 2, 3, // second Triangle
  ];
  final vao = glexGenVertexArrays(1)[0];
  final vbo = glexGenBuffers(1)[0];
  final ebo = glexGenBuffers(1)[0];
  // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).  // optional: de-allocate all resources once they've outlived their purpose:
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glexBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glexBufferUint32(GL_ELEMENT_ARRAY_BUFFER, indices, GL_STATIC_DRAW);
  glexVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    3 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex attribute's bound vertex buffer object so afterwards we can safely unbind
  glBindBuffer(GL_ARRAY_BUFFER, 0);

  // remember: do NOT unbind the EBO while a VAO is active as the bound element buffer object IS stored in the VAO; keep the EBO bound.
  //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

  // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
  // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
  glBindVertexArray(0);
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
    // draw our first triangle
    glUseProgram(shaderProgram);
    // seeing as we only have a single VAO there's no need to bind it every time, but we'll do so to keep things a bit more organized
    glBindVertexArray(vao);
    //glDrawArrays(GL_TRIANGLES, 0, 6);
    glexDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0 * sizeOf<Uint32>());
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
  glexDeleteBuffers([vbo, ebo]);
  glDeleteProgram(shaderProgram);
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  event.callocFree();
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
