# SPARK: sense / think / act, with the thinking proved

Mirrors `ravenscar/tasking_project_sense_think_act`. Two Ravenscar tasks share
one reading through a protected object; the decision logic and the protected
object are proved, the hardware is not.

| File | SPARK_Mode | Proved? | Touches hardware? |
|---|---|---|---|
| `src/core/robot_brain.ads` / `.adb` | `On` | yes | no |
| `src/robot_tasks.ads` / `.adb` | `Off` | no | yes (sensor, motors, tasks) |
| `src/main.adb` | `Off` | no | starts the tasks |

## Run it

```shell
python3 tools/mb.py flash --use spark/sense_think_act
python3 tools/mb.py prove --use spark/sense_think_act --mode=prove --level=1
```

HC-SR04 ultrasonic sensor: trigger on P16, echo on P0. Serial at 115200 shows
the distance and the chosen mode.

## What is proved

**The decision logic is total.** `Decide` has an answer for every distance in
`0 .. 400`, and its postcondition pins down exactly which: stop under 15 cm,
slow under 40, cruise beyond. There is no input that falls through.

**The protected object keeps its promise.** `Update`'s postcondition is written
in terms of the *public* function:

```ada
procedure Update (D : Distance_Cm) with Post => Value_Cm = D;
```

Callers reason about the abstraction, never the representation. For GNATprove to
discharge that, the accessors are **expression functions** in the body — an
ordinary function body is opaque to the prover, and it will tell you so:

> possible fix: you should consider adding a postcondition to function Value_Cm
> or turning it into an expression function

**The sample counter cannot overflow.** `Samples + 1` is exactly the kind of
check that never fails in testing and eventually fails in the field. It is
guarded:

```ada
if Samples < Natural'Last then
   Samples := Samples + 1;
end if;
```

Remove that guard and GNATprove reports the overflow it can no longer rule out.

## Tasking in SPARK needs to be declared

Proving anything with tasks requires the concurrency model to be pinned down, or
GNATprove refuses outright:

```
error: tasking in SPARK requires sequential elaboration (SPARK RM 9(2))
```

Hence `spark.adc`, referenced from `proof.gpr`:

```ada
pragma Profile (Ravenscar);
pragma Partition_Elaboration_Policy (Sequential);
```

These are not a fudge to quieten the tool — they describe what the board really
runs, since `embedded-nrf52833` is a Ravenscar-profile runtime.

## What is deliberately *not* proved

The tasks. They read a real sensor and drive real motors, so they live in
`robot_tasks.adb` with `SPARK_Mode => Off`.

What the protected object still buys you there is **mutual exclusion by
construction**: only one task is inside it at a time, so the two tasks cannot
race on the reading no matter how their timing interleaves. That is a property
of the language, not of the proof — and it is why the shared state is the one
part of the hardware half worth putting in the proved core.
