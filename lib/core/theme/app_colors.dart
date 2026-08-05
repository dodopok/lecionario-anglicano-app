import 'package:flutter/material.dart';

/// A restrained palette inspired by old prayer books: paper, pine and copper.
class AppColors {
  AppColors._();

  static const paper = Color(0xFFF4F0E7);
  static const paperDeep = Color(0xFFEAE3D5);
  static const cream = Color(0xFFFBF9F4);
  static const ink = Color(0xFF19372E);
  static const inkSoft = Color(0xFF315247);
  static const muted = Color(0xFF718078);
  static const mutedLight = Color(0xFF9BA59C);
  static const pine = Color(0xFF214D3D);
  static const pineDeep = Color(0xFF123229);
  static const pineWash = Color(0xFFDDE8DF);
  static const copper = Color(0xFFB9794D);
  static const copperDark = Color(0xFF8E5637);
  static const copperWash = Color(0xFFF0DFD0);
  static const line = Color(0xFFDDD6C8);
  static const white = Color(0xFFFFFDF9);
  static const danger = Color(0xFF9B4F48);

  static const liturgicalGreen = Color(0xFF557A55);
  static const liturgicalWhite = Color(0xFFB88A47);
  static const liturgicalRed = Color(0xFFA5574E);
  static const liturgicalPurple = Color(0xFF756184);
  static const liturgicalRose = Color(0xFFB67886);
  static const liturgicalBlue = Color(0xFF53738A);
  static const liturgicalBlack = Color(0xFF3D403C);

  static Color liturgical(String value) {
    return switch (value.toLowerCase()) {
      'branco' || 'white' => liturgicalWhite,
      'vermelho' || 'red' => liturgicalRed,
      'roxo' || 'violeta' || 'purple' => liturgicalPurple,
      'rosa' || 'rose' => liturgicalRose,
      'azul' || 'blue' => liturgicalBlue,
      'verde' || 'green' => liturgicalGreen,
      'preto' || 'black' => liturgicalBlack,
      _ => mutedLight,
    };
  }
}
