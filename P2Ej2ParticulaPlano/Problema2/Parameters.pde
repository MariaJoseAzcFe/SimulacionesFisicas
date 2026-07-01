enum CollisionDataType { NONE, GRID, HASH }

final int DRAW_FREQ = 100;
final int DISPLAY_SIZE_X = 1000;
final int DISPLAY_SIZE_Y = 1000;
final int[] BACKGROUND_COLOR = {200, 210, 240};
final int[] TEXT_COLOR = {0, 0, 0};
final String FILE_NAME = "p2data.csv";

// Simulation parameters
final float TS        = 0.01;   
final float KE  = 0.0;    
final float KD  = 8.0;  
final float CR  = 0.0;   
final float DM  = 0.12;
final float L0  = 0.12;
final float R   = 0.06;
final float M   = 0.1;
final float G   = 9.81;


final float M_TO_PX   = 100.0;


final float W_X1 = 175, W_Y1 = 50;
final float W_X2 = 300, W_Y2 = 50;
final float W_X3 = 700, W_Y3 = 50;
final float W_X4 = 825, W_Y4 = 50;
final float W_X5 = 425, W_Y5 = 650;
final float W_X6 = 575, W_Y6 = 650;

final float SC_GRID = 1.25;       
final float SC_HASH = 1.25;       
final int   NC_HASH = 500;     

final int   SPAWN_N  = 50;        
final float SPAWN_VX = 0.0;   
final float SPAWN_VY = 0.0;     

final color PARTICLES_COLOR = color(80, 130, 220, 220);
