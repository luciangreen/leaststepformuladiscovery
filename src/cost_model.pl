:- module(cost_model,
    [ default_cost/2,
      cost_of/2,
      set_cost_model/1,
      current_cost_model/1,
      reset_cost_model/0
    ]).

:- dynamic user_cost/2.

default_cost(constant,1).
default_cost(variable,0).
default_cost(unification,1).
default_cost(arithmetic_operator,1).
default_cost(predicate_call,1).
default_cost(dictionary_lookup,1).
default_cost(index_lookup,1).
default_cost(recursive_call,1).
default_cost(arithmetic,1).
default_cost(list_traversal,5).

set_cost_model(Pairs) :-
    reset_cost_model,
    forall(member(Key-Value, Pairs), assertz(user_cost(Key, Value))).

current_cost_model(Pairs) :-
    findall(Key-Value, user_cost(Key, Value), Pairs).

reset_cost_model :-
    retractall(user_cost(_, _)).

cost_of(Key, Cost) :-
    ( user_cost(Key, Cost) ->
        true
    ; default_cost(Key, Cost)
    ), !.
cost_of(_, 1).
