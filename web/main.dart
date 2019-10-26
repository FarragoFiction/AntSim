import 'dart:html';

import 'scripts/World.dart';

void main() {
  World world = new World();
  world.attachToScreen(querySelector("#output"));
}
