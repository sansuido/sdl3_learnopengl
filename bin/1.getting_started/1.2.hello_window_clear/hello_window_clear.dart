// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/1.2.hello_window_clear/hello_window_clear.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';

// settings
const gScrWidth = 800;
const gScrHeight = 600;

int main() {
  // sdl: Initialize and configure
  // -----------------------------
  if (!sdlInit(SDL_INIT_VIDEO)) {
    return -1;
  }
  sdlGlSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
  sdlGlSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
  sdlGlSetAttribute(SDL_GL_DOUBLEBUFFER, 1);
  // sdl window creation
  final window = sdlCreateWindow(
    'LearnOpenGL',
    gScrWidth,
    gScrHeight,
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
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  while (!quit) {
    // render
    // ------
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    sdlGlSwapWindow(window);
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
  // sdl: terminate, clearing all previously allocated SDL resources.
  // ----------------------------------------------------------------
  calloc.free(event);
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
