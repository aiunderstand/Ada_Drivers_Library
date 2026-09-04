pragma SPARK_Mode (On);

package body Sensor_Scaling is

   function To_Percent (R : Raw; Lo, Hi : Raw) return Percent is
      Span    : constant Positive := Hi - Lo;   --  > 0 because Lo < Hi
      Clamped : constant Raw      := (if R < Lo then Lo elsif R > Hi then Hi else R);
      --  Offset is in 0 .. Span, so Offset * 200 is at most 1023 * 200 =
      --  204_600. That comfortably fits Integer, which is what lets GNATprove
      --  discharge the overflow check.
      Offset  : constant Natural  := Clamped - Lo;
   begin
      return ((Offset * 200) / Span) - 100;
   end To_Percent;

   function Saturating_Add (A, B : Percent) return Percent is
      Sum : constant Integer := A + B;   --  in -200 .. 200
   begin
      if Sum >= 100 then
         return 100;
      elsif Sum <= -100 then
         return -100;
      else
         return Sum;
      end if;
   end Saturating_Add;

   function Dead_Zone (P : Percent; Width : Natural) return Percent is
   begin
      if abs P <= Width then
         return 0;
      else
         return P;
      end if;
   end Dead_Zone;

end Sensor_Scaling;
