// Onda direccional: se propaga en una sola dirección
// W(x,y,t) = A · sin( k · ( d⃗·(x,y) + vp·t ) )
//   d⃗ = vector unitario de dirección

class DirectionalWave extends Wave
{
   PVector _dir;  // Dirección normalizada de propagación

   DirectionalWave(float A, float lambda, float vp, float dx, float dy)
   {
      super(A, lambda, vp);
      _dir = new PVector(dx, dy, 0).normalize();
   }

   float getHeight(float x, float y, float t)
   {
      float dot = _dir.x*x + _dir.y*y;
      return _A * sin(k() * (dot + _vp * t));
   }
}
