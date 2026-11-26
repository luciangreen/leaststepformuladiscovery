:- module(index_formula,
    [ discover_index_formula/2,
      discover_affine_formula/2,
      discover_quadratic_formula/2
    ]).

:- use_module(library(error)).

discover_index_formula(Pairs, index_formula(a(A), b(B), expression('O is A*I+B'))) :-
    discover_affine_formula(Pairs, affine(A, B)).

discover_affine_formula(Examples, affine(A, B)) :-
    must_be(list, Examples),
    maplist(as_io_pair, Examples, Inputs, Outputs),
    maplist(number, Inputs),
    maplist(number, Outputs),
    Inputs = [X1, X2|_],
    Outputs = [Y1, Y2|_],
    DX is X2 - X1,
    DX =\= 0,
    A0 is (Y2 - Y1) / DX,
    integer_or_float(A0, A),
    B0 is Y1 - A*X1,
    integer_or_float(B0, B),
    forall(member(io(X, Y), Examples), Y =:= A*X + B).

integer_or_float(Value, Out) :-
    ( float(Value), round(Value) =:= Value -> Out is round(Value)
    ; Out = Value
    ).

as_io_pair(io(X, Y), X, Y).

%% discover_quadratic_formula(+Examples, -Formula)
% Fit O = A*I*I + B*I + C exactly from the first three examples (with
% distinct inputs) and check it on all of them. A must not be zero, so a
% linear relation is left to discover_affine_formula/2.
discover_quadratic_formula(Examples, quadratic(A, B, C)) :-
    must_be(list, Examples),
    maplist(as_io_pair, Examples, Inputs, Outputs),
    maplist(number, Inputs),
    maplist(number, Outputs),
    Inputs = [X1, X2, X3|_],
    Outputs = [Y1, Y2, Y3|_],
    D is (X1 - X2) * (X1 - X3) * (X2 - X3),
    D =\= 0,
    A0 is (X3*(Y2 - Y1) + X2*(Y1 - Y3) + X1*(Y3 - Y2)) / D,
    B0 is (X3*X3*(Y1 - Y2) + X2*X2*(Y3 - Y1) + X1*X1*(Y2 - Y3)) / D,
    C0 is (X2*X3*(X2 - X3)*Y1 + X3*X1*(X3 - X1)*Y2 + X1*X2*(X1 - X2)*Y3) / D,
    integer_or_float(A0, A),
    integer_or_float(B0, B),
    integer_or_float(C0, C),
    A =\= 0,
    forall(member(io(X, Y), Examples), Y =:= A*X*X + B*X + C).
