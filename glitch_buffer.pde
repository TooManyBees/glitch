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
    if (false) { // if Processing 2 (not sure how to check)
      buffer.blend(
        frame,
        0, 0, w, h,
        0, 0, w, h,
        DIFFERENCE
      );
    } else {
      manualDiff(buffer, frame);
    }
  }

  int factor() {
    return int(0.5/threshold * 100);
  }

  void crankUpTheRainbows() {
    threshold = max(0, threshold - 0.05);
  }

  void dialBackTheRainbows() {
    threshold = min(1, threshold + 0.05);
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

  private void manualDiff(PImage dst, PImage src) {
    int len = w * h;
    dst.loadPixels();
    src.loadPixels();

    for (int i = 0; i < len; ++i) {
      int pd = dst.pixels[i];
      int ps = src.pixels[i];
      dst.pixels[i] = oldBlendDifference(pd, ps);
    }
    dst.updatePixels();
  }

  // The rest of this crap is to emulate Processing 2's DIFFERENCE blend mode.
  // Yeah, it's kind of integral to the whole look.

  private final int ALPHA_MASK = 0xff000000;
  private final int RED_MASK   = 0x00ff0000;
  private final int GREEN_MASK = 0x0000ff00;
  private final int BLUE_MASK  = 0x000000ff;

  private int oldBlendDifference(int a, int b) {
    // setup (this portion will always be the same)
    int f = (b & ALPHA_MASK) >>> 24;
    int ar = (a & RED_MASK) >> 16;
    int ag = (a & GREEN_MASK) >> 8;
    int ab = (a & BLUE_MASK);
    int br = (b & RED_MASK) >> 16;
    int bg = (b & GREEN_MASK) >> 8;
    int bb = (b & BLUE_MASK);
    // formula:
    int cr = (ar > br) ? (ar-br) : (br-ar);
    int cg = (ag > bg) ? (ag-bg) : (bg-ag);
    int cb = (ab > bb) ? (ab-bb) : (bb-ab);
    // alpha blend (this portion will always be the same)
    return (min(((a & ALPHA_MASK) >>> 24) + f, 0xff) << 24 |
            (constrain(ar + (((cr - ar) * f) >> 8), 0, 255) << 16) |
            (constrain(ag + (((cg - ag) * f) >> 8), 0, 255) << 8) |
            (constrain(ab + (((cb - ab) * f) >> 8), 0, 255) ) );
  }

}
