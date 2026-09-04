pragma SPARK_Mode (On);

package body Robot_Brain is

   function Decide (D : Distance_Cm) return Mode is
   begin
      if D <= Stop_Below then
         return Stop;
      elsif D <= Slow_Below then
         return Slow;
      else
         return Cruise;
      end if;
   end Decide;

   function Speed_For (M : Mode) return Speed is
   begin
      case M is
         when Stop   => return 0;
         when Slow   => return 30;
         when Cruise => return 80;
      end case;
   end Speed_For;

   protected body Latest_Reading is

      procedure Update (D : Distance_Cm) is
      begin
         Value := D;
         --  Saturate rather than wrap. Without this guard GNATprove reports an
         --  overflow check it cannot discharge on Samples + 1, which is a real
         --  bug in any long-running robot.
         if Samples < Natural'Last then
            Samples := Samples + 1;
         end if;
      end Update;

      --  Expression functions, not ordinary bodies: GNATprove can see through
      --  an expression function, so Update's postcondition -- written in terms
      --  of Value_Cm -- is provable without exposing the representation.
      function Value_Cm return Distance_Cm is (Value);

      function Sample_Count return Natural is (Samples);

   end Latest_Reading;

end Robot_Brain;
