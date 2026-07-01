// Onda Gerstner: modifica también las coordenadas XY para crear
// crestas puntiagudas (más realistas que una onda sinusoidal pura).
//
// W(x,y,t) = [ QA·dx·cos(fase),  QA·dy·cos(fase),  A·sin(fase) ]
//   fase = k·( d⃗·(x,y) + vp·t )
//   Q    = factor de inclinación de cresta  (0 = suave, ≤1 = puntiaguda)

class GerstnerWave extends Wave
{
   PVector _dir;  // Dirección normalizada
   float   _Q;    // Steepness

   GerstnerWave(float A, float lambda, float vp, float Q, float dx, float dy)
   {
      super(A, lambda, vp);
      _Q   = Q;
      _dir = new PVector(dx, dy, 0).normalize();
   }

   // La Gerstner desplaza XY además de Z
   PVector getDisplacement(float x, float y, float t)
   {
      float fase = k() * (_dir.x*x + _dir.y*y + _vp*t);
      return new PVector(
         _Q * _A * _dir.x * cos(fase),   // dx
         _Q * _A * _dir.y * cos(fase),   // dy
         _A * sin(fase)                  // dz
      );
   }

   float getHeight(float x, float y, float t)
   {
      return getDisplacement(x, y, t).z;
   }
}
