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
}

void modeBar(int n){
  editMode = n;
  println(editMode);
}