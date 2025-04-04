#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <Servo.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#define trigPin 8
#define echoPin 9
#define SERVO_PIN 11
#define MAX_DISTANCE 40  // Maximum detection range in cm

Servo myservo;
long duration;
int distance;

// Function to calculate distance using HC-SR04
int calculateDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = duration * 0.034 / 2;
  return distance;
}

// Function to draw radar on OLED
void drawRadar(int angle, int objDist) {
  display.clearDisplay();
  
  // Draw semi-circular radar grid
  display.drawCircle(64, 60, 20, WHITE);  // 10cm ring
  display.drawCircle(64, 60, 30, WHITE);  // 20cm ring
  display.drawCircle(64, 60, 40, WHITE);  // 30cm ring
  display.drawLine(64, 60, 64, 20, WHITE);  // 90° line
  display.drawLine(64, 60, 94, 40, WHITE);  // 45° line
  display.drawLine(64, 60, 34, 40, WHITE);  // 135° line

  // Convert angle to screen coordinates
  float rad = radians(angle);
  int radarX = 64 + cos(rad) * 40;
  int radarY = 60 - sin(rad) * 40;

  // Draw radar line
  display.drawLine(64, 60, radarX, radarY, WHITE);

  // Draw detected object if within range
  if (objDist > 0 && objDist <= MAX_DISTANCE) {
    int objX = 64 + cos(rad) * (objDist * 1.5);  // Scale for OLED
    int objY = 60 - sin(rad) * (objDist * 1.5);
    display.fillCircle(objX, objY, 2, WHITE);
  }

  // Display angle and distance
  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0, 0);
  display.print("Angle: ");
  display.print(angle);
  display.print(" Deg");

  display.setCursor(0, 10);
  display.print("Dist: ");
  display.print(objDist);
  display.print(" cm");

  display.display();
}

void setup() {
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  myservo.attach(SERVO_PIN);
  
  // Initialize OLED
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    while (true);  // Stop if OLED not found
  }
  display.clearDisplay();
  display.display();
}

void loop() {
  for (int i = 15; i <= 165; i += 2) {  // Sweep forward
    myservo.write(i);
    delay(15);
    int dist = calculateDistance();
    drawRadar(i, dist);
  }

  for (int i = 165; i >= 15; i -= 2) {  // Sweep backward
    myservo.write(i);
    delay(15);
    int dist = calculateDistance();
    drawRadar(i, dist);
  }
}
