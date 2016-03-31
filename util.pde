PImage duplicate(PImage frame) {
  int w = frame.width;
  int h = frame.height;
  PImage f = createImage(w, h, frame.format);
  f.copy(frame, 0, 0, w, h, 0, 0, w, h);
  return f;
}
