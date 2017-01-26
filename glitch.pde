import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;
UserMask userMask;

boolean drawMeSomeMotherfuckingRainbows;
boolean displayVideo;
boolean threshold;
boolean maskUsers;
boolean record;

void setup() {
  size(640, 480);
  frameRate(30);
  context = new SimpleOpenNI(this);

  drawMeSomeMotherfuckingRainbows = true;
  displayVideo = true;
  threshold = true;
  maskUsers = true;
  record = false;

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
        // video = userMask.mask(video, context.userMap());
        userMask.mask_over(video, context.userMap());
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
      println(record ? "Recording frames!" : "Stopped recording");
    break;
    case 'u':
      maskUsers = !maskUsers;
    break;
    case 't':
      threshold = !threshold;
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
    "(T) threshold video",
    "(U) mask threshold by users",
    "(F) record frames",
  };
  printArray(messages);
}
