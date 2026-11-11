// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/src/1.getting_started/2.3.hello_triangle_exercise1/hello_triangle_exercise1.cpp
import 'dart:ffi';
import 'dart:typed_data';

import 'package:sdl3/sdl3.dart';

// settings
const gScreenWidth = 800;
const gScreenHeight = 600;
const int gGpuFormat = SdlkGpuShaderformat.spirv;

final gFirstTriangle = [
  -0.9, -0.5, 0.0, // left
  -0.0, -0.5, 0.0, // right
  -0.45, 0.5, 0.0, // top
];
final gSecondTriangle = [
  0.0, -0.5, 0.0, // left
  0.9, -0.5, 0.0, // right
  0.45, 0.5, 0.0, // top
];

const gVertexSource = '''
struct VS_INPUT {
    float3 aPos : POSITION;
};
struct VS_OUTPUT {
    float4 Position : SV_POSITION;
};
VS_OUTPUT main(VS_INPUT input) {
    VS_OUTPUT output;
    output.Position = float4(input.aPos, 1.0f);
    return output;
}
''';

const gFragmentSource = '''
float4 main() : SV_Target {
    return float4(1.0f, 0.5f, 0.2f, 1.0f);
}
''';

// global variables
Pointer<SdlWindow> gWindow = nullptr;
Pointer<SdlGpuDevice> gDevice = nullptr;
Pointer<SdlGpuGraphicsPipeline> gPipeline = nullptr;
Pointer<SdlGpuBuffer> gFirstVertexBuffer = nullptr;
Pointer<SdlGpuBuffer> gSecondVertexBuffer = nullptr;

// create vertex buffer and upload data
Pointer<SdlGpuBuffer> createVertexBuffer(
  Pointer<SdlGpuDevice> device,
  List<double> vertices,
) {
  final bufferSize = vertices.length * sizeOf<Float>();
  final bufferInfo = SdlxGpuBufferCreateInfo(
    usage: SdlkGpuBufferusage.vertex,
    size: bufferSize,
  );
  final vertexBuffer = sdlxCreateGpuBuffer(device, bufferInfo);

  final transferInfo = SdlxGpuTransferBufferCreateInfo(size: bufferSize);
  final transferBuffer = sdlxCreateGpuTransferBuffer(device, transferInfo);

  final mapPtr = sdlMapGpuTransferBuffer(device, transferBuffer, false);
  final floatPtr = mapPtr.cast<Float>();
  for (var i = 0; i < vertices.length; i++) {
    floatPtr[i] = vertices[i];
  }
  sdlUnmapGpuTransferBuffer(device, transferBuffer);

  final commandBuffer = sdlAcquireGpuCommandBuffer(device);
  final copyPass = sdlBeginGpuCopyPass(commandBuffer);

  final location = SdlxGpuTransferBufferLocation(
    transferBuffer: transferBuffer,
  );
  final destination = SdlxGpuBufferRegion(
    buffer: vertexBuffer,
    size: bufferSize,
  );

  sdlxUploadToGpuBuffer(copyPass, location, destination);
  sdlEndGpuCopyPass(copyPass);
  sdlSubmitGpuCommandBuffer(commandBuffer);

  sdlReleaseGpuTransferBuffer(device, transferBuffer);
  return vertexBuffer;
}

Pointer<SdlGpuShader> createShaderFromSource(
  Pointer<SdlGpuDevice> device,
  String source, {
  required int format,
  required int stage,
  int samplerCount = 0,
  int uniformBufferCount = 0,
  int storageBufferCount = 0,
  int storageTextureCount = 0,
  String entrypoint = 'main',
}) {
  Pointer<SdlGpuShader> shader = nullptr;
  Uint8List? shaderCode;
  final hlslInfo = SdlxShaderCrossHlslInfo(
    source: source,
    shaderStage: stage,
    entrypoint: entrypoint,
  );
  switch (format) {
    case SdlkGpuShaderformat.dxbc:
      shaderCode = sdlxShaderCrossCompileDxbcFromHlsl(hlslInfo);
    case SdlkGpuShaderformat.dxil:
      shaderCode = sdlxShaderCrossCompileDxilFromHlsl(hlslInfo);
    case SdlkGpuShaderformat.spirv:
      shaderCode = sdlxShaderCrossCompileSpirvFromHlsl(hlslInfo);
  }
  if (shaderCode == null) {
    print('Failed to compile shader: ${sdlGetError()}');
  } else {
    final shaderInfo = SdlxGpuShaderCreateInfo(
      code: shaderCode,
      entrypoint: entrypoint,
      format: format,
      stage: stage,
      numSamplers: samplerCount,
      numUniformBuffers: uniformBufferCount,
      numStorageBuffers: storageBufferCount,
      numStorageTextures: storageTextureCount,
    );
    shader = sdlxCreateGpuShader(device, shaderInfo);
    if (shader == nullptr) {
      print('Failed to create shader: ${sdlGetError()}');
    }
  }
  return shader;
}

bool appInit() {
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

  gFirstVertexBuffer = createVertexBuffer(gDevice, gFirstTriangle);
  if (gFirstVertexBuffer == nullptr) {
    print('Failed to create first vertex buffer');
    return false;
  }
  gSecondVertexBuffer = createVertexBuffer(gDevice, gSecondTriangle);
  if (gSecondVertexBuffer == nullptr) {
    print('Failed to create second vertex buffer');
    return false;
  }

  final vertexShader = createShaderFromSource(
    gDevice,
    gVertexSource,
    format: gGpuFormat,
    stage: SdlkGpuShaderstage.vertex,
  );
  final fragmentShader = createShaderFromSource(
    gDevice,
    gFragmentSource,
    format: gGpuFormat,
    stage: SdlkGpuShaderstage.fragment,
  );

  if (vertexShader != nullptr && fragmentShader != nullptr) {
    const vertexAttribute = SdlxGpuVertexAttribute(
      format: SdlkGpuVertexelementformat.float3,
    );
    const vertexBufferDescription = SdlxGpuVertexBufferDescription(
      pitch: 12, // float3 (4byte * 3)
    );
    final colorTargetDescription = SdlxGpuColorTargetDescription(
      format: sdlGetGpuSwapchainTextureFormat(gDevice, gWindow),
    );
    final pipelineCreateInfo = SdlxGpuGraphicsPipelineCreateInfo(
      targetInfo: SdlxGpuGraphicsPipelineTargetInfo(
        colorTargetDescriptions: [colorTargetDescription],
      ),
      vertexShader: vertexShader,
      fragmentShader: fragmentShader,
      vertexInputState: const SdlxGpuVertexInputState(
        vertexAttributes: [vertexAttribute],
        vertexBufferDescriptions: [vertexBufferDescription],
      ),
    );
    gPipeline = sdlxCreateGpuGraphicsPipeline(gDevice, pipelineCreateInfo);
    sdlReleaseGpuShader(gDevice, vertexShader);
    sdlReleaseGpuShader(gDevice, fragmentShader);
  }
  return true;
}

void appQuit() {
  if (gFirstVertexBuffer != nullptr) {
    sdlReleaseGpuBuffer(gDevice, gFirstVertexBuffer);
    gFirstVertexBuffer = nullptr;
  }
  if (gSecondVertexBuffer != nullptr) {
    sdlReleaseGpuBuffer(gDevice, gSecondVertexBuffer);
    gSecondVertexBuffer = nullptr;
  }
  if (gPipeline != nullptr) {
    sdlReleaseGpuGraphicsPipeline(gDevice, gPipeline);
    gPipeline = nullptr;
  }
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
  final colorTargetInfo = SdlxGpuColorTargetInfo(
    texture: swapchainTexture,
    clearColor: const SdlxFColor(0.2, 0.3, 0.3),
    loadOp: SdlkGpuLoadop.clear,
  );
  final renderPass = sdlxBeginGpuRenderPass(commandBuffer, [colorTargetInfo]);
  sdlBindGpuGraphicsPipeline(renderPass, gPipeline);

  sdlxBindGpuVertexBuffers(renderPass, [
    SdlxGpuBufferBinding(buffer: gFirstVertexBuffer),
  ]);
  sdlDrawGpuPrimitives(renderPass, 3, 1, 0, 0);

  sdlxBindGpuVertexBuffers(renderPass, [
    SdlxGpuBufferBinding(buffer: gSecondVertexBuffer),
  ]);
  sdlDrawGpuPrimitives(renderPass, 3, 1, 0, 0);

  sdlEndGpuRenderPass(renderPass);
  return true;
}

int main() {
  if (!sdlInit(SdlkInit.video)) {
    return -1;
  }
  if (!sdlShaderCrossInit()) {
    sdlQuit();
    return -1;
  }
  if (appInit()) {
    var running = true;
    while (running) {
      running = appEvent();
      if (!running) {
        break;
      }

      final commandBuffer = sdlAcquireGpuCommandBuffer(gDevice);
      if (commandBuffer != nullptr) {
        final rec = sdlxWaitAndAcquireGpuSwapchainTexture(
          commandBuffer,
          gWindow,
        );
        if (rec != null && rec.width > 0 && rec.height > 0) {
          running = appIterate(commandBuffer, rec.texture);
          sdlSubmitGpuCommandBuffer(commandBuffer);
        } else {
          sdlCancelGpuCommandBuffer(commandBuffer);
        }
      }
    }
  }
  appQuit();
  sdlShaderCrossQuit();
  sdlQuit();
  return 0;
}
