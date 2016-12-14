//Contains variables & methods for each segment of LEDs

class Segment{
  int startX, startY, endX, endY, ledN;
  
  boolean checkedLedN = false;
  
  //The indices of the segments above, these can actually be serialized
  Segment next;
  int nexti = -1;
  int connectedChannels = 0;
  Segment[] sn = new Segment[2];
  Segment[] en = new Segment[2];
  
  int[] sni = {-1,-1};
  int[] eni = {-1,-1};
  
  LED[] leds;
  
  boolean selected = false;
  color c;
  color col_con = #660000;  //Dark red for data mode, when segment is connected
  color col_conErr = #FF00FF; //pink to indicate this segment is connected wrong (more than once or less than zero which should not happen)
  color col_sel = #FFFF00;  //yellow
  color col_nb = #00FFFF;   //cyan
  color col_data = #00FF00; //green
  color col_norm = #FF0000; //red
  color col_hov = #FFBBBB;   //light red
  
  //For calculating distance to this segment
  float d, ca, sa;
  
  Segment(int startX, int startY, int endX, int endY, int ln){
    this.startX = startX;
    this.startY = startY;
    this.endX = endX;
    this.endY = endY;
    
    //Calculate ledN automatically if it is set to 0
    if(ln == 0){
      float d = dist(startX, startY, endX, endY)*(float)HEIGHT/height;
      ledN = floor(d/LED_PITCH);
    }
    else ledN = ln;
    
    updateLEDs(ledN);
    
    //For calculating distance to this line
    updateDistVars();
  }
  
  Segment(JSONObject json){
    fromJson(json);
  }
  
  void update(){
    if(selected){ 
      c = color(255,255,0);
      if(showNeighbours && !dataMode){
        if(sn[0] != null) sn[0].setColor(col_nb);
        if(sn[1] != null) sn[1].setColor(col_nb);
        if(en[0] != null) en[0].setColor(col_nb);
        if(en[1] != null) en[1].setColor(col_nb);
      }
    }
    else if(mouseHover()) c = col_hov;
  }
  
  void draw(){
    if(showSegments){
      stroke(c);
      strokeWeight(2);
      line(startX,startY,endX,endY);
      
      if(showOrientation){
        noFill();
        strokeWeight(1);
        int mx = startX+(endX-startX)/2;  //Middle point of segment
        int my = startY+(endY-startY)/2;
        pushMatrix();
        translate(mx, my);
        rotate(atan2(endY-startY, endX-startX));
        triangle(2, 0, -4, 3, -4, -3);
        popMatrix(); 
      }
    }
    
    //Show start/end position if selected
    if(selected){
      noStroke();
      fill(0,255,0);
      ellipse(startX,startY,5,5);
      fill(255,0,0);
      ellipse(endX,endY,5,5);
    }
    
    if(showLeds){
      for(int i = 0; i<ledN; i++){
        leds[i].draw();
      }
    }
    
    if(dataMode){
      if(connectedChannels == 0) c = col_norm;
      else if(connectedChannels == 1) c = col_con;
      else c = col_conErr;
    }
    else{ 
      if(!checkLeds) c = col_norm;
      else{
        if(checkedLedN) c = col_norm;
        else c = col_conErr;
      }
    }
  }
  
  //Adds a neighbour to the proper place or gives an error message if it is already full
  void addNeighbour(Segment neighbour, int place){
    if(place == 1){
      if(sn[0] == null) sn[0] = neighbour;
      else if(sn[1] == null) sn[1] = neighbour;
      else println("Segment "+segments.indexOf(this)+" already has two neighbours at its start");
    }
    else{
      if(en[0] == null) en[0] = neighbour;
      else if(en[1] == null) en[1] = neighbour;
      else println("Segment "+segments.indexOf(this)+" already has two neighbours at its end");
    }
  }
  
  //This finds and adds the neighbours around this segment
  void autoFindNeighbours(){
    for(int i = 0; i<segments.size(); i++){
      Segment s = segments.get(i);
      if(s != this){
        int n = s.getPossibleNeighbour(startX,startY);
        if(n > 0){
          s.addNeighbour(this, n);
          addNeighbour(s, 1);
        }
        else{
          n = s.getPossibleNeighbour(endX,endY);
          if(n > 0){
            s.addNeighbour(this, n);
            addNeighbour(s, 2);
          }
        }
      }
    }
  }
  
  //Finds and removes a neighbour and gives an error message if the neighbour is not found
  void removeNeighbour(Segment neighbour){
    boolean found = false;
    for(int i = 0; i < 4; i++){
      if(i < 2){
        if(sn[i] == neighbour){ 
          sn[i] = null;
          neighbour.removeNeighbour(this);
          found = true;
        }
      }
      else{
        if(en[i-2] == neighbour){ 
          en[i-2] = null;
          neighbour.removeNeighbour(this);
          found = true;
        }
      }
    }
    //if(!found) println("Cannot delete neighbour, not found");
  }
  
  //Returns if a potential start/end position can be a neighbour of this segment
  //1 if this is the case for the startPos of this segment, 2 for endPos
  int getPossibleNeighbour(int x, int y){
    if(inRange(x, startX, NEIGHBOUR_DIST) && inRange(y, startY, NEIGHBOUR_DIST)){
      if(sn[0] == null || sn[1] == null) return 1;
      else return 0;
    }
    if(inRange(x, endX, NEIGHBOUR_DIST) && inRange(y, endY, NEIGHBOUR_DIST)){
      if(en[0] == null || en[1] == null) return 2;
      else return 0;
    }
    return 0;
  }
  
  void flip(){
    int tempX = startX;
    int tempY = startY;
    startX = endX;
    startY = endY;
    endX = tempX;
    endY = tempY;
    updateDistVars();
  }
  
  private boolean inRange(int x1, int x2, int range){
    return (x1 > x2-range && x1 < x2+range);
  }
  
  boolean mouseHover(){
    if(getDistance(mouseX, mouseY) < 2) return true;
    else return false;
  }
  
  void setColor(color col){
    c = col;
  }
  
  float getDistance(float x, float y){
    float mx = (-startX+x)*ca + (-startY+y)*sa;
    
    if(mx <= 0) return dist(x,y,startX,startY);
    else if(mx >= d) return dist(x,y,endX,endY);
    else return dist(x, y, startX+mx*ca, startY+mx*sa);
  }
  
  void updateLEDs(int ledn){
    ledN = ledn;
    leds = new LED[ledN];
    for(int i = 0; i < ledN; i++){
      int x = (int)lerp(startX, endX, 1.0/(2*ledN)+(float)i/ledN);
      int y = (int)lerp(startY, endY, 1.0/(2*ledN)+(float)i/ledN);
      leds[i] = new LED(x, y);
      leds[i].setColor(255, 255, 255, 255);
    }
  }
  
  //Deletes this segment
  void delete(){
    segments.remove(this);
    selectedSegment = null;
    for(int i = 0; i<4; i++){
      if(i < 2){
        if(sn[i] != null) sn[i].removeNeighbour(this);
      }
      else{
        if(en[i-2] != null) en[i-2].removeNeighbour(this);
      }
    }
  }
  
  void updateDistVars(){
    float dx = endX - startX; 
    float dy = endY - startY; 
    d = sqrt( dx*dx + dy*dy ); 
    ca = dx/d; // cosine
    sa = dy/d; // sine 
  }
  
  //Convert indices to Segments again
  void updateSegments(){
    for(int i = 0; i<2; i++){
      if(sni[i] != -1) sn[i] = segments.get(sni[i]);
      if(eni[i] != -1) en[i] = segments.get(eni[i]);
    }
    if(nexti != -1) next = segments.get(nexti);
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    
    if(startX < 536) out.setInt("startX", startX);
    else out.setInt("startX", startX+170);
    out.setInt("startY", startY);
    if(endX < 536) out.setInt("endX", endX);
    else out.setInt("endX", endX+170);
    out.setInt("endY", endY);
    out.setInt("ledN", ledN);
    out.setInt("nexti", segments.indexOf(next));
    out.setInt("connectedChannels", connectedChannels);
    out.setInt("col_con", col_con);
    out.setBoolean("checkedLedN", checkedLedN);
    
    JSONArray t = new JSONArray();
    t.append(segments.indexOf(sn[0]));
    t.append(segments.indexOf(sn[1]));
    out.setJSONArray("sni", t);
    t = new JSONArray();
    t.append(segments.indexOf(en[0]));
    t.append(segments.indexOf(en[1]));
    out.setJSONArray("eni", t);
    
    
    
    t = new JSONArray();
    for(int i = 0; i<leds.length; i++){
      t.append(leds[i].toJson());
    }
    out.setJSONArray("leds", t);
    
   // out.setBoolean("selected", selected);
    out.setInt("c", c);
    out.setFloat("d", d);
    out.setFloat("ca", ca);
    out.setFloat("sa", sa);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    if(json.getInt("startX") < 706) startX = json.getInt("startX");
    else startX = json.getInt("startX")-170;
    startY = json.getInt("startY");
    if(json.getInt("endX") < 706) endX = json.getInt("endX");
    else endX = json.getInt("endX")-170;
    endY = json.getInt("endY");
    ledN = json.getInt("ledN");
    col_con = json.getInt("col_con");
    checkedLedN = json.getBoolean("checkedLedN");
    
    nexti = json.getInt("nexti");
    connectedChannels = json.getInt("connectedChannels");
    sni = json.getJSONArray("sni").getIntArray();
    eni = json.getJSONArray("eni").getIntArray();
    
    leds = new LED[ledN];
    JSONArray t = json.getJSONArray("leds");
    for(int i = 0; i<ledN; i++){
      leds[i] = new LED(t.getJSONObject(i));
    }
    
  //  selected = json.getBoolean("selected");
    c = json.getInt("c");
    d = json.getFloat("d");
    ca = json.getFloat("ca");
    sa = json.getFloat("sa");
  }
}