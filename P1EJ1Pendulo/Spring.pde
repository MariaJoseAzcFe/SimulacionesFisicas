public class Spring
{
   PVector _pos1;
   PVector _pos2;

   float _Ke;
   float _l0;

   float _energy;

   PVector _F;

   Spring(PVector pos1,PVector pos2,float Ke,float l0)
   {
      _pos1=pos1;
      _pos2=pos2;
      _Ke=Ke;
      _l0=l0;

      _energy=0;
      _F=new PVector();
   }

   void setPos1(PVector pos1)
   {
      _pos1=pos1;
   }

   void setPos2(PVector pos2)
   {
      _pos2=pos2;
   }

   void setKe(float Ke)
   {
      _Ke=Ke;
   }

   void setRestLength(float l0)
   {
      _l0=l0;
   }

   void update()
   {
      PVector dir = PVector.sub(_pos1,_pos2);

      float length = dir.mag();

      dir.normalize();

      float elongation = length - _l0;

      _F = PVector.mult(dir,_Ke*elongation);

      updateEnergy();
   }

   void updateEnergy()
   {
      float length=PVector.sub(_pos2,_pos1).mag();

      float elongation=length-_l0;

      _energy=0.5*_Ke*elongation*elongation;
   }

   float getEnergy()
   {
      return _energy;
   }

   PVector getForce()
   {
      return _F;
   }
}
