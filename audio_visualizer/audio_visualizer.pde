import ddf.minim.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;

float bufferSize;
int time = 0;
int currentPosition;

void setup() {
  size(1024, 512);
  minim = new Minim(this);
  player = minim.loadFile("xu.mp3");
  meta = player.getMetaData();
  bufferSize = player.bufferSize();
 }

void keyPressed() {
  if (key == 'a') {
    if (player.isPlaying()) {
      player.pause();
    }
    else if (player.position() == player.length()) {
      player.rewind();
      player.play();
    }
    else {
      player.play();
    }
  }
}

void playStatus() {
  if (player.isPlaying()) {
    text("Press 'a' to pause.", 5, 75);
  } else {
    text("Press 'a' to play.", 5, 75);
  }
}

void fileInfo() {
  text("File name: " + meta.fileName(), 5, 25);
}

void trackTime() {
  currentPosition = player.position() / 1000;
  int s = currentPosition % 60;
  int m = (currentPosition - s) / 60;
  String t = String.format("%02d:%02d", m, s);
  text(t, width - 110, 456);
}

void draw() {
  background(0);
  
  // Shows name of current file, along with playing stauts on top-left corner
  textSize(24);
  playStatus();
  fileInfo();
  
  // Shows current time of the track
  trackTime();
  
  
  stroke(255, 255, 0, min(time, 255));
  noFill();
  
  // Draws waveform of audio
  beginShape();
  for (int i = 0; i < bufferSize; i += 1)
  {
    float x1 = map(i, 0, bufferSize, 0, width);
    vertex(x1, 256 + player.left.get(i) * 50);
  }
  endShape();
  
  // Draws current position in the track.
  beginShape();
  float posx = map(player.position(), 0, player.length(), 128, width - 128);
  stroke(255, 255, 255);
  strokeWeight(1);
  line(120, 450, width - 120, 450);
  strokeWeight(2);
  line(posx, height - 56, posx, height - 68);
  endShape();
  
  // Fade-in effect for waveform
  if (player.isPlaying()) {
    time += 1;
  }
}
