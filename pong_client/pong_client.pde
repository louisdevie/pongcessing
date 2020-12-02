import processing.net.*;

String IP = "127.0.0.1";

float ry;
float by;
float ballx;
float bally;

int rstate = 0;
int bstate = 0;
String scoremsg = "C'est parti !";
int countdown;

String input;
String data[];
Client client;

void setup() {
  client = new Client(this, IP, 8080);
  
  size(900, 600);
  noStroke();
  textAlign(CENTER);
}

void draw() {
  background(0);
  
  if(rstate==1) {fill(255, 0, 0);} else {fill(255, 200, 200);}
  rect(40, ry-75, 20, 150);
  
  if(bstate==1) {fill(50, 100, 255);} else {fill(150, 210, 255);}
  rect(width-60, by-75, 20, 150);
  
  fill(255);
  ellipse(ballx, bally, 30, 30);
  
  if(rstate == 0) {
    fill(255);
    textSize(32);
    if(bstate == 0) {text("En attente des deux joueurs ...", width/2, height/2+16);}
    else {text("En attente du joueur rouge ...", width/2, height/2+16);}
  } else {
    fill(255);
    textSize(32);
    if(bstate == 0) {text("En attente du joueur bleu ...", width/2, height/2+16);}
    else {
      switch(countdown) {
        case 4: text(scoremsg, width/2, height/2+16); break;
        case 3: text("3", width/2, height/2+16); break;
        case 2: text("2", width/2, height/2+16); break;
        case 1: text("1", width/2, height/2+16); break;
      }
    }
  }
  
  client.write(bstate + " " + mouseY + "\n");
  
  if (client.available() > 0) { 
    input = client.readString();
    input = input.substring(0, input.indexOf("\n"));
    data = split(input, ' ');
    rstate = int(data[0]);
    countdown = int(data[1]);
    ry = float(data[2]);
    by = float(data[3]);
    ballx = float(data[4]);
    bally = float(data[5]);
    formatScore(int(data[6]), int(data[7]));
  }
}

void mouseClicked() {
  bstate = 1;
}

void formatScore(int r, int b) {
  scoremsg = r + " - " + b;
}
