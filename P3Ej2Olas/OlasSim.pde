import peasy.*;

PeasyCam _camera;

final int   GRID = 60;
final float EXT  = 20.0;
final float STEP = (2*EXT) / GRID;

PVector[][] _pos0;
PVector[][] _posD;

ArrayList<Wave> _waves;
int _mode = 4;

Barco _barco;

float _t    = 0.0;
int   _last = 0;

boolean _wire = false;

// ─────────────────────────────────────────────────────────────

void settings() { size(1000, 1000, P3D); }

void setup()
{
   frameRate(60);

   // perspective() ANTES de crear PeasyCam — imprescindible
   perspective(PI/3.0, float(width)/float(height), 0.1, 5000.0);

   _camera = new PeasyCam(this, 0);
   _camera.setDistance(60);
   _camera.rotateX(1.05);   // ~60° de inclinación para ver el océano

   // Rejilla base
   _pos0 = new PVector[GRID+1][GRID+1];
   _posD = new PVector[GRID+1][GRID+1];
   for (int i = 0; i <= GRID; i++)
      for (int j = 0; j <= GRID; j++)
      {
         float x = -EXT + i*STEP;
         float y = -EXT + j*STEP;
         _pos0[i][j] = new PVector(x, y, 0);
         _posD[i][j] = new PVector(x, y, 0);
      }

   setMode(_mode);
   _barco = new Barco(5, 3, 0.4, 0.9);
   _last  = millis();
}

// =============================================================
// MODOS DE ONDA
// =============================================================

void setMode(int mode)
{
   _mode  = mode;
   _waves = new ArrayList<Wave>();

   switch (mode)
   {
      case 1:
         _waves.add(new RadialWave(0.7, 10.0, 3.5, 0, 0));
         break;
      case 2:
         _waves.add(new DirectionalWave(0.8, 14.0, 5.0, 1.0, 0.3));
         break;
      case 3:
         _waves.add(new GerstnerWave(1.0, 16.0, 5.5, 0.75, 1.0, 0.0));
         break;
      default:
         _waves.add(new GerstnerWave(0.80, 20.0, 6.0, 0.70,  1.0,  0.0));
         _waves.add(new GerstnerWave(0.50, 12.0, 4.5, 0.65,  0.7,  0.7));
         _waves.add(new GerstnerWave(0.20,  5.0, 2.5, 0.50,  0.9, -0.4));
         _waves.add(new DirectionalWave(0.15, 8.0, 3.0, -0.5, 1.0));
         break;
   }
}

// =============================================================
// DRAW
// =============================================================

void draw()
{
   int  now = millis();
   float dt = (now - _last) / 1000.0;
   _last    = now;
   _t      += dt;

   background(5, 15, 45);

   ambientLight(50, 70, 120);
   directionalLight(200, 220, 255,  0.5,  0.6, -1.0);
   directionalLight(100, 130, 180, -0.5, -0.3, -0.5);

   updateHeightMap();
   _barco.update(_t, dt);

   drawOcean();
   _barco.render();

   drawHUD();
}

// =============================================================
// MAPA DE ALTURAS
// =============================================================

void updateHeightMap()
{
   for (int i = 0; i <= GRID; i++)
      for (int j = 0; j <= GRID; j++)
      {
         float x0 = _pos0[i][j].x;
         float y0 = _pos0[i][j].y;
         float dx = 0, dy = 0, dz = 0;
         for (Wave w : _waves)
         {
            PVector d = w.getDisplacement(x0, y0, _t);
            dx += d.x; dy += d.y; dz += d.z;
         }
         _posD[i][j].set(x0+dx, y0+dy, dz);
      }
}

float totalHeight(float x, float y)
{
   float h = 0;
   for (Wave w : _waves) h += w.getHeight(x, y, _t);
   return h;
}

PVector surfaceNormal(float x, float y)
{
   float e  = 0.2;
   float h0 = totalHeight(x, y);
   PVector tx = new PVector(e, 0, totalHeight(x+e, y) - h0);
   PVector ty = new PVector(0, e, totalHeight(x, y+e) - h0);
   return tx.cross(ty).normalize();
}

// =============================================================
// RENDERIZADO DEL OCÉANO
// =============================================================

void drawOcean()
{
   float maxA = 0;
   for (Wave w : _waves) maxA += w._A;
   if (maxA < 0.01) maxA = 0.01;

   for (int i = 0; i < GRID; i++)
      for (int j = 0; j < GRID; j++)
      {
         PVector p00 = _posD[i][j];
         PVector p10 = _posD[i+1][j];
         PVector p11 = _posD[i+1][j+1];
         PVector p01 = _posD[i][j+1];
         float avgZ  = (p00.z + p10.z + p11.z + p01.z) * 0.25;

         if (_wire) { stroke(60,150,230); strokeWeight(0.4); noFill(); }
         else       { noStroke(); fill(oceanColor(avgZ, maxA)); }

         beginShape(QUADS);
         vertex(p00.x, p00.y, p00.z);
         vertex(p10.x, p10.y, p10.z);
         vertex(p11.x, p11.y, p11.z);
         vertex(p01.x, p01.y, p01.z);
         endShape();
      }
}

color oceanColor(float z, float maxA)
{
   float t = constrain((z/maxA + 1.0) * 0.5, 0, 1);
   color c0 = color(0,   20,  90);
   color c1 = color(10,  80, 170);
   color c2 = color(50, 150, 230);
   color c3 = color(210, 235, 255);

   if      (t < 0.35) return lerpColor(c0, c1, t/0.35);
   else if (t < 0.65) return lerpColor(c1, c2, (t-0.35)/0.30);
   else               return lerpColor(c2, c3, (t-0.65)/0.35);
}

// =============================================================
// TECLADO
// =============================================================

void keyPressed()
{
   if (key == '1') setMode(1);
   if (key == '2') setMode(2);
   if (key == '3') setMode(3);
   if (key == '4') setMode(4);
   if (key == 'd' || key == 'D') _wire = !_wire;
   if (key == 'r' || key == 'R') setMode(_mode);

   for (Wave w : _waves)
   {
      if (key == '+' || key == '=') w._A      = max(0.05, w._A      * 1.10);
      if (key == '-')               w._A      = max(0.05, w._A      * 0.90);
      if (keyCode == UP)            w._vp     = max(0.10, w._vp     * 1.10);
      if (keyCode == DOWN)          w._vp     = max(0.10, w._vp     * 0.90);
      if (keyCode == RIGHT)         w._lambda = max(0.50, w._lambda * 1.10);
      if (keyCode == LEFT)          w._lambda = max(0.50, w._lambda * 0.90);
   }
}

// =============================================================
// HUD  — usa beginHUD/endHUD de PeasyCam para el overlay 2D
// =============================================================

void drawHUD()
{
   _camera.beginHUD();   // <-- modo 2D sin afectar la cámara 3D

   fill(255); textSize(14);
   String[] nombres = {"","Onda Radial","Onda Direccional","Onda Gerstner","Océano (combinación)"};
   float lx = 18, ly = 28, ls = 22;

   text("Modo: "  + nombres[_mode],               lx, ly); ly += ls;
   text("Ondas: " + _waves.size(),                lx, ly); ly += ls;
   text("t = "    + nf(_t, 0, 1) + " s",          lx, ly); ly += ls;

   if (!_waves.isEmpty())
   {
      Wave w = _waves.get(0);
      text("A  = " + nf(w._A, 0, 2)       + " m",   lx, ly); ly += ls;
      text("λ  = " + nf(w._lambda, 0, 1)  + " m",   lx, ly); ly += ls;
      text("vp = " + nf(w._vp, 0, 1)      + " m/s", lx, ly); ly += ls;
      text("T  = " + nf(w.period(), 0, 2) + " s",   lx, ly); ly += ls;
      text("k  = " + nf(w.k(), 0, 3)      + " rad/m", lx, ly); ly += ls;
   }

   textSize(11);
   fill(180, 220, 255);
   text("[1] Radial  [2] Direccional  [3] Gerstner  [4] Océano  " +
        "[+/-] A  [↑↓] vp  [←→] λ  [d] wireframe  [r] reiniciar",
        lx, height - 18);

   _camera.endHUD();     // <-- volver al modo 3D
}

// =============================================================
// CLASE BARCO
// =============================================================

class Barco
{
   float _x, _y;
   float _heading;
   float _speed;

   Barco(float x, float y, float heading, float speed)
   {
      _x = x; _y = y; _heading = heading; _speed = speed;
   }

   void update(float t, float dt)
   {
      _x += cos(_heading) * _speed * dt;
      _y += sin(_heading) * _speed * dt;
      if (_x >  EXT*0.85) { _heading = PI  - _heading; _x =  EXT*0.85; }
      if (_x < -EXT*0.85) { _heading = PI  - _heading; _x = -EXT*0.85; }
      if (_y >  EXT*0.85) { _heading = -_heading;      _y =  EXT*0.85; }
      if (_y < -EXT*0.85) { _heading = -_heading;      _y = -EXT*0.85; }
   }

   void render()
   {
      float   z = totalHeight(_x, _y);
      PVector n = surfaceNormal(_x, _y);

      float cosH  = cos(_heading), sinH = sin(_heading);
      float pitch = atan2(-(n.x*cosH + n.y*sinH), n.z);
      float roll  = atan2( -n.x*sinH + n.y*cosH,  n.z);

      pushMatrix();
      translate(_x, _y, z);
      rotateZ(_heading);
      rotateY(pitch);
      rotateX(roll);

      fill(140, 60, 25); stroke(80, 35, 10); strokeWeight(0.5);
      box(4.2, 1.6, 0.55);

      translate(0, 0, 0.42);
      fill(190, 155, 100);
      box(3.8, 1.1, 0.14);

      translate(-0.4, 0, 0.42);
      fill(215, 195, 150);
      box(1.5, 0.85, 0.60);

      translate(1.2, 0, 0.70);
      fill(110, 70, 30); noStroke();
      box(0.09, 0.09, 1.80);

      translate(0, 0, 0.5);
      fill(240, 238, 225, 210);
      beginShape(TRIANGLES);
      vertex(0,  0,     0);
      vertex(0,  0.85, -0.9);
      vertex(0,  0,    -1.2);
      endShape();

      translate(0, 0, 0.7);
      fill(200, 30, 30); noStroke();
      beginShape(TRIANGLES);
      vertex(0,  0,     0);
      vertex(0,  0.35, -0.15);
      vertex(0,  0,    -0.30);
      endShape();

      popMatrix();
   }
}
