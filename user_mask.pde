class UserMask {
  private PShader userMaskShader;

  UserMask() {
    userMaskShader = loadShader("identity.vert", "usermask.frag");
  }

  PImage mask(PImage video, int[] userMap) {
    PImage img = duplicate(video);
    img.mask(maskUsersArray(userMap));
    return img;
  }

  void mask_over(PImage video, int[] userMap) {
    video.mask(maskUsersArray(userMap));
  }

  void paint_onto(PGraphics canvas, PImage video, PImage userMask, float threshold) {
    userMaskShader.set("video", video);
    userMaskShader.set("userMask", userMask);
    userMaskShader.set("threshold", threshold);
    canvas.filter(userMaskShader);
  }

  private int[] maskUsersArray(int[] frame) {
    for (int i = 0; i < frame.length; i++) {
      frame[i] = frame[i] > 0 ? 255 : 0;
    }
    return frame;
  }
}
