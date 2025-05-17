import 'dart:ui';

late final FlutterView window = PlatformDispatcher.instance.views.first;

void main() {
  Application app = Application();
  PlatformDispatcher.instance.onPointerDataPacket =
      (PointerDataPacket packet) =>
          app.handlePointerEvent(PointerEvent(packet));
  PlatformDispatcher.instance.onBeginFrame = (_) {
    app.frame();
    PlatformDispatcher.instance.scheduleFrame();
  };
  renderApp(app);
  PlatformDispatcher.instance.scheduleFrame();
}

class PointerEvent {
  PointerEvent(this._packet);
  final PointerDataPacket _packet;
  @override
  String toString() => "${_packet.data.first.change}";
  bool get isClickEnd => _packet.data.first.change == PointerChange.up;
  bool get isClickStart => _packet.data.first.change == PointerChange.down;
  bool get isPointerDown => _packet.data.first.buttons & 0x01 != 0;
  Offset get position =>
      Offset(_packet.data.first.physicalX, _packet.data.first.physicalY);
}

void renderApp(Application app) {
  PictureRecorder pr = PictureRecorder();
  app.render(Canvas(pr));
  SceneBuilder sb = SceneBuilder();
  sb.addPicture(Offset.zero, pr.endRecording());
  window.render(sb.build());
}

class Application {
  void frame() {
    Offset offset = circle2Pos - circlePos;
    if (offset != Offset.zero) {
      velocity += (offset * 10000) / (offset.distance * offset.distanceSquared);
      velocity2 -=
          (offset / 10000) / (offset.distance * offset.distanceSquared);
    }
    circlePos += velocity;

    circle2Pos += velocity2;
    renderApp(this);
  }

  Offset velocity = const Offset(0, 0);
  Offset velocity2 = const Offset(0, 0);
  Offset circlePos = Offset.zero;
  Offset circle2Pos = Offset.zero;
  Offset? startDragPos;
  late Offset currentMousePos;
  Offset get originInSC =>
      window.physicalSize.center(Offset.zero) - circle2Pos;//(circle2Pos + (circlePos - circle2Pos) / 2);
  void render(Canvas cv) {
    cv.drawCircle(originInSC, 15, Paint()..color=const Color(0xFFFFFF00));
    cv.drawCircle(originInSC+circle2Pos+(circlePos-circle2Pos)/2, 15, Paint()..color=const Color(0xFFFFFFFF));
    cv.drawCircle(
      circlePos + originInSC,
      20,
      Paint()..color = const Color(0xFF00FF00),
    );
    cv.drawCircle(
      circle2Pos + originInSC,
      20,
      Paint()..color = const Color(0xFFFF0000),
    );
    if(startDragPos != null) {
    cv.drawLine(startDragPos!, currentMousePos, Paint()..color = const Color(0xFFFFFFFF));
    cv.drawCircle(startDragPos!, 20, Paint()..color = const Color(0x7700FF00));
    }
  }

  void handlePointerEvent(PointerEvent event) {
    if (event.isClickStart) {
      startDragPos = event.position;
    }
    currentMousePos = event.position;
    if(event.isClickEnd) {
      circlePos = startDragPos! - originInSC;
      velocity = currentMousePos - startDragPos!;
      startDragPos = null;
    }
  }
}
