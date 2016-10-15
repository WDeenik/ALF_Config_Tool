

class LED{
  int posX, posY;
  color c;
  
  LED(int posX, int posY){
    this.posX = posX;
    this.posY = posY;
  }
  
  void draw(){
    //stroke(0,255,0);
    //point(posX,posY);
    imageMode(CENTER);
    tint(c, 128);
    image(LED_Sprite, posX, posY);
  }
  
  void setColor(int r, int g, int b){
    c = color(r,g,b);
  }
  
  void setColor(color c){
    this.c = c;
  }
}