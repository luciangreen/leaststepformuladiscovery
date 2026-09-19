# leaststepformuladiscovery

Least-Step Formula Discovery in SWI-Prolog.

This project discovers compact formulas/programs from input/output examples.  
The command showcase below is designed to be copy-paste ready, pretty printed, and fully explained.

## Prerequisites

- SWI-Prolog 9+
- A shell (examples use bash)

Install SWI-Prolog on Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y swi-prolog
```

## Complete command showcase

All commands below assume you are in the repository root:

```bash
cd /home/runner/work/leaststepformuladiscovery/leaststepformuladiscovery
```

---

### 1) Run the full automated test suite

```bash
swipl -q -g "['tests/discovery_tests.pl'], run_tests, halt."
```

What it does:
- Loads the PLUnit test file in `tests/discovery_tests.pl`
- Runs all tests
- Exits cleanly

Expected result:
- `....` (one dot per passing test)
- Process exits with code `0`

---

### 2) Discover an affine formula from examples

```bash
swipl -q -g "['src/complex_formula_discovery.pl'], \
Examples=[io(1,3),io(2,5),io(3,7),io(4,9)], \
complex_formula_discovery:discover_formula(Examples, [], Formula), \
portray_clause(formula(Formula)), halt."
```

What it does:
- Uses no dictionary primitives (`[]`)
- Learns the least-cost formula matching all examples
- Pretty prints the discovered formula as a Prolog term

Expected output:
```prolog
formula(affine(2, 1)).
```

---

### 3) Discover a composed program using dictionary primitives

```bash
swipl -q -g "['src/complex_formula_discovery.pl'], \
Dictionary=[dictionary_entry(inc/2,[in,out],det,pure,1,(inc(X,Y):-Y is X+1)), \
            dictionary_entry(double/2,[in,out],det,pure,1,(double(X,Y):-Y is X*2))], \
Examples=[io(1,4),io(2,6),io(3,8)], \
complex_formula_discovery:discover_formula(Examples, Dictionary, Program), \
portray_clause(program(Program)), halt."
```

What it does:
- Declares two allowed primitives (`inc/2`, `double/2`)
- Learns the shortest successful composition from the dictionary
- Pretty prints the selected call sequence

Expected output:
```prolog
program([call(inc/2), call(double/2)]).
```

---

### 4) Discover an index formula (linear relation)

```bash
swipl -q -g "['src/complex_formula_discovery.pl'], \
Pairs=[io(1,3),io(2,5),io(3,7),io(4,9)], \
complex_formula_discovery:discover_index_formula(Pairs, Formula), \
portray_clause(index_formula(Formula)), halt."
```

What it does:
- Fits a linear index relation of the shape `O = A*I + B`
- Returns coefficients as a structured `index_formula/3` term

Expected output:
```prolog
index_formula(index_formula(a(2), b(1), expression(O is A*I+B))).
```

---

### 5) Discover a recursive map-style formula

```bash
swipl -q -g "['src/complex_formula_discovery.pl'], \
Dictionary=[predicate(succ/2)], \
Examples=[io([1,2,3],[2,3,4]),io([4,5],[5,6])], \
complex_formula_discovery:discover_recursive_formula(Examples, Dictionary, Program), \
portray_clause(program(Program)), halt."
```

What it does:
- Restricts recursion to the provided per-element predicate (`succ/2`)
- Verifies all list examples with same-length input/output lists
- Returns a `recursive_map/1` program

Expected output:
```prolog
program(recursive_map(succ)).
```

---

### 6) Get formula + cost + proof report in one run

```bash
swipl -q -g "['src/complex_formula_discovery.pl'], \
Examples=[io(1,3),io(2,5),io(3,7),io(4,9)], \
complex_formula_discovery:discover_formula(target/2, Examples, [], Formula, Proof, Cost), \
portray_clause(formula(Formula)), \
portray_clause(cost(Cost)), \
portray_clause(proof(Proof)), halt."
```

What it does:
- Runs the 6-argument discovery predicate
- Returns:
  - `Formula`: selected model/program
  - `Cost`: least cost from the internal cost model
  - `Proof`: selection/verification report structure
- Pretty prints each artifact as a Prolog clause-like term

Example output:
```prolog
formula(affine(2, 1)).
cost(2).
proof([kind(candidate(formula)), [selected(affine(2, 1)), verified(all_examples)], report([target(target/2), examples_count(4), dictionary_entries(0), selected_program(affine(2, 1)), cost(2), verification([selected(affine(2, 1)), verified(all_examples)])])]).
```

## Notes

- Use `portray_clause/1` when you want readable, reproducible output in docs or logs.
- Use `writeln/1` for quick ad-hoc inspection.
- The examples in this README are validated against the current repository state.
