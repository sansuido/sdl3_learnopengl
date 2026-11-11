// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/2.lighting/2.3.basic_lighting_exercise1/basic_lighting_exercise1.cpp
import 'dart:ffi';
import 'dart:math' as math;

import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'package:sdl3_learnopengl/opengl_library.dart';
import 'package:vector_math/vector_math.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;
// camera
var gCamera = Camera(position: Vector3(0, 0, 3));
double gLastX = 800 / 2.0;
double gLastY = 600 / 2.0;
var gFirstMouse = true;
// timing
var gDeltaTime = 0.0;
var gLastFrame = 0.0;
// lighting
var gLightPos = Vector3(1.2, 1, 2);

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
  // configure global opengl state
  // -----------------------------
  glEnable(GL_DEPTH_TEST);
  // build and compile our shader program
  // ------------------------------------
  final lightingShader = Shader(
    vertexFilePath: 'assets/shaders/2.lighting/2.2.basic_lighting_specular/basic_lighting.vs',
    fragmentFilePath: 'assets/shaders/2.lighting/2.2.basic_lighting_specular/basic_lighting.fs',
  );
  final lightCubeShader = Shader(
    vertexFilePath:
        'assets/shaders/2.lighting/2.2.basic_lighting_specular/light_cube.vs',
    fragmentFilePath:
        'assets/shaders/2.lighting/2.2.basic_lighting_specular/light_cube.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final vertices = [
    [-0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, 0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, -0.5, -0.5, 0.0, 0.0, -1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, 0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0, 1.0],
    [-0.5, 0.5, 0.5, -1.0, 0.0, 0.0],
    [-0.5, 0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, -1.0, 0.0, 0.0],
    [-0.5, -0.5, 0.5, -1.0, 0.0, 0.0],
    [-0.5, 0.5, 0.5, -1.0, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, -1.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, -1.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [-0.5, 0.5, 0.5, 0.0, 1.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0, 0.0],
  ];
  // first, configure the cube's VAO (and VBO)
  final cubeVao = glxGenVertexArrays(1)[0];
  final vbo = glxGenBuffers(1)[0];
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glxBufferFloat(
    GL_ARRAY_BUFFER,
    vertices.expand((values) => values).toList(),
    GL_STATIC_DRAW,
  );
  glBindVertexArray(cubeVao);
  // position attribute
  glxVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    6 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // normal attribute
  glxVertexAttribPointer(
    1,
    3,
    GL_FLOAT,
    GL_FALSE,
    6 * sizeOf<Float>(),
    3 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(1);
  // second, configure the light's VAO (VBO stays the same; the vertices are the same for the light object which is also a 3D cube)
  final lightCubeVao = glxGenVertexArrays(1)[0];
  glBindVertexArray(lightCubeVao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  // note that we update the lamp's position attribute's stride to reflect the updated buffer data
  glxVertexAttribPointer(
    0,
    3,
    GL_FLOAT,
    GL_FALSE,
    6 * sizeOf<Float>(),
    0 * sizeOf<Float>(),
  );
  glEnableVertexAttribArray(0);
  // render loop
  // -----------
  var quit = false;
  void draw() {
    // render
    // ------
    glClearColor(0.1, 0.1, 0.1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // change the light's position values over time (can be done anywhere in the render loop actually, but try to do it at least before using the light source positions)
    gLightPos.x = 1.0 + math.sin(sdlGetTicks() / 1000) * 2.0;
    gLightPos.y = math.sin(sdlGetTicks() / 1000 / 2.0) * 1.0;
    // be sure to activate shader when setting uniforms/drawing objects
    lightingShader
      ..use()
      ..setVector3('objectColor', Vector3(1, 0.5, 0.31))
      ..setVector3('lightColor', Vector3(1, 1, 1))
      ..setVector3('lightPos', gLightPos)
      ..setVector3('viewPos', gCamera.position);
    // view/projection transformations
    final projection = makePerspectiveMatrix(
      radians(gCamera.zoom),
      gScreenWidth / gScreenHeight,
      0.1,
      100,
    );
    final view = gCamera.getViewMatrix();
    lightingShader
      ..setMatrix4('projection', projection)
      ..setMatrix4('view', view);
    // world transformation
    final model = Matrix4.identity();
    lightingShader.setMatrix4('model', model);
    // render the cube
    glBindVertexArray(cubeVao);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    // also draw the lamp object
    lightCubeShader
      ..use()
      ..setMatrix4('projection', projection)
      ..setMatrix4('view', view);
    model
      ..translateByVector3(gLightPos)
      ..scaleByVector3(Vector3.all(0.2));
    lightCubeShader.setMatrix4('model', model);
    glBindVertexArray(lightCubeVao);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    sdlGlSwapWindow(window);
  }

  while (!quit) {
    final currentFrame = sdlGetTicks() / 1000;
    gDeltaTime = currentFrame - gLastFrame;
    gLastFrame = currentFrame;
    // input
    // -----
    cursorInput();
    processInput();
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
        // make sure the viewport matches the new window dimensions; note that width and
        // height will be significantly larger than specified on retina displays.
        glViewport(0, 0, event.data1, event.data2);
      }
      // sdl: whenever the mouse scroll wheel scrolls, this callback is called
      // ---------------------------------------------------------------------
      if (event is SdlxMouseWheelEvent) {
        gCamera.processMouseScroll(event.y);
      }
    }
  }
  // optional: de-allocate all resources once they've outlived their purpose:
  // ------------------------------------------------------------------------
  //  glxDeleteTextures([texture1, texture2]);
  glxDeleteVertexArrays([cubeVao, lightCubeVao]);
  glxDeleteBuffers([vbo]);
  lightingShader.delete();
  lightCubeShader.delete();
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}

// sdl: whenever the mouse moves, this callback is called
// ------------------------------------------------------
void cursorInput() {
  final rec = sdlxGetGlobalMouseState();
  if (gFirstMouse) {
    gLastX = rec.x;
    gLastY = rec.y;
    gFirstMouse = false;
  }
  final xoffset = rec.x - gLastX;
  // reversed since y-coordinates go from bottom to top
  final yoffset = gLastY - rec.y;
  gLastX = rec.x;
  gLastY = rec.y;
  gCamera.processMouseMovement(xoffset, yoffset);
}

// process all input: query sdl whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput() {
  final keys = sdlGetKeyboardState(nullptr);
  if (keys[SdlkScancode.w]) {
    gCamera.processKeyboard(CameraMovement.forward, gDeltaTime);
  }
  if (keys[SdlkScancode.s]) {
    gCamera.processKeyboard(CameraMovement.backward, gDeltaTime);
  }
  if (keys[SdlkScancode.a]) {
    gCamera.processKeyboard(CameraMovement.left, gDeltaTime);
  }
  if (keys[SdlkScancode.d]) {
    gCamera.processKeyboard(CameraMovement.right, gDeltaTime);
  }
}
