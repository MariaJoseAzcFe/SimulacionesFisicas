 //<>//

float _timeStep;        
float _simTime = 0.0;   
// Output control:

boolean _writeToFile = true;
PrintWriter _output;
boolean _computeParticleCollisions = true;
boolean _computePlaneCollisions = true;


ParticleSystem _ps;
ArrayList<PlaneSection> _planes;

// Performance measures:
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
   float cx = mouseX / PIXELS_PER_METER;
   float cy = mouseY / PIXELS_PER_METER;
   float maxX = DISPLAY_SIZE_X / PIXELS_PER_METER;
   float maxY = DISPLAY_SIZE_Y / PIXELS_PER_METER;

   for (int i = 0; i < N_CLICK; i++)
   {
      float mass = random(M_MIN, M_MAX);
      float scatter = 3.0 * RADIUS;
      float px = constrain(cx + random(-scatter, scatter), RADIUS, maxX - RADIUS);
      float py = constrain(cy + random(-scatter, scatter), RADIUS, maxY - RADIUS);
      _ps.addParticle(mass, new PVector(px, py), new PVector(0, 0), RADIUS, color(0));
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
}

void initParticleSystem()
{
   _ps = new ParticleSystem(new PVector());
   float maxX = DISPLAY_SIZE_X / PIXELS_PER_METER;
   float maxY = DISPLAY_SIZE_Y / PIXELS_PER_METER;

   for (int i = 0; i < N_INITIAL; i++)
   {
      float mass = random(M_MIN, M_MAX);
      PVector pos = new PVector(random(RADIUS, maxX - RADIUS), random(RADIUS, maxY - RADIUS));
      _ps.addParticle(mass, pos, new PVector(0, 0), RADIUS, color(0));
   }
}

void restartSimulation()
{
   _simTime = 0.0;
   _timeStep = TS;
   _ps.restart();
   initParticleSystem();
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

   // Draw wind direction indicator
   float theta = radians(THETA_WIND);
   float arrowLen = 40.0;
   float cx = 60, cy = 60;
   float ex = cx + arrowLen * cos(theta);
   float ey = cy + arrowLen * sin(theta);

   stroke(80, 80, 200);
   strokeWeight(2);
   line(cx, cy, ex, ey);

   float ax1 = ex + 10 * cos(theta + PI*0.8);
   float ay1 = ey + 10 * sin(theta + PI*0.8);
   float ax2 = ex + 10 * cos(theta - PI*0.8);
   float ay2 = ey + 10 * sin(theta - PI*0.8);
   line(ex, ey, ax1, ay1);
   line(ex, ey, ax2, ay2);

   fill(80, 80, 200);
   noStroke();
   textSize(13);
   text("Wind " + V_WIND + " m/s", cx - 10, cy + 55);
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
   
   textSize(13);
   text("Controls: R - Restart   +/- - Change timestep   Click - Add " + N_CLICK + " particles", width*0.3, height*0.31);
   text("Legend: Color=charge(blue:low, red:high) | Border=mass | Opacity=lifetime", width*0.3, height*0.33);
}
