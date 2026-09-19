:- module(recursive_discovery,
    [ discover_recursive_formula/3
    ]).

:- use_module(dictionary).

discover_recursive_formula(Examples, Dictionary, recursive_map(Pred)) :-
    member(Entry, Dictionary),
    dictionary:dictionary_predicate(Entry, Pred/2, [in,out]),
    examples_are_lists(Examples),
    maplist(matches_map(Pred), Examples), !.

examples_are_lists([]).
examples_are_lists([io(In,Out)|Rest]) :-
    is_list(In),
    is_list(Out),
    examples_are_lists(Rest).

matches_map(Pred, io(Input, Output)) :-
    same_length(Input, Output),
    maplist(call_pred(Pred), Input, Output).

call_pred(Pred, In, Out) :-
    Goal =.. [Pred, In, Out],
    call(Goal).
