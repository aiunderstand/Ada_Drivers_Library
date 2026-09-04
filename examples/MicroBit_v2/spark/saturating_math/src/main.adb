--  SPARK example: scaling a real sensor reading, with the arithmetic proved.
--
--    src/core/sensor_scaling.ads/.adb   SPARK_Mode => On   proved, no hardware
--    src/main.adb                       SPARK_Mode => Off  hardware, not proved
--
--  Reads pin 1 (0 .. 1023, i.e. 0V .. 3.3V) and maps it to a signed percentage
--  the way you would drive a motor. The mapping divides by (Hi - Lo) and
--  multiplies by 200 -- a division by zero and an overflow waiting to happen,
--  both ruled out by proof rather than by hoping the test covered it.
--
--    build and flash :  python3 tools/mb.py flash --use spark/saturating_math
--    prove           :  python3 tools/mb.py prove --use spark/saturating_math

pragma SPARK_Mode (Off);

with MicroBit.Console;        use MicroBit.Console;
with MicroBit.IOsForTasking;  use MicroBit.IOsForTasking;
with Sensor_Scaling;          use Sensor_Scaling;

procedure Main is
   --  Calibration: the band of the sensor we actually care about. Lo < Hi is
   --  To_Percent's precondition -- swap these two and the proof fails.
   Lo : constant Raw := 100;
   Hi : constant Raw := 900;

   Reading : Analog_Value;
   Speed   : Percent;
begin
   Put_Line ("Reading pin 1 and scaling it to a motor percentage.");

   loop
      Reading := Analog (1);

      --  Analog_Value and Raw are both 0 .. 1023.
      Speed := To_Percent (Integer (Reading), Lo, Hi);

      --  Ignore small wobbles around centre so the motors do not twitch.
      Speed := Dead_Zone (Speed, Width => 5);

      Put_Line ("raw" & Reading'Image & "  ->  speed" & Speed'Image & "%");

      delay 0.2;
   end loop;
end Main;
