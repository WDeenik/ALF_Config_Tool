void drawMesh(){
  imageMode(CORNER);
  noTint();
  image(meshBackground, 0, 0);
  //Draw street side mesh mirrored since we look at it from the other direction
  scale(-1,1);
  image(meshBackground, -meshBackground.width*2-10, 0);
  scale(-1,1); 
}

void setupGUI(){
  cp5 = new ControlP5(this);
  
  cp5.addToggle("showMesh")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*2)
      .setSize(GUI_WIDTH/2-1, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .setCaptionLabel("Show Mesh");
      
  cp5.addToggle("showSegments")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .setCaptionLabel("Show Segments");
      
  cp5.addToggle("showLeds")
      .setPosition(width-GUI_WIDTH/2, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .setCaptionLabel("Show LEDs");
      
  cp5.addToggle("showNeighbours")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*6)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .setCaptionLabel("Show Neighbours");
      
  segmentInfo = cp5.addGroup("segmentInfo")
    .setPosition(width-GUI_WIDTH, height-BUTTON_HEIGHT*10)
    .hideBar()
    .setVisible(false);
    
  /*segment_ledN = cp5.addTextlabel("segment_ledN")
    .setText("LED no: ")
    .setPosition(0,0)
    .setGroup(segmentInfo);*/
    
  ledN_slider = cp5.addSlider("ledN")
    .setPosition(0,0)
    .setGroup(segmentInfo)
    .setRange(0,10)
    .setNumberOfTickMarks(11)
    .setCaptionLabel("LED Number")
    ;
    
  //TODO: Bang button to flip an edge (important for dataflow)
}

void ledN(float n){
  if(selectedSegment != null) selectedSegment.updateLEDs(round(n));
}