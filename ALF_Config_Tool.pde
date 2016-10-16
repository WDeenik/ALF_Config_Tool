import controlP5.*;

static final int WIDTH = 4500;   //Real life width in mm
static final int HEIGHT = 6000;  //Real life height in mm

//GUI
ControlP5 cp5;
int editMode = 0;
static final int GUI_WIDTH = 180;    //Width of GUI bar
static final int BUTTON_HEIGHT = 20; //Height of GUI buttons
boolean showMesh = true;
boolean showSegments = true;
boolean showLeds = false;
Segment selectedSegment;

//Mesh
PImage meshBackground;


//Segments
static final int NEIGHBOUR_DIST = 5;  //Distance in which segments will auto-detect neighbours
ArrayList<Segment> segments = new ArrayList<Segment>();
int startX, startY;

//LEDs
PImage LED_Sprite;
static final float LED_PITCH = 16.6667;  //Pitch between LEDs in mm
static final int LED_SIZE = 32;          //Size of the light-blob of each LED in pixels

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
  
  if(showMesh) drawMesh();
  
  fill(255);
  textAlign(CENTER);
  text("Water side", meshBackground.width/2, 20);
  text("Street side", meshBackground.width*1.5+10, 20);
  
  //Draw segments & connections to possible neighbours from mouse position
  for(Segment s : segments){
    int n = s.getPossibleNeighbour(mouseX,mouseY);
    if(n > 0){
      s.c = color(0,255,255);
      stroke(255);
      strokeWeight(1);
      if(n == 1) line(mouseX,mouseY,s.startX,s.startY);
      else line(mouseX,mouseY,s.endX, s.endY);
    }
    s.draw();
  }
  
  //Draw the proposed edge
  if(mousePressed && editMode == 0){
    stroke(255,0,0);
    strokeWeight(2);
    line(startX, startY, mouseX, mouseY);
  }
}

void mousePressed(){
  if(editMode == 0){
    startX = mouseX;
    startY = mouseY;
  }
}

void mouseReleased(){
  //Check if and which segment to select
  boolean onSegment = false;
  for(Segment s : segments){
    if(s.mouseHover()){
      onSegment = true;
      selectSegment(s);
    }
  }
  if(!onSegment){ 
    selectSegment(null);
  }
  
  if(editMode == 0 && !(mouseX == startX && mouseY == startY)){
    Segment ns = new Segment(startX, startY, mouseX, mouseY, 0);
    segments.add(ns);
    selectSegment(ns);
    for(int i = 0; i<segments.size()-1; i++){
      Segment s = segments.get(i);
      int n = s.getPossibleNeighbour(startX,startY);
      if(n > 0){
        s.addNeighbour(ns, n);
        ns.addNeighbour(s, 1);
      }
      else{
        n = s.getPossibleNeighbour(mouseX,mouseY);
        if(n > 0){
          s.addNeighbour(ns, n);
          ns.addNeighbour(s, 2);
        }
      }
    }
  } 
}

void selectSegment(Segment s){
  if(selectedSegment != null) selectedSegment.selected = false;
  if(s != null) s.selected = true;
  selectedSegment = s;
}