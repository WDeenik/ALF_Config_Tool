//Contains variables & methods for each segment of LEDs

class Segment{
  int startX, startY, endX, endY, ledN;
  Segment next;
  Segment[] startNeighbours = new Segment[2];
  Segment[] endNeighbours = new Segment[2];
  LED[] leds;
  
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
  }
  
  void draw(){
    if(showSegments){
      stroke(255,0,0);
      strokeWeight(2);
      line(startX,startY,endX,endY);
    }
    if(showLeds){
      for(int i = 0; i<ledN; i++){
        leds[i].draw();
      }
    }
  }
  
  //Invoked by another segment when it detect this is probably one of its neighbours
  void setNeigbour(Segment neighbour, boolean start){
    if(start){
      if(startNeighbours[0] == null) startNeighbours[0] = neighbour;
      else if(startNeighbours[1] == null) startNeighbours[1] = neighbour;
      else println("This segment already has two neighbours at its start");
    }
    else{
      if(endNeighbours[0] == null) endNeighbours[0] = neighbour;
      else if(endNeighbours[1] == null) endNeighbours[1] = neighbour;
      else println("This segment already has two neighbours at its end");
    }
  }
}