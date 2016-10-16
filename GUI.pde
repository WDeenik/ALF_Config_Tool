void drawMesh(){
  imageMode(CORNER);
  noTint();
  image(meshBackground, 0, 0);
  //Draw street side mesh mirrored since we look at it from the other direction
  scale(-1,1);
  image(meshBackground, -meshBackground.width*2-10, 0);
  scale(-1,1); 
}

//Updates GUI (highlighting segments when hover over bangs and other stuff like that)
void updateGUI(){
  if(selectedSegment != null){
    segment_ledN.setText("LED no: "+selectedSegment.ledN);
    updateSegmentBang(bang_nbs1, selectedSegment.startNeighbours[0]);
  }
}

void updateSegmentBang(Bang b, Segment target){
  if(target != null){
    b.setLock(false);
    if(b.isInside()){
      if(mousePressed && mouseButton == LEFT){ 
        selectSegment(target);
        delay(100); //Prevent that we immediately switch back
      }
      else if(mousePressed && mouseButton == RIGHT){
        selectedSegment.removeNeighbour(target);
        target.removeNeighbour(selectedSegment);
        delay(100);
      }
      target.highLight();
    }
  }
  else b.setLock(true);
}

void setupGUI(){
  cp5 = new ControlP5(this);
  
  cp5.addButtonBar("modeBar")
      .setPosition(width-GUI_WIDTH, 0)
      .setSize(GUI_WIDTH, BUTTON_HEIGHT-1)
      .addItems(split("Segments Data"," "))
      .setCaptionLabel("Edit mode")
      .setValue(0)
      ;
  
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
      
  segmentInfo = cp5.addGroup("segmentInfo")
    .setPosition(width-GUI_WIDTH, height-BUTTON_HEIGHT*10)
    .hideBar()
    .setVisible(false);
    
  segment_ledN = cp5.addTextlabel("segment_ledN")
    .setText("LED no: ")
    .setPosition(0,0)
    .setGroup(segmentInfo);
  
  bang_nbs1 = cp5.addBang("bang_nbs1")
    .setPosition(0,BUTTON_HEIGHT)
    .setGroup(segmentInfo)
    .setCaptionLabel("Neighbour1")
    .setLock(true);
}

void modeBar(int n){
  editMode = n;
}