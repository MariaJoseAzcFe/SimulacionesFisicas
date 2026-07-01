class HashTable
{
   ArrayList<ArrayList<Particle>> _table;

   int _numCells;
   float _cellSize;
   color[] _colors;

   HashTable(float cellSize, int numCells)
   {
      _table = new ArrayList<ArrayList<Particle>>();
      _cellSize = cellSize;
      _numCells = numCells;

      _colors = new color[_numCells];

      for (int i = 0; i < _numCells; i++)
      {
         ArrayList<Particle> cell = new ArrayList<Particle>();
         _table.add(cell);
         _colors[i] = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)), 150);
      }
   }

}
