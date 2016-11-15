//Contains variables & methods for each segment of LEDs

class Segment{
  int startX, startY, endX, endY, ledN;
  
  //The indices of the segments above, these can actually be serialized
  int n = -1;
  int[] sni = {-1,-1};
  int[] eni = {-1,-1};
  
  LED[] leds;
  
  boolean selected = false;
  color c;
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
      if(showNeighbours){
        if(sni[0] != -1) segments.get(sni[0]).setColor(col_nb);
        if(sni[1] != -1) segments.get(sni[1]).setColor(col_nb);
        if(eni[0] != -1) segments.get(eni[0]).setColor(col_nb);
        if(eni[1] != -1) segments.get(eni[1]).setColor(col_nb);
      }
    }
    else if(mouseHover()) c = col_hov;
  }
  
  void draw(){
    if(showSegments){
      stroke(c);
      strokeWeight(2);
      line(startX,startY,endX,endY);
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
    
    c = col_norm;
  }
  
  //Adds a neighbour to the proper place or gives an error message if it is already full
  void addNeighbour(Segment neighbour, int place){
    if(place == 1){
      if(sni[0] == -1) sni[0] = segments.indexOf(neighbour);
      else if(sni[1] == -1) sni[1] = segments.indexOf(neighbour);
      else println("Segment "+segments.indexOf(this)+" already has two neighbours at its start");
    }
    else{
      if(eni[0] == -1) eni[0] = segments.indexOf(neighbour);
      else if(eni[1] == -1) eni[1] = segments.indexOf(neighbour);
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
        if(segments.get(sni[i]) == neighbour){ 
          sni[i] = -1;
          found = true;
        }
      }
      else{
        if(segments.get(eni[i-2]) == neighbour){ 
          eni[i-2] = -1;
          found = true;
        }
      }
    }
    if(!found) println("Cannot delete neighbour, not found");
  }
  
  //Returns if a potential start/end position can be a neighbour of this segment
  //1 if this is the case for the startPos of this segment, 2 for endPos
  int getPossibleNeighbour(int x, int y){
    if(inRange(x, startX, NEIGHBOUR_DIST) && inRange(y, startY, NEIGHBOUR_DIST)){
      if(sni[0] == -1 || sni[1] == -1) return 1;
      else return 0;
    }
    if(inRange(x, endX, NEIGHBOUR_DIST) && inRange(y, endY, NEIGHBOUR_DIST)){
      if(eni[0] == -1 || eni[1] == -1) return 2;
      else return 0;
    }
    return 0;
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
        if(sni[i] != -1) segments.get(sni[i]).removeNeighbour(this);
      }
      else{
        if(eni[i-2] != -1) segments.get(eni[i-2]).removeNeighbour(this);
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
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    out.setInt("startX", startX);
    out.setInt("startY", startY);
    out.setInt("endX", endX);
    out.setInt("endY", endY);
    out.setInt("ledN", ledN);
    out.setInt("n", n);
    
    JSONArray t = new JSONArray();
    t.append(sni[0]);
    t.append(sni[1]);
    out.setJSONArray("sni", t);
    t = new JSONArray();
    t.append(eni[0]);
    t.append(eni[1]);
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
    startX = json.getInt("startX");
    startY = json.getInt("startY");
    endX = json.getInt("endX");
    endY = json.getInt("endY");
    ledN = json.getInt("ledN");
    
    n = json.getInt("n");
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