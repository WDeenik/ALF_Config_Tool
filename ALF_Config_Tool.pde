import controlP5.*;

static final int WIDTH = 4500;   //Real life width in mm
static final int HEIGHT = 6000;  //Real life height in mm

//GUI
ControlP5 cp5;
//int editMode = 0;
static final int GUI_WIDTH = 180;    //Width of GUI bar
static final int BUTTON_HEIGHT = 20; //Height of GUI buttons
static final int MESH_WIDTH = 533;
static final int MESH_HEIGHT = 800;

boolean showMesh = false;
boolean showSegments = true;
boolean showLeds = false;
boolean showNeighbours = true;
Segment selectedSegment;
Group segmentInfo;
Slider ledN_slider;

//Mesh
PImage meshBackground;

//Segments
static final int NEIGHBOUR_DIST = 2;  //Distance in which segments will auto-detect neighbours
ArrayList<Segment> segments = new ArrayList<Segment>();
int startX, startY;

//LEDs
PImage LED_Sprite;
static final float LED_PITCH = 16.6667;  //Pitch between LEDs in mm
static final int LED_SIZE = 32;          //Size of the light-blob of each LED in pixels

void setup(){
  int w = 2*MESH_WIDTH+GUI_WIDTH+20;
  size(1266,800, P2D);
  meshBackground = loadImage("ALF_mesh.png");
  meshBackground.resize((int)(meshBackground.width*((float)height/meshBackground.height)), height);
  LED_Sprite = loadImage("Pixel_Sprite.png");
  LED_Sprite.resize(LED_SIZE, LED_SIZE);
  
  setupGUI();
  
  //Read edges from file
  BufferedReader r = createReader("edges.txt");
  String line = "";
  while(true){
      try {
        line = r.readLine();
      } catch (IOException e) {
        e.printStackTrace();
        line = null;
      }
      if(line == null) break;
      String[] coords = split(line, ' ');
      Integer[] coordsPixel = new Integer[4];
      for(int i = 0; i<4; i++){
        coordsPixel[i] = round(float(coords[i])/((float)HEIGHT/height));
      }
      Segment s = new Segment( coordsPixel[0],
                               coordsPixel[1],
                               coordsPixel[2],
                               coordsPixel[3],
                               0);
                               
      segments.add(s);
      s.autoFindNeighbours();
      
      //Uncomment if we use a file with just one side of edges (this will be mirrored)
      
      Segment sm = new Segment (-coordsPixel[0]+2*MESH_WIDTH+10,
                                coordsPixel[1],
                                -coordsPixel[2]+2*MESH_WIDTH+10,
                                coordsPixel[3],
                                0);
      segments.add(sm);
      sm.autoFindNeighbours();
       
  }
}

void draw(){
  background(0);
  
  if(showMesh) drawMesh();
  
  fill(255);
  textAlign(CENTER);
  text("Water side", MESH_WIDTH/2, 20);
  text("Street side", MESH_WIDTH*1.5+10, 20);
  
  //Draw segments & connections to possible neighbours from mouse position
  for(Segment s : segments){
    s.update();
    s.draw();
  }
}

void mousePressed(){
}

void mouseReleased(){
  //Check if and which segment to select
  if(mouseX < width-GUI_WIDTH){
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
  }
}

void keyPressed(){
  if(key == 127){ //127 is ASCII DELETE
    if(selectedSegment != null){
      selectedSegment.delete();
      selectedSegment = null;
    }
  }
  
  if(key == 's'){
    //Save edges to file
    println("Writing edges to file...");
    PrintWriter out = createWriter("data/edges.txt");
    for(int i = 0; i<segments.size(); i++){
      Segment s = segments.get(i);
      float sx, sy, ex, ey;
      sx = s.startX*((float)HEIGHT/height);
      sy = s.startY*((float)HEIGHT/height);
      ex = s.endX*((float)HEIGHT/height);
      ey = s.endY*((float)HEIGHT/height);
      out.println(sx+" "+sy+" "+ex+" "+ey);
    }
    out.flush();
    out.close();
    println("Done!");
  }
}

void selectSegment(Segment s){
  if(selectedSegment != null) selectedSegment.selected = false;
  if(s != null){ 
    s.selected = true;
    ledN_slider.setRange(s.ledN-5, s.ledN+5);
    ledN_slider.setValue(s.ledN);
  }
  selectedSegment = s;
  if(selectedSegment != null){ 
    segmentInfo.setVisible(true);
  }
  else segmentInfo.setVisible(false);
  
}