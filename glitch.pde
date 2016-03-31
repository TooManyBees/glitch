import SimpleOpenNI.*;

SimpleOpenNI context;

GlitchBuffer glitchBuffer;

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
  glitchBuffer = new GlitchBuffer(width, height);
}

void draw() {
  context.update();

  glitchBuffer.feed(context.depthImage());
  PImage video = context.rgbImage();
  PImage rainbow = glitchBuffer.getRainbow();

  image(video, 0, 0);
  image(rainbow, 0, 0);
}
