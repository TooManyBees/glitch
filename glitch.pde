import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;
UserMask userMask;

boolean drawMeSomeMotherfuckingRainbows;
boolean displayVideo;
boolean threshold;
boolean maskUsers;
boolean record;
boolean bordered;

void setup() {
  size(640, 480);
  context = new SimpleOpenNI(this);

  drawMeSomeMotherfuckingRainbows = true;
  displayVideo = true;
  threshold = true;
  maskUsers = true;
  record = false;
  bordered = true;

  if (!context.isInit()) {
    println("We fucked up somehow!");
    exit();
    return;
  }

  context.setMirror(true);
  context.enableDepth();
  context.enableUser();
  context.enableRGB();

  colorMode(HSB, 255, 100, 100);
  glitchBuffer = new GlitchBuffer(width, height);
  userMask = new UserMask();

  printHelp();
}

void draw() {
  context.update();

  background(0);
  glitchBuffer.feed(context.depthImage());

  if (displayVideo) {
    PImage video = context.rgbImage();
    video = sizeVideoToDepth(video);

    if (threshold) {
      video.filter(THRESHOLD, 0.2);
      if (maskUsers) {
        video = userMask.mask(video, context.userMap());
      }
    }

    image(video, 0, 0);
  }

  if (drawMeSomeMotherfuckingRainbows) {
    image(glitchBuffer.getRainbow(), 0, 0);
  }

  if (record) {
    saveFrame();
  }
}

void keyPressed() {
  switch (key) {
    case 'v':
      displayVideo = !displayVideo;
    break;
    case 'r':
      drawMeSomeMotherfuckingRainbows = !drawMeSomeMotherfuckingRainbows;
    break;
    case 'f':
      record = !record;
      if (record) {
        frameRate(30);
      } else {
        frameRate(60);
      }
      println(record ? "Recording frames!" : "Stopped recording");
    break;
    case 'u':
      maskUsers = !maskUsers;
    break;
    case 't':
      threshold = !threshold;
    break;
    case 'b':
      bordered = !bordered;
      removeBorder(bordered);
    break;
  }

  if (key == CODED) {
    if (keyCode == UP) {
      glitchBuffer.crankUpTheRainbows();
      println("RAINBOW FACTOR "+glitchBuffer.factor()+" ENGAGE!");
    } else {
      glitchBuffer.dialBackTheRainbows();
      println("RAINBOW FACTOR "+glitchBuffer.factor()+" ENGAGE!");
    }
  }
}

void printHelp() {
  String[] messages = {
    "(V) draw video",
    "(R) MOTHERFUCKING RAINBOWS",
    "(B) remove border (buggy)",
    "(T) threshold video",
    "(U) mask threshold by users",
    "(F) record frames",
  };
  printArray(messages);
}

void removeBorder(boolean b) {
  frame.removeNotify();
  frame.setUndecorated(b);
  frame.addNotify();
}
