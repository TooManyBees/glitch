import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;
UserMask userMask;

boolean drawMeSomeMotherfuckingRainbows;
boolean displayVideo;
boolean displayBuffer;
boolean threshold;
boolean maskUsers;
boolean record;
boolean paused;

int scaleHeight;
int scaleWidth;

private final int CAMERA_WIDTH = 640;
private final int CAMERA_HEIGHT = 480;

void setup() {
  // size(640, 480, P2D);
  fullScreen(P2D);
  frameRate(30);
  context = new SimpleOpenNI(this);

  drawMeSomeMotherfuckingRainbows = true;
  displayVideo = true;
  displayBuffer = false;
  threshold = true;
  maskUsers = true;
  record = false;
  paused = false;

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
  glitchBuffer = new GlitchBuffer(CAMERA_WIDTH, CAMERA_HEIGHT);
  userMask = new UserMask();

  {
    // Figure out how to scale up image
    float scaleWidthRatio = width / CAMERA_WIDTH;
    float scaleHeightRatio = height / CAMERA_HEIGHT;

    if (CAMERA_HEIGHT * scaleWidthRatio <= height) {
      // if scaling to max width still fits the height
      scaleWidth = width;
      scaleHeight = (int) (CAMERA_HEIGHT * scaleWidthRatio);
    } else {
      scaleHeight = height;
      scaleWidth = (int) (CAMERA_WIDTH * scaleHeightRatio);
    }
    println("Agreed to scale video to "+ scaleWidth +" by "+ scaleHeight + ".");
  }

  imageMode(CENTER);
  background(0);

  printHelp();
}

void draw() {
  context.update();

  glitchBuffer.feed(context.depthImage());

  PGraphics canvas = createGraphics(CAMERA_WIDTH, CAMERA_HEIGHT);
  canvas.beginDraw();
  canvas.background(0);

  if (displayBuffer) {
    canvas.image(glitchBuffer.buffer, 0, 0);
  } else if (displayVideo) {
    PImage video = context.rgbImage();
    video = sizeVideoToDepth(video);

    if (threshold) {
      video.filter(THRESHOLD, 0.2);
      if (maskUsers) {
        userMask.mask_over(video, context.userMap());
      }
    }

    canvas.image(video, 0, 0);
  }

  if (drawMeSomeMotherfuckingRainbows) {
    canvas.image(glitchBuffer.getRainbow(), 0, 0);
  }

  canvas.endDraw();
  image(canvas, width/2, height/2, scaleWidth, scaleHeight);

  if (record) {
    canvas.save(String.format("glitch_%06d.tif", frameCount));
  }
}

void keyPressed() {
  switch (key) {
    case 'v':
      displayVideo = !displayVideo;
    break;
    case 'b':
      displayBuffer = !displayBuffer;
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
    case ' ':
      paused = !paused;
      if (paused) {
        noLoop();
      } else {
        loop();
      }
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
