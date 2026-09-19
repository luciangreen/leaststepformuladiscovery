:- module(behaviour_signature,
    [ examples_inputs_outputs/3,
      signature_for_goal/3,
      signatures_equal/2
    ]).

examples_inputs_outputs(Examples, Inputs, Outputs) :-
    maplist(example_io, Examples, Inputs, Outputs).

example_io(io(Input, Output), Input, Output).

signature_for_goal(GoalPred, Inputs, Signature) :-
    maplist(run_goal(GoalPred), Inputs, Signature).

run_goal(GoalPred, Input, Output) :-
    call(GoalPred, Input, Output).

signatures_equal(A, B) :- A == B.
