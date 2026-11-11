// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/4.2.textures_combined/textures_combined.cpp
import 'dart:ffi';

import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'package:sdl3_learnopengl/opengl_library.dart';

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
        'assets/shaders/1.getting_started/4.2.textures_combined/texture.vs',
    fragmentFilePath:
        'assets/shaders/1.getting_started/4.2.textures_combined/texture.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final vertices = [
    // positions       // colors        // texture coords
    0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom left
    -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top left
  ];
  final indices = [
    0, 1, 3, // first triangle
    1, 2, 3, // second triangle
  ];
  final vao = glxGenVertexArrays(1)[0];
  final vbo = glxGenBuffers(1)[0];
  final ebo = glxGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glxBufferFloat(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
  glxBufferUint32(GL_ELEMENT_ARRAY_BUFFER, indices, GL_STATIC_DRAW);
  // position attribute
  glxVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    8 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // color attribute
  glxVertexAttribPointer(
    1,
    3,
    GL_FLOAT,
    GL_FALSE,
    8 * sizeOf<Float>(),
    3 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(1);
  // texture attribute
  glxVertexAttribPointer(
    2,
    2,
    GL_FLOAT,
    GL_FALSE,
    8 * sizeOf<Float>(),
    6 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(2);
  // load and create a texture
  // texture 1
  // ---------
  final texture1 = Texture2d()..load('assets/textures/container.jpg');
  //  final texture1 = glxGenTextures(1)[0];
  //  glBindTexture(GL_TEXTURE_2D, texture1);
  //  // set the texture wrapping parameters
  //  // set texture wrapping to GL_REPEAT (default wrapping method)
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  //  // set texture filtering parameters
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  //  final image1 = decodeJpg(
  //    File('assets/textures/container.jpg').readAsBytesSync(),
  //  )!;
  //  glxTexImage2D(
  //    GL_TEXTURE_2D,
  //    0,
  //    GL_RGB,
  //    image1.width,
  //    image1.height,
  //    0,
  //    GL_RGB,
  //    image1.getBytes(order: ChannelOrder.rgb),
  //  );
  //  glGenerateMipmap(GL_TEXTURE_2D);
  // texture 1
  // ---------
  final texture2 = Texture2d()..load('assets/textures/awesomeface.png');
  //  final texture2 = glxGenTextures(1)[0];
  //  glBindTexture(GL_TEXTURE_2D, texture2);
  //  // set the texture wrapping parameters
  //  // set texture wrapping to GL_REPEAT (default wrapping method)
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  //  // set texture filtering parameters
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  //  final image2 = decodePng(
  //    File('assets/textures/awesomeface.png').readAsBytesSync(),
  //  );
  //  glxTexImage2D(
  //    GL_TEXTURE_2D,
  //    0,
  //    GL_RGBA,
  //    image2!.width,
  //    image2.height,
  //    0,
  //    GL_RGBA,
  //    image2.getBytes(),
  //  );
  //  glGenerateMipmap(GL_TEXTURE_2D);
  // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
  // -------------------------------------------------------------------------------------------
  // don't forget to activate/use the shader before setting uniforms!
  ourShader.use();
  // either set it manually like so:
  glUniform1i(glGetUniformLocation(ourShader.id, 'texture1'), 0);
  // or set it via the texture class
  ourShader.setInt('texture2', 1);
  // render loop
  // -----------
  var quit = false;
  void draw() {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    texture1.bind();
    //    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    texture2.bind();
    //    glBindTexture(GL_TEXTURE_2D, texture2);
    // render container
    ourShader.use();
    glBindVertexArray(vao);
    glxDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0 * sizeOf<Uint32>());
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
  texture1.delete();
  texture2.delete();
  //  glxDeleteTextures([texture1, texture2]);
  glxDeleteVertexArrays([vao]);
  glxDeleteBuffers([vbo, ebo]);
  ourShader.delete();
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
