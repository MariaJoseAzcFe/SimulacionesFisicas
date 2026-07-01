// Clase base abstracta para todos los tipos de onda
// El mapa de alturas usa el plano XY con Z como altura

abstract class Wave
{
   float _A;       // Amplitud (m)
   float _lambda;  // Longitud de onda (m)
   float _vp;      // Velocidad de propagación (m/s)

   Wave(float A, float lambda, float vp)
   {
      _A      = A;
      _lambda = lambda;
      _vp     = vp;
   }

   // Número de onda k = 2π/λ
   float k() { return TWO_PI / _lambda; }

   // Frecuencia angular ω = k·vp
   float omega() { return k() * _vp; }

   // Período T = 2π/ω
   float period() { return TWO_PI / omega(); }

   // Altura (desplazamiento en Z) en el punto (x,y) en el instante t
   abstract float getHeight(float x, float y, float t);

   // Desplazamiento vectorial completo (dx, dy, dz).
   // Para onda radial y direccional sólo hay componente Z.
   // La onda Gerstner sobreescribe este método para añadir XY.
   PVector getDisplacement(float x, float y, float t)
   {
      return new PVector(0, 0, getHeight(x, y, t));
   }
}
