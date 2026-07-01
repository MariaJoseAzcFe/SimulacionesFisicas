public class Particle
{
   ParticleSystem _ps;
   int   _id;
   float _m;
   PVector _s;   
   PVector _v;   
   PVector _a;  
   PVector _F;   
   float _radius;
   color _color;

   ArrayList<Particle> _neighbors;

   Particle(ParticleSystem ps, int id, float m, PVector s, PVector v, float radius, color c)
   {
      _ps      = ps;
      _id      = id;
      _m       = m;
      _s       = s.copy();
      _v       = v.copy();
      _a       = new PVector(0, 0);
      _F       = new PVector(0, 0);
      _radius  = radius;
      _color   = c;
      _neighbors = new ArrayList<Particle>();
   }

   void setPos(PVector s) { _s = s; }
   void setVel(PVector v) { _v = v; }
   PVector getForce()  { return _F; }
   float   getRadius() { return _radius; }
   float   getColor()  { return _color; }  

void update(float timeStep)
{

   updateForce();  
   _v.add(PVector.mult(_F, timeStep / _m));
   _s.add(PVector.mult(_v, timeStep));
   _F.set(0, 0);  // reset al final
}

void updateForce()
{
   _F.add(new PVector(0, _m * G));
   float speed = _v.mag();
   if (speed > 0)
      _F.add(PVector.mult(_v, -KD * speed));
}

void planeCollision(ArrayList<PlaneSection> planes)
{
   for (PlaneSection plane : planes)
   {
      PVector sPx = new PVector(_s.x * M_TO_PX, _s.y * M_TO_PX);
      float radiusPx = _radius * M_TO_PX;
      PVector n = plane.getNormal();


      float d = (plane._coefs[0]*sPx.x + plane._coefs[1]*sPx.y + 
                 plane._coefs[2]*sPx.z + plane._coefs[3]) /
                sqrt(plane._coefs[0]*plane._coefs[0] + 
                     plane._coefs[1]*plane._coefs[1] + 
                     plane._coefs[2]*plane._coefs[2]);

      if (plane._inverted) d = -d;


      if (d < radiusPx)
      {
         
         float vn = PVector.dot(_v, n);
         if (vn < 0)
            _v.sub(PVector.mult(n, (1.0 + CR) * vn));


         float penetration = radiusPx - d;
         _s.add(PVector.mult(n, (penetration + 1.0) / M_TO_PX));
      }
   }
}

   void particleCollision(float timeStep)
{
   for (Particle other : _neighbors)
   {
      if (other._id <= _id) continue;

      PVector delta = PVector.sub(_s, other._s);
      float dist = delta.mag();
      float minDist = _radius + other._radius;

      if (dist < minDist && dist > 0.001)
      {
         PVector dir = PVector.div(delta, dist);
         float overlap = minDist - dist;


         _s.add(PVector.mult(dir, overlap * 0.5));
         other._s.sub(PVector.mult(dir, overlap * 0.5));

         PVector relVel = PVector.sub(_v, other._v);
         float vNormal = PVector.dot(relVel, dir);

         PVector cancel = PVector.mult(dir, vNormal * 0.5);
         _v.sub(cancel);
         other._v.add(cancel);

         _v.mult(0.85);
         other._v.mult(0.85);
      }
   }
}

   void updateNeighborsGrid(Grid grid)
{
   insertIntoGrid(grid);
   gatherNeighborsGrid(grid);
}

void insertIntoGrid(Grid grid)
{
   int col = constrain(int(_s.x / grid._cellSize), 0, grid._nCols - 1);
   int row = constrain(int(_s.y / grid._cellSize), 0, grid._nRows - 1);
   grid._cells[row][col]._vector.add(this);
   _color = grid._colors[row][col];
}

void gatherNeighborsGrid(Grid grid)
{
   _neighbors.clear();
   int col = constrain(int(_s.x / grid._cellSize), 0, grid._nCols - 1);
   int row = constrain(int(_s.y / grid._cellSize), 0, grid._nRows - 1);

   for (int dr = -1; dr <= 1; dr++)
   {
      for (int dc = -1; dc <= 1; dc++)
      {
         int nr = row + dr;
         int nc = col + dc;
         if (nr < 0 || nr >= grid._nRows || nc < 0 || nc >= grid._nCols) continue;
         for (Particle p : grid._cells[nr][nc]._vector)
            if (p._id != _id) _neighbors.add(p);
      }
   }
}

void updateNeighborsHash(HashTable ht)
{
   insertIntoHash(ht);
   gatherNeighborsHash(ht);
}

void insertIntoHash(HashTable ht)
{
   int idx = ht.hashFunction(_s);
   ht._table.get(idx).add(this);
   _color = ht._colors[idx];
}

void gatherNeighborsHash(HashTable ht)
{
   _neighbors.clear();
   int cx = int(_s.x / ht._cellSize);
   int cy = int(_s.y / ht._cellSize);

   for (int dr = -1; dr <= 1; dr++)
   {
      for (int dc = -1; dc <= 1; dc++)
      {
         int idx = ht.hashCoords(cx + dc, cy + dr);
         for (Particle p : ht._table.get(idx))
            if (p._id != _id) _neighbors.add(p);
      }
   }
}

   void draw()
   {

      float px = _s.x * M_TO_PX;
      float py = _s.y * M_TO_PX;
      float pr = _radius * M_TO_PX;
      stroke(red(_color)*0.6, green(_color)*0.6, blue(_color)*0.6, 200);
      strokeWeight(1);
      fill(_color);
      ellipse(px, py, pr * 2, pr * 2);
   }
}
