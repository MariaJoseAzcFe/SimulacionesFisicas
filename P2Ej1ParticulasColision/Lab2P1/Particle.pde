// Class for a simple particle with no rotational motion
public class Particle
{
   ParticleSystem _ps;  // Reference to the parent ParticleSystem
   int _id;             // Id. of the particle

   float _m;            // Mass of the particle (kg)
   PVector _s;          // Position of the particle (m)
   PVector _v;          // Velocity of the particle (m/s)
   PVector _a;          // Acceleration of the particle (m/(s·s))
   PVector _F;          // Force applied on the particle (N)

   float _radius;       // Radius of the particle (m)
   color _color;        // Color of the particle (RGBA)
   float _q;
   float _lifetime;
      
   Particle(ParticleSystem ps, int id, float m, PVector s, PVector v, float radius, color c)
   {
      _ps = ps;
      _id = id;
      _m = m;
      _s = s.copy();
      _v = v.copy();
      _a = new PVector(0, 0);
      _F = new PVector(0, 0);
      _radius = radius;
      
      _q = random(Q_MIN, Q_MAX);
      _lifetime = TL;
      
      colorMode(HSB, 360, 100, 100, 255);
      float hue = map(_q, Q_MIN, Q_MAX, 200, 0);
      _color = color(hue, 80, 90, 220);
      colorMode(RGB, 255);
   }

   void setPos(PVector s)
   {
      _s = s;
   }

   void setVel(PVector v)
   {
      _v = v;
   }

   PVector getForce()
   {
      return _F;
   }

   float getRadius()
   {
      return _radius;
   }

   float getColor()
   {
      return _color;
   }

   void update(float timeStep)
   {
      updateForce();
      
      _a = PVector.div(_F, _m);
      _v.add(PVector.mult(_a, timeStep));
      _s.add(PVector.mult(_v, timeStep));
      
      _lifetime -= timeStep;
   }

   void updateForce()
   {
      float theta = radians(THETA_WIND);
      PVector vWind = new PVector(V_WIND * cos(theta), V_WIND * sin(theta));
      PVector vRel = PVector.sub(_v, vWind);

      float vRelMag = vRel.mag();
      if (vRelMag > 0.0)
      {
         PVector fDrag = vRel.copy();
         fDrag.normalize();
         fDrag.mult(-KD * vRelMag * vRelMag);
         _F.add(fDrag);
      }
   }

   void planeCollision(ArrayList<PlaneSection> planes)
   {
      //
      //
      //
   }

   void particleCollision(float timeStep)
   {
      //
      //
      //
   }

   void updateNeighborsGrid(Grid grid)
   {
      //
      //
      //
   }

   void updateNeighborsHash(HashTable hashTable)
   {
      //
      //
      //
   }

   void draw()
  {
      float px = _s.x * PIXELS_PER_METER;
      float py = _s.y * PIXELS_PER_METER;
      float pr = _radius * PIXELS_PER_METER;
      
      float sw = map(_m, M_MIN, M_MAX, 1.0, 4.0);
      strokeWeight(sw);
      stroke(30, 30, 30, 180);

      float alpha = map(_lifetime, 0, TL, 40, 220);
      alpha = constrain(alpha, 40, 220);

      colorMode(HSB, 360, 100, 100, 255);
      float hue = map(_q, Q_MIN, Q_MAX, 200, 0);
      fill(hue, 80, 90, alpha);
      colorMode(RGB, 255);

      ellipse(px, py, 2*pr, 2*pr);
   }
}
