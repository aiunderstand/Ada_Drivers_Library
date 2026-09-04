--  SPARK example: a line-following robot whose steering logic is proved.
--
--    src/core/line_control.ads/.adb   SPARK_Mode => On   proved, no hardware
--    src/main.adb                     SPARK_Mode => Off  hardware, not proved
--
--  Mirrors ravenscar/tasking_project_linetracker, but the decision-making is
--  separated from the I/O so it can be proved. The core guarantees the duty
--  cycles it returns are always inside the motor driver's 12-bit range, so this
--  shell cannot hand the hardware a value it would reject.
--
--    build and flash :  python3 tools/mb.py flash --use spark/line_follower
--    prove           :  python3 tools/mb.py prove --use spark/line_follower

pragma SPARK_Mode (Off);

with HAL;                     use HAL;
with MicroBit.Console;        use MicroBit.Console;
with MicroBit.IOsForTasking;  use MicroBit.IOsForTasking;
with MicroBit.MotorDriver;    use MicroBit.MotorDriver;
with Line_Control;            use Line_Control;

procedure Main is
   --  Two reflectance sensors straddling the line.
   Left_Sensor  : constant Pin_Id := 1;
   Right_Sensor : constant Pin_Id := 2;

   Cruise : constant Speed := 60;   --  percent
   G      : constant Gain  := 6;

   Dev : Deviation;
   Cmd : Command;

   --  The core deals in plain Integers; the driver wants UInt12. The core has
   --  already proved the values are in 0 .. 4095, so this conversion is safe.
   function Duty12 (D : Duty) return UInt12 is (UInt12 (D));
begin
   Put_Line ("SPARK line follower. Sensors on pins 1 and 2.");

   loop
      Dev := Deviation_Of (Left_Sees  => Set (Left_Sensor),
                           Right_Sees => Set (Right_Sensor));

      --  Both sensors off the line means the line is lost: stop rather than
      --  guess. Deviation_Of cannot distinguish that case, so it is decided
      --  here, in the shell, where the sensors are.
      if not Set (Left_Sensor) and not Set (Right_Sensor) then
         Cmd := Halted;
      else
         Cmd := Steer (Dev, Cruise, G);
      end if;

      case Cmd.Turn is
         when Halt =>
            Drive (Stop);
         when Straight | Bear_Left | Bear_Right =>
            --  Differential drive: left wheels forward at Cmd.Left, right at
            --  Cmd.Right. Backward duties stay at zero.
            Drive (Forward,
                   (lf => Duty12 (Cmd.Left),  lb => 0,
                    rf => Duty12 (Cmd.Right), rb => 0));
      end case;

      Put_Line ("dev" & Dev'Image & "  " & Cmd.Turn'Image
                & "  L" & Cmd.Left'Image & "  R" & Cmd.Right'Image);

      delay 0.05;
   end loop;
end Main;
