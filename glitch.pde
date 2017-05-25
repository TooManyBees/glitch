import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;
UserMask userMask;

GifLink gifLink;

boolean paused;
boolean displayUi;

Toggle toggleBuffer, toggleVideo, toggleThreshold, toggleRainbows;
Toggle[] ui;

int scaleHeight;
int scaleWidth;

float thresholdVideo;

private final int CAMERA_WIDTH = 640;
private final int CAMERA_HEIGHT = 480;

private final int RECORD_MAX_SECONDS = 5;

private PFont statsFont;
private PFont uiFont;

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

  statsFont = createFont("AnonymousPro-Bold", 18);
  uiFont = createFont("AnonymousPro", 12);

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
        break;
      case DOWN:
        glitchBuffer.dialBackTheRainbows();
        break;
      case LEFT:
        thresholdVideo = min(1.0, (round(thresholdVideo * 40) + 1) / 40.0);
        break;
      case RIGHT:
        thresholdVideo = max(0.0, (round(thresholdVideo * 40) - 1) / 40.0);
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
        if (gifLink == null) {
          gifLink = new GifLink(RECORD_MAX_SECONDS);
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
  println("(u) toggle ui");
  for (Toggle t : ui) {
    println("("+t.label()+") "+t.description());
  }
  println("(f) record frames");
  println("(↓ ↑) less/more rainbow");
  println("(← →) less/more user");
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
}

void drawUi(PApplet canvas) {
  if (displayUi) {
    canvas.rectMode(RADIUS);
    canvas.textAlign(CENTER, CENTER);
    for (Toggle t : ui) {
      t.draw(canvas);
    }

    canvas.fill(255);
    canvas.textAlign(LEFT, BOTTOM);
    if (statsFont != null) { canvas.textFont(statsFont); }
    canvas.text("Rainbows: "+glitchBuffer.factor()+"\n"+"Faces: "+thresholdVideo, 0, scaleHeight);
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
