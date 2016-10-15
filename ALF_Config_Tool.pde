import controlP5.*;

static final int WIDTH = 4500;   //Real life width in mm
static final int HEIGHT = 6000;  //Real life height in mm

//GUI
ControlP5 cp5;
int editMode = 0;
static final int GUI_WIDTH = 180;    //Width of GUI bar
static final int BUTTON_HEIGHT = 20; //Height of GUI buttons

//Mesh
PImage meshBackground;
boolean showMesh = true;

//Segments
static final int NEIGHBOUR_DIST = 5;  //Distance in which segments will auto-detect neighbours
ArrayList<Segment> segments = new ArrayList<Segment>();
int startX, startY;

//LEDs
PImage LED_Sprite;
static final float LED_PITCH = 16.6667;  //Pitch between LEDs in mm
static final int LED_SIZE = 10;          //Size of the light-blob of each LED in pixels

void setup(){
  size(1400,800, P2D);
  meshBackground = loadImage("ALF_mesh.png");
  meshBackground.resize((int)(meshBackground.width*((float)height/meshBackground.height)), height);
  LED_Sprite = loadImage("Pixel_Sprite.png");
  LED_Sprite.resize(LED_SIZE, LED_SIZE);
  
  setupGUI();
}

void draw(){
  background(0);
  
  fill(0,0,255);
  
  if(showMesh){
    imageMode(CORNER);
    noTint();
    image(meshBackground, 0, 0);
    //Draw street side mesh mirrored since we look at it from the other direction
    scale(-1,1);
    image(meshBackground, -meshBackground.width*2-10, 0);
    scale(-1,1); 
  }
  
  fill(255);
  textAlign(CENTER);
  text("Water side", meshBackground.width/2, 20);
  text("Street side", meshBackground.width*1.5+10, 20);
  
  if(mousePressed && editMode == 0){
    stroke(0,255,255);
    line(startX, startY, mouseX, mouseY);
  }
}

void mousePressed(){
  if(editMode == 0){
    startX = mouseX;
    startY = mouseY;
  }
}