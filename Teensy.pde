class Teensy{
  Segment channel[] = new Segment[8];
  
  color[] connColors = {#660000, #006666, #664D00, #001A66, #336600, #330066, #00661A, #66004D};
  
  Teensy(){
  }
  
  Teensy(JSONObject json){
    fromJson(json);
  }
  
  /*
  A function that relays the data of this teensy to the channels.
  Each 'channel' is just the first segment in that data chain, 
  segments relay the data themselves to the proper segment after them
  */
  
  
  void showData(int c){
    int mx1,my1,mx2,my2;
    Segment s = channel[c];
    if(s != null){
      s.setColor(#00FF00);
      mx1 = s.startX+(s.endX-s.startX)/2;  //Middle point of segment
      my1 = s.startY+(s.endY-s.startY)/2;
      drawDataArrows(c, true);
      
    }
  }
  
  void showDataDirection(){
    for(int i = 0; i < 8; i++){
      drawDataArrows(i, false);
    }
  }
  
  void drawDataArrows(int c, boolean sel){
    Segment s = channel[c];
    if(s != null){
      int mx1 = s.startX+(s.endX-s.startX)/2;  //Middle point of segment
      int my1 = s.startY+(s.endY-s.startY)/2;
      int mx2,my2;
      while(s.next != null){
          //Draw arrow from this segment to next one
          s = s.next;
          mx2 = s.startX+(s.endX-s.startX)/2;
          my2 = s.startY+(s.endY-s.startY)/2;
          drawArrow(mx1,my1,mx2,my2);
          mx1 = mx2;
          my1 = my2;
          if(sel) s.setColor(#00FFFF);
      }
    }
  }
  
  void drawArrow(int x1, int y1, int x2, int y2){
    strokeWeight(1);
    stroke(255,255,0);
    noFill();
    // draw the line
    line(x1, y1, x2, y2);
    
    // draw a triangle at (x2, y2)
    pushMatrix();
      translate(x2, y2);
      rotate(atan2(y2-y1, x2-x1));
      triangle(0, 0, -3, 1, -3, -1);
    popMatrix(); 

  }
  
  void addSegment(int c, Segment newS){
    Segment s = channel[c];
    if(s != null){
      while(s.next != null){ 
        if(s == newS) return;
        s = s.next;
      }
      s.next = newS;
      if(dist(s.endX, s.endY, newS.startX, newS.startY) > dist(s.endX, s.endY, newS.endX, newS.endY)){
        newS.flip();
      }
    }
    else{ 
      channel[c] = newS;
    }
    
    newS.connectedChannels++;
    newS.col_con = connColors[c];
    
    updateChannelInfo();
    addSnapshot();
  }
  
  void removeSegment(int c){
    Segment s = channel[c];
    if(s != null){
      Segment prevS = s;
      while(s.next != null){ 
        prevS = s;
        s = s.next;
      }
      if(prevS == s) channel[c] = null;
      else prevS.next = null;
      s.connectedChannels--;
    }
    updateChannelInfo();
    addSnapshot();
  }
  
  int LEDCount(int c){
    if(channel[c] == null) return 0;
    Segment s = channel[c];
    int count = s.ledN;
    while(s.next != null){
      s = s.next;
      count += s.ledN;
    }
    return count;
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    JSONArray ch = new JSONArray();
    for(int i = 0; i<8; i++){
      ch.append(segments.indexOf(channel[i]));
      //if(i == 0) println(segments.indexOf(channel[i]));
    }
    out.setJSONArray("chi", ch);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    for(int i = 0; i < 8; i++){
      int j = json.getJSONArray("chi").getInt(i);
      if(j >= 0){ 
        channel[i] = segments.get(j);
      }
    }    
  }  
}