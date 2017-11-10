import oscP5.*;
import processing.serial.*;
//import ddf.minim.*;
import netP5.*;
import processing.sound.*;

SinOsc sine;
SinOsc sine2;
NetAddress remote;
OscP5 oscP5;

// Re-Send OSC message to Osculator (Serial > HTTP) 
Serial serial;
OscSerial osc;
String serialName = "/dev/cu.usbserial-AH05JHVZ";
 
int led = 0;

SinOsc sineOsc1;
SinOsc sineOsc2;
 
void setup() {
  serial = new Serial(this, serialName, 38400);
  osc = new OscSerial(this, serial);
  osc.plug(this, "myFunction", "/helloFromArduino");
  
  oscP5 = new OscP5(this,12000);
  remote = new NetAddress("127.0.0.1",8000);
  
  sine = new SinOsc(this);
  //sine.play();
  sine.freq(200);
  
  sine2 = new SinOsc(this);
  //sine2.play();
  sine2.freq(500);
  
  sineOsc1 = new SinOsc(this);
  sineOsc1.play();
  
  sineOsc2 = new SinOsc(this);
  sineOsc2.play();
}
 
void draw() {
}
 
void keyPressed() {
  // send an OSC message
  OscMessage msg = new OscMessage("/led");
 
  if (led == 1) led = 0;
  else led = 1;  
 
  msg.add(led);
  osc.send(msg);
}
 
void plugTest(int value) {
  println("Plugged from /pattern: " + value);
}
 
// Any unplugged message will come here
void oscEvent(OscMessage theMessage) {
  println("Message: " + theMessage + ", " + theMessage.isPlugged());
  println(" typetag: "+theMessage.typetag());
  print(" data: ");
  theMessage.printData();

  //print(theMessage.get(0).floatValue());
  //print(" / ");
  //println(theMessage.get(1).floatValue());
 
  //OscMessage msg = new OscMessage("/gyro/status");
  //msg.add("2001");
  //oscP5.send(msg,remote);
  
  // TODO: Modulate the frequencies by using the original rotational velocity values
  //       to speed up or slow down the played notes.
  // FIXME: If NaN (or other), skip value change
  float gyroRoll = (float)abs(theMessage.get(0).floatValue()*20.);
  float gyroPitch = (float)abs(theMessage.get(1).floatValue()*20.);
  
  gyroPitch = map(gyroPitch, 0, 200, 0, 10);
  
  if(!Float.isNaN(gyroRoll)) {
    //sine.freq(gyroRoll);
    sineOsc1.freq(gyroRoll);
  }
  
  if(!Float.isNaN(gyroPitch) && !Float.isNaN(gyroRoll)) {
    //sine2.freq(gyroPitch);
    sineOsc2.freq(abs(gyroPitch+gyroRoll));
  }
}
