:- begin_tests(complex_formula_discovery).

:- use_module('../src/complex_formula_discovery').
:- use_module('../src/cost_model').

setup_costs :- cost_model:reset_cost_model.

test(linear_formula_discovery, [setup(setup_costs)]) :-
    Examples = [io(1,3), io(2,5), io(3,7), io(4,9)],
    complex_formula_discovery:discover_formula(Examples, [], affine(2,1)).

test(two_call_composition, [setup(setup_costs)]) :-
    Examples = [io(1,4), io(2,6), io(3,8)],
    Dictionary = [
        dictionary_entry(inc/2,[in,out],det,pure,1,(inc(X,Y) :- Y is X+1)),
        dictionary_entry(double/2,[in,out],det,pure,1,(double(X,Y) :- Y is X*2))
    ],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Program),
    assertion(Program == [call(inc/2), call(double/2)]).

test(structural_dictionary_primitive, [setup(setup_costs)]) :-
    Examples = [io([a,b],[b,a]), io([a,b,c],[c,b,a]), io([1,2,3,4],[4,3,2,1])],
    Dictionary = [predicate(reverse/2)],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Program),
    assertion(Program == [call(reverse/2)]).

test(index_formula_discovery, [setup(setup_costs)]) :-
    Pairs = [io(1,3), io(2,5), io(3,7), io(4,9)],
    complex_formula_discovery:discover_index_formula(Pairs, index_formula(a(2), b(1), expression('O is A*I+B'))).

:- end_tests(complex_formula_discovery).
