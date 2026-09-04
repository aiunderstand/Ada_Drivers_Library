--  SPARK example: a proved bounded queue driving real hardware.
--
--  The interesting part of this example is the SPLIT:
--
--    src/core/ring_buffer.ads/.adb   SPARK_Mode => On   -- proved, no hardware
--    src/main.adb                    SPARK_Mode => Off  -- hardware, not proved
--
--  GNATprove analyses everything it can see, and the Ada Drivers Library is not
--  written in SPARK, so a program that mixes the two cannot be proved as one
--  unit. Keeping the logic hardware-free is what makes it provable -- and it is
--  good design regardless, because the logic becomes testable on its own.
--
--  Button A pushes a value, button B pops one. The queue holds 8 items; the
--  contracts on Push and Pop say they must not be called when the buffer is
--  full or empty, and GNATprove proves the guards below are enough.
--
--    build and flash :  python3 tools/mb.py flash --use spark/bounded_queue
--    prove           :  python3 tools/mb.py prove --use spark/bounded_queue

pragma SPARK_Mode (Off);

with MicroBit.Console;   use MicroBit.Console;
with MicroBit.Buttons;   use MicroBit.Buttons;
with MicroBit.DisplayRT;
with Ring_Buffer;        use Ring_Buffer;

procedure Main is
   Queue : Buffer := Empty_Buffer;
   Next  : Item   := 0;
   Value : Item;
begin
   Put_Line ("SPARK bounded queue. A = push, B = pop.");

   loop
      if MicroBit.Buttons.State (Button_A) = Pressed then
         --  The guard is what discharges Push's precondition.
         if Is_Full (Queue) then
            MicroBit.DisplayRT.Display ('F');
            Put_Line ("full");
         else
            Push (Queue, Next);
            MicroBit.DisplayRT.Display (Character'Val (Character'Pos ('0') + Length (Queue)));
            Put_Line ("pushed" & Item'Image (Next) & ", length" & Count_Type'Image (Length (Queue)));
            Next := (if Next = Item'Last then 0 else Next + 1);
         end if;

      elsif MicroBit.Buttons.State (Button_B) = Pressed then
         if Is_Empty (Queue) then
            MicroBit.DisplayRT.Display ('E');
            Put_Line ("empty");
         else
            Pop (Queue, Value);
            MicroBit.DisplayRT.Display (Character'Val (Character'Pos ('0') + Length (Queue)));
            Put_Line ("popped" & Item'Image (Value) & ", length" & Count_Type'Image (Length (Queue)));
         end if;

      else
         MicroBit.DisplayRT.Clear;
      end if;
   end loop;
end Main;
