//https://github.com/JoeyDeVries/LearnOpenGL/blob/master/includes/learnopengl/shader_m.h
import 'dart:io';

import 'package:sdl3/sdl3opengl.dart';
import 'package:vector_math/vector_math.dart';

class Shader {
  Shader({
    String? vertexShaderSource,
    String? vertexFilePath,
    String? fragmentShaderSource,
    String? fragmentFilePath,
  }) {
    var vertexShaderSource0 = vertexShaderSource;
    var fragmentShaderSource0 = fragmentShaderSource;
    id = glCreateProgram();
    if (vertexShaderSource0 == null && vertexFilePath != null) {
      vertexShaderSource0 = File(vertexFilePath).readAsStringSync();
    }
    if (vertexShaderSource0 != null) {
      final vertexShaderID = glCreateShader(GL_VERTEX_SHADER);
      glxShaderSource(vertexShaderID, vertexShaderSource0);
      glCompileShader(vertexShaderID);
      if (_checkCompileErrors(vertexShaderID, 'VERTEX')) {
        glAttachShader(id, vertexShaderID);
      }
      glDeleteShader(vertexShaderID);
    }
    if (fragmentShaderSource0 == null && fragmentFilePath != null) {
      fragmentShaderSource0 = File(fragmentFilePath).readAsStringSync();
    }
    if (fragmentShaderSource0 != null) {
      final fragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);
      glxShaderSource(fragmentShaderID, fragmentShaderSource0);
      glCompileShader(fragmentShaderID);
      if (_checkCompileErrors(fragmentShaderID, 'FRAGMENT')) {
        glAttachShader(id, fragmentShaderID);
      }
      glDeleteShader(fragmentShaderID);
    }
    glLinkProgram(id);
    if (!_checkCompileErrors(id, 'PROGRAM')) {
      glDeleteProgram(id);
      id = 0;
    }
  }
  var id = 0;

  void use() {
    glUseProgram(id);
  }

  void delete() {
    if (id != 0) {
      glDeleteProgram(id);
      id = 0;
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void setBool(String name, bool value) {
    glUniform1i(glGetUniformLocation(id, name), value ? GL_TRUE : GL_FALSE);
  }

  void setInt(String name, int value) {
    glUniform1i(glGetUniformLocation(id, name), value);
  }

  void setFloat(String name, double value) {
    glUniform1f(glGetUniformLocation(id, name), value);
  }

  void setVector2(String name, Vector2 value) {
    glxUniform2fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setVector3(String name, Vector3 value) {
    glxUniform3fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setVector4(String name, Vector4 value) {
    glxUniform4fv(glGetUniformLocation(id, name), 1, value.storage);
  }

  void setMatrix2(String name, Matrix2 value) {
    glxUniformMatrix2fv(
      glGetUniformLocation(id, name),
      1,
      GL_FALSE,
      value.storage,
    );
  }

  void setMatrix3(String name, Matrix3 value) {
    glxUniformMatrix3fv(
      glGetUniformLocation(id, name),
      1,
      GL_FALSE,
      value.storage,
    );
  }

  void setMatrix4(String name, Matrix4 value) {
    glxUniformMatrix4fv(
      glGetUniformLocation(id, name),
      1,
      GL_FALSE,
      value.storage,
    );
  }

  bool _checkCompileErrors(int shader, String type) {
    var success = GL_FALSE;
    var bufSize = 0;
    switch (type) {
      case 'PROGRAM':
        success = glxGetProgramiv(shader, GL_LINK_STATUS);
        if (success != GL_TRUE) {
          print(
            'ERROR::PROGRAM_LINKING_ERROR of type: '
            '$type',
          );
          bufSize = glxGetProgramiv(shader, GL_INFO_LOG_LENGTH);
          if (bufSize > 1) {
            print(glxGetProgramInfoLog(shader, bufSize));
          }
        }
      default:
        success = glxGetShaderiv(shader, GL_COMPILE_STATUS);
        if (success != GL_TRUE) {
          print(
            'ERROR::SHADER_COMPILATION_ERROR of type: '
            '$type',
          );
          bufSize = glxGetShaderiv(shader, GL_INFO_LOG_LENGTH);
          if (bufSize > 1) {
            print(glxGetShaderInfoLog(shader, bufSize));
          }
        }
    }
    return success == GL_TRUE;
  }
}
