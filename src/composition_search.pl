:- module(composition_search,
    [ least_cost_composition/6
    ]).

:- use_module(dictionary).
:- use_module(cost_model).
:- use_module(behaviour_signature).

least_cost_composition(Examples, Dictionary, MaxCost, Program, Cost, Proof) :-
    dictionary:ensure_dictionary_loaded(Dictionary),
    behaviour_signature:examples_inputs_outputs(Examples, Inputs, Outputs),
    expand_entries(Dictionary, Entries),
    search([node(Inputs, [], 0)], Outputs, Entries, MaxCost, ProgramRev, Cost),
    reverse(ProgramRev, Program),
    Proof = [search(uniform_cost), selected_calls(Program), verified(all_examples)].

expand_entries(Dictionary, Entries) :-
    findall(entry(Name, Arity, Modes, Cost),
        ( member(E, Dictionary),
          dictionary:dictionary_predicate(E, Name/Arity, Modes),
          dictionary:predicate_cost(E, Cost)
        ),
        Raw),
    sort(Raw, Entries).

search(Open, Outputs, _Entries, _MaxCost, Program, Cost) :-
    select_best(Open, node(Values, Program, Cost), _),
    behaviour_signature:signatures_equal(Values, Outputs), !.
search(Open, Outputs, Entries, MaxCost, Program, Cost) :-
    select_best(Open, Node, Rest),
    Node = node(Values, ProgramSoFar, CostSoFar),
    findall(node(NewValues, [call(Name/Arity)|ProgramSoFar], NewCost),
      ( member(entry(Name, Arity, Modes, StepCost), Entries),
        Modes = [in,out],
        Arity =:= 2,
        apply_predicate(Name, Values, NewValues),
        NewCost is CostSoFar + StepCost,
        NewCost =< MaxCost
      ),
      NextNodes),
    append(Rest, NextNodes, NewOpen),
    search(NewOpen, Outputs, Entries, MaxCost, Program, Cost).

select_best([H|T], Best, Rest) :-
    foldl(select_lower_cost, T, H, Best),
    select(Best, [H|T], Rest).

select_lower_cost(node(V1,P1,C1), node(_V2,_P2,C2), node(V1,P1,C1)) :- C1 =< C2, !.
select_lower_cost(_, Node, Node).

apply_predicate(Name, Inputs, Outputs) :-
    maplist(call_predicate(Name), Inputs, Outputs).

call_predicate(Name, Input, Output) :-
    Goal =.. [Name, Input, Output],
    call(user:Goal),
    !.
