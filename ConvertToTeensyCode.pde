void convertToTeensyCode(int t){
  String code = "";
  Teensy teensy = teensies[t];
  
  int maxN = 0;
  for(int i = 0; i < 8; i++){
    int c = teensy.LEDCount(i);
    if(c > maxN) maxN = c;
  }
  
  ArrayList<Segment> teensySegments = new ArrayList<Segment>();
  
  code += String.format("const int ledsPerStrip = %d;\n", maxN);
  
  code += "LED leds[] = {\n";
  
  for(int c = 0; c < 8; c++){
    int ledN = 0;
    Segment currentSegment = teensy.channel[c];
    while(currentSegment != null){
      teensySegments.add(currentSegment);
      for(int l = 0; l < currentSegment.ledN; l++){
        int x = currentSegment.leds[l].posX - (int)(1.5*MESH_WIDTH+10);
        int y = currentSegment.leds[l].posY;
        code += String.format("\tLED(%d, %d, %d, %d),\n", c, ledN, x, y);
        ledN++;
      }
      currentSegment = currentSegment.next;
    }
  }
  
  code += "};\n\n";
  
  code += "Edge edges[] = {\n";
  
  for(int i = 0; i < teensySegments.size(); i++){
    Segment s = teensySegments.get(i);
    code += String.format("\tEdge(%d, %d, %d, %d, %d, %d, %d, %d),\n", 
        s.startX - (int)(1.5*MESH_WIDTH+10), 
        s.startY, 
        s.endX - (int)(1.5*MESH_WIDTH+10), 
        s.endY, 
        teensySegments.indexOf(s.sn[0]),
        teensySegments.indexOf(s.sn[1]),
        teensySegments.indexOf(s.en[0]),
        teensySegments.indexOf(s.en[1]));
  }
  
  code += "};";
  
  PrintWriter out = createWriter("data/teensyCode.c");
  out.print(code);
  out.flush();
  out.close();
}