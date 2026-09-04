pragma SPARK_Mode (On);

package body Line_Control is

   function Deviation_Of (Left_Sees, Right_Sees : Boolean) return Deviation is
   begin
      if Left_Sees = Right_Sees then
         --  Both on the line, or both off it: no information, hold course.
         return 0;
      elsif Left_Sees then
         return -100;
      else
         return 100;
      end if;
   end Deviation_Of;

   function To_Duty (P : Speed) return Duty is
   begin
      --  P is at most 100, so P * 4095 is at most 409_500: well inside Integer.
      return (P * 4095) / 100;
   end To_Duty;

   --  Clamp an unbounded percentage back into Speed.
   function Clamp (V : Integer) return Speed is
     (if V < 0 then 0 elsif V > 100 then 100 else V);

   function Steer (Dev : Deviation; Cruise : Speed; G : Gain) return Command is
      --  G <= 10 and abs Dev <= 100, so the product is within -1000 .. 1000
      --  and the adjustment within -100 .. 100. Both checked by the prover.
      Adjust : constant Integer := (G * Dev) / 10;
      L      : constant Speed   := Clamp (Cruise - Adjust);
      R      : constant Speed   := Clamp (Cruise + Adjust);
      Turn   : constant Turn_Kind :=
        (if Dev = 0 then Straight elsif Dev < 0 then Bear_Left else Bear_Right);
   begin
      return (Turn => Turn, Left => To_Duty (L), Right => To_Duty (R));
   end Steer;

   function Halted return Command is
   begin
      return (Turn => Halt, Left => 0, Right => 0);
   end Halted;

end Line_Control;
