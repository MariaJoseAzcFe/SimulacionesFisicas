// Class for a plane section in 2D
class PlaneSection
{
   boolean _inverted;
   PVector _pos1;
   PVector _pos2;
   PVector _normal;
   float[] _coefs = new float[4];


   PlaneSection(float x1, float y1, float x2, float y2, boolean invert)
   {
      _pos1 = new PVector(x1, y1);
      _pos2 = new PVector(x2, y2);

      setCoefficients();
      _inverted = invert;
      calculateNormal();
   }

   PVector getPoint1()
   {
      return _pos1;
   }

   PVector getPoint2()
   {
      return _pos2;
   }

   void setCoefficients()
   {
      PVector v = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 0.0);
      PVector z = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 1.0);

      _coefs[0] = v.y*z.z - z.y*v.z;
      _coefs[1] = -(v.x*z.z - z.x*v.z);
      _coefs[2] = v.x*z.y - z.x*v.y;
      _coefs[3] = -_coefs[0]*_pos1.x - _coefs[1]*_pos1.y - _coefs[2]*_pos1.z;
   }

   void calculateNormal()
   {
      _normal = new PVector(_coefs[0], _coefs[1], _coefs[2]);
      _normal.normalize();

      if (_inverted)
         _normal.mult(-1);
   }

   float getDistance(PVector p)
   {
      float d = (_coefs[0]*p.x + _coefs[1]*p.y + _coefs[2]*p.z + _coefs[3]) / (sqrt(_coefs[0]*_coefs[0] + _coefs[1]*_coefs[1] + _coefs[2]*_coefs[2]));
      return abs(d);
   }

   boolean checkSide(PVector p)
   {
      float d = (_coefs[0]*p.x + _coefs[1]*p.y + _coefs[2]*p.z + _coefs[3]) / (sqrt(_coefs[0]*_coefs[0] + _coefs[1]*_coefs[1] + _coefs[2]*_coefs[2]));

      if (_inverted)
         return (d < 0.0);
      else
         return (d > 0.0);
   }

   boolean checkLimits(PVector p)
   {
      PVector s1 = PVector.sub(_pos1, p);
      float l1 = s1.magSq();
      
      PVector s2 = PVector.sub(_pos2, p);
      float l2 = s2.magSq();

      PVector s3 = PVector.sub(_pos2, _pos1);
      float l3 = s3.magSq();

      if (l1 + l2 <= l3)
         return true;
      else
         return false;
   }

   PVector getNormal()
   {
      return _normal;
   }

   void draw()
   {
      stroke(0, 0, 0);
      strokeWeight(5);
      line(_pos1.x, _pos1.y, _pos2.x, _pos2.y);

      float cx = _pos1.x*0.5 + _pos2.x*0.5;
      float cy = _pos1.y*0.5 + _pos2.y*0.5;

      line(cx, cy, cx + 5.0*_normal.x, cy + 5.0*_normal.y);
   }
}
