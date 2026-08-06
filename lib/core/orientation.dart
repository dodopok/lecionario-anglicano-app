import 'package:flutter/services.dart';

/// Shortest side from which a device is treated as a tablet.
const tabletShortestSide = 600.0;

/// Phones stay upright.
///
/// The home is one column meant to be read portrait — on its side a phone has
/// no height for the month, and there is no landscape layout worth rotating
/// into. A tablet has one, and turns freely.
List<DeviceOrientation> allowedOrientations(Size size) {
  if (size.shortestSide >= tabletShortestSide) return DeviceOrientation.values;
  return const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
}
