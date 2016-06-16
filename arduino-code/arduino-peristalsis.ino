/*
      Arduino MEGA controller code for peristaltic pattern
      ..... <-.... --... .--.. ..--. ...-- ....- ..... <wait psPeriod>
      (psDelay is the time delay between changing these states)

      Legend:
      - = depressed valve
      . = released valve
*/

// Pin 13 has an LED connected on most Arduino boards.
// give it a name:
int i = 1;

int pinOutput = 1;
int pinMin = 1;
int pinMax = 8;
int psDelay = 500;
int psPeriod = 120000;

/*
      This setup routine runs once when you press reset
      and initializes the states of all pins.
*/
void setup() {
      pinMode(pinOutput, OUTPUT);
}


/*
      Main loop that executes peristalsis.
*/
void loop() {
      // GO through each pin 'i'
      for (i = 1; i <= 2*pinMax; i++) {
            // if 'i' is odd, then just light up
            if (i == 1) {
              analogWrite(11, 255);
            }
            else if (i == 2) {
              // analogWrite(11, 0);
              analogWrite(i, 255);
            }
            else if (i == 2*pinMax) {
              // release the last one
              analogWrite(pinMax, 0);
            }
            else {
              if (i%2 == 0) {
                // even loop parts that are not the last one
                analogWrite(i/2 + 1, 255);
              }
              else {
                // odd loop parts that aren't the first one
               if (i == 3) {
                 analogWrite(11, 0);
               }
               else {
                 analogWrite((i-1)/2, 0);
               }
              }
            }
            // time delay between next squeeze/release
            delay(psDelay);
      } // end for loop
      // time delay between squeezing periods
      delay(psPeriod);
}// end loop function
