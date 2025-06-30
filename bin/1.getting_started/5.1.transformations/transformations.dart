// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/5.1.transformations/transformations.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'package:sdl3_learnopengl/sdl3_learnopengl.dart';
import 'package:vector_math/vector_math.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;

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
    vertexFilePath:
        'assets/shaders/1.getting_started/5.1.transformations/transform.vs',
    fragmentFilePath:
        'assets/shaders/1.getting_started/5.1.transformations/transform.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final vertices = [
    // positions       // texture coords
    0.5, 0.5, 0.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 0.0, // bottom left
    -0.5, 0.5, 0.0, 0.0, 1.0, // top left
  ];
  final indices = [
    0, 1, 3, // first triangle
    1, 2, 3, // second triangle
  ];
  final vao = glexGenVertexArrays(1)[0];
  final vbo = glexGenBuffers(1)[0];
  final ebo = glexGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glexBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glexBufferUint32(GL_ELEMENT_ARRAY_BUFFER, indices, GL_STATIC_DRAW);
  // position attribute
  glexVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    5 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // texture coord attribute
  glexVertexAttribPointer(
    1,
    2,
    GL_FLOAT,
    GL_FALSE,
    5 * sizeOf<Float>(),
    3 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(1);
  // load and create a texture
  // -------------------------
  // texture 1
  // ---------
  final texture1 = Texture2d()..load('assets/textures/container.jpg');
  // texture 2
  // ---------
  final texture2 = Texture2d()..load('assets/textures/awesomeface.png');
  // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
  // -------------------------------------------------------------------------------------------
  ourShader
    ..use()
    ..setInt('texture1', 0)
    ..setInt('texture2', 1);
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  void draw() {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    texture1.bind();
    glActiveTexture(GL_TEXTURE1);
    texture2.bind();
    // create transformations
    final transform = Matrix4.identity()
      ..translateByVector3(Vector3(0.5, -0.5, 0))
      ..rotate(Vector3(0, 0, 1), sdlGetTicks() / 1000);
    // get matrix's uniform location and set matrix
    ourShader.use();
    final transformLoc = glGetUniformLocation(ourShader.id, 'transform');
    glexUniformMatrix4fv(transformLoc, 1, GL_FALSE, transform.storage);
    // render cotainer
    glBindVertexArray(vao);
    glexDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0 * sizeOf<Uint32>());
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
  texture1.delete();
  texture2.delete();
  //  glexDeleteTextures([texture1, texture2]);
  glexDeleteVertexArrays([vao]);
  glexDeleteBuffers([vbo, ebo]);
  ourShader.delete();
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  event.callocFree();
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
