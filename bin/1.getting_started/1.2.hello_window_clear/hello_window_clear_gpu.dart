// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/1.1.hello_window/hello_window.cpp
// https://github.com/libsdl-org/SDL/blob/main/test/testgpu_simple_clear.c
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;
const int gGpuFormats =
    SDL_GPU_SHADERFORMAT_SPIRV |
    SDL_GPU_SHADERFORMAT_DXBC |
    SDL_GPU_SHADERFORMAT_DXIL |
    SDL_GPU_SHADERFORMAT_METALLIB;

int main() {
  // sdl: Initialize and configure
  // -----------------------------
  if (!sdlInit(SdlkInit.video)) {
    return -1;
  }
  // sdl window creation
  // -------------------
  final window = sdlCreateWindow(
    'LearnOpenGL',
    gScreenWidth,
    gScreenHeight,
    SdlkWindow.resizable,
  );
  if (window == nullptr) {
    print('Failed to create SDL window');
    sdlQuit();
    return -1;
  }
  final device = sdlCreateGpuDevice(gGpuFormats, true, null);
  if (device == nullptr) {
    print('Failed to create GPU device');
    sdlDestroyWindow(window);
    sdlQuit();
    return -1;
  }
  if (!sdlClaimWindowForGpuDevice(device, window)) {
    print('sdlClaimWindowForGpuDevice failed: ${sdlGetError()}');
    sdlDestroyWindow(window);
    sdlQuit();
    return -1;
  }
  final mode = sdlGetCurrentDisplayMode(sdlGetPrimaryDisplay());
  if (mode != nullptr) {
    print((mode.ref.format >> 8) & 0xff);
  }
  // render loop
  // -----------
  var quit = false;
  final event = calloc<SdlEvent>();
  final swapchainTexture = calloc<Pointer<SdlGpuTexture>>();
  final swapchainTextureWidth = calloc<Uint32>();
  final swapchainTextureHeight = calloc<Uint32>();
  void draw() {
    final commandBuffer = sdlAcquireGpuCommandBuffer(device);
    if (sdlWaitAndAcquireGpuSwapchainTexture(
      commandBuffer,
      window,
      swapchainTexture,
      swapchainTextureWidth,
      swapchainTextureHeight,
    )) {
      if (swapchainTextureWidth.value > 0 && swapchainTextureHeight.value > 0) {
        final colorTargetInfo = calloc<SdlGpuColorTargetInfo>();
        colorTargetInfo.ref.texture = swapchainTexture.value;
        colorTargetInfo.clearColor.ref.r = 0.2;
        colorTargetInfo.clearColor.ref.g = 0.3;
        colorTargetInfo.clearColor.ref.b = 0.3;
        colorTargetInfo.clearColor.ref.a = 1.0;
        colorTargetInfo.ref.loadOp = SDL_GPU_LOADOP_CLEAR;
        colorTargetInfo.ref.storeOp = SDL_GPU_STOREOP_STORE;
        final renderpass = sdlBeginGpuRenderPass(
          commandBuffer,
          colorTargetInfo,
          1,
          nullptr,
        );
        sdlEndGpuRenderPass(renderpass);
        sdlSubmitGpuCommandBuffer(commandBuffer);
        colorTargetInfo.callocFree();
      } else {
        sdlCancelGpuCommandBuffer(commandBuffer);
      }
    } else {
      sdlCancelGpuCommandBuffer(commandBuffer);
    }
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
  swapchainTexture.callocFree();
  swapchainTextureWidth.callocFree();
  swapchainTextureHeight.callocFree();
  sdlReleaseWindowFromGpuDevice(device, window);
  sdlDestroyGpuDevice(device);
  sdlDestroyWindow(window);
  sdlQuit();
  return 0;
}
