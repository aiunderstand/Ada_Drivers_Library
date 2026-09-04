# SPARK: proved sensor scaling

Mirrors the `ravenscar/analog_in` and `ravenscar/math_functions` examples, but
the arithmetic is **proved** rather than tested.

| File | SPARK_Mode | Proved? | Touches hardware? |
|---|---|---|---|
| `src/core/sensor_scaling.ads` / `.adb` | `On` | yes | no |
| `src/main.adb` | `Off` | no | yes |

## Run it

```shell
python3 tools/mb.py flash --use spark/saturating_math
python3 tools/mb.py prove --use spark/saturating_math --mode=prove --level=1
```

Connect a potentiometer or LDR to pin 1 and watch the scaled value on the serial
monitor at 115200.

## What is proved

`To_Percent` maps a raw reading onto `-100 .. 100`:

```ada
return ((Offset * 200) / Span) - 100;
```

That one line contains two classic embedded bugs, and GNATprove rules out both:

* **Division by zero.** `Span` is `Hi - Lo`. The precondition `Lo < Hi` is what
  makes `Span` a `Positive`. Remove it and the proof fails immediately.
* **Overflow.** `Offset * 200` is at most `1023 * 200 = 204_600`. GNATprove
  checks that against `Integer'Last` rather than taking your word for it.

It also proves the result really lands in `Percent`, and the postconditions:
readings at or below `Lo` give exactly `-100`, at or above `Hi` exactly `100`,
`Saturating_Add` clips instead of wrapping, and `Dead_Zone` zeroes small values
and leaves everything else alone.

## Try breaking it

Swap the calibration constants in `main.adb` so `Lo > Hi`. It still compiles --
and on a real board it would divide by a negative span and produce nonsense.
Now express the same mistake in the contract by deleting `Pre => Lo < Hi` from
`sensor_scaling.ads` and proving again:

```
sensor_scaling.adb:6:41: medium: range check might fail,
                        cannot prove lower bound for Hi - Lo
```

Note *where* it fails: not at the division, but at

```ada
Span : constant Positive := Hi - Lo;
```

Declaring `Span` as `Positive` is a claim that it is at least 1. Without the
precondition, GNATprove cannot establish that -- and it is precisely that claim
which later makes the division safe. The type and the contract do the work
together.

The precondition is not decoration: it is the obligation the caller has to meet,
and the prover checks both sides of that bargain.
