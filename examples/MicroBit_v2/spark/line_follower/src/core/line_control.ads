--  The steering logic of a line-following robot, proved free of run-time errors.
--
--  This package knows nothing about the micro:bit. It turns two boolean sensor
--  readings into a pair of motor duty cycles, and proves that those duty cycles
--  are always inside the 12-bit range the motor driver accepts -- so the shell
--  in main.adb cannot be handed a value the hardware would reject.
--
--  Prove it with:  python3 tools/mb.py prove --use spark/line_follower

pragma SPARK_Mode (On);

package Line_Control is

   subtype Deviation is Integer range -100 .. 100;   --  - is left of line
   subtype Speed     is Integer range    0 .. 100;   --  percent
   subtype Duty      is Integer range    0 .. 4095;  --  the driver's UInt12
   subtype Gain      is Integer range    0 ..   10;

   type Turn_Kind is (Straight, Bear_Left, Bear_Right, Halt);

   type Command is record
      Turn  : Turn_Kind;
      Left  : Duty;
      Right : Duty;
   end record;

   --  Two sensors straddling the line. Seeing the line on the left means the
   --  robot has drifted right, so the error is negative.
   function Deviation_Of (Left_Sees, Right_Sees : Boolean) return Deviation
     with
       Post => (if Left_Sees = Right_Sees then Deviation_Of'Result = 0
                elsif Left_Sees then Deviation_Of'Result = -100
                else Deviation_Of'Result = 100);

   --  Proportional steering: slow the inside wheel, speed up the outside one.
   function Steer (Dev : Deviation; Cruise : Speed; G : Gain) return Command
     with
       Post => (if Dev = 0 then Steer'Result.Turn = Straight
                elsif Dev < 0 then Steer'Result.Turn = Bear_Left
                else Steer'Result.Turn = Bear_Right);

   function Halted return Command
     with Post => Halted'Result = (Turn => Halt, Left => 0, Right => 0);

   --  Percent to the motor driver's 12-bit duty cycle.
   --
   --  P * 4095 reaches 409_500, so this is an overflow check worth having the
   --  prover discharge rather than assuming.
   function To_Duty (P : Speed) return Duty
     with Post => (if P = 0 then To_Duty'Result = 0);

end Line_Control;
