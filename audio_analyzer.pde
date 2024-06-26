import processing.sound.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import complexnumbers.*;

Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;

float bufferSize;

int time = 0;
int currentPosition;

int maxSample;
float maxFreq = 300;
float[] freqArr = new float[(int) maxFreq];
float beatRadius;

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

float realDFT(float freq) {
  float reX = 0;
  for (int i = 0; i < bufferSize; i++) {
    reX += player.left.get(i) * cos(TWO_PI * freq * (i/bufferSize));
  }
  return reX;
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
  float posx = map(player.position(), 0, player.length(), 120, width - 120);
  float posFill = map(player.position(), 0, player.length(), 0, width - 240);
  stroke(255, 255, 255);
  noFill();
  strokeWeight(1);
  rect(120, height - 66, width - 240, 8);
  //line(120, height - 62, width - 120, height - 62);
  strokeWeight(4);
  line(posx, height - 56, posx, height - 68);
  noStroke();
  fill(255, 0, 0);
  rect(120, height - 66, posFill, 8);
}

void drawWaveform() {
  strokeWeight(2);
  noFill();
  stroke(255, 255, 0);
  for (int i = 0; i < bufferSize - 1; i += 1) {
    float x1 = map(i, 0, bufferSize, 10, (width / 2) - 10);
    float x2 = map(i + 1, 0, bufferSize, 10, (width / 2) - 10);
    line(x1, (height / 4) + player.left.get(i) * 75, x2, (height / 4) + player.left.get(i+1) * 75);
  }
  stroke(255, 255, 255);
  rect(10, (height / 4) - 120, (width / 2) - 20, (height / 4) - 20);
  fill(255, 255, 255);
  text("Audio Waveform:", 25, (height / 4 ) - 90);
}

void drawLevel() {
  strokeWeight(2);
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
  strokeWeight(2);
  float x1;
  float y1;
  float x2;
  float y2;
  
  // Raw RDFT 
  stroke(255, 0, 0);
  noFill();
  beginShape();
  for (float f = 0; f < maxFreq; f++) {
    x1 = map(f, 0, maxFreq, 10, (width / 2) - 10);
    y1 = abs(realDFT(f));
    freqArr[(int) f] += (y1 - freqArr[(int) f]) * 0.1;
    //x2 = map(f + 1, 0, maxFreq, 10, (width / 2) - 5);
    //y2 = abs(realDFT(f+1));
    
    y1 = (5 * y1) + (height / 2) + 100;
    //y2 = (5 * y2) + (height / 2) + 100;
    
    y1 = min(y1, height - 150);
    //y2 = min(y2, height - 150);
    
    //line(x1, y1, x2, y2);
    vertex(x1, y1);
  }
  endShape();
  
  // Smoothed RDFT
  stroke(255, 255, 0);
  beginShape();
  for (float f = 0; f < maxFreq; f++) {
    x2 = map(f, 0, maxFreq, 10, (width / 2) - 10);
    y2 = (5 * -freqArr[(int) f]) + (height / 2) + 100;
    y2 = max(y2, (height / 2) - 90);
    vertex(x2, y2);
  }
  endShape();
  
  stroke(255, 255, 255);
  noFill();
  line(10, (height / 2) + 100, (width / 2) - 10, (height / 2) + 100);
  rect(10, (height / 2) - 130, (width / 2) - 20, (height / 2) - 20);
  fill(255, 255, 255);
  text("RDFT:", 25, (height / 2) - 100);
}

void drawPolar() {
  float lineDist = ((height / 2) + 250) - ((height / 2) - 50);
  int midX = (5 * width) / 8;
  int midY = (((height / 2) + 250) + ((height / 2) - 50))/2;
  
  stroke(255, 255, 0);
  strokeWeight(2);
  noFill();
  beginShape();
  for (int i = 0; i < bufferSize; i += 5) {
    float theta = map(i, 0, bufferSize, 0, TWO_PI);
    float r = player.left.get(i);
    vertex(midX + 200 * r * cos(theta), midY + 200 * r * sin(theta)); 
  }
  endShape();
  
  stroke(255, 255, 255);
  noFill();
  rect((width / 2) + 10, (height / 2) - 130, (width / 4) - 20, (height / 2) - 20);
  line(midX - (lineDist/2), (height / 2) + 100, midX + (lineDist/2), (height / 2) + 100);
  line(midX, (height / 2) - 50, midX, (height / 2) + 250);
  
  //rect(((3 *width) / 4) + 10, (height / 2) - 130, (width / 4) - 20, (height / 2) - 20);
  fill(255, 255, 255);
  text("Waveform Polar Graph:", (width / 2) + 25, (height / 2) - 100);
}

void drawBeat() {
  float lineDist = ((height / 2) + 250) - ((height / 2) - 50);
  int midX = (7 * width) / 8;
  int midY = (((height / 2) + 250) + ((height / 2) - 50))/2;
  
  noStroke();
  float a = map(beatRadius, 20, 80, 60, 255);
  fill(255, 255, 0, a);
  if (beat.isOnset()) {
    beatRadius = (3 * lineDist)/4;
  }
  ellipse(midX, midY, beatRadius, beatRadius);
  beatRadius *= 0.95;
  if (beatRadius < 20) {
    beatRadius = 20;
  }
  
  stroke(255, 255, 255);
  strokeWeight(2);
  noFill();
  //rect((width / 2) + 10, (height / 2) - 130, (width / 4) - 20, (height / 2) - 20);
  rect(((3 *width) / 4) + 10, (height / 2) - 130, (width / 4) - 20, (height / 2) - 20);
  line(midX - (lineDist/2), (height / 2) + 100, midX + (lineDist/2), (height / 2) + 100);
  line(midX, (height / 2) - 50, midX, (height / 2) + 250);
  fill(255, 255, 255);
  text("Beat:", ((3 * width) / 4) + 25, (height / 2) - 100);
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

void setup() {
  fullScreen(P3D);
  
  minim = new Minim(this);
  player = minim.loadFile("xu.mp3");
  meta = player.getMetaData();
  beat = new BeatDetect();
  
  bufferSize = player.bufferSize();
 }

void draw() {
  background(0);
  beat.detect(player.mix);
  
  fill(255);
  drawHeader();
  drawPosition();
  
  maxSample = findMaxSample();
  
  drawWaveform();
  drawLevel();
  drawDFT();
  drawPolar();
  drawBeat();
}
