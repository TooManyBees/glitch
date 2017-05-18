import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

class GifLink {

  private int length;
  private int max_length;
  private Process process;
  private String out_filename;
  private String first_filename;
  private String last_filename;
  private String dir;

  private static final int fps = 30;

  GifLink(int seconds) {
    DateFormat dateformat = new SimpleDateFormat("YYYY-MM-dd-HH-mm-ss");
    this.dir = dateformat.format(new Date());

    this.max_length = seconds * fps;
    this.length = 0;
    println("Recording frames!");
  }

  void feed(PGraphics canvas) {
    if (this.length <= this.max_length) {
      String filename = String.format("glitch_%06d.tif", frameCount);
      if (this.first_filename == null) {
        this.first_filename = filename;
      }
      this.last_filename = filename;
      String out_frame = new File(this.dir, filename).toString();
      canvas.save(out_frame);
    }

    if (this.process == null && this.length >= this.max_length) {
      this.end();
    }

    this.length += 1;
  }

  void end() {
    if (this.process != null) {
      return;
    }
    clearGifLink();
    println("Stopped recording.");

    ProcessBuilder pb = new ProcessBuilder("bash", "-c", String.format(
      "/Users/esbe/.cargo/bin/engiffen -o %s -f %d -s 2 -r %s %s && echo I am about to remove %s",
      String.format("%s.gif", sketchPath(this.dir)),
      this.fps,
      new File(sketchPath(this.dir), this.first_filename).toString(),
      new File(sketchPath(this.dir), this.last_filename).toString(),
      sketchPath(this.dir)
    ));
    pb.redirectOutput(ProcessBuilder.Redirect.INHERIT);
    pb.redirectError(ProcessBuilder.Redirect.INHERIT);
    try {
      this.process = pb.start();
    } catch (IOException e) {
      println("uh oh ", e);
    }
  }
}
