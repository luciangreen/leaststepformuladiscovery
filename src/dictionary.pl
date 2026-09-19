:- module(dictionary,
    [ dictionary_predicate/3,
      predicate_cost/2,
      predicate_mode/2,
      ensure_dictionary_loaded/1
    ]).

:- use_module(cost_model).

ensure_dictionary_loaded(Dictionary) :-
    forall(member(Entry, Dictionary), ensure_entry(Entry)).

ensure_entry(dictionary_entry(_NameArity,_Modes,_Det,_Purity,_Cost,Definition)) :-
    nonvar(Definition),
    ( Definition = (Head :- Body) ->
        ( clause(user:Head, Body) -> true ; assertz(user:(Head :- Body)) )
    ; Definition = Head,
      ( clause(user:Head, true) -> true ; assertz(user:Head) )
    ), !.
ensure_entry(_).

dictionary_predicate(dictionary_entry(Name/Arity, Modes, _Det, _Purity, _Cost, _Definition), Name/Arity, Modes).
dictionary_predicate(pred(Name, Arity, Modes), Name/Arity, Modes).
dictionary_predicate(predicate(Name/Arity), Name/Arity, [in,out]).
dictionary_predicate(Name/Arity, Name/Arity, [in,out]) :- atom(Name), integer(Arity).
dictionary_predicate(predicate(Name), Name/2, [in,out]) :- atom(Name).

predicate_mode(Entry, Mode) :-
    dictionary_predicate(Entry, _NameArity, Mode).

predicate_cost(dictionary_entry(_NameArity, _Modes, _Det, _Purity, Cost, _Definition), Cost) :-
    number(Cost), !.
predicate_cost(_, Cost) :-
    cost_model:cost_of(predicate_call, Cost).
