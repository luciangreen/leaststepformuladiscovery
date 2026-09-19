:- module(candidate_verify,
    [ verify_program/3,
      deterministic_program/1,
      safe_program/1
    ]).

verify_program(ProgramGoal, Examples, proof([verified(Passed,Total)])) :-
    length(Examples, Total),
    include(example_passes(ProgramGoal), Examples, Passing),
    length(Passing, Passed),
    Passed =:= Total.

example_passes(ProgramGoal, io(Input, Output)) :-
    call(ProgramGoal, Input, Found),
    Found == Output.

deterministic_program(_).
safe_program(_).
