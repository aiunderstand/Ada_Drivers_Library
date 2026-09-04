--  Scaling a raw sensor reading to a percentage, proved free of run-time errors.
--
--  Two classic embedded bugs are ruled out here by proof rather than by testing:
--  division by zero, and integer overflow in the intermediate multiplication.
--
--  Prove it with:  python3 tools/mb.py prove --use spark/saturating_math

pragma SPARK_Mode (On);

package Sensor_Scaling is

   --  The micro:bit's ADC is 10-bit: MicroBit.IOsForTasking.Analog_Value.
   subtype Raw is Integer range 0 .. 1023;

   --  A signed percentage, e.g. a motor speed: full reverse to full forward.
   subtype Percent is Integer range -100 .. 100;

   --  Map a reading in [Lo, Hi] onto [-100, 100], clamping outside that band.
   --
   --  The precondition is what makes this provable. Without Lo < Hi the
   --  division below could be by zero, and GNATprove says so.
   function To_Percent (R : Raw; Lo, Hi : Raw) return Percent
     with
       Pre  => Lo < Hi,
       Post => (if R <= Lo then To_Percent'Result = -100
                elsif R >= Hi then To_Percent'Result = 100);

   --  Add two percentages, saturating instead of wrapping or overflowing.
   function Saturating_Add (A, B : Percent) return Percent
     with
       Post => (if A + B >= 100 then Saturating_Add'Result = 100
                elsif A + B <= -100 then Saturating_Add'Result = -100
                else Saturating_Add'Result = A + B);

   --  A symmetric dead zone around zero, so a noisy sensor does not twitch
   --  the motors.
   function Dead_Zone (P : Percent; Width : Natural) return Percent
     with
       Pre  => Width <= 100,
       Post => (if abs P <= Width then Dead_Zone'Result = 0
                else Dead_Zone'Result = P);

end Sensor_Scaling;
