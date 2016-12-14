

class LED{
  int posX, posY;
  color c;
  
  LED(int posX, int posY){
    this.posX = posX;
    this.posY = posY;
  }
  
  LED(JSONObject json){
    fromJson(json);
  }
  
  void draw(){
    imageMode(CENTER);
    tint(c);
    image(LED_Sprite, posX, posY);
  }
  
  void setColor(int r, int g, int b, int a){
    c = color(r,g,b,a);
  }
  
  void setColor(color c){
    this.c = c;
  }
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    if(posX < 536) out.setInt("posX", posX);
    else out.setInt("posX", posX+170);
    if(posY < 536) out.setInt("posY", posY);
    else out.setInt("posY", posY+170);
    out.setInt("c", c);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    
    if(json.getInt("posX") < 536) posX = json.getInt("posX");
    else posX = json.getInt("posX")-170;
    if(json.getInt("posY") < 536) posY = json.getInt("posY");
    else posY = json.getInt("posY")-170;
    c = json.getInt("c");
    
  }
}