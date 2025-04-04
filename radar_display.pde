import processing.serial.*; // imports library for serial communication
import java.awt.event.KeyEvent; // imports library for reading the data from the serial port
import java.io.IOException;

Serial myPort; // defines Object Serial

// Defines variables
String angle = "";
String distance = "";
String data = "";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1 = 0;
int index2 = 0;
PFont orcFont;

void setup() {
  size (1200, 700); // Screen size
  smooth();
  myPort = new Serial(this, "COM5", 9600); // Start serial communication
  myPort.bufferUntil('.'); // Reads data from the serial port up to the character '.'
}

void draw() {
  fill(98, 245, 31);
  
  // Simulating motion blur and slow fade of the moving line
  noStroke();
  fill(0, 4); 
  rect(0, 0, width, height - height * 0.065); 

  fill(98, 245, 31); // Green color
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent (Serial myPort) { // Start reading data from Serial Port
  data = myPort.readStringUntil('.');
  data = data.substring(0, data.length() - 1);

  index1 = data.indexOf(",");
  angle = data.substring(0, index1);
  distance = data.substring(index1 + 1, data.length());

  // Convert String variables into Integer
  iAngle = int(angle);
  iDistance = int(distance);
}

void drawRadar() {
  pushMatrix();
  translate(width / 2, height - height * 0.074); // Move the starting coordinates
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);

  // Draws the arc lines
  arc(0, 0, (width - width * 0.0625), (width - width * 0.0625), PI, TWO_PI);
  arc(0, 0, (width - width * 0.27), (width - width * 0.27), PI, TWO_PI);
  arc(0, 0, (width - width * 0.479), (width - width * 0.479), PI, TWO_PI);
  arc(0, 0, (width - width * 0.687), (width - width * 0.687), PI, TWO_PI);
  
  // Draws the angle lines
  line(-width / 2, 0, width / 2, 0);
  for (int a = 30; a <= 150; a += 30) {
    line(0, 0, (-width / 2) * cos(radians(a)), (-width / 2) * sin(radians(a)));
  }
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(width / 2, height - height * 0.074);
  strokeWeight(9);
  stroke(255, 10, 10); // Red color

  pixsDistance = iDistance * ((height - height * 0.1666) * 0.025); 

  if (iDistance < 40) {
    line(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)), 
         (width - width * 0.505) * cos(radians(iAngle)), -(width - width * 0.505) * sin(radians(iAngle)));
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(width / 2, height - height * 0.074);
  line(0, 0, (height - height * 0.12) * cos(radians(iAngle)), -(height - height * 0.12) * sin(radians(iAngle)));
  popMatrix();
}

void drawText() { 
  pushMatrix();
  if (iDistance > 40) {
    noObject = "Out of Range";
  } else {
    noObject = "In Range";
  }
  fill(0, 0, 0);
  noStroke();
  rect(0, height - height * 0.0648, width, height);
  fill(98, 245, 31);
  textSize(25);

  text("10cm", width - width * 0.3854, height - height * 0.0833);
  text("20cm", width - width * 0.281, height - height * 0.0833);
  text("30cm", width - width * 0.177, height - height * 0.0833);
  text("40cm", width - width * 0.0729, height - height * 0.0833);
  
  // Removed "N-Tech"
  textSize(40);
  text("Angle: " + iAngle + " ", width - width * 0.48, height - height * 0.0277);
  
  // Adjusted Distance text position
  text("Distance: " + iDistance + " cm", width - width * 0.26, height - height * 0.0277);

  textSize(25);
  fill(98, 245, 60);

  // Draw angle numbers
  int angles[] = {30, 60, 90, 120, 150};
  for (int a : angles) {
    resetMatrix();
    translate((width - width * 0.4994) + width / 2 * cos(radians(a)), 
              (height - height * 0.0907) - width / 2 * sin(radians(a)));
    rotate(-radians(90 - a));
    text(a, 0, 0);
  }
  popMatrix();
}
