class ParticleList
{
   ArrayList<Particle> _vector;
   ParticleList()
   {
      _vector = new ArrayList<Particle>();
   }
}

class Grid
{
   float _cellSize;
   int _nRows;
   int _nCols;
   int _numCells;

   ParticleList [][] _cells;
   color [][] _colors;

   Grid(float cellSize)
   {
      _cellSize = cellSize;
      _nRows = int(height/_cellSize);
      _nCols = int(width/_cellSize);
      _numCells = _nRows*_nCols;

      _cells  = new ParticleList[_nRows][_nCols];
      _colors = new color[_nRows][_nCols];

      for (int i = 0; i < _nRows; i++)
      {
         for (int j = 0; j < _nCols; j++)
         {
            _cells[i][j] = new ParticleList();
            _colors[i][j] = color(int(random(0, 256)), int(random(0, 256)), int(random(0, 256)), 150);
         }
      }
   }

   //
   //
   //
}
