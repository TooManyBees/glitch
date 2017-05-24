import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.nio.file.Paths;

class GifLink {

  private int length;
  private int max_length;
  private Process process;
  private String out_filename;
  private String first_filename;
  private String last_filename;
  private String dir;

  private static final int fps = 30;
  private final String engiffenCmd = Paths.get(System.getProperty("user.home"), ".cargo", "bin", "engiffen").toString();
  // Is file separator == "\" a reliable way to test for Windows? Probably not!
  private final String deleteCmd = System.getProperty("file.separator") == "\\" ? "del" : "rm -r";
  private final boolean engiffenInstalled = isEngiffenInstalled();

  GifLink(int seconds) {
    DateFormat dateformat = new SimpleDateFormat("YYYY-MM-dd-HH-mm-ss");
    this.dir = dateformat.format(new Date());

    this.max_length = seconds * fps;
    this.length = 0;
    println("Recording frames!");
  }

  void feed(PGraphics canvas) {
    // Only limit length if we're actually turning something into a gif
    // Otherwise dump frames infinitely like usual
    if (!this.engiffenInstalled || (this.length <= this.max_length)) {
      String filename = String.format("glitch_%06d.bmp", frameCount);
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

    if (this.engiffenInstalled) {
      ProcessBuilder pb = new ProcessBuilder("bash", "-c", String.format(
        "%s -o %s -f %d -s 2 -r %s %s && %s %s",
        this.engiffenCmd,
        String.format("%s.gif", sketchPath(this.dir)),
        this.fps,
        new File(sketchPath(this.dir), this.first_filename).toString(),
        new File(sketchPath(this.dir), this.last_filename).toString(),
        this.deleteCmd,
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

  private boolean isEngiffenInstalled() {
    File f = new File(this.engiffenCmd);
    return f.exists() && !f.isDirectory();
  }
}
