--  A bounded ring buffer, proved free of run-time errors.
--
--  This package is the "provable core" of the example: it is pure Ada with no
--  hardware dependency at all, which is what makes it provable. The parts that
--  touch the micro:bit live in main.adb with SPARK_Mode => Off.
--
--  Prove it with:  python3 tools/mb.py prove --use spark/bounded_queue

pragma SPARK_Mode (On);

package Ring_Buffer is

   Capacity : constant := 8;

   subtype Index_Type is Natural range 0 .. Capacity - 1;
   subtype Count_Type is Natural range 0 .. Capacity;

   type Item is range -128 .. 127;

   type Buffer is private;

   function Length (B : Buffer) return Count_Type;

   function Is_Empty (B : Buffer) return Boolean is (Length (B) = 0);
   function Is_Full  (B : Buffer) return Boolean is (Length (B) = Capacity);

   function Empty_Buffer return Buffer
     with Post => Is_Empty (Empty_Buffer'Result);

   procedure Push (B : in out Buffer; Value : Item)
     with
       Pre  => not Is_Full (B),
       Post => Length (B) = Length (B'Old) + 1;

   procedure Pop (B : in out Buffer; Value : out Item)
     with
       Pre  => not Is_Empty (B),
       Post => Length (B) = Length (B'Old) - 1;

private

   type Item_Array is array (Index_Type) of Item;

   type Buffer is record
      Items : Item_Array := (others => 0);
      Head  : Index_Type := 0;
      Count : Count_Type := 0;
   end record;

   function Length (B : Buffer) return Count_Type is (B.Count);

end Ring_Buffer;
