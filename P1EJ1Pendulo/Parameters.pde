enum IntegratorType
{
   NONE,
   EXPLICIT_EULER,
   SIMPLECTIC_EULER,
   RK2,
   RK4,
   HEUN
}

final int DRAW_FREQ = 100;
final int DISPLAY_SIZE_X = 1000;
final int DISPLAY_SIZE_Y = 1000;

final int[] BACKGROUND_COLOR = {220,190,210};
final int[] TEXT_COLOR = {0,0,0};
final int[] STATIC_ELEMENTS_COLOR = {0,255,0};
final int[] MOVING_ELEMENTS_COLOR = {255,0,0};

final float OBJECTS_SIZE = 20.0;

final String FILE_NAME = "data.csv";

final float TS = 0.005;
final float M = 3.0;
final float G = 9.801;
final float D = 250.0;

final float KE = 10000.0;
final float L0 = 100.0;

final float KD = 0.0;

final PVector Gv = new PVector(0,G);

final PVector C = new PVector(500,500);
final PVector S0 = PVector.add(C,new PVector(0,D));
