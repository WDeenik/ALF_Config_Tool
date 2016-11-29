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
      
  cp5.addToggle("checkLeds")
      .setPosition(width-GUI_WIDTH/2, BUTTON_HEIGHT*6)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Check LED #");
      
  cp5.addToggle("dataMode")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*8)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Data Mode");
      
  dataInfo = cp5.addGroup("dataInfo")
    .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*10)
    .hideBar()
    .setVisible(dataMode);
    
  cp5.addToggle("dataDir")
      .setPosition(0,0)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Show data direction")
      .setGroup(dataInfo);
    
  cp5.addToggle("dataAdd")
      .setPosition(0, BUTTON_HEIGHT*2)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Modify data points")
      .setGroup(dataInfo);
      
  cp5.addToggle("showData")
      .setPosition(GUI_WIDTH/2, BUTTON_HEIGHT*2)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setCaptionLabel("Show data chain")
      .setGroup(dataInfo);
    
  String[] values = {"0","1","2","3","4","5","6","7"};
  cp5.addScrollableList("teensy_list")
    .setPosition(0,BUTTON_HEIGHT*4)
    .setGroup(dataInfo)
    .addItems(values)
    .setCaptionLabel("Teensy")
    .setSize(GUI_WIDTH/2-3, 8*BUTTON_HEIGHT-1)
    .setValue(selectedTeensy)
    .close()
    ;
    
  cp5.addScrollableList("channel_list")
    .setPosition(GUI_WIDTH/2,BUTTON_HEIGHT*4)
    .setGroup(dataInfo)
    .addItems(values)
    .setCaptionLabel("Channel")
    .setSize(GUI_WIDTH/2-3, 8*BUTTON_HEIGHT-1)
    .setValue(selectedChannel)
    .close()
    ;
    
  channel_ledN = cp5.addLabel("Channels LED #:")
    .setPosition(0, 11*BUTTON_HEIGHT)
    .setGroup(dataInfo)
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
    
  String info = "Info:\n"+
                "Select by clicking on segments\n"+
                "DEL: Delete selected segment\n"+
                "F: Flip selected segment\n"+
                "S: Save mesh to mesh.json\n"+
                "Ctrl-Z: Undo\n"+
                "Ctrl-Y: Redo\n"+
                " - : Remove last segment from current\n"+
                "      data chain";

  cp5.addLabel(info)
    .setPosition(width-GUI_WIDTH,height-BUTTON_HEIGHT*5)
    ;
                

}

/*void ledN(float n){
  if(selectedSegment != null) selectedSegment.updateLEDs(round(n));
  //addSnapshot();
}*/

void controlEvent(ControlEvent e){
  if(frameCount > 0){ //cp5 triggers everything a couple of times when started
    Controller c = e.getController();
    if (c.getName().equals("ledN")){
      if(selectedSegment != null) selectedSegment.updateLEDs(round(c.getValue()));
      selectedSegment.checkedLedN = true;
      addSnapshot();
    }
    
    if(c.getName().equals("dataMode")){
      dataInfo.setVisible(dataMode);
    }
    
    if(c.getName().equals("dataAdd")){
      if(dataAdd) selectSegment(null);
    }
    
    if(c.getName().equals("teensy_list")){
      selectedTeensy = (int)c.getValue();
      updateChannelInfo();
    }
    
    if(c.getName().equals("channel_list")){
      selectedChannel = (int)c.getValue();
    }
  }
}

void updateChannelInfo(){
  String text = "";
  for(int i = 0; i < 8; i++){
    text += "Channel #"+i+": "+teensies[selectedTeensy].LEDCount(i)+"\n";
  }
  channel_ledN.setText(text);
}