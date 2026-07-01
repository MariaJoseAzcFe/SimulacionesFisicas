// Class for a particle system controller
class ParticleSystem
{
   PVector _location;
   ArrayList<Particle> _particles;
   int _nextId;

   Grid _grid;
   HashTable _hashTable;
   CollisionDataType _collisionDataType;

   ParticleSystem(PVector location)
   {
      _location = location;
      _particles = new ArrayList<Particle>();
      _nextId = 0;

      _grid = new Grid(SC_GRID);
      _hashTable = new HashTable(SC_HASH, NC_HASH);
      _collisionDataType = CollisionDataType.NONE;
   }

   void addParticle(float mass, PVector initPos, PVector initVel, float radius, color c)
   {
      PVector s = PVector.add(_location, initPos);
      _particles.add(new Particle(this, _nextId, mass, s, initVel, radius, c));
      _nextId++;
   }

   void restart()
   {
      _particles.clear();
      _nextId = 0;
   }

   void setCollisionDataType(CollisionDataType collisionDataType)
   {
      _collisionDataType = collisionDataType;
   }

   int getNumParticles()
   {
      return _particles.size();
   }

   ArrayList<Particle> getParticleArray()
   {
      return _particles;
   }

   void updateCollisionData()
   {
      // Reiniciamos fuerzas en este paso ya que no se usa para colisiones en P1
      for (Particle p : _particles) {
         p._F.set(0, 0, 0);
      }
   }

   void updateGrid()
   {
   }

   void updateHashTable()
   {
   }

   void computePlanesCollisions(ArrayList<PlaneSection> planes)
   {
   }

   void computeParticleCollisions(float timeStep)
   {
      // Reutilizamos esta función para las fuerzas eléctricas
      int n = _particles.size();
      for (int i = 0; i < n - 1; i++)
      {
         Particle pi = _particles.get(i);
         for (int j = i + 1; j < n; j++)
         {
            Particle pj = _particles.get(j);
            PVector diff = PVector.sub(pj._s, pi._s);
            float d = diff.mag();

            if (d < 0.0001) continue;
            
            float fMag = KA * pi._q * pj._q / d;
            PVector unit = diff.copy();
            unit.normalize();

            PVector fOnI = PVector.mult(unit, fMag);
            pi._F.add(fOnI);

            PVector fOnJ = PVector.mult(unit, -fMag);
            pj._F.add(fOnJ);
         }
      }
   }

   void update(float timeStep)
   {
      int n = _particles.size();
      for (int i = n - 1; i >= 0; i--)
      {
         Particle p = _particles.get(i);
         p.update(timeStep);
         
         if (p._lifetime <= 0.0) {
            _particles.remove(i);
         }
      }
   }

   void draw()
   {
      for (Particle p : _particles) {
         p.draw();
      }
   }
}
