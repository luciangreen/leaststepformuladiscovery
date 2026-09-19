:- module(search_state,
    [ state_signature/2,
      initial_state/2,
      make_state/4
    ]).

make_state(Values, Program, Cost, state(Values, Program, Cost)).
initial_state(Values, state(Values, [], 0)).
state_signature(state(Values, _Program, _Cost), Values).
