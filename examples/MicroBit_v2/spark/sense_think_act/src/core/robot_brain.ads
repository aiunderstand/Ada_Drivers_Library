--  Sense / think / act, with the "think" half proved.
--
--  Two tasks share one reading: a sensing task writes it, an acting task reads
--  it. The protected object that makes that safe lives here, together with the
--  decision logic, and both are proved. The tasks themselves and the hardware
--  they talk to live in main.adb.
--
--  Prove it with:  python3 tools/mb.py prove --use spark/sense_think_act

pragma SPARK_Mode (On);

package Robot_Brain is

   --  An HC-SR04 reports roughly 2 cm .. 4 m.
   subtype Distance_Cm is Integer range 0 .. 400;
   subtype Speed       is Integer range 0 .. 100;

   type Mode is (Cruise, Slow, Stop);

   Stop_Below : constant Distance_Cm := 15;
   Slow_Below : constant Distance_Cm := 40;

   --  The "think" step: a total function of the reading, so there is no state
   --  to get wrong and every input has a defined answer.
   function Decide (D : Distance_Cm) return Mode
     with
       Post => (if D <= Stop_Below then Decide'Result = Stop
                elsif D <= Slow_Below then Decide'Result = Slow
                else Decide'Result = Cruise);

   function Speed_For (M : Mode) return Speed
     with
       Post => (if M = Stop then Speed_For'Result = 0
                elsif M = Slow then Speed_For'Result = 30
                else Speed_For'Result = 80);

   --  Shared state between the two tasks.
   --
   --  A protected object is Ada's mutual exclusion: only one task is inside it
   --  at a time, so there is no data race by construction. What the prover adds
   --  is that the invariant on the state holds after every operation.
   protected type Latest_Reading is

      function Value_Cm return Distance_Cm;

      --  The postcondition is written in terms of the public function, not the
      --  private component: callers reason about the abstraction, not the
      --  representation.
      procedure Update (D : Distance_Cm)
        with Post => Value_Cm = D;

      --  Saturating, deliberately: an unbounded counter would eventually
      --  overflow and GNATprove would (rightly) refuse to prove it.
      function Sample_Count return Natural;

   private
      Value   : Distance_Cm := Distance_Cm'Last;
      Samples : Natural     := 0;
   end Latest_Reading;

   Max_Samples : constant := Natural'Last;

end Robot_Brain;
