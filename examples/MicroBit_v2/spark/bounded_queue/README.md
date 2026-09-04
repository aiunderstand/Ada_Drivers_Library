# SPARK: a proved bounded queue

The point of this example is the **split**, not the queue:

| File | SPARK_Mode | Proved? | Touches hardware? |
|---|---|---|---|
| `src/core/ring_buffer.ads` / `.adb` | `On` | yes | no |
| `src/main.adb` | `Off` | no | yes |

GNATprove analyses every unit it can see, and the Ada Drivers Library is **not**
written in SPARK - `STMPE1600_Expander`, for instance, uses an access
discriminant, which SPARK does not allow. So a program that mixes ADL calls and
provable logic cannot be proved as one unit.

The fix is the standard SPARK boundary: keep the logic hardware-free, and put
the I/O in a thin shell. That is why there are two project files:

* `bounded_queue.gpr` - the flashable program: core + shell + the ADL.
* `proof.gpr` - the core **only**, with no ADL dependency. This is what
  GNATprove runs on.

Keeping the logic hardware-free is good design anyway: it is the part you can
reason about, test, and reuse.

## Run it

```shell
python3 tools/mb.py flash --use spark/bounded_queue   # build and flash
python3 tools/mb.py prove --use spark/bounded_queue   # flow analysis (fast)
python3 tools/mb.py prove --use spark/bounded_queue --mode=prove --level=1
```

Button A pushes a value, button B pops one; the display shows the queue length,
`F` for full and `E` for empty. Open a serial monitor at **115200** to see the
values.

## What is actually proved

At `--mode=prove --level=1`, GNATprove discharges every check with no
assumptions left over:

* no buffer overrun - `B.Items (Tail)` is always in range;
* no overflow - `B.Count + 1` cannot exceed `Capacity`, and `B.Count - 1` cannot
  go below zero;
* no division by zero in the `mod Capacity` wrap-around;
* the postconditions on `Push` and `Pop`, so the length really does go up by one
  and down by one.

Note what makes this work: `Push` has `Pre => not Is_Full (B)`. The
precondition is not decoration - it is what lets GNATprove prove the increment
cannot overflow, and it is the caller's obligation to satisfy it. In
`main.adb` the `if Is_Full (Queue)` guard is what discharges it.

## Try breaking it

Delete the `Pre => not Is_Full (B)` line from `ring_buffer.ads` and prove again:

```
ring_buffer.adb:16:33: medium: range check might fail,
                       cannot prove upper bound for B.Count + 1
```

GNATprove has found a real bug: without the guarantee that the buffer is not
full, `B.Count + 1` can leave `Count_Type`. Put the line back and it proves
again. This is the whole idea - the contract is a claim, and the prover checks
it against the body **and** every caller.

## The ladder

`--mode=flow` is the fast first rung: it catches uninitialised variables,
aliasing, and missing `Global` contracts. `--mode=prove --level=1` then proves
absence of run-time errors and the contracts. Higher levels give the prover more
time and more solvers; you rarely need them for code this size.
