import 'package:flutter/material.dart';

/// Placeholder devices and scenes: there is no Google Home / Xiaomi Home API yet,
/// so toggles only change in-memory state.
enum Device { living, bedroom, fan, ac }

const deviceInfo = {
  Device.living: ('Living room light', Icons.lightbulb_outline),
  Device.bedroom: ('Bedroom light', Icons.lightbulb_outline),
  Device.fan: ('Fan', Icons.mode_fan_off_outlined),
  Device.ac: ('AC', Icons.ac_unit),
};

enum Scene { morning, movie, night }

/// Label, icon and the device states a scene sets (devices not listed stay as they are).
const sceneInfo = {
  Scene.morning: ('Good morning', Icons.wb_sunny_outlined, {Device.living: true, Device.bedroom: true, Device.fan: false, Device.ac: false}),
  Scene.movie: ('Movie', Icons.movie_outlined, {Device.living: false, Device.bedroom: false}),
  Scene.night: ('Good night', Icons.bedtime_outlined, {Device.living: false, Device.bedroom: false, Device.fan: false, Device.ac: false}),
};
