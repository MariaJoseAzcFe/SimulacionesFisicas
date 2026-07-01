// Onda radial: parte de un foco y se propaga en todas direcciones
// W(x,y,t) = A · cos( k · (s − vp·t) )
//   s = distancia euclidea al centro (xc, yc)

class RadialWave extends Wave
{
   float _xc, _yc;  // Centro de la onda (m)

   RadialWave(float A, float lambda, float vp, float xc, float yc)
   {
      super(A, lambda, vp);
      _xc = xc;
      _yc = yc;
   }

   float getHeight(float x, float y, float t)
   {
      float s = sqrt((x - _xc)*(x - _xc) + (y - _yc)*(y - _yc));
      return _A * cos(k() * (s - _vp * t));
   }
}
