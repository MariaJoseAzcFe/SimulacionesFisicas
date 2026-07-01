// Problem description: //<>//
//
// Particle attached to a spring under gravity and damping.
//
// Differential equations:
//
// m * s'' = Fe + Fd + Fg
//
// Fe = spring force
// Fd = damping force
// Fg = gravity
//

// Simulation and time control:

IntegratorType _integrator = IntegratorType.NONE;
float _timeStep;
float _simTime = 0.0;


// Output control:

boolean _writeToFile = true;
PrintWriter _output;


// Variables to be solved:

PVector _s = new PVector();
PVector _v = new PVector();
PVector _a = new PVector();
float _energy;


// Springs:

Spring _sp;


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

void mouseClicked()
{
   _s.set(mouseX, mouseY);
   _v.set(0.0, 0.0);
   _a.set(0.0, 0.0);
   _simTime = 0.0;
}

void keyPressed()
{
   if (key == 'r' || key == 'R')
      restartSimulation();
   else if (key == ' ')
      _integrator = IntegratorType.NONE;
   else if (key == '1')
      _integrator = IntegratorType.EXPLICIT_EULER;
   else if (key == '2')
      _integrator = IntegratorType.SIMPLECTIC_EULER;
   else if (key == '3')
      _integrator = IntegratorType.RK2;
   else if (key == '4')
      _integrator = IntegratorType.RK4;
   else if (key == '5')
      _integrator = IntegratorType.HEUN;
   else if (key == '+')
      _timeStep *= 1.1;
   else if (key == '-')
      _timeStep /= 1.1;
}

void initSimulation()
{
   if (_writeToFile)
   {
      _output = createWriter(FILE_NAME);
      writeToFile("t,E,dt,integrator,sx,sy,vx,vy,ax,ay");
   }

   _simTime = 0.0;
   _timeStep = TS;

   _s = S0.copy();
   _v.set(0.0, 0.0);
   _a.set(0.0, 0.0);

   _sp = new Spring(C.copy(), _s.copy(), KE, L0);
}

void restartSimulation()
{
   _simTime = 0.0;

   _s = S0.copy();
   _v.set(0.0, 0.0);
   _a.set(0.0, 0.0);

   _sp.setPos1(C.copy());
   _sp.setPos2(_s.copy());
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
   drawStaticEnvironment();
   drawMovingElements();

   updateSimulation();
   calculateEnergy();
   displayInfo();

   if (_writeToFile)
      writeToFile(_simTime + "," + _energy + "," + _timeStep + "," + _integrator + "," +
      _s.x + "," + _s.y + "," + _v.x + "," + _v.y + "," + _a.x + "," + _a.y);
}

void drawStaticEnvironment()
{
   background(BACKGROUND_COLOR[0], BACKGROUND_COLOR[1], BACKGROUND_COLOR[2]);
   fill(STATIC_ELEMENTS_COLOR[0], STATIC_ELEMENTS_COLOR[1], STATIC_ELEMENTS_COLOR[2]);

   ellipse(C.x, C.y, 10, 10);
}

void drawMovingElements()
{
   fill(MOVING_ELEMENTS_COLOR[0], MOVING_ELEMENTS_COLOR[1], MOVING_ELEMENTS_COLOR[2]);

   line(C.x, C.y, _s.x, _s.y);
   ellipse(_s.x, _s.y, 20, 20);
}

void updateSimulation()
{
   switch (_integrator)
   {
      case EXPLICIT_EULER:
         updateSimulationExplicitEuler();
         break;

      case SIMPLECTIC_EULER:
         updateSimulationSimplecticEuler();
         break;

      case HEUN:
         updateSimulationHeun();
         break;

      case RK2:
         updateSimulationRK2();
         break;

      case RK4:
         updateSimulationRK4();
         break;
   }

   _simTime += _timeStep;
}

void calculateEnergy()
{
   float kinetic = 0.5 * M * _v.magSq();
   float elastic = _sp.getEnergy();
   float gravitational = -M * G * (_s.y - C.y);

   _energy = kinetic + elastic + gravitational;
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

   text("Draw: " + frameRate + "fps", width*0.025, height*0.05);
   text("Integrator: " + _integrator, width*0.025, height*0.075);
   text("dt = " + _timeStep, width*0.025, height*0.1);
   text("t = " + _simTime, width*0.025, height*0.125);
   text("Energy: " + _energy, width*0.025, height*0.15);
}

void updateSimulationExplicitEuler()
{
   _a = calculateAcceleration(_s,_v);

   _s.add(PVector.mult(_v,_timeStep));
   _v.add(PVector.mult(_a,_timeStep));
}

void updateSimulationSimplecticEuler()
{
   _a = calculateAcceleration(_s,_v);
   _v.add(PVector.mult(_a,_timeStep));
   _s.add(PVector.mult(_v,_timeStep));
}

void updateSimulationRK2()
{
   PVector s1 = _s.copy();
   PVector v1 = _v.copy();
   PVector a1 = calculateAcceleration(s1,v1);

   PVector sMid = PVector.add(s1,PVector.mult(v1,_timeStep*0.5));
   PVector vMid = PVector.add(v1,PVector.mult(a1,_timeStep*0.5));

   PVector aMid = calculateAcceleration(sMid,vMid);

   _s.add(PVector.mult(vMid,_timeStep));
   _v.add(PVector.mult(aMid,_timeStep));

   _a = calculateAcceleration(_s,_v);
}

void updateSimulationRK4()
{
   PVector s1 = _s.copy();
   PVector v1 = _v.copy();
   PVector a1 = calculateAcceleration(s1,v1);

   PVector s2 = PVector.add(s1,PVector.mult(v1,_timeStep*0.5));
   PVector v2 = PVector.add(v1,PVector.mult(a1,_timeStep*0.5));
   PVector a2 = calculateAcceleration(s2,v2);

   PVector s3 = PVector.add(s1,PVector.mult(v2,_timeStep*0.5));
   PVector v3 = PVector.add(v1,PVector.mult(a2,_timeStep*0.5));
   PVector a3 = calculateAcceleration(s3,v3);

   PVector s4 = PVector.add(s1,PVector.mult(v3,_timeStep));
   PVector v4 = PVector.add(v1,PVector.mult(a3,_timeStep));
   PVector a4 = calculateAcceleration(s4,v4);

   PVector vFinal = PVector.add(v1,
      PVector.add(PVector.mult(v2,2),
      PVector.add(PVector.mult(v3,2),v4)));

   _s.add(PVector.mult(vFinal,_timeStep/6.0));

   PVector aFinal = PVector.add(a1,
      PVector.add(PVector.mult(a2,2),
      PVector.add(PVector.mult(a3,2),a4)));

   _v.add(PVector.mult(aFinal,_timeStep/6.0));

   _a = calculateAcceleration(_s,_v);
}

void updateSimulationHeun()
{
   PVector s1=_s.copy();
   PVector v1=_v.copy();
   PVector a1=calculateAcceleration(s1,v1);

   PVector s2=PVector.add(s1,PVector.mult(v1,_timeStep));
   PVector v2=PVector.add(v1,PVector.mult(a1,_timeStep));
   PVector a2=calculateAcceleration(s2,v2);

   _s.add(PVector.mult(PVector.add(v1,v2),_timeStep*0.5));
   _v.add(PVector.mult(PVector.add(a1,a2),_timeStep*0.5));

   _a = calculateAcceleration(_s,_v);
}

PVector calculateAcceleration(PVector s,PVector v)
{
   _sp.setPos2(s);
   _sp.update();

   PVector Fe = _sp.getForce();
   PVector Fd = PVector.mult(v,-KD);
   PVector Fg = PVector.mult(Gv,M);

   PVector Ftotal = PVector.add(Fe,PVector.add(Fd,Fg));

   return PVector.div(Ftotal,M);
}
