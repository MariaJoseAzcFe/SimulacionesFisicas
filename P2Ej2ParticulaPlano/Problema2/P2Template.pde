 //<>//

float _timeStep;        
float _simTime = 0.0;  
boolean _writeToFile = true;
PrintWriter _output;
boolean _computeParticleCollisions = true;
boolean _computePlaneCollisions = true;


ParticleSystem _ps;
ArrayList<PlaneSection> _planes;


float _Tint = 0.0;    
float _Tdata = 0.0;   
float _Tcol1 = 0.0;   
float _Tcol2 = 0.0;  
float _Tsim = 0.0;    
float _Tdraw = 0.0;  

// Main code:

void settings()
{
   size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup()
{
   frameRate(DRAW_FREQ);
   background(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2]);

   initSimulation();
}

void stop()
{
   endSimulation();
}

void keyPressed()
{
   if (key == 'r' || key == 'R')
      restartSimulation();
   else if (key == 'c' || key == 'C')
      _computeParticleCollisions = !_computeParticleCollisions;
   else if (key == 'p' || key == 'P')
      _computePlaneCollisions = !_computePlaneCollisions;
   else if (key == 'n' || key == 'N')
      _ps.setCollisionDataType(CollisionDataType.NONE);
   else if (key == 'g' || key == 'G')
      _ps.setCollisionDataType(CollisionDataType.GRID);
   else if (key == 'h' || key == 'H')
      _ps.setCollisionDataType(CollisionDataType.HASH);
   else if (key == '+')
      _timeStep *= 1.1;
   else if (key == '-')
      _timeStep /= 1.1;
}

void mousePressed()
{
   // Convert mouse px → simulation metres
   float mx = mouseX / M_TO_PX;
   float my = mouseY / M_TO_PX;
   for (int i = 0; i < SPAWN_N; i++)
   {
      float ox = random(-R, R);
      float oy = random(-R, R);
      _ps.addParticle(M, new PVector(mx + ox, my + oy),
                      new PVector(SPAWN_VX, SPAWN_VY), R, PARTICLES_COLOR);
   }
}

void initSimulation()
{
   if (_writeToFile)
   {
      _output = createWriter(FILE_NAME);
      writeToFile("t, n, Tsim");
   }

   _simTime = 0.0;
   _timeStep = TS;

   initPlanes();
   initParticleSystem();
}

void initPlanes()
{
   _planes = new ArrayList<PlaneSection>();
   _planes.add(new PlaneSection(W_X1, W_Y1, W_X2, W_Y2, true));   // tope izq  → normal hacia abajo
   _planes.add(new PlaneSection(W_X3, W_Y3, W_X4, W_Y4, true));   // tope der  → normal hacia abajo
   _planes.add(new PlaneSection(W_X1, W_Y1, W_X5, W_Y5, false));  // diag izq  → normal hacia dentro
   _planes.add(new PlaneSection(W_X4, W_Y4, W_X6, W_Y6, true));   // diag der  → normal hacia dentro
   _planes.add(new PlaneSection(W_X5, W_Y5, W_X6, W_Y6, false));  // fondo     → normal hacia arriba
}

void initParticleSystem()
{
   _ps = new ParticleSystem(new PVector(0, 0));
}

void restartSimulation()
{
   _simTime = 0.0;
   _timeStep = TS;
   _ps.restart();
}

void endSimulation()
{
   if (_writeToFile)
   {
      _output.flush();
      _output.close();
   }
}

void draw()
{
   float time = millis();
   drawStaticEnvironment();
   drawMovingElements();
   _Tdraw = millis() - time;

   time = millis();
   updateSimulation();
   _Tsim = millis() - time;

   displayInfo();

   if (_writeToFile)
      writeToFile(_simTime + ", " + _ps.getNumParticles() + "," + _Tsim);
}

void drawStaticEnvironment()
{
   background(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2]);

   for (int i = 0; i < _planes.size(); i++)
      _planes.get(i).draw();
}

void drawMovingElements()
{
   _ps.draw();
}

void updateSimulation()
{
   float time = millis();
   if (_computePlaneCollisions)
      _ps.computePlanesCollisions(_planes);
   _Tcol1 = millis() - time;

   time = millis();
   if (_computeParticleCollisions)
      _ps.updateCollisionData();
   _Tdata = millis() - time;

   time = millis();
   if (_computeParticleCollisions)
      _ps.computeParticleCollisions(_timeStep);
   _Tcol2 = millis() - time;

   time = millis();
   _ps.update(_timeStep);
   _simTime += _timeStep;
   _Tint = millis() - time;
}

void writeToFile(String data)
{
   _output.println(data);
}

void displayInfo()
{
   stroke(TEXT_COLOR[0], TEXT_COLOR[1], TEXT_COLOR[2]);
   fill(TEXT_COLOR[0], TEXT_COLOR[1], TEXT_COLOR[2]);
   textSize(20);
   text("Time integrating equations: " + _Tint + " ms", width*0.3, height*0.025);
   text("Time updating collision data: " + _Tdata + " ms", width*0.3, height*0.050);
   text("Time computing collisions (planes): " + _Tcol1 + " ms", width*0.3, height*0.075);
   text("Time computing collisions (particles): " + _Tcol2 + " ms", width*0.3, height*0.100);
   text("Total simulation time: " + _Tsim + " ms", width*0.3, height*0.125);
   text("Time drawing: " + _Tdraw + " ms", width*0.3, height*0.150);
   text("Total step time: " + (_Tsim + _Tdraw) + " ms", width*0.3, height*0.175);
   text("Fps: " + frameRate + "fps", width*0.3, height*0.200);
   text("Simulation time step = " + _timeStep + " s", width*0.3, height*0.225);
   text("Simulated time = " + _simTime + " s", width*0.3, height*0.250);
   text("Number of particles: " + _ps.getNumParticles(), width*0.3, height*0.275);
}
