import processing.net.*; // importer la bibliothèque réseau de processing

float ry; // position y de la raquette rouge
float by; // position y du la raquette bleue
float ballx; // position x de la balle
float bally; // position y de la balle
float balld; // direction de la balle
int radius = 15; // rayon de la balle
float vel = 10.0; // vitesse de la alle
boolean rcollision; // collision avec la raquette rouge
boolean bcollision; // collision avec la raquette bleue
boolean out; // balle sortie
int bmouseY; // souris y du client
float wheight = 5.0; // inertie des raquettes

int rstate = 0; // joueur rouge prêt
int bstate = 0; // joueur bleu prêt
int rscore; // score du joueur rouge
int bscore; // score du joueur bleu
int countdown; // compte à rebours
float counter; // timer
String scoremsg = "C'est parti !"; // message

String input; // données crues reçues
String data[]; // données reçues
Server server; // serveur
Client client; // client

void setup() {
  server = new Server(this, 8080); // ouverture du seveur
  
  size(900, 600); // fenêtre de 900 x 600 px
  noStroke(); // pas de contour
  textAlign(CENTER); // aligner le texte au centre
  
  ry = height/2; 
  by = height/2; // mettre les raquettes au millieu
  
  ballx = -100;
  bally = -100; // balle pas en jeu
  
  countdown = 5; // compte à rebours pas déclenché
  out = false; // balle pas sortie
  rscore = 0;
  bscore = 0; // scores à 0
}

void draw() {
  if(countdown <= 0 && (ballx < 0 || out)) { // si en phase de jeu et balle pas encore en jeu out bale sortie
    out = false;
    ballx = width/2;
    bally = height/2; // balle au millieu de l'écran
    balld = random(-1.0, 1.0) + PI*int(random(2.0)); // direction aléatoire bornée
    vel = 10.0;
  }
  
  if(countdown <= 0 && !out) { // si en phase de jeu et balle en jeu
    ry = min(max(ry+(mouseY - ry)/wheight, 75), height-75); 
    by = min(max(by+(bmouseY - by)/wheight, 75), height-75); // déplacement des raquettes
    
    vel += 0.05;
    
    ballx += cos(balld)*vel;
    bally += sin(balld)*vel; // déplacement de la balle
    
    rcollision = (cos(balld) < 0 && ballx < 60+radius && ry-75 < bally && bally < ry+75);
    bcollision = (cos(balld) > 0 && ballx > width-(60+radius) && by-75 < bally && bally < by+75);
    
    if(bally < radius || bally > height-radius) {balld = -balld;}
    else if(ballx > width-radius) {out = true; rscore ++; formatScore();}
    else if(ballx < radius) {out = true; bscore ++; formatScore();}  
    else if(rcollision || bcollision) {
      balld = PI-balld;
      float rnd = +random(-0.3, 0.3);
      if(abs(cos(balld+rnd)) > .5) {
        balld += rnd;
      }
    }
  }
  
  if(countdown <= 0 && out) {
    countdown = 4;
    counter = millis() + 5000;
  }
  
  if(countdown != 5 && countdown > 0) {
    countdown = min(int((counter - millis())/1000 + 1), 4);
  }
  
  background(0);
  
  if(rstate==1) {fill(255, 0, 0);} else {fill(255, 200, 200);}
  rect(40, ry-75, 20, 150);
  
  if(bstate==1) {fill(50, 100, 255);} else {fill(150, 210, 255);}
  rect(width-60, by-75, 20, 150);
  
  fill(255);
  ellipse(ballx, bally, radius*2, radius*2);
  
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
      if(countdown == 5) {countdown = 4; counter = millis() + 4000;}
      switch(countdown) {
        case 4: text(scoremsg, width/2, height/2+16); break;
        case 3: text("3", width/2, height/2+16); break;
        case 2: text("2", width/2, height/2+16); break;
        case 1: text("1", width/2, height/2+16); break;
      }
    }
  }
  
  server.write(rstate + " " + countdown + " " + ry + " " + by + " " + ballx + " " + bally + " " + rscore + " " + bscore + "\n");
  client = server.available();
  
  if (client != null) {
    input = client.readString(); 
    input = input.substring(0, input.indexOf("\n"));
    data = split(input, ' ');
    bstate = int(data[0]);
    bmouseY = int(data[1]);
  }
}

void mouseClicked() {
  rstate = 1;
}

void formatScore() {
  scoremsg = rscore + " - " + bscore;
}
