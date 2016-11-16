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
      .setCaptionLabel("Show Mesh");
      
  cp5.addToggle("showSegments")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Show Segments");
      
  cp5.addToggle("showLeds")
      .setPosition(width-GUI_WIDTH/2, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Show LEDs");
      
  cp5.addToggle("showNeighbours")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*6)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Show Neighbours");
      
  cp5.addToggle("dataMode")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*8)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Data Mode");
      
  dataInfo = cp5.addGroup("dataInfo")
    .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*14)
    .hideBar()
    .setVisible(dataMode);
    
  String[] values = {"0","1","2","3","4","5","6","7"};
  cp5.addScrollableList("teensy_list")
    .setPosition(0,0)
    .setGroup(dataInfo)
    .addItems(values)
    .setCaptionLabel("Teensy")
    .setSize(GUI_WIDTH/2-3, 8*BUTTON_HEIGHT-1)
    .close()
    ;
    
  cp5.addScrollableList("channel_list")
    .setPosition(GUI_WIDTH/2,0)
    .setGroup(dataInfo)
    .addItems(values)
    .setCaptionLabel("Channel")
    .setSize(GUI_WIDTH/2-3, 8*BUTTON_HEIGHT-1)
    .close()
    ;
      
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
    .setTriggerEvent(Slider.RELEASE)
    ;

}

/*void ledN(float n){
  if(selectedSegment != null) selectedSegment.updateLEDs(round(n));
  //addSnapshot();
}*/

void controlEvent(ControlEvent e){
  if(frameCount > 0){
    Controller c = e.getController();
    if (c.getName().equals("ledN")){
      if(selectedSegment != null) selectedSegment.updateLEDs(round(c.getValue()));
      addSnapshot();
    }
    
    if(c.getName().equals("dataMode")){
      dataInfo.setVisible(dataMode);
    }
  }
}