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
      _location       = location;
      _particles      = new ArrayList<Particle>();
      _nextId         = 0;
      _grid           = new Grid(SC_GRID);
      _hashTable      = new HashTable(SC_HASH, NC_HASH);
      _collisionDataType = CollisionDataType.NONE;
   }

   void addParticle(float mass, PVector initPos, PVector initVel, float radius, color c)
   {
      _particles.add(new Particle(this, _nextId, mass, initPos, initVel, radius, c));
      _nextId++;
   }

   void restart()          { _particles.clear(); _nextId = 0; }
   void setCollisionDataType(CollisionDataType t) { _collisionDataType = t; }
   int  getNumParticles()  { return _particles.size(); }
   ArrayList<Particle> getParticleArray() { return _particles; }

   void updateCollisionData()
   {
      switch (_collisionDataType)
      {
         case GRID: updateGrid();      break;
         case HASH: updateHashTable(); break;
         default:   
                    break;
      }
   }

   void updateGrid()
{
   // Paso 1: limpiar e insertar TODAS las partículas
   for (int r = 0; r < _grid._nRows; r++)
      for (int c = 0; c < _grid._nCols; c++)
         _grid._cells[r][c]._vector.clear();

   for (Particle p : _particles)
      p.insertIntoGrid(_grid);


   for (Particle p : _particles)
      p.gatherNeighborsGrid(_grid);
}

void updateHashTable()
{

   for (ArrayList<Particle> bucket : _hashTable._table)
      bucket.clear();

   for (Particle p : _particles)
      p.insertIntoHash(_hashTable);


   for (Particle p : _particles)
      p.gatherNeighborsHash(_hashTable);
}

   void computePlanesCollisions(ArrayList<PlaneSection> planes)
   {
      for (Particle p : _particles)
         p.planeCollision(planes);
   }

   void computeParticleCollisions(float timeStep)
{
   if (_collisionDataType == CollisionDataType.NONE)
   {
      for (Particle p : _particles) p._neighbors.clear();
      int n = _particles.size();
      for (int i = 0; i < n; i++)
         for (int j = i + 1; j < n; j++)
         {
            _particles.get(i)._neighbors.add(_particles.get(j));
            _particles.get(j)._neighbors.add(_particles.get(i));
         }
   }
   for (Particle p : _particles)
      p.particleCollision(timeStep);
}

   void update(float timeStep)
   {
      int n = _particles.size();
      for (int i = n - 1; i >= 0; i--)
         _particles.get(i).update(timeStep);
   }

   void draw()
   {
      for (Particle p : _particles)
         p.draw();
   }
}
