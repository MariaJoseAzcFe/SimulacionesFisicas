// Damped spring between two particles:
//
// Fp1 = Fe - Fd
// Fp2 = -Fe + Fd = -(Fe - Fd) = -Fp1
//
//    Fe = Ke·(l - l0)·eN
//    Fd = -Kd·eN·v
//
//    e = s2 - s1  : current elongation vector between the particles
//    l = |e|      : current length
//    eN = e/l     : current normalized elongation vector
//    v = dl/dt    : rate of change of length

public class DampedSpring
{
  Particle _p1;   // First particle attached to the spring
  Particle _p2;   // Second particle attached to the spring

  float _Ke;   // Elastic constant (N/m) 
  float _Kd;   // Damping coefficient (kg/m)

  float _lr;   // Rest length (m)
  float _l;    // Current length (m)
  float _lMax; // Maximum allowed distance before breaking apart (m)
  float _v;    // Current rate of change of length (m/s)

  PVector _e;   // Current elongation vector (m)
  PVector _eN;  // Current normalized elongation vector (no units)
  PVector _F;   // Force applied by the spring on particle 1 (the force on particle 2 is -_F) (N)
  float _FMax;  // Maximum allowed force before breaking apart (N)

  boolean _broken;   // True when the spring is broken 
  boolean _repulsionOnly;   // True if the spring only works one way (repulsion only)


  DampedSpring(Particle p1, Particle p2, float Ke, float Kd, boolean repulsionOnly, float maxForce, float maxDist)
  {
    _p1 = p1;
    _p2 = p2;

    _Ke = Ke;
    _Kd = Kd;

    _e = PVector.sub(_p2.getPosition(), _p1.getPosition());
    _eN = _e.copy();
    _eN.normalize();

    _l = _e.mag();
    _lr = _l; 

    _FMax = maxForce; //NET_MAX_FORCE
    _lMax = maxDist;  //NET_BREAK_LENGTH_FACTOR

    _v = 0.0;
    _broken = false;
    _repulsionOnly = repulsionOnly;

    _F = new PVector(0.0, 0.0, 0.0);
  }

  Particle getParticle1()
  {
    return _p1;
  }
  
  Particle getParticle2()
  {
    return _p2;
  }
  
  void setRestLength(float restLength)
  {
    _lr = restLength;
  }
  
  
/* Este método debe actualizar todas las variables de la clase 
   que cambien según avanza la simulación (_e, _l, _v, _F, etc.),
   siguiendo las ecuaciones de un muelle con amortiguamiento lineal
   entre dos partículas.
 */
  void update(float simStep)
  {
     _F.set(0,0,0);
     
     float p_l = _l; //longitud actual
     float s;        
     
     _e = PVector.sub(_p2.getPosition(), _p1.getPosition()); //elongación actual
     _l = _e.mag();  //nueva longitud
     
     if (_repulsionOnly)
       s = _l - _ball.getRadius(); // Si el muelle es sólo de repulsión (nodo-bola), la elongación será la longitud actual - radio de la bola
     else
       s = _l - _lr;               // Si el muelle es de repulsión y atracción (nodo-nodo), la elongación será la longitud actual - longitud de reposo
    
     _eN = _e.copy();
     _eN.normalize(); 
     
     _v = (_l - p_l) / simStep; // ( derivada de la elongación / dt) = velocidad
     
     //Fuerza damping o de amortiguación
     PVector aux_l = PVector.mult(_eN.copy(), _v); //obtenemos la dirección de v con la de la elongación
     PVector Fd = PVector.mult(aux_l, _Kd); //cálculo similar a la fuerza de rozamiento = k*v
     
     //Fuerza elástica
     PVector F = PVector.mult(_eN, _Ke * s);    //Fe = ke*s --> en la dirección de la elongación
     
     //Suma de fuerzas 
     F.add(Fd);
    
     
     if(!_broken)
     {
       //Si la fuerza supera un umbral o la longitud es máxima, el muelle se romperá 
       //si la malla no es irrompible y los muelles son los correspondientes a la unión de los nodos
       
       if((_F.mag() > _FMax && _FMax > 0 || _l > _lMax && _lMax > 0) && !_repulsionOnly && !NET_IS_UNBREAKABLE)
       {
         _F.set(0,0,0);
         breakIt();
       }
       else
         _F = F.copy(); //En caso de no romperse, los muelles seguirán ejerciendo la fuerza contra la bola y contra su rotura
     }     
  }

  void applyForces()
  { 
    _p1.addExternalForce(_F);
    _p2.addExternalForce(PVector.mult(_F, -1.0));
  }

  boolean isBroken()
  {
    return _broken;
  }

  void breakIt()
  {
    _broken = true;
  }

  void fixIt()
  {
    _broken = false;
  }
}
