pragma SPARK_Mode (On);

package body Ring_Buffer is

   function Empty_Buffer return Buffer is
   begin
      return (Items => (others => 0), Head => 0, Count => 0);
   end Empty_Buffer;

   procedure Push (B : in out Buffer; Value : Item) is
      --  Pre guarantees B.Count < Capacity, so Tail is a valid Index_Type and
      --  B.Count + 1 cannot overflow Count_Type. GNATprove checks both.
      Tail : constant Index_Type := (B.Head + B.Count) mod Capacity;
   begin
      B.Items (Tail) := Value;
      B.Count        := B.Count + 1;
   end Push;

   procedure Pop (B : in out Buffer; Value : out Item) is
   begin
      Value  := B.Items (B.Head);
      B.Head := (B.Head + 1) mod Capacity;
      B.Count := B.Count - 1;
   end Pop;

end Ring_Buffer;
