import controlP5.*;
import java.util.Arrays;

static final int WIDTH = 4000;   //Real life width in mm
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

static final int HISTORY_SIZE = 20;
ArrayList<JSONObject> stateQueue = new ArrayList<JSONObject>();
int stateN = 0;

//Mesh
PImage meshBackground;

//Segments
static final int NEIGHBOUR_DIST = 2;  //Distance in which segments will auto-detect neighbours
ArrayList<Segment> segments = new ArrayList<Segment>();
//int startX, startY;

//LEDs
PImage LED_Sprite;
static final float LED_PITCH = 16.6667;  //Pitch between LEDs in mm
static final int LED_SIZE = 32;          //Size of the light-blob of each LED in pixels

void setup(){
  size(1266,800, P2D);
  meshBackground = loadImage("ALF_mesh.png");
  meshBackground.resize((int)(meshBackground.width*((float)height/meshBackground.height)), height);
  LED_Sprite = loadImage("Pixel_Sprite.png");
  LED_Sprite.resize(LED_SIZE, LED_SIZE);
  
  setupGUI();
  
  //Get mesh from json if it is provided, otherwise build it using edges.txt
  File json = new File(sketchPath("data/mesh.json"));
  println(json.getAbsolutePath());
  if(json.isFile()){
    /*Gson gson = new Gson();
    String[] jsonLine = loadStrings(json);
    Segment[] temp = gson.fromJson(jsonLine[0], Segment[].class);
    segments = new ArrayList<Segment>(Arrays.asList(temp));
    for(Segment s : segments) s.json2led();*/
    
    JSONObject mesh = loadJSONObject("mesh.json");
    returnToState(mesh);
    
  }
  else{
    //Read edges from txt file if JSON file does not exist.
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
        int[] coordsPixel = new int[4];
        for(int i = 0; i<4; i++){
          coordsPixel[i] = round(float(coords[i])/((float)HEIGHT/height));
        }
        
        if(!(coordsPixel[0] == coordsPixel[2] && coordsPixel[1] == coordsPixel[3])){
          Segment s = new Segment( coordsPixel[0],
                                 coordsPixel[1],
                                 coordsPixel[2],
                                 coordsPixel[3],
                                 0);
                                 
          segments.add(s);
          s.autoFindNeighbours();                      
        
          //Uncomment if we use a file with just one side of edges (this will be mirrored)
          
          /*Segment sm = new Segment (-coordsPixel[0]+2*MESH_WIDTH+10,
                                    coordsPixel[1],
                                    -coordsPixel[2]+2*MESH_WIDTH+10,
                                    coordsPixel[3],
                                    0);
          segments.add(sm);
          sm.autoFindNeighbours();*/
        }
         
    }
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
    PrintWriter out = createWriter("data/mesh.json");
    /*for(int i = 0; i<segments.size(); i++){
      Segment s = segments.get(i);
      float sx, sy, ex, ey;
      sx = s.startX*((float)HEIGHT/height);
      sy = s.startY*((float)HEIGHT/height);
      ex = s.endX*((float)HEIGHT/height);
      ey = s.endY*((float)HEIGHT/height);
      out.println(sx+" "+sy+" "+ex+" "+ey);
    }*/
    
    /*Gson gson = new Gson();
    for(Segment s : segments) s.led2json();
    String json;
    json = gson.toJson(segments);
    out.print(json);
    
    out.flush();
    out.close();*/
    
    JSONObject json = state();
    saveJSONObject(json, "data/mesh.json");
    
    println("Done!");
  }
  
  if(key == 'f'){
    //Flip the current edge
    if(selectedSegment != null){
      int tempX, tempY;
      tempX = selectedSegment.startX;
      tempY = selectedSegment.startY;
      selectedSegment.startX = selectedSegment.endX;
      selectedSegment.startY = selectedSegment.endY;
      selectedSegment.endX = tempX;
      selectedSegment.endY = tempY;
      selectedSegment.updateDistVars();
    }
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

//Saves state of program in JSON object
JSONObject state(){
  JSONObject out = new JSONObject();
  
  out.setBoolean("showMesh", showMesh);
  out.setBoolean("showSegments", showSegments);
  out.setBoolean("showLeds", showLeds);
  out.setBoolean("showNeighbours", showNeighbours);
  
  JSONArray ss = new JSONArray();
  for(int i = 0; i<segments.size(); i++){
    Segment s = segments.get(i);
    ss.append(s.toJson());
  }
  
  out.setJSONArray("segments", ss);
  
  return out;
}

void returnToState(JSONObject json){
  showMesh = json.getBoolean("showMesh");
  showSegments = json.getBoolean("showSegments");
  showLeds = json.getBoolean("showLeds");
  showNeighbours = json.getBoolean("showNeighbours");
  
  JSONArray ss = json.getJSONArray("segments");
  for(int i = 0; i < ss.size(); i++){
    segments.add(new Segment(ss.getJSONObject(i)));
  }
}

void addSnapshot(){
  stateQueue.add(++stateN, state());
  
  //If we control-z'd a couple of times and continue, remove all states after the new one
  if(stateN != stateQueue.size()-1){
    for(int i = stateN+1; i < stateQueue.size(); i++){
      stateQueue.remove(i);
    }
  }
  
  if(stateQueue.size() > HISTORY_SIZE) stateQueue.remove(0);
}