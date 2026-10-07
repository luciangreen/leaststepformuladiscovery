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

test(least_cost_prefers_formula, [setup(setup_costs)]) :-
    Examples = [io(1,4), io(2,6), io(3,8)],
    Dictionary = [
        dictionary_entry(inc/2,[in,out],det,pure,5,(inc(X,Y) :- Y is X+1)),
        dictionary_entry(double/2,[in,out],det,pure,5,(double(X,Y) :- Y is X*2))
    ],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Formula),
    assertion(Formula == affine(2,2)).

test(least_cost_prefers_composition, [setup(setup_costs)]) :-
    cost_model:set_cost_model([arithmetic_operator-5]),
    Examples = [io(1,4), io(2,6), io(3,8)],
    Dictionary = [
        dictionary_entry(inc/2,[in,out],det,pure,1,(inc(X,Y) :- Y is X+1)),
        dictionary_entry(double/2,[in,out],det,pure,1,(double(X,Y) :- Y is X*2))
    ],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Formula),
    assertion(Formula == [call(inc/2), call(double/2)]).

test(composition_longer_than_six_calls, [setup(setup_costs)]) :-
    Dictionary = [
        dictionary_entry(step1/2,[in,out],det,pure,1,(step1(0,1))),
        dictionary_entry(step2/2,[in,out],det,pure,1,(step2(1,2))),
        dictionary_entry(step3/2,[in,out],det,pure,1,(step3(2,3))),
        dictionary_entry(step4/2,[in,out],det,pure,1,(step4(3,4))),
        dictionary_entry(step5/2,[in,out],det,pure,1,(step5(4,5))),
        dictionary_entry(step6/2,[in,out],det,pure,1,(step6(5,6))),
        dictionary_entry(step7/2,[in,out],det,pure,1,(step7(6,7)))
    ],
    Examples = [io(0,7)],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Formula),
    assertion(Formula == [call(step1/2), call(step2/2), call(step3/2),
                          call(step4/2), call(step5/2), call(step6/2),
                          call(step7/2)]).

test(structural_dictionary_primitive, [setup(setup_costs)]) :-
    Examples = [io([a,b],[b,a]), io([a,b,c],[c,b,a]), io([1,2,3,4],[4,3,2,1])],
    Dictionary = [predicate(reverse/2)],
    complex_formula_discovery:discover_formula(Examples, Dictionary, Program),
    assertion(Program == [call(reverse/2)]).

test(index_formula_discovery, [setup(setup_costs)]) :-
    Pairs = [io(1,3), io(2,5), io(3,7), io(4,9)],
    complex_formula_discovery:discover_index_formula(Pairs, index_formula(a(2), b(1), expression('O is A*I+B'))).

:- end_tests(complex_formula_discovery).
