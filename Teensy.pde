class Teensy{
  Segment channel[] = new Segment[8];
  
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
  
  JSONObject toJson(){
    JSONObject out = new JSONObject();
    
    JSONArray ch = new JSONArray();
    for(int i = 0; i<8; i++){
      ch.append(segments.indexOf(channel[i]));
    }
    out.setJSONArray("chi", ch);
    
    return out;
  }
  
  void fromJson(JSONObject json){
    for(int i = 0; i < 8; i++){
      int j = json.getJSONArray("chi").getInt(i);
      if(j >= 0) channel[i] = segments.get(i);
    }    
  }  
}