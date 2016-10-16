//Contains variables & methods for each segment of LEDs

class Segment{
  int startX, startY, endX, endY, ledN;
  Segment next;
  Segment[] startNeighbours = new Segment[2];
  Segment[] endNeighbours = new Segment[2];
  LED[] leds;
  boolean selected = false;
  boolean highlight = false;
  color c;
  
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
    
    leds = new LED[ledN];
    for(int i = 0; i < ledN; i++){
      int x = (int)lerp(startX, endX, 1.0/(2*ledN)+(float)i/ledN);
      int y = (int)lerp(startY, endY, 1.0/(2*ledN)+(float)i/ledN);
      leds[i] = new LED(x, y);
      leds[i].setColor(255, 255, 255, 255);
    }
    
    //For calculating distance to this line
    float dx = endX - startX; 
    float dy = endY - startY; 
    d = sqrt( dx*dx + dy*dy ); 
    ca = dx/d; // cosine
    sa = dy/d; // sine 
  }
  
  void update(){
    if(highlight){ 
      c = color(0,255,255);
      highlight = false; //Needs to be activated each frame (ugly but makes other code much easier)
    }
    else if(selected) c = color(255,255,0);
    else if(mouseHover()) c = color(255,128,128);
    else c = color(255,0,0);
  }
  
  void draw(){
    if(showSegments){
      stroke(c);
      strokeWeight(2);
      line(startX,startY,endX,endY);
    }
    
    if(showLeds){
      for(int i = 0; i<ledN; i++){
        leds[i].draw();
      }
    }
  }
  
  //Invoked by another segment when it detects this is probably one of its neighbours
  void addNeighbour(Segment neighbour, int place){
    if(place == 1){
      if(startNeighbours[0] == null) startNeighbours[0] = neighbour;
      else if(startNeighbours[1] == null) startNeighbours[1] = neighbour;
      else println("Segment "+segments.indexOf(this)+" already has two neighbours at its start");
    }
    else{
      if(endNeighbours[0] == null) endNeighbours[0] = neighbour;
      else if(endNeighbours[1] == null) endNeighbours[1] = neighbour;
      else println("Segment "+segments.indexOf(this)+" already has two neighbours at its end");
    }
  }
  
  void removeNeighbour(Segment neighbour){
    boolean found = false;
    for(int i = 0; i < 4; i++){
      if(i < 2){
        if(startNeighbours[i] == neighbour){ 
          startNeighbours[i] = null;
          found = true;
        }
      }
      else{
        if(endNeighbours[i] == neighbour){ 
          endNeighbours[i] = null;
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
      if(startNeighbours[0] == null || startNeighbours[1] == null) return 1;
      else return 0;
    }
    if(inRange(x, endX, NEIGHBOUR_DIST) && inRange(y, endY, NEIGHBOUR_DIST)){
      if(endNeighbours[0] == null || endNeighbours[1] == null) return 2;
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
  
  void highLight(){
    highlight = true;
  }
  
  float getDistance(float x, float y){
    float mx = (-startX+x)*ca + (-startY+y)*sa;
    
    if(mx <= 0) return dist(x,y,startX,startY);
    else if(mx >= d) return dist(x,y,endX,endY);
    else return dist(x, y, startX+mx*ca, startY+mx*sa);
  }
  
  //Deletes this segment
  void delete(){
    segments.remove(this);
    for(int i = 0; i<4; i++){
      if(i < 2){
        if(startNeighbours[i] != null) startNeighbours[i].removeNeighbour(this);
      }
      else{
        if(endNeighbours[i-2] != null) endNeighbours[i-2].removeNeighbour(this);
      }
    }
  }
}