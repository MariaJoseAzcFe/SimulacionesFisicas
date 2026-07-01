// Use PeasyCam for 3D rendering //<>// //<>//
import peasy.*;



PeasyCam _camera;  


// Time control:

int _lastTimeDraw = 0;  
float _deltaTimeDraw = 0.0;   
float _simTime = 0.0;   
float _elapsedTime = 0.0;  


// Simulated entities:

Ball _ball;  
DeformableSurface _net;  


// Main code:

void initSimulation(SpringLayout springLayout)
{
  _simTime = 0.0;
  _elapsedTime = 0.0;
  NET_SPRING_LAYOUT = springLayout;

  _net = new DeformableSurface(NET_LENGTH_X, NET_LENGTH_Y, NET_NUMBER_OF_NODES_X, NET_NUMBER_OF_NODES_Y, NET_POS_Z, NET_NODE_MASS, NET_KE, NET_KD, NET_MAX_FORCE, NET_BREAK_LENGTH_FACTOR, NET_SPRING_LAYOUT, NET_IS_UNBREAKABLE, NET_COLOR);
  _ball = new Ball(BALL_START_POS, BALL_START_VEL, BALL_MASS, BALL_RADIUS, BALL_COLOR);
}

void resetBall()
{
  _ball.setPosition(BALL_START_POS);
  _ball.setVelocity(BALL_START_VEL);
}

void updateSimulation()
{
  _ball.update(SIM_STEP);
  _net.avoidCollision(_ball, COLLISION_KE, COLLISION_KD, COLLISION_MAX_FORCE, COLLISION_BREAK_LENGTH_FACTOR);
  _net.update(SIM_STEP);

  _simTime += SIM_STEP;
}

void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen(P3D);
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
  {
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y, P3D);
  }
}

void setup()
{
  frameRate(DRAW_FREQ);
  _lastTimeDraw = millis();
  SIM_STEP *= TIME_ACCEL;
  
  float aspect = float(DISPLAY_SIZE_X)/float(DISPLAY_SIZE_Y);  
  perspective((FOV*PI)/180, aspect, NEAR, FAR);
  _camera = new PeasyCam(this, 0);

  initSimulation(SpringLayout.STRUCTURAL);
}

void printInfo()
{
  pushMatrix();
  {
    camera();
    fill(0);
    textSize(20);
    
    text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", width*0.025, height*0.05);
    text("Elapsed time = " + _elapsedTime + " s", width*0.025, height*0.075);
    text("Simulated time = " + _simTime + " s ", width*0.025, height*0.1);
    text("Spring layout = " + NET_SPRING_LAYOUT, width*0.025, height*0.125);
    text("Ball start velocity = " + BALL_START_VEL + " m/s", width*0.025, height*0.15);

    if (NET_IS_UNBREAKABLE)
      text("Net is unbreakable", width*0.025, height*0.175);
    else   
      text("Net is breakable", width*0.025, height*0.175);
  }
  popMatrix();
}

void drawStaticEnvironment()
{
  fill(255, 255, 255);
  sphere(1.0);

  fill(255, 0, 0);
  box(200.0, 0.25, 0.25);

  fill(0, 255, 0);
  box(0.25, 200.0, 0.25);

  fill(0, 0, 255);
  box(0.25, 0.25, 200.0);
}

void drawDynamicEnvironment()
{
  _net.draw();
  _ball.render();
}

void draw()
{
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;



  background(BACKGROUND_COLOR);
  //drawStaticEnvironment();
  drawDynamicEnvironment();

  if (REAL_TIME)
  {
    float expectedSimulatedTime = TIME_ACCEL*_deltaTimeDraw;
    float expectedIterations = expectedSimulatedTime/SIM_STEP;
    int iterations = 0; 

    for (; iterations < floor(expectedIterations); iterations++)
      updateSimulation();

    if ((expectedIterations - iterations) > random(0.0, 1.0))
    {
      updateSimulation();
      iterations++;
    }

  } 
  else
    updateSimulation();

  printInfo();
}

void keyPressed()
{
  if (key == '1')
    initSimulation(SpringLayout.STRUCTURAL);

  if (key == '2')
    initSimulation(SpringLayout.SHEAR);

  if (key == '3')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR);

  if (key == '4')
    initSimulation(SpringLayout.STRUCTURAL_AND_BEND);    

  if (key == '5')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR_AND_BEND);  
  
  if (key == ' ')
    resetBall();

  if (keyCode == UP)
    BALL_START_VEL.mult(1.05);

  if (keyCode == DOWN)
    BALL_START_VEL.div(1.05);
    
  if (key == 'B' || key == 'b')
  {
    NET_IS_UNBREAKABLE = !NET_IS_UNBREAKABLE;
    initSimulation(NET_SPRING_LAYOUT);
  }
}
