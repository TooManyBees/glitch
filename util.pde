PImage duplicate(PImage frame) {
  int w = frame.width;
  int h = frame.height;
  PImage f = createImage(w, h, frame.format);
  f.copy(frame, 0, 0, w, h, 0, 0, w, h);
  return f;
}

PImage sizeVideoToDepth(PImage video) {
  int w = video.width;
  int h = video.height;
  PImage img = createImage(w, h, video.format);
  img.copy(video, 40, 20, w-60, h-40, 0, 0, w, h);
  return img;
}
