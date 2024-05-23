import ddf.minim.*;
import complexnumbers.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;

float bufferSize;

int time = 0;
int currentPosition;

int maxSample;
float maxFreq = 300;

boolean visualizer;

void setup() {
  fullScreen();
  
  minim = new Minim(this);
  player = minim.loadFile("xu.mp3");
  meta = player.getMetaData();
  bufferSize = player.bufferSize();
  visualizer = false;
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
  else if (key == 'v') {
    visualizer = !visualizer;
  }
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
  
  // Switch between waveform analysis and audio visualizer.
  if (visualizer) {
    text("Press 'v' to view waveform analysis.", 5, 75);
  } else {
    text("Press 'v' to view audio visualizer.", 5, 75);
  }
}

void trackTime() {
  currentPosition = player.position() / 1000;
  int s = currentPosition % 60;
  int m = (currentPosition - s) / 60;
  String t = String.format("%02d:%02d", m, s);
  text(t, width - 110, height - 56);
}

void drawPosition() {
  // Shows current time of the track
  trackTime();
  
  // Draws current position in the track.
  float posx = map(player.position(), 0, player.length(), 128, width - 128);
  stroke(255, 255, 255);
  strokeWeight(1);
  line(120, height - 62, width - 120, height - 62);
  strokeWeight(2);
  line(posx, height - 56, posx, height - 68);
}

int findMaxSample() {
  int maxI = 0;
  float maxVal = 0;
  float val;
  for (int i = 0; i < bufferSize; i++) {
    val = player.left.get(i);
    if (val > maxVal) {
      maxVal = val;
      maxI = i;
    }
  }
  return maxI;
}

void drawWaveform() {
  noFill();
  stroke(255, 255, 0);
  for (int i = 0; i < bufferSize - 1; i += 1) {
    float x1 = map(i, 0, bufferSize, 10, (width / 2) - 10);
    float x2 = map(i + 1, 0, bufferSize, 10, (width / 2) - 10);
    line(x1, (height / 4) + player.left.get(i) * 75, x2, (height / 4) + player.left.get(i+1) * 75);
  }
  stroke(255, 255, 255);
  text("Audio Waveform:", 25, (height / 4 ) - 90);
  rect(10, (height / 4) - 120, (width / 2) - 20, (height / 4) - 20);
}

void drawLevel() {
  stroke(255, 0, 0);
  noFill();
  //rect((width / 2) + 25, (height / 4) - 60, rmsLevel * ((width / 2) + 60), 120);
  float x = map(maxSample, 0, bufferSize, (width / 2) + 25, width - 35);
  line(x, (height / 4) - 60, x, (height / 4) + 60);
  
  noStroke();
  fill(255, 255, 0);
  float rmsLevel = player.left.level();
  rect((width / 2) + 25, (height / 4) - 60, rmsLevel * ((width / 2) + 60), 120);
  
  stroke(255, 255, 255);
  noFill();
  rect((width / 2) + 10, (height / 4) - 120, (width / 2) - 20, (height / 4) - 20);
  line((width / 2) + 25, (height / 4) - 80, (width / 2) + 25, (height / 4) + 80);
  fill(255, 255, 255);
  text("Audio Level:", (width / 2) + 25, (height / 4 ) - 90);
}

void drawDFT() {
  stroke(255, 255, 0);
  noFill();
  float x1;
  float y1;
  float x2;
  float y2;
  for (float f = 0; f < maxFreq - 1; f++) {
    x1 = map(f, 0, maxFreq, 10, (width / 2) - 10);
    y1 = abs(realDFT(f));
    x2 = map(f + 1, 0, maxFreq, 10, (width / 2) - 10);
    y2 = abs(realDFT(f+1));
    line(x1, (5 * -y1) + (height / 2), x2, (5 * -y2) + (height / 2));
  }
}

float realDFT(float freq) {
  float reX = 0;
  for (int i = 0; i < bufferSize; i++) {
    reX += player.left.get(i) * cos(TWO_PI * freq * (i/bufferSize));
  }
  return reX;
}

void draw() {
  background(0);
  
  fill(255);
  drawHeader();
  drawPosition();
  
  maxSample = findMaxSample();
  
  if (!visualizer) {
    drawWaveform();
    drawLevel();
    
    drawDFT();
    
  }
  //wave = 
}
