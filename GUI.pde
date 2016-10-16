void setupGUI(){
  cp5 = new ControlP5(this);
  
  ButtonBar modeBar = cp5.addButtonBar("modeBar")
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
      .getCaptionLabel().setText("Show Mesh");
      
  cp5.addToggle("showSegments")
      .setPosition(width-GUI_WIDTH, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .getCaptionLabel().setText("Show Segments");
      
  cp5.addToggle("showLeds")
      .setPosition(width-GUI_WIDTH/2, BUTTON_HEIGHT*4)
      .setSize(GUI_WIDTH/2-3, BUTTON_HEIGHT-1)
      .setMode(ControlP5.SWITCH)
      .getCaptionLabel().setText("Show LEDs");
}

void modeBar(int n){
  editMode = n;
}