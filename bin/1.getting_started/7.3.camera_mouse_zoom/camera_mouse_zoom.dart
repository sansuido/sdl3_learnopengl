// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/7.3.camera_mouse_zoom/camera_mouse_zoom.cpp
import 'dart:ffi';
import 'dart:math' as math;
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'package:sdl3_learnopengl/sdl3_learnopengl.dart';
import 'package:vector_math/vector_math.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;
// camera
var gCameraPos = Vector3(0, 0, 3);
var gCameraFront = Vector3(0, 0, -1);
var gCameraUp = Vector3(0, 1, 0);
var gFirstMouse = true;
var gYaw = -90.0;
var gPitch = 0.0;
double gLastX = 800 / 2.0;
double gLastY = 600 / 2.0;
var gFov = 45.0;
// timing
var gDeltaTime = 0.0;
var gLastFrame = 0.0;

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
  final ourShader = Shader(
    vertexFilePath:
        'assets/shaders/1.getting_started/7.3.camera_mouse_zoom/camera.vs',
    fragmentFilePath:
        'assets/shaders/1.getting_started/7.3.camera_mouse_zoom/camera.fs',
  );
  // set up vertex data (and buffer(s)) and configure vertex attributes
  // ------------------------------------------------------------------
  final vertices = [
    [-0.5, -0.5, -0.5, 0.0, 0.0],
    [0.5, -0.5, -0.5, 1.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 1.0],
    [0.5, 0.5, 0.5, 1.0, 1.0],
    [-0.5, 0.5, 0.5, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, 0.5, -0.5, 1.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, 0.5, 0.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [0.5, -0.5, -0.5, 1.0, 1.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [0.5, -0.5, 0.5, 1.0, 0.0],
    [-0.5, -0.5, 0.5, 0.0, 0.0],
    [-0.5, -0.5, -0.5, 0.0, 1.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
    [0.5, 0.5, -0.5, 1.0, 1.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [0.5, 0.5, 0.5, 1.0, 0.0],
    [-0.5, 0.5, 0.5, 0.0, 0.0],
    [-0.5, 0.5, -0.5, 0.0, 1.0],
  ];
  // world space positions of our cubes
  final cubePositions = [
    Vector3(0, 0, 0),
    Vector3(2, 5, -15),
    Vector3(-1.5, -2.2, -2.5),
    Vector3(-3.8, -2, -12.3),
    Vector3(2.4, -0.4, -3.5),
    Vector3(-1.7, 3, -7.5),
    Vector3(1.3, -2, -2.5),
    Vector3(1.5, 2, -2.5),
    Vector3(1.5, 0.2, -1.5),
    Vector3(-1.3, 1, -1.5),
  ];
  final vao = glexGenVertexArrays(1)[0];
  final vbo = glexGenBuffers(1)[0];
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glexBufferFloat(
    GL_ARRAY_BUFFER,
    vertices.expand((values) => values).toList(),
    GL_STATIC_DRAW,
  );
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
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // bind textures on corresponding texture units
    glActiveTexture(GL_TEXTURE0);
    texture1.bind();
    glActiveTexture(GL_TEXTURE1);
    texture2.bind();
    // active shader
    ourShader.use();
    // pass projection matrix to shader (as projection matrix rarely changes there's no need to do this per frame)
    // -----------------------------------------------------------------------------------------------------------
    final projection = makePerspectiveMatrix(
      radians(gFov),
      gScreenWidth / gScreenHeight,
      0.1,
      100,
    );
    ourShader.setMatrix4('projection', projection);
    // camera/view transformation
    final view = makeViewMatrix(
      gCameraPos,
      gCameraPos + gCameraFront,
      gCameraUp,
    );
    ourShader.setMatrix4('view', view);
    // render boxes
    for (var i = 0; i < 10; i++) {
      final model = Matrix4.identity()..translateByVector3(cubePositions[i]);
      final angle = 20.0 * i;
      model.rotate(Vector3(1, 0.3, 0.5), radians(angle));
      ourShader.setMatrix4('model', model);
      glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    sdlGlSwapWindow(window);
  }

  while (!quit) {
    final currentFrame = sdlGetTicks() / 1000;
    gDeltaTime = currentFrame - gLastFrame;
    gLastFrame = currentFrame;
    // input
    // -----
    processInput();
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
        // sdl: whenever the mouse moves, this callback is called
        // ------------------------------------------------------
        case SdlkEvent.mouseMotion:
          final xpos = event.motion.ref.x;
          final ypos = event.motion.ref.y;
          if (gFirstMouse) {
            gLastX = xpos;
            gLastY = ypos;
            gFirstMouse = false;
          }
          var xoffset = xpos - gLastX;
          // reversed since y-coordinates go from bottom to top
          var yoffset = gLastY - ypos;
          gLastX = xpos;
          gLastY = ypos;
          // change this value to your liking
          const sensitivity = 0.1;
          xoffset *= sensitivity;
          yoffset *= sensitivity;
          gYaw += xoffset;
          gPitch += yoffset;
          // make sure that when pitch is out of bounds, screen doesn't get flipped
          if (gPitch > 89.0) {
            gPitch = 89.0;
          }
          if (gPitch < -89.0) {
            gPitch = -89.0;
          }
          final front = Vector3(
            math.cos(radians(gYaw)) * math.cos(radians(gPitch)),
            math.sin(radians(gPitch)),
            math.sin(radians(gYaw)) * math.cos(radians(gPitch)),
          );
          gCameraFront = front.normalized();
        // sdl: whenever the mouse scroll wheel scrolls, this callback is called
        // ---------------------------------------------------------------------
        case SdlkEvent.mouseWheel:
          gFov -= event.wheel.ref.y;
          if (gFov < 1.0) {
            gFov = 1.0;
          }
          if (gFov > 45.0) {
            gFov = 45.0;
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

// process all input: query sdl whether relevant keys are pressed/released this frame and react accordingly
// ---------------------------------------------------------------------------------------------------------
void processInput() {
  final cameraSpeed = 2.5 * gDeltaTime;
  final keys = sdlGetKeyboardState(nullptr);
  if (keys[SdlkScancode.w] != 0) {
    gCameraPos += gCameraFront.scaled(cameraSpeed);
  }
  if (keys[SdlkScancode.s] != 0) {
    gCameraPos -= gCameraFront.scaled(cameraSpeed);
  }
  if (keys[SdlkScancode.a] != 0) {
    gCameraPos -= gCameraFront.cross(gCameraUp).scaled(cameraSpeed);
  }
  if (keys[SdlkScancode.d] != 0) {
    gCameraPos += gCameraFront.cross(gCameraUp).scaled(cameraSpeed);
  }
}
