import 'package:flutter/material.dart';

/// Model to represent a single segment
class Segment {
  final Color color; // Color of the phase

  Segment({
    required this.color,
  });
}

/// Model to represent a case
class TrafficCase {
  final int duration; // Duration in seconds
  final Color direction1Color;
  final Color direction2Color;
  final Color pedestrian1Color;
  final Color pedestrian2Color;

  TrafficCase({
    required this.duration,
    required this.direction1Color,
    required this.direction2Color,
    required this.pedestrian1Color,
    required this.pedestrian2Color,
  });
}
