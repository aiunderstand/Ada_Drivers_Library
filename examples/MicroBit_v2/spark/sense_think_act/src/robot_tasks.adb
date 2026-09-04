pragma SPARK_Mode (Off);

with Ada.Real_Time;           use Ada.Real_Time;
with HAL;                     use HAL;
with MicroBit.Console;        use MicroBit.Console;
with MicroBit.MotorDriver;    use MicroBit.MotorDriver;
with MicroBit.Types;
with MicroBit.Ultrasonic;
with MicroBit;                use MicroBit;
with Robot_Brain;             use Robot_Brain;

package body Robot_Tasks is

   package Front is new MicroBit.Ultrasonic (Trigger_Pin => MB_P16,
                                             Echo_Pin    => MB_P0);

   Sense_Period : constant Time_Span := Milliseconds (100);
   Act_Period   : constant Time_Span := Milliseconds (100);

   --  SENSE: read the sensor, publish the reading. Nothing else.
   task Sense with Priority => 5;

   task body Sense is
      Next : Time := Clock;
      D    : MicroBit.Types.Distance_cm;
   begin
      loop
         D := Front.Read;
         --  Both are 0 .. 400, so this conversion cannot fail.
         Reading.Update (Robot_Brain.Distance_Cm (D));

         Next := Next + Sense_Period;
         delay until Next;
      end loop;
   end Sense;

   --  ACT: take the latest reading, ask the proved logic what to do, do it.
   task Act with Priority => 4;

   task body Act is
      Next    : Time := Clock;
      D       : Robot_Brain.Distance_Cm;
      What    : Mode;
      Percent : Robot_Brain.Speed;
      Duty    : UInt12;
   begin
      loop
         D    := Reading.Value_Cm;
         What := Decide (D);              --  proved total, and in range
         Percent := Speed_For (What);     --  proved 0 for Stop

         --  Speed_For is proved to return 0 .. 100, so this stays inside UInt12.
         Duty := UInt12 ((Percent * 4095) / 100);

         if What = Stop then
            Drive (MicroBit.MotorDriver.Stop);
         else
            Drive (Forward, (lf => Duty, lb => 0, rf => Duty, rb => 0));
         end if;

         Put_Line (D'Image & " cm -> " & What'Image & " (" & Percent'Image & "%)");

         Next := Next + Act_Period;
         delay until Next;
      end loop;
   end Act;

end Robot_Tasks;
