// https://github.com/JoeyDeVries/LearnOpenGL/blob/master/includes/learnopengl/camera.h
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart';

// Defines several possible options for camera movement. Used as abstraction to stay away from window-system specific input methods
enum CameraMovement { forward, backward, left, right }

// Default camera values
const gYaw = -90.0;
const gPitch = 0.0;
const gSpeed = 2.5;
const gSensitivity = 0.1;
const gZoom = 45.0;

class Camera {
  Camera({
    Vector3? position,
    Vector3? worldUp,
    this.yaw = gYaw,
    this.pitch = gPitch,
  }) {
    if (position != null) {
      this.position = position;
    }
    if (worldUp != null) {
      this.worldUp = worldUp;
    }
    updateCameraVectors();
  }
  var position = Vector3(0, 0, 0);
  var front = Vector3(0, 0, -1);
  Vector3? up;
  Vector3? right;
  var worldUp = Vector3(0, 1, 0);
  late double yaw;
  late double pitch;
  double movementSpeed = gSpeed;
  double mouseSensitivity = gSensitivity;
  double zoom = gZoom;

  // returns the view matrix calculated using Euler Angles and the LookAt Matrix
  Matrix4 getViewMatrix() => makeViewMatrix(position, position + front, up!);

  // processes input received from any keyboard-like input system. Accepts input parameter in the form of camera defined ENUM (to abstract it from windowing systems)
  void processKeyboard(CameraMovement direction, double deltaTime) {
    final velocity = movementSpeed * deltaTime;
    switch (direction) {
      case CameraMovement.forward:
        position += front.scaled(velocity);
      case CameraMovement.backward:
        position -= front.scaled(velocity);
      case CameraMovement.left:
        position -= right!.scaled(velocity);
      case CameraMovement.right:
        position += right!.scaled(velocity);
    }
  }

  void processMouseMovement(
    double xoffset,
    double yoffset, {
    constrainPitch = true,
  }) {
    var xoffset0 = xoffset;
    var yoffset0 = yoffset;
    xoffset0 *= mouseSensitivity;
    yoffset0 *= mouseSensitivity;
    yaw += xoffset0;
    pitch += yoffset0;
    // make sure that when pitch is out of bounds, screen doesn't get flipped
    if (constrainPitch) {
      if (pitch > 89.0) {
        pitch = 89.0;
      }
      if (pitch < -89.0) {
        pitch = 89.0;
      }
    }
    // update Front, Right and Up Vectors using the updated Euler angles
    updateCameraVectors();
  }

  void processMouseScroll(double yoffset) {
    zoom -= yoffset;
    if (zoom < 1.0) {
      zoom = 1.0;
    }
    if (zoom > 45.0) {
      zoom = 45.0;
    }
  }

  // calculate the new Front vector
  void updateCameraVectors() {
    front.x = math.cos(radians(yaw)) * math.cos(radians(pitch));
    front.y = math.sin(radians(pitch));
    front.z = math.sin(radians(yaw)) * math.cos(radians(pitch));
    front.normalize();
    // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    right = front.cross(worldUp).normalized();
    up = right!.cross(front).normalized();
  }
}
