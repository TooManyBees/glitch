class UserMask {
  PImage mask(PImage video, int[] userMap) {
    PImage img = duplicate(video);
    img.mask(maskUsersArray(userMap));
    return img;
  }

  private int[] maskUsersArray(int[] frame) {
    for (int i = 0; i < frame.length; i++) {
      frame[i] = frame[i] > 0 ? 255 : 0;
    }
    return frame;
  }
}
