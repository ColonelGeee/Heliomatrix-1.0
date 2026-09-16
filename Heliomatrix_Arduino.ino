// initialize your four output pins in here
int s0 = 22;
int s1 = 23;
int s2 = 24;
int s3 = 25;

// define the input pins for your setup
int SIG_pins[8] = {A0, A1, A2, A3, A4, A5, A6, A7};  // eight Multiplexer

void setup() {
  pinMode(s0, OUTPUT);
  pinMode(s1, OUTPUT);
  pinMode(s2, OUTPUT);
  pinMode(s3, OUTPUT);

  digitalWrite(s0, LOW);
  digitalWrite(s1, LOW);
  digitalWrite(s2, LOW);
  digitalWrite(s3, LOW);

  Serial.begin(115200);
}

void loop() {
  // one loop for 128 channels, serial communication, all sensors are in one chain
  for (int chan = 0; chan < 128; chan++) {
    int m = chan / 16;                
    int SIG_pin = SIG_pins[m];        
    int muxChannel = chan % 16;       

    changeChannelTo(muxChannel);  
    Serial.print(analogRead(SIG_pin));

    if (chan == 127) {
      Serial.print('e'); // ends stream with letter "e" for exit           
    } else {
      Serial.print(","); // comma between numbers
    }
  }
  Serial.println();
  delay(0.2); // wait time for stabilizing the data stream. CRUCIAL!!!
}

void changeChannelTo(int c) {
  int controls[4] = {s0, s1, s2, s3};
  int binaryValues[16][4] = {
    {0,0,0,0}, {1,0,0,0}, {0,1,0,0}, {1,1,0,0}, {0,0,1,0}, {1,0,1,0},
    {0,1,1,0}, {1,1,1,0}, {0,0,0,1}, {1,0,0,1}, {0,1,0,1}, {1,1,0,1},
    {0,0,1,1}, {1,0,1,1}, {0,1,1,1}, {1,1,1,1},
  };
  for (int i = 0; i < 4; i++) {
    digitalWrite(controls[i], binaryValues[c][i]);
  }
  delay(0.1);
}
