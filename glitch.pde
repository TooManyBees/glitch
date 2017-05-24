import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;
UserMask userMask;

GifLink gifLink;

// boolean record;
boolean paused;
boolean displayUi;

Toggle toggleBuffer, toggleVideo, toggleThreshold, toggleRainbows, toggleGif, toggleFrames;
Toggle[] ui;

int scaleHeight;
int scaleWidth;

float thresholdVideo;

private final int CAMERA_WIDTH = 640;
private final int CAMERA_HEIGHT = 480;

void setup() {
  // size(640, 480, P2D);
  fullScreen(P2D);
  frameRate(30);
  context = new SimpleOpenNI(this);
  if (!context.isInit()) {
    println("We fucked up somehow!");
    exit();
    return;
  }

  // record = false;
  paused = false;
  displayUi = true;

  thresholdVideo = 0.2;

  setupUi();

  context.setMirror(true);
  context.enableDepth();
  context.enableUser();
  context.enableRGB();

  colorMode(HSB, 255, 100, 100);
  glitchBuffer = new GlitchBuffer(CAMERA_WIDTH, CAMERA_HEIGHT);
  userMask = new UserMask();

  {
    // Figure out how to scale up image
    float scaleWidthRatio = (float) width / (float) CAMERA_WIDTH;
    float scaleHeightRatio = (float) height / (float) CAMERA_HEIGHT;

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
  rectMode(RADIUS);
  textAlign(CENTER, CENTER);
  background(0);

  printHelp();
}

void draw() {
  context.update();

  glitchBuffer.feed(context.depthImage());

  PGraphics canvas = createGraphics(CAMERA_WIDTH, CAMERA_HEIGHT);
  canvas.beginDraw();
  canvas.background(0);

  if (toggleBuffer.on()) {
    canvas.image(glitchBuffer.buffer, 0, 0);
  } else if (toggleVideo.on()) {
    PImage video = context.rgbImage();
    video = sizeVideoToDepth(video);

    if (toggleThreshold.on()) {
      video.filter(THRESHOLD, thresholdVideo);
      userMask.mask_over(video, context.userMap());
    }

    canvas.image(video, 0, 0);
  }

  if (toggleRainbows.on()) {
    canvas.image(glitchBuffer.getRainbow(), 0, 0);
  }

  canvas.endDraw();
  image(canvas, width/2, height/2, scaleWidth, scaleHeight);

  // if (record) {
  //   canvas.save(String.format("glitch_%06d.tif", frameCount));
  // }
  if (gifLink != null) {
    gifLink.feed(canvas);
  }

  updateUi();
  drawUi(this);
}

void clearGifLink() {
  gifLink = null;
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
      case UP:
        glitchBuffer.crankUpTheRainbows();
        println("RAINBOW FACTOR "+glitchBuffer.factor()+" ENGAGE!");
        break;
      case DOWN:
        glitchBuffer.dialBackTheRainbows();
        println("RAINBOW FACTOR "+glitchBuffer.factor()+" ENGAGE!");
        break;
      case LEFT:
        thresholdVideo = min(1.0, (round(thresholdVideo * 40) + 1) / 40.0);
        println("Threshold at "+thresholdVideo);
        break;
      case RIGHT:
        thresholdVideo = max(0.0, (round(thresholdVideo * 40) - 1) / 40.0);
        println("Threshold at "+thresholdVideo);
        break;
    }
  } else {
    for (int i = 0; i < ui.length; i++) {
      Toggle t = ui[i];
      if (t.wasPressed(key)) {
        t.click();
        return;
      }
    }
    switch (key) {
      case 'f':
        // record = !record;
        // println(record ? "Recording frames!" : "Stopped recording");
        if (gifLink == null) {
          gifLink = new GifLink(5);
        } else {
          gifLink.end();
        }
        break;
      case 'u':
        displayUi = !displayUi;
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
  }
}

void printHelp() {
  for (Toggle t : ui) {
    println("("+t.label()+") "+t.description());
  }
  println("(f) record frames");
  println("( space ) pause");
}

void setupUi() {
  toggleBuffer = new Toggle("B", 'b', "draw buffer", 20, 20);
  toggleVideo = new Toggle("V", 'v', "draw video", 20, 45, true);
  toggleThreshold = new Toggle("T", 't', "threshold video", 20, 70, true);
  toggleRainbows = new Toggle("R", 'r', "rainbows", 20, 95, true);
  ui = new Toggle[]{toggleBuffer, toggleVideo, toggleThreshold, toggleRainbows};
}

void updateUi() {
  toggleVideo.enableThisFrame(!toggleBuffer.on());
  toggleThreshold.enableThisFrame(!toggleBuffer.on());
  toggleRainbows.enableThisFrame(!toggleBuffer.on());
  // toggleFrames.enableThisFrame(!toggleGif.on());
  // toggleGif.enableThisFrame(!toggleFrames.on());
}

void drawUi(PApplet canvas) {
  if (displayUi) {
    for (Toggle t : ui) {
      t.draw(canvas);
    }
  }
}

void mouseClicked() {
  if (displayUi) {
    int mx = (int) mouseX;
    int my = (int) mouseY;
    for (int i = 0; i < ui.length; i++) {
      Toggle t = ui[i];
      if (t.wasClicked(mx, my)) {
        t.click();
        return;
      }
    }
  }
}
