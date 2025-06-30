import 'dart:ffi';
import 'dart:typed_data';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';
import 'gl_ex.dart';

class Texture2d {
  Texture2d({
    this.width = 0,
    this.height = 0,
    this.internalFormat = GL_RGBA,
    this.imageFormat = GL_RGBA,
    this.wrapS = GL_REPEAT,
    this.wrapT = GL_REPEAT,
    this.filterMin = GL_LINEAR,
    this.filterMax = GL_LINEAR,
  }) {
    id = glexGenTextures(1)[0];
  }
  var id = 0;
  int width;
  int height;
  int internalFormat;
  int imageFormat;
  int wrapS;
  int wrapT;
  int filterMin;
  int filterMax;

  void load(String filename) {
    final surface = imgLoad(filename);
    createFromSurface(surface);
    surface.callocFree();
  }

  void createFromSurface(Pointer<SdlSurface> surface) {
    final width = surface.ref.w;
    final height = surface.ref.h;
    final pixels = surface.ref.pixels.cast<Uint8>();
    Pointer<SdlPalette> palette = nullptr;
    final list = <int>[];
    final details = sdlGetPixelFormatDetails(surface.ref.format);
    if (details == nullptr) {
      return;
    }
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final index = x * details.ref.bytesPerPixel + y * surface.ref.pitch;
        var byte = 0;
        if (details.ref.bytesPerPixel == 1) {
          if (palette == nullptr) {
            palette = sdlGetSurfacePalette(surface);
          }
          final pixel = pixels + index;
          final color = (palette.ref.colors.cast<Uint32>() + pixel.value)
              .cast<SdlColor>();
          list
            ..add(color.ref.r)
            ..add(color.ref.g)
            ..add(color.ref.b)
            ..add(color.ref.a);
        } else {
          for (var p = 0; p < details.ref.bytesPerPixel; p++) {
            final pixel = pixels + index + p;
            byte += pixel.value << (p * 8);
          }
          final r = (byte & details.ref.rmask) >> details.ref.rshift;
          final g = (byte & details.ref.gmask) >> details.ref.gshift;
          final b = (byte & details.ref.bmask) >> details.ref.bshift;
          var a = (byte & details.ref.amask) >> details.ref.ashift;
          if (details.ref.amask == 0) {
            a = 255;
          }
          list
            ..add(r)
            ..add(g)
            ..add(b)
            ..add(a);
        }
      }
    }
    surface.unlock();
    generate(width, height, Uint8List.fromList(list));
  }

  void generate(int width, int height, Uint8List data) {
    this.width = width;
    this.height = height;
    // create Texture
    glBindTexture(GL_TEXTURE_2D, id);
    // set Texture wrap and filter modes
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterMin);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterMax);
    glexTexImage2D(
      GL_TEXTURE_2D,
      0,
      internalFormat,
      width,
      height,
      0,
      imageFormat,
      data,
    );
    glGenerateMipmap(GL_TEXTURE_2D);
    // unbind texture
    glBindTexture(GL_TEXTURE_2D, 0);
  }

  void bind() {
    glBindTexture(GL_TEXTURE_2D, id);
  }

  void delete() {
    glexDeleteTextures([id]);
  }
}
