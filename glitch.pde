import SimpleOpenNI.*;

SimpleOpenNI context;

PImage glitchBuffer;

void setup() {
  size(640, 480);
  context = new SimpleOpenNI(this);

  if (!context.isInit()) {
     println("We fucked up somehow!"); 
     exit();
     return;  
  }

  context.setMirror(true);
  context.enableDepth();
  context.enableRGB();

  colorMode(HSB, 255, 100, 100);
  glitchBuffer = createImage(width, height, HSB);
}

void draw() {
  context.update();

  glitchBuffer.blend(context.depthImage(), 0, 0, width, height, 0, 0, width, height, DIFFERENCE);
  PImage video = context.rgbImage();
  PImage rainbow = thatsAGreatFrameYouGotThere(glitchBuffer);

  image(video, 0, 0);
  image(rainbow, 0, 0);
}

float THRESHOLD_OF_GREATNESS = 60.0; // 50 was a good pick
PImage thatsAGreatFrameYouGotThere(PImage noise) {
  int len = width * height;

  PImage clampedNoise = duplicate(noise);
  clampedNoise.filter(THRESHOLD, THRESHOLD_OF_GREATNESS / 100);
  
  PImage f = createImage(width, height, HSB);
  f.loadPixels();

  int c = color(random(255), 100, 100);
  for (int i = 0; i < len; ++i) {
    f.pixels[i] = c;
  }
  f.updatePixels();
  f.mask(clampedNoise);
  return f;
}

PImage duplicate(PImage frame) {
  int w = frame.width;
  int h = frame.height;
  PImage f = createImage(w, h, frame.format);
  f.copy(frame, 0, 0, w, h, 0, 0, w, h);
  return f;
}
