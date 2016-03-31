class GlitchBuffer {
  PImage buffer;
  private int w;
  private int h;
  private float threshold;

  GlitchBuffer(int w, int h) {
    this.w = w;
    this.h = h;
    // How sensitive should we be?
    // 50: picks of lots of motion
    // 60: ideal value for a single person, but won't pick up my hair :/
    // 80: mostly captures sweeping gentures with limbs
    threshold = 0.6;
    buffer = createImage(w, h, HSB);
  }

  void feed(PImage frame) {
    buffer.blend(
      frame,
      0, 0, w, h,
      0, 0, w, h,
      DIFFERENCE
    );
  }

  PImage getMask() {
    PImage mask = duplicate(buffer);
    mask.filter(THRESHOLD, threshold);
    return mask;
  }

  PImage getRainbow() {
    int len = w * h;
    PImage f = createImage(w, h, HSB);
    f.loadPixels();

    int c = color(random(255), 100, 100);
    for (int i = 0; i < len; ++i) {
      f.pixels[i] = c;
    }
    f.updatePixels();
    f.mask(getMask());
    return f;
  }

}
