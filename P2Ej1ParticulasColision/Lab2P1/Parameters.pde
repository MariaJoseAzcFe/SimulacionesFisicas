// Definitions:

enum CollisionDataType
{
   NONE,
   GRID,
   HASH
}

// Display and output parameters:

final int DRAW_FREQ = 100;                
final int DISPLAY_SIZE_X = 1000;                      
final int DISPLAY_SIZE_Y = 1000;                
final int [] BACKGROUND_COLOR = {200, 210, 240};      
final int [] TEXT_COLOR = {0, 0, 0};                  
final String FILE_NAME = "p3data.csv";       

// Parameters of the problem:

final float TS = 0.005;                               
final float M = 0.1;                                  

// Constantes añadidas para el Problema 1:
final float PIXELS_PER_METER = 100.0;
final float RADIUS = 0.08;
final float TL = 15.0;
final float M_MIN = 0.5;
final float M_MAX = 5.0;
final float Q_MIN = 1.0;
final float Q_MAX = 10.0;
final int   N_INITIAL = 100;
final int   N_CLICK = 100;
final float KA = 0.5;
final float KD = 0.02;
final float V_WIND = 1.0;
final float THETA_WIND = 45.0;

// Constants of the problem:

final color PARTICLES_COLOR = color(120, 150, 200);
final int SC_GRID = 50;                            
final int SC_HASH = 50;                             
final int NC_HASH = 1000;                            
