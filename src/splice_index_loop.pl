:- module(splice_index_loop,
    [ splice_program/2
    ]).

splice_program(Program, Spliced) :-
    remove_duplicate_calls(Program, Spliced).

remove_duplicate_calls([], []).
remove_duplicate_calls([X,X|Rest], Out) :- !,
    remove_duplicate_calls([X|Rest], Out).
remove_duplicate_calls([X|Rest], [X|Out]) :-
    remove_duplicate_calls(Rest, Out).
