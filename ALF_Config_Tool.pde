import controlP5.*;
import java.util.Arrays;
import processing.pdf.*;

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
boolean dataMode = false;
boolean dataAdd = false;
boolean showData = true;
boolean showOrientation = true;
boolean pdfExport = false;
boolean dataDir = false;
boolean checkLeds = false;

Segment selectedSegment;
Group dataInfo;
Group segmentInfo;
Slider ledN_slider;
Textlabel channel_ledN;

static final int HISTORY_SIZE = 20;
ArrayList<JSONObject> stateQueue = new ArrayList<JSONObject>();
int stateN = -1;

//Mesh
PImage meshBackground;

//Segments
static final int NEIGHBOUR_DIST = 2;  //Distance in which segments will auto-detect neighbours
ArrayList<Segment> segments = new ArrayList<Segment>();
//int startX, startY;

//Teensies
static final int TEENSY_NUMBER = 8;
Teensy[] teensies = new Teensy[TEENSY_NUMBER];
int selectedTeensy = 0;
int selectedChannel = 0;

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
    BufferedReader r = createReader("waterSide.txt");
    String line = "";
    for(int i = 0; i < TEENSY_NUMBER; i++){
      teensies[i] = new Teensy();
    }
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

    r = createReader("streetSide.txt");
    line = "";
    for(int i = 0; i < TEENSY_NUMBER; i++){
      teensies[i] = new Teensy();
    }
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
          Segment s = new Segment (-coordsPixel[0]+2*MESH_WIDTH+10,
                                    coordsPixel[1],
                                    -coordsPixel[2]+2*MESH_WIDTH+10,
                                    coordsPixel[3],
                                    0);
                                 
          segments.add(s);
          s.autoFindNeighbours();                      
        }
         
    }
  }
  
  setupGUI();
  
  println(segments.size());
  
  println(teensies[0].LEDCount(2));
  
  addSnapshot(); //Store first state
}

void draw(){
  if(pdfExport) beginRecord(PDF, "export.pdf");
  
  background(0);
  
  if(showMesh) drawMesh();
  
  fill(255);
  textAlign(CENTER);
  text("Water side", MESH_WIDTH/2, 20);
  text("Street side", MESH_WIDTH*1.5+10, 20);
  
  //Draw edges of plates
  stroke(86);
  line(0,0,0,800);
  line(0,800,533,800);
  line(533,800,533,0);
  line(0,0,533,0);
  line(0,400,533,400);
  line(267,0,267,800);
  line(MESH_WIDTH+10,0,MESH_WIDTH+10,600);
  line(MESH_WIDTH+10,600,2*MESH_WIDTH+10, 600);
  line(2*MESH_WIDTH+10,600,2*MESH_WIDTH+10,0);
  line(MESH_WIDTH+10, 0, 2*MESH_WIDTH+10, 0);
  line(1.5*MESH_WIDTH+10, 0, 1.5*MESH_WIDTH+10, 600);
  line(MESH_WIDTH+10, 400, 2*MESH_WIDTH+10, 400);
  //line(0,800-66,MESH_WIDTH,800-66);
  
  //Draw segments & connections to possible neighbours from mouse position
  for(Segment s : segments){
    s.update();
    s.draw();
  }
  
  if(dataMode && selectedTeensy >= 0 && selectedChannel >= 0 && showData){
    teensies[selectedTeensy].showData(selectedChannel);
  }
  if(dataDir){
    for(Teensy t : teensies){
      t.showDataDirection();
    }
  }
  
  if(pdfExport){
    endRecord();
    pdfExport = false;
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
        if(dataAdd){ 
          teensies[selectedTeensy].addSegment(selectedChannel, s);
          break;
        }
        else{ 
          selectSegment(s);
          break;
        }
      }
    }
    if(!onSegment){ 
      selectSegment(null);
    }
  }
}

void keyPressed(KeyEvent e){
  if(key == 127){ //127 is ASCII DELETE
    if(selectedSegment != null){
      selectedSegment.delete();
      selectedSegment = null;
      addSnapshot();
    }
  }
  
  if(key == '-'){
    if(dataAdd) teensies[selectedTeensy].removeSegment(selectedChannel);
  }
  
  if(key == 'e'){
    pdfExport = true;
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
      selectedSegment.flip();
      addSnapshot();
    }
  }
  
  if(key == 0x1A){ //Somehow key == 0x1A when CTRL-Z is pressed
    if(stateN > 0) returnToState(stateQueue.get(--stateN));
  }
  
  if(key == 0x19){ //CTRL-Y
    if(stateN < stateQueue.size()-1) returnToState(stateQueue.get(++stateN));
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
  out.setBoolean("dataMode", dataMode);
  out.setInt("selectedTeensy", selectedTeensy);
  out.setInt("selectedChannel", selectedChannel);
  out.setBoolean("showOrientation", showOrientation);
  
  JSONArray ss = new JSONArray();
  for(int i = 0; i<segments.size(); i++){
    Segment s = segments.get(i);
    ss.append(s.toJson());
  }  
  out.setJSONArray("segments", ss);
  
  JSONArray ts = new JSONArray();
  for(int i = 0; i<teensies.length; i++){
    ts.append(teensies[i].toJson());
  }
  out.setJSONArray("teensies", ts);
  
  return out;
}

void returnToState(JSONObject json){
  showMesh = json.getBoolean("showMesh");
  showSegments = json.getBoolean("showSegments");
  showLeds = json.getBoolean("showLeds");
  showNeighbours = json.getBoolean("showNeighbours");
  dataMode = json.getBoolean("dataMode");
  selectedTeensy = json.getInt("selectedTeensy");
  selectedChannel = json.getInt("selectedChannel");
  //showOrientation = json.getBoolean("showOrientation");
  
  JSONArray ss = json.getJSONArray("segments");
  segments = new ArrayList<Segment>();
  for(int i = 0; i < ss.size(); i++){
    segments.add(new Segment(ss.getJSONObject(i)));
  }
  
  ArrayList<Segment> rem = new ArrayList<Segment>();
  for(Segment s : segments){ 
    s.updateSegments();
  }  
  
  JSONArray ts = json.getJSONArray("teensies");
  for(int i = 0; i < teensies.length; i++){
    teensies[i] = new Teensy(ts.getJSONObject(i));
  }  
  
  int ledNumber = 0;
  for(Segment s : segments){ 
    if(s.ledN < 2)  rem.add(s);
    else ledNumber += s.ledN;
  }  
  for(Segment s : rem) segments.remove(s);
  
  println(ledNumber);
  
  
}

void addSnapshot(){
  if(stateN < HISTORY_SIZE-1) stateN++;
  stateQueue.add(stateN, state());
  
  //If we control-z'd a couple of times and continue, remove all states after the new one
  
  if(stateQueue.size() > HISTORY_SIZE) stateQueue.remove(0);
  
  if(stateN != stateQueue.size()-1){
    for(int i = stateN+1; i < stateQueue.size(); i++){
      stateQueue.remove(i);
    }
  }
  
}