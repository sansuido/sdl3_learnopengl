// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/1.1.hello_window/hello_window.cpp
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;

int main() {
  // sdl: Initialize and configure
  // -----------------------------
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
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  while (!quit) {
    // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
    // ------------------------------------------------------------------------------
    sdlGlSwapWindow(window);
    while (sdlPollEvent(event)) {
      switch (event.type) {
        case SdlkEvent.quit:
          quit = true;
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
  event.callocFree();
  sdlGlDestroyContext(context);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
