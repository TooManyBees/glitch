class Toggle {

  private String label;
  private char hotkey;
  private String description;
  private int x, y, r;
  public boolean on;
  public boolean enabled;

  public static final int radius = 10;

  Toggle(String label, char hotkey, String description, int x, int y) {
    this.label = label;
    this.hotkey = hotkey;
    this.description = description;
    this.x = x;
    this.y = y;
    this.r = radius;
    this.on = false;
    this.enabled = true;
  }

  Toggle(String label, char hotkey, String description, int x, int y, boolean startOn) {
    this(label, hotkey, description, x, y);
    this.on = startOn;
  }

  String label() {
    return label;
  }

  String description() {
    return description;
  }

  void enableThisFrame(boolean isEnabled) {
    enabled = isEnabled;
  }

  boolean wasClicked(int mx, int my) {
    return enabled && (x-r) < mx && mx < (x+r) && (y-r) < my && my < (y+r);
  }

  boolean wasPressed(char key) {
    return enabled && key == hotkey;
  }

  boolean on() {
    return on && enabled;
  }

  // void turnOn() {
  //   on = true;
  // }

  // void turnOff() {
  //   on = false;
  // }

  void click() {
    on = !on;
  }

  void draw(PApplet canvas) {
    int bg, fg;
    if (!enabled) {
      bg = 128;
      fg = 0;
    } else if (on) {
      bg = 255;
      fg = 0;
    } else {
      bg = 0;
      fg = 255;
    }
    canvas.fill(bg);
    canvas.stroke(fg);
    canvas.rect(x, y, (float) r, (float) r);
    canvas.fill(fg);
    canvas.textFont(uiFont);
    canvas.text(label, x, y);
  }
}
