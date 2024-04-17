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
    xVel += (circle2Pos.dx - circlePos.dx) / 1000;
    yVel += (circle2Pos.dy - circlePos.dy) / 1000;
    //xVel2 += (circlePos.dx - circle2Pos.dx).sign / 10;
    //yVel2 += (circlePos.dy - circle2Pos.dy).sign / 10;
    circlePos += Offset(xVel, 0);
    circlePos += Offset(0, yVel);

    circle2Pos += Offset(xVel2, 0);
    circle2Pos += Offset(0, yVel2);
    renderApp(this);
  }

  double yVel = 0;
  double xVel = 0;
  double yVel2 = 10;
  double xVel2 = 0;
  Offset circlePos = const Offset(0, 0);
  Offset circle2Pos = const Offset(0, 0);
  void render(Canvas cv) {
    cv.drawCircle(
      (circlePos - circle2Pos) + window.physicalSize.center(Offset.zero),
      20,
      Paint()..color = const Color(0xFF00FF00),
    );
    cv.drawCircle(
      window.physicalSize.center(Offset.zero),
      20,
      Paint()..color = const Color(0xFFFF0000),
    );
  }

  void handlePointerEvent(PointerEvent event) {
    if (event.isPointerDown) {
      circlePos = (event.position - window.physicalSize.center(Offset.zero)) +
          circle2Pos;
      yVel = 0;
      xVel = 0;
      renderApp(this);
    }
  }
}
