import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppGradients {
  static const accent = LinearGradient(
    begin: Alignment(-1.3914, 1.0057999999999998),
    end: Alignment(2.0484, -1.3258),
    stops: [0, 1],
    colors: [Color(0xffff97cd), Color(0xffff349d)],
  );

  static const linear2 = LinearGradient(
    begin: Alignment(-1.3914, 1.0057999999999998),
    end: Alignment(2.0484, -1.3258),
    stops: [0, 1],
    colors: [Color(0xffffcee2), Color(0xfff99bb1)],
  );

  static const gradientLinearGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(1, 1.0028000000000001),
    stops: [0, 0.37, 0.72, 1],
    colors: [
      Color(0x4dffffff),
      Color(0x26ffffff),
      Color(0x1affffff),
      Color(0x4dffffff),
    ],
  );

  static const gradientLinearSecondaryGradient = LinearGradient(
    begin: Alignment(-0.6918, 1),
    end: Alignment(0.679, -1),
    stops: [0, 1],
    colors: [Color(0xffffcee2), Color(0xfff99bb1)],
  );

  static const gradientLinearPrimaryGradient = LinearGradient(
    begin: Alignment(-0.28200000000000003, 1),
    end: Alignment(0.28200000000000003, -1),
    stops: [0, 1],
    colors: [Color(0xffff97cd), Color(0xffff349d)],
  );

  static const gradientLinearGr4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.2822, 1],
    colors: [Color(0xffff7f65), Color(0xfff63d68), Color(0xffffd9d1)],
  );

  static const gradientLinearGr5 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.6112, 0.1976),
    stops: [0, 0.5312, 1],
    colors: [Color(0xfffbb1c3), Color(0xff2834e7), Color(0xff000000)],
  );

  static const gradientLinearGr6 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.6112, 0.1976),
    stops: [0, 0.5312, 1],
    colors: [Color(0xffffd9d1), Color(0xff7042d2), Color(0xff000000)],
  );

  static const gradientLinearGr7 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.6112, 0.1976),
    stops: [0, 0.5312, 1],
    colors: [Color(0xff91f3f3), Color(0xff4648ff), Color(0xff000000)],
  );

  static const gradientLinearGr8 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.5524, 0.4710000000000001),
    stops: [0, 0.2822, 1],
    colors: [Color(0xffffccc1), Color(0xfff63d68), Color(0xff000000)],
  );

  static const gradientGreyGrey1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 1],
    colors: [Color(0xff16171f), Color(0xff000000)],
  );

  static const gradientGreyGrey2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 1],
    colors: [Color(0xff20212b), Color(0xff16171f)],
  );

  static const gradientGreyGrey3 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 1],
    colors: [Color(0xff373946), Color(0xff16171f)],
  );

  static const gradientGreyGrey4 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 1],
    colors: [Color(0xff4d4f60), Color(0xff292a36)],
  );

  static const backgroundLinearGlass = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    stops: [0, 0.3702, 0.7212, 1],
    colors: [
      Color(0x4dffffff),
      Color(0x26ffffff),
      Color(0x1affffff),
      Color(0x4dffffff),
    ],
  );

  static const glassStroke = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    transform: GradientRotation(45 * (math.pi / 180)),
    stops: [0, 0.3702, 0.7212, 1],
    colors: [
      Color(0x3FFFFFFF), // was 6 * 5, now 9 * 7
      Color(0x1CFFFFFF), // was 3 * 5, now 4 * 7
      Color(0x15FFFFFF), // was 2 * 5, now 3 * 7
      Color(0x31FFFFFF), // was 6 * 5, now 7 * 7
    ],
  );

  static const glassStrokeLight = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    stops: [0, 0.3702, 0.7212, 1],
    colors: [
      Color(0x4d000000),
      Color(0x26000000),
      Color(0x1a000000),
      Color(0x4d000000),
    ],
  );

  static const darkStroke = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    transform: GradientRotation(45 * (math.pi / 180)),
    stops: [0, 0.3702, 0.7212, 1],
    colors: [
      Color(0xFF313131),
      Color(0xFF232323),
      Color(0xFF1E1E1E),
      Color(0xFF313131),
    ],
  );

  static const softDarkStroke = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    transform: GradientRotation(45 * (math.pi / 180)),
    stops: [0, 0.7212, 1],
    colors: [Color(0xFF6F6F6F), Color(0xFF3D3D3D), Color(0xFF6F6F6F)],
  );

  static const lightStroke = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    transform: GradientRotation(45 * (math.pi / 180)),
    stops: [0, 0.3702, 0.7212, 1],
    colors: [
      Color(0xFFFEFEFE),
      Color(0xFFFCFCFC),
      Color(0xFFF1F1F1),
      Color(0xFFFEFEFE),
    ],
  );

  static const softLightStroke = LinearGradient(
    begin: Alignment(-0.8200000000000001, -0.8),
    end: Alignment(0.72, 0.8200000000000001),
    transform: GradientRotation(45 * (math.pi / 180)),
    stops: [0, 0.7212, 1],
    colors: [Color(0xFFB0B0B0), Color(0xFFD2D2D2), Color(0xFFB0B0B0)],
  );

  static const green = LinearGradient(
    colors: [Color(0xFF97FFBF), Color(0xFF34FF34)],
    begin: Alignment(-0.8, -1),
    end: Alignment(0.8, 1),
  );

  AppGradients._();
}
