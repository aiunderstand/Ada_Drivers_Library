# SPARK: proved line-following steering

Mirrors `ravenscar/tasking_project_linetracker`, but the decision-making is
separated from the I/O so it can be proved.

| File | SPARK_Mode | Proved? | Touches hardware? |
|---|---|---|---|
| `src/core/line_control.ads` / `.adb` | `On` | yes | no |
| `src/main.adb` | `Off` | no | yes |

## Run it

```shell
python3 tools/mb.py flash --use spark/line_follower
python3 tools/mb.py prove --use spark/line_follower --mode=prove --level=1
```

Two reflectance sensors on pins 1 and 2, straddling the line, and the DFR0548
motor board. Serial output at 115200 shows the deviation and both duty cycles.

## What is proved

The interesting guarantee is at the **boundary**: the motor driver takes a
`UInt12`, and `Steer` proves its results are always in `0 .. 4095`. So the
conversion in `main.adb`

```ada
function Duty12 (D : Duty) return UInt12 is (UInt12 (D));
```

cannot fail — not because it was tested with a few values, but because the range
was established for *every* input.

Along the way GNATprove also discharges:

* the overflow check on `P * 4095` in `To_Duty`, which reaches 409,500;
* the division checks in `(P * 4095) / 100` and `(G * Dev) / 10`;
* that `Clamp` really does return something in `Speed`;
* the postconditions — a zero deviation gives `Straight`, negative gives
  `Bear_Left`, positive `Bear_Right`.

## Where the boundary sits, and why

Notice what is **not** in the proved core: the decision that both sensors reading
low means the line is lost. `Deviation_Of` cannot tell "both on the line" from
"both off it" — that needs to know what the sensors mean, which is a property of
the robot, not of the arithmetic. So it lives in `main.adb`.

Drawing that line is the skill this example is really teaching. Push too much
into the core and you end up importing the hardware; push too little and you
prove nothing interesting.

## Try breaking it

Raise the gain past its range, say `G : constant Gain := 20;`. That fails to
compile, because `Gain` is `0 .. 10` — the type catches it.

Now widen the subtype to `0 .. 100` in `line_control.ads` and prove again. The
adjustment can then exceed a wheel's range, and `Clamp` is what keeps the result
legal — remove the clamp too and GNATprove reports the range check it can no
longer discharge.
