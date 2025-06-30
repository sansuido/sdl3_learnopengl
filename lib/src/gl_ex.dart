import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:sdl3/sdl3.dart';
import 'package:sdl3/sdl3opengl.dart';

// lib_gl: 607
void glexDeleteTextures(List<int> textures) {
  final texture = calloc<Uint32>();
  for (final id in textures) {
    texture.value = id;
    glDeleteTextures(1, texture);
  }
  calloc.free(texture);
}

// lib_gl: 687
void glexDrawElements(int mode, int count, int type, int indices) {
  final indicesPointer = Pointer<Void>.fromAddress(indices);
  glDrawElements(mode, count, type, indicesPointer);
}

// lib_gl: 997
List<int> glexGenTextures(int n) {
  final result = <int>[];
  final textures = calloc<Uint32>(n);
  glGenTextures(n, textures);
  for (var i = 0; i < n; i++) {
    result.add((textures + i).value);
  }
  calloc.free(textures);
  return result;
}

// lib_gl: 3030
void glexTexImage2D(
  int target,
  int level,
  int internalformat,
  int width,
  int height,
  int border,
  int format,
  Uint8List pixels, {
  bool inverted = true,
}) {
  Pointer<Uint8> callocPixelsPointer(
    Uint8List pixels,
    int height, {
    bool inverted = true,
  }) {
    final pixelsPointer = calloc<Uint8>(pixels.length);
    final radix = pixels.length ~/ height;
    var index = 0;
    for (var h = 0; h < height; h++) {
      var pos = h;
      if (inverted) {
        pos = height - h - 1;
      }
      final values = pixels.getRange(pos * radix, (pos + 1) * radix);
      for (final value in values) {
        (pixelsPointer + index).value = value;
        index++;
      }
    }
    return pixelsPointer;
  }

  final pixelsPointer = callocPixelsPointer(pixels, height, inverted: inverted);
  glTexImage2D(
    target,
    level,
    internalformat,
    width,
    height,
    border,
    format,
    GL_UNSIGNED_BYTE,
    pixelsPointer.cast<Void>(),
  );
  calloc.free(pixelsPointer);
}

// lib_glad_version_1_4:
void glexDeleteBuffers(List<int> buffers) {
  final buffer = calloc<Uint32>();
  for (final id in buffers) {
    buffer.value = id;
    glDeleteBuffers(1, buffer);
  }
  calloc.free(buffer);
}

// lib_glad_version_1_4:
void glexBufferUint32(int target, List<int> list, int usage) {
  final bufferData = calloc<Uint32>(list.length);
  for (var i = 0; i < list.length; i++) {
    (bufferData + i).value = list[i];
  }
  glBufferData(
    target,
    Pointer<Uint32>.fromAddress(sizeOf<Uint32>() * list.length),
    bufferData.cast<Void>(),
    usage,
  );
  calloc.free(bufferData);
}

// lib_glad_version_1_4:
void glexBufferFloat(int target, List<double> buffer, int usage) {
  final bufferData = calloc<Float>(buffer.length);
  for (var i = 0; i < buffer.length; i++) {
    (bufferData + i).value = buffer[i];
  }
  glBufferData(
    target,
    Pointer<Uint32>.fromAddress(sizeOf<Float>() * buffer.length),
    bufferData.cast<Void>(),
    usage,
  );
  calloc.free(bufferData);
}

// lib_glad_version_1_4:
List<int> glexGenBuffers(int n) {
  final result = <int>[];
  final buffers = calloc<Uint32>(n);
  glGenBuffers(n, buffers);
  for (var i = 0; i < n; i++) {
    result.add((buffers + i).value);
  }
  calloc.free(buffers);
  return result;
}

// lib_glad_version_2_0:
String glexGetProgramInfoLog(int program, int bufSize) {
  String result;
  final infoLog = calloc<Int8>(bufSize);
  final length = calloc<Uint32>();
  glGetProgramInfoLog(program, bufSize, length, infoLog);
  result = infoLog.cast<Utf8>().toDartString();
  infoLog.callocFree();
  length.callocFree();
  return result;
}

// lib_glad_version_2_0:
int glexGetProgramiv(int program, int pname) {
  final paramPtr = calloc<Int32>();
  int result;
  glGetProgramiv(program, pname, paramPtr);
  result = paramPtr.value;
  calloc.free(paramPtr);
  return result;
}

// lib_glad_version_2_0:
String glexGetShaderInfoLog(int shader, int bufSize) {
  String result;
  final infoLog = calloc<Int8>(bufSize);
  final length = calloc<Uint32>();
  glGetShaderInfoLog(shader, bufSize, length, infoLog);
  result = infoLog.cast<Utf8>().toDartString();
  length.callocFree();
  infoLog.callocFree();
  return result;
}

// lib_glad_version_2_0:
int glexGetShaderiv(int shader, int pname) {
  int result;
  final params = calloc<Int32>();
  glGetShaderiv(shader, pname, params);
  result = params.value;
  params.callocFree();
  return result;
}

// lib_glad_version_2_0:
void glexShaderSource(int shader, String source) {
  final sourceNative = source.toNativeUtf8();
  final string = calloc<Pointer<Int8>>()..value = sourceNative.cast<Int8>();
  final length = calloc<Int32>()..value = sourceNative.length;
  glShaderSource(shader, 1, string, length);
  length.callocFree();
  string.callocFree();
  sourceNative.callocFree();
}

// lib_glad_version_2_0:
void glexUniform2fv(int location, int count, Float32List value) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniform2fv(location, count, valuePointer);
  valuePointer.callocFree();
}

// lib_glad_version_2_0:
void glexUniform3fv(int location, int count, Float32List value) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniform3fv(location, count, valuePointer);
  calloc.free(valuePointer);
}

// lib_glad_version_2_0:
void glexUniform4fv(int location, int count, Float32List value) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniform4fv(location, count, valuePointer);
  valuePointer.callocFree();
}

// lib_glad_version_2_0:
void glexUniformMatrix2fv(
  int location,
  int count,
  int transpose,
  Float32List value,
) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniformMatrix2fv(location, count, transpose, valuePointer);
  valuePointer.callocFree();
}

// lib_glad_version_2_0:
void glexUniformMatrix3fv(
  int location,
  int count,
  int transpose,
  Float32List value,
) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniformMatrix3fv(location, count, transpose, valuePointer);
  valuePointer.callocFree();
}

// lib_glad_version_2_0:
void glexUniformMatrix4fv(
  int location,
  int count,
  int transpose,
  Float32List value,
) {
  final valuePointer = calloc<Float>(value.length);
  for (var i = 0; i < value.length; i++) {
    (valuePointer + i).value = value[i];
  }
  glUniformMatrix4fv(location, count, transpose, valuePointer);
  valuePointer.callocFree();
}

// lib_glad_version_2_0:
void glexVertexAttribPointer(
  int index,
  int size,
  int type,
  int normalized,
  int stride,
  int pos,
) {
  glVertexAttribPointer(
    index,
    size,
    type,
    normalized,
    stride,
    Pointer<Void>.fromAddress(pos),
  );
}

// lib_glad_arb_vertex_array_object:
void glexDeleteVertexArrays(List<int> arrays) {
  final array = calloc<Uint32>();
  for (final id in arrays) {
    array.value = id;
    glDeleteVertexArrays(1, array);
  }
  calloc.free(array);
}

// lib_glad_arb_vertex_array_object:
List<int> glexGenVertexArrays(int n) {
  final result = <int>[];
  final arrays = calloc<Uint32>(n);
  glGenVertexArrays(n, arrays);
  for (var i = 0; i < n; i++) {
    result.add((arrays + i).value);
  }
  arrays.callocFree();
  return result;
}
