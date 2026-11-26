:- module(program_synthesis,
    [ synthesise/6,
      least_cost_program/6
    ]).

:- use_module(cost_model).
:- use_module(composition_search).
:- use_module(index_formula).

synthesise(Examples, Dictionary, Program, Cost, Proof, candidate(composition)) :-
    ( affine_candidate(Examples, _Affine, AffineCost, _AffineProof) ->
        MaxCost = AffineCost
    ; MaxCost = unbounded
    ),
    composition_search:least_cost_composition(Examples, Dictionary, MaxCost, Program, Cost, Proof).
synthesise(Examples, _Dictionary, Formula, Cost, Proof, candidate(formula)) :-
    affine_candidate(Examples, Formula, Cost, Proof).
synthesise(Examples, _Dictionary, Formula, Cost, Proof, candidate(formula)) :-
    \+ affine_candidate(Examples, _, _, _),
    quadratic_candidate(Examples, Formula, Cost, Proof).

% A quadratic costs five operators (two multiplications for I*I, one for B*I
% and two additions), so it is chosen only where no linear formula fits.
% With exactly three examples it fits any three points, so the proof says
% that more examples are needed to confirm it.
quadratic_candidate(Examples, quadratic(A, B, C), Cost, [selected(quadratic(A,B,C)), verified(all_examples), Confidence]) :-
    index_formula:discover_quadratic_formula(Examples, quadratic(A, B, C)),
    cost_model:cost_of(arithmetic_operator, Op),
    Cost is 5 * Op,
    length(Examples, N),
    ( N > 3 -> Confidence = confirmed_by_extra_examples(N) ; Confidence = exact_fit_needs_more_examples ).

affine_candidate(Examples, affine(A, B), Cost, [selected(affine(A,B)), verified(all_examples)]) :-
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
