
IntegratorType _integrator = IntegratorType.NONE; 
float _simTime, _dt;
PVector _s, _v, _a;
ArrayList<PVector> _path = new ArrayList<PVector>(); // Rastro de la simulación
PrintWriter output;
boolean grabando = false;
boolean _hasHit = false;  //objetivo alcanzado

void settings() {
  size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup() {
  frameRate(DRAW_FREQ);
  _s = new PVector();
  _v = new PVector();
  _a = new PVector();
  restartSimulation();
}

void restartSimulation() {
  _simTime = 0.0;
  _dt = TS_INICIAL;
  _hasHit = false;

  _s.set(0, HW); 
  
  float angleRad = radians(THETA);
  _v.set(V0_MAG * cos(angleRad), V0_MAG * sin(angleRad)); 
  _a.set(0, 0);
  _path.clear(); 
}

void draw() {
  background(255, 253, 230); 
  

  pushMatrix();
  translate(50, MAR_Y_PANTALLA); 
  scale(1, -1);                
  
  drawScene();                   
  
  drawAnalyticalTrajectory();
  
  if (_integrator != IntegratorType.NONE) {
    updateSimulation();
    if (frameCount % 2 == 0) _path.add(_s.copy()); // Guardar rastro
  }
  
  drawCurrentPath();
  
  fill(255, 0, 0);
  noStroke();
  ellipse(_s.x, _s.y, 10, 10);
  
  popMatrix();
  
  displayHUD();
}

PVector calculateAcceleration(PVector s, PVector v) {
  PVector Fw = new PVector(0, -M * G); 
  float kdActual = (s.y >= 0) ? KDA : KDW;
  PVector Fd = PVector.mult(v, -kdActual); 
  
  return PVector.add(Fw, Fd).div(M); // a = F/m
}

void updateSimulation() {
  if (_hasHit || _s.y < -300) return; 
  
  switch (_integrator) {
    case EXPLICIT_EULER:   updateExplicitEuler(); break;
    case SIMPLECTIC_EULER: updateSimplecticEuler(); break;
    case HEUN:             updateHeun(); break;
    case RK2:              updateRK2(); break;
    case RK4:              updateRK4(); break;
    default: break;
  }
  _simTime += _dt;

  if (grabando && output != null) {
      output.println(nf(_s.x, 0, 4).replace(',', '.') + "," + nf(_s.y, 0, 4).replace(',', '.'));
  
  }

  float radioBarco = 20; 
  if (_s.y <= 5 && _s.y >= -5 && _s.x >= (D - radioBarco) && _s.x <= (D + radioBarco)) {
    _hasHit = true;
    println("¡OBJETIVO ALCANZADO!");
  }

  if (_s.y <= 0 || _hasHit) {
      if (grabando) {
          finalizarGrabacion();
      }
  }
}

// --- Integradores Numéricos  ---

void updateExplicitEuler() {
  _a = calculateAcceleration(_s, _v);
  _s.add(PVector.mult(_v, _dt));
  _v.add(PVector.mult(_a, _dt));
}

void updateSimplecticEuler() {
  _a = calculateAcceleration(_s, _v);
  _v.add(PVector.mult(_a, _dt));
  _s.add(PVector.mult(_v, _dt));
}

void updateHeun() {
  PVector a_ini = calculateAcceleration(_s, _v);
  PVector s_pre = PVector.add(_s, PVector.mult(_v, _dt));
  PVector v_pre = PVector.add(_v, PVector.mult(a_ini, _dt));
  PVector a_pre = calculateAcceleration(s_pre, v_pre);
  _s.add(PVector.mult(PVector.add(_v, v_pre), _dt * 0.5));
  _v.add(PVector.mult(PVector.add(a_ini, a_pre), _dt * 0.5));
}

void updateRK2() {
  PVector a1 = calculateAcceleration(_s, _v);
  PVector s_mid = PVector.add(_s, PVector.mult(_v, _dt/2.0));
  PVector v_mid = PVector.add(_v, PVector.mult(a1, _dt/2.0));
  PVector a_mid = calculateAcceleration(s_mid, v_mid);
  _s.add(PVector.mult(v_mid, _dt));
  _v.add(PVector.mult(a_mid, _dt));
}

void updateRK4() {
  float h = _dt;
  PVector k1v = _v.copy();
  PVector k1a = calculateAcceleration(_s, k1v);
  PVector k2v = PVector.add(_v, PVector.mult(k1a, h/2));
  PVector k2a = calculateAcceleration(PVector.add(_s, PVector.mult(k1v, h/2)), k2v);
  PVector k3v = PVector.add(_v, PVector.mult(k2a, h/2));
  PVector k3a = calculateAcceleration(PVector.add(_s, PVector.mult(k2v, h/2)), k3v);
  PVector k4v = PVector.add(_v, PVector.mult(k3a, h));
  PVector k4a = calculateAcceleration(PVector.add(_s, PVector.mult(k3v, h)), k4v);
  _s.add(PVector.add(k1v, PVector.add(PVector.mult(k2v, 2), PVector.add(PVector.mult(k3v, 2), k4v))).mult(h/6));
  _v.add(PVector.add(k1a, PVector.add(PVector.mult(k2a, 2), PVector.add(PVector.mult(k3a, 2), k4a))).mult(h/6));
}

// --- Visualización y HUD ---

void drawAnalyticalTrajectory() {
  noFill();
  stroke(0, 200, 0, 150); 
  strokeWeight(2);
  
  float vt = (M * G) / KDA; 
  float angleRad = radians(THETA);
  
  beginShape();
  for (float t = 0; t < 30; t += 0.05) {
    float x = (V0_MAG * vt * cos(angleRad) / G) * (1 - exp(-G * t / vt));
    float y = (vt / G) * (V0_MAG * sin(angleRad) + vt) * (1 - exp(-G * t / vt)) - (vt * t) + HW; 
    vertex(x, y);
    if (y < 0) break; 
  }
  endShape();
}

void drawCurrentPath() {
  stroke(255, 0, 0, 180);
  strokeWeight(2);
  for (PVector p : _path) point(p.x, p.y);
}

void drawScene() {
  // Agua 
  noStroke();
  fill(0, 100, 255, 120); 
  rect(-50, -MAR_Y_PANTALLA, width + 100, MAR_Y_PANTALLA); 

  // Ejes
  stroke(255, 200, 0);
  strokeWeight(2);
  line(-20, 0, width, 0);      
  line(0, -20, 0, HW + 100);    
  
  // Barco
  fill(0);
  rect(D - 20, -5, 40, 5); 
}

void displayHUD() {
  fill(0);
  textSize(16);
  text("VERDE: Solución Analítica (Referencia)", 20, 30);
  text("PUNTOS ROJOS: Tu simulación (" + _integrator + ")", 20, 50);
  text("Altura (Y): " + nf(_s.y, 1, 2) + " m", 20, 70);
  text("1-5: Integradores, R: Reset", 20, 90);
  if (_hasHit) {
    fill(0, 150, 0); // Verde para el éxito
    textSize(24);
    text("¡OBJETIVO ALCANZADO!", width/2 - 100, height/2);
  } else if (_s.y < 0 && !_hasHit) {
    fill(200, 0, 0);
    text("FALLO: El proyectil está en el agua", 20, 110);
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') restartSimulation();
  
  if (key >= '1' && key <= '5') {
    grabando = true;
    String nombreMetodo = "";
    if (key == '1') { _integrator = IntegratorType.EXPLICIT_EULER; nombreMetodo = "Euler"; }
    if (key == '2') { _integrator = IntegratorType.SIMPLECTIC_EULER; nombreMetodo = "Simplectic"; }
    if (key == '3') { _integrator = IntegratorType.RK2; nombreMetodo = "RK2"; }
    if (key == '4') { _integrator = IntegratorType.RK4; nombreMetodo = "RK4"; }
    if (key == '5') { _integrator = IntegratorType.HEUN; nombreMetodo = "Heun"; }

    output = createWriter("datos_" + nombreMetodo + "_dt" + _dt + ".csv");
    output.println("x,y");
    restartSimulation();
  }
}

void finalizarGrabacion() {
  output.flush();
  output.close();
  output = null;
  grabando = false;
  println("Archivo CSV guardado.");
}
enum IntegratorType { NONE, EXPLICIT_EULER, SIMPLECTIC_EULER, RK2, RK4, HEUN }
