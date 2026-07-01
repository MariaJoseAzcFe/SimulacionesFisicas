// Spring Layout
enum SpringLayout 
{
  STRUCTURAL, 
  SHEAR, 
  STRUCTURAL_AND_SHEAR, 
  STRUCTURAL_AND_BEND, 
  STRUCTURAL_AND_SHEAR_AND_BEND
}


// Simulation values:

final boolean REAL_TIME = true;
final float TIME_ACCEL = 1.0;   // To simulate faster (or slower) than real-time
float SIM_STEP = 0.001;   // Simulation time-step (s)


// Problem parameters:

final PVector G = new PVector(0.0, 0.0, -9.81);   // Acceleration due to gravity (m/(s*s))

final float NET_LENGTH_X = 500.0;    // Length of the net in the X direction (m)      //600     //400
final float NET_LENGTH_Y = 350.0;    // Length of the net in the Y direction (m)      //400     //260
final float NET_POS_Z = -500.0;   // Position of the net in the Z axis (m)
final int NET_NUMBER_OF_NODES_X = 50;   // Number of nodes of the net in the X direction     //60     //40
final int NET_NUMBER_OF_NODES_Y = 35;   // Number of nodes of the net in the Y direction     //40     //26
final float NET_NODE_MASS = 0.1;   // Mass of the nodes of the net (kg)

final float NET_KE = 150.0;   // Ellastic constant of the net's springs (N/m) 
final float NET_KD = 5.0;   // Damping constant of the net's springs (kg/m)
final float NET_MAX_FORCE = 500.0;   // Maximum force allowed for the net's springs (N)
final float NET_BREAK_LENGTH_FACTOR = 18.0;   // Maximum distance factor (measured in number of times the rest length) allowed for the net's springs

boolean NET_IS_UNBREAKABLE = false;   // True if the net cannot be broken
SpringLayout NET_SPRING_LAYOUT;   // Current spring layout

final PVector BALL_START_POS = new PVector(0.0, 0.0, -200.0);   // Initial position of the sphere (m)
PVector BALL_START_VEL = new PVector(0.0, 0.0, -200.0);   // Initial velocity of the sphere (m/s)
final float BALL_MASS = 100.0;   // Mass of the sphere (kg) //a 800 se traspasa
final float BALL_RADIUS = 50.0;   // Radius of the sphere (m)

final float COLLISION_KE = 100.0;   // Ellastic constant of the collision springs (N/m) 
final float COLLISION_KD = 3.0;   // Damping constant of the net's springs (kg/m)
final float COLLISION_MAX_FORCE = 500.0;   // Maximum force allowed for the collision springs (N)
final float COLLISION_BREAK_LENGTH_FACTOR = 18.0;   // Maximum distance factor (measured in number of times the rest length) allowed for the collision springs


// Display stuff:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

final float FOV = 60;   // Field of view (º)
final float NEAR = 0.01;   // Camera near distance (m)
final float FAR = 100000.0;   // Camera far distance (m)

final color BACKGROUND_COLOR = color(230, 240, 200);   // Background color (RGB)
final color NET_COLOR = color(0, 0, 0);   // Net lines color (RGB)
final color BALL_COLOR = color(250, 0, 0);   // Ball color (RGB)
