--  The hardware half of the sense/think/act example.
--
--  SPARK_Mode is Off here: this package talks to the Ada Drivers Library, which
--  is not written in SPARK. The decision logic and the shared state it uses are
--  in Robot_Brain, which is proved.
--
--  The tasks and the shared object are declared at library level because that
--  is what the Ravenscar profile requires -- tasks nested inside a subprogram
--  are not allowed.

pragma SPARK_Mode (Off);

with Robot_Brain;

package Robot_Tasks is

   --  The tasks themselves live in the body; this tells the compiler a body is
   --  expected and must be elaborated with the spec.
   pragma Elaborate_Body;

   --  The one piece of shared state. A protected object, so the two tasks
   --  below cannot race on it.
   Reading : Robot_Brain.Latest_Reading;

end Robot_Tasks;
