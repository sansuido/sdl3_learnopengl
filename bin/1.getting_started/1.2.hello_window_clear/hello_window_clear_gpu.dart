// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/1.1.hello_window/hello_window.cpp
// https://github.com/libsdl-org/SDL/blob/main/test/testgpu_simple_clear.c
import 'dart:ffi';

import 'package:sdl3/sdl3.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;
const int gGpuFormat = SdlkGpuShaderformat.spirv;

// global variables
Pointer<SdlWindow> gWindow = nullptr;
Pointer<SdlGpuDevice> gDevice = nullptr;

bool appInit() {
  // sdl window creation
  // -------------------
  gWindow = sdlCreateWindow(
    'LearnOpenGL to GPU(Vulkan)',
    gScreenWidth,
    gScreenHeight,
    SdlkWindow.resizable,
  );
  if (gWindow == nullptr) {
    print('Failed to create SDL window: ${sdlGetError()}');
    return false;
  }
  gDevice = sdlCreateGpuDevice(gGpuFormat, true, null);
  if (gDevice == nullptr) {
    print('Failed to create GPU device: ${sdlGetError()}');
    return false;
  }
  if (!sdlClaimWindowForGpuDevice(gDevice, gWindow)) {
    print('sdlClaimWindowForGpuDevice failed: ${sdlGetError()}');
    return false;
  }
  return true;
}

void appQuit() {
  if (gDevice != nullptr && gWindow != nullptr) {
    sdlReleaseWindowFromGpuDevice(gDevice, gWindow);
  }
  if (gDevice != nullptr) {
    sdlDestroyGpuDevice(gDevice);
    gDevice = nullptr;
  }
  if (gWindow != nullptr) {
    sdlDestroyWindow(gWindow);
    gWindow = nullptr;
  }
}

bool appEvent() {
  SdlxEvent? event;
  while ((event = sdlxPollEvent()) != null) {
    if (event is SdlxQuitEvent) {
      return false;
    }
    if (event is SdlxKeyboardEvent && event.type == SdlkEvent.keyDown) {
      if (event.scancode == Sdlk.escape) {
        return false;
      }
    }
  }
  return true;
}

bool appIterate(
  Pointer<SdlGpuCommandBuffer> commandBuffer,
  Pointer<SdlGpuTexture> swapchainTexture,
) {
  // draws a single frame of our application
  // -----------------------------
  final colorTargetInfo = SdlxGpuColorTargetInfo(
    texture: swapchainTexture,
    clearColor: const SdlxFColor(0.2, 0.3, 0.3),
    loadOp: SDL_GPU_LOADOP_CLEAR,
    //storeOp: SDL_GPU_STOREOP_STORE
  );
  final renderpass = sdlxBeginGpuRenderPass(commandBuffer, [colorTargetInfo]);
  sdlEndGpuRenderPass(renderpass);
  sdlSubmitGpuCommandBuffer(commandBuffer);
  return true;
}

int main() {
  // sdl: Initialize and configure
  // -----------------------------
  if (!sdlInit(SdlkInit.video)) {
    return -1;
  }
  if (appInit()) {
    // render loop
    // -----------
    var running = true;
    while (running) {
      // sdl: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
      // ------------------------------------------------------------------------------
      running = appEvent();
      if (!running) {
        break;
      }
      // iterate the application, and rendering
      // ------
      if (running) {
        final commandBuffer = sdlAcquireGpuCommandBuffer(gDevice);
        if (commandBuffer != nullptr) {
          final rec = sdlxWaitAndAcquireGpuSwapchainTexture(
            commandBuffer,
            gWindow,
          );
          if (rec != null) {
            if (rec.width > 0 && rec.height > 0) {
              running = appIterate(commandBuffer, rec.texture);
            } else {
              sdlCancelGpuCommandBuffer(commandBuffer);
            }
          }
        }
      }
    }
  }
  appQuit();
  sdlQuit();
  return 0;
}
