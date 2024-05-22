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

void trackTime() {
  currentPosition = player.position() / 1000;
  int s = currentPosition % 60;
  int m = (currentPosition - s) / 60;
  String t = String.format("%02d:%02d", m, s);
  text(t, width - 110, 456);
}

void drawHeader() {
  textSize(24);
  
  // Shows name of audio file being played.
  text("File name: " + meta.fileName(), 5, 25);
  
  // Shows current playing status of the audio.
  if (player.isPlaying()) {
    text("Press 'a' to pause.", 5, 50);
  } else {
    text("Press 'a' to play.", 5, 50);
  }
}

void drawPosition() {
  // Shows current time of the track
  trackTime();
  
  // Draws current position in the track.
  beginShape();
  float posx = map(player.position(), 0, player.length(), 128, width - 128);
  stroke(255, 255, 255);
  strokeWeight(1);
  line(120, 450, width - 120, 450);
  strokeWeight(2);
  line(posx, height - 56, posx, height - 68);
  endShape();
}

void draw() {
  background(0);
  
  fill(255);
  drawHeader();
  drawPosition();
  
  // Fade-in effect for waveform
  stroke(255, 255, 0, min(time, 255));
  //if (player.isPlaying()) {
  //  time += 1;
  //}
  
  // Draws waveform of audio
  stroke(255, 255, 0);
  noFill();
  beginShape();
  for (int i = 0; i < bufferSize; i += 1)
  {
    float x1 = map(i, 0, bufferSize, 0, width);
    vertex(x1, 256 + player.left.get(i) * 50);
  }
  endShape();
  
  //// Draws level bar of audio
  //noStroke();
  //fill(255, 128);
  //rect(0, 192, player.left.level() * width, 128);
  ellipse(512, 256, player.left.level() * height, player.left.level() * height);
}
