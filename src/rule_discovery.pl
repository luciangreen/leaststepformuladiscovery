:- module(rule_discovery,
    [ discover_rule/4
    ]).

discover_rule(_Target, Examples, _Dictionary, sign_rule) :-
    maplist(example_sign, Examples), !.

example_sign(io(X,-1)) :- X < 0.
example_sign(io(0,0)).
example_sign(io(X,1)) :- X > 0.
