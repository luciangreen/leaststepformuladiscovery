:- module(program_synthesis,
    [ synthesise/6,
      least_cost_program/6
    ]).

:- use_module(cost_model).
:- use_module(composition_search).
:- use_module(index_formula).

synthesise(Examples, Dictionary, Program, Cost, Proof, candidate(composition)) :-
    cost_model:cost_of(predicate_call, Step),
    MaxCost is max(2, Step * 6),
    composition_search:least_cost_composition(Examples, Dictionary, MaxCost, Program, Cost, Proof), !.
synthesise(Examples, _Dictionary, affine(A, B), Cost, [selected(affine(A,B)), verified(all_examples)], candidate(formula)) :-
    index_formula:discover_affine_formula(Examples, affine(A,B)),
    cost_model:cost_of(arithmetic_operator, ACost),
    cost_model:cost_of(arithmetic_operator, BCost),
    Cost is ACost + BCost.

least_cost_program(Inputs, Outputs, Dictionary, Program, Cost, Proof) :-
    pairs_to_examples(Inputs, Outputs, Examples),
    synthesise(Examples, Dictionary, Program, Cost, Proof, _).

pairs_to_examples([], [], []).
pairs_to_examples([I|Is], [O|Os], [io(I,O)|Es]) :-
    pairs_to_examples(Is, Os, Es).
