--  SPARK example: sense / think / act, with the thinking proved.
--
--    src/core/robot_brain.ads/.adb   SPARK_Mode => On   proved, no hardware
--    src/robot_tasks.ads/.adb        SPARK_Mode => Off  hardware and tasks
--
--  The work happens in the two tasks in Robot_Tasks, which start during
--  elaboration. Main has nothing left to do.
--
--    build and flash :  python3 tools/mb.py flash --use spark/sense_think_act
--    prove           :  python3 tools/mb.py prove --use spark/sense_think_act

pragma SPARK_Mode (Off);

with MicroBit.Console; use MicroBit.Console;
with Robot_Tasks;
pragma Unreferenced (Robot_Tasks);

procedure Main is
begin
   Put_Line ("SPARK sense/think/act. Ultrasonic on P16, echo on P0.");
   loop
      null;
   end loop;
end Main;
