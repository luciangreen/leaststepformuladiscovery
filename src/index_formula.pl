:- module(index_formula,
    [ discover_index_formula/2,
      discover_affine_formula/2
    ]).

:- use_module(library(error)).

discover_index_formula(Pairs, index_formula(a(A), b(B), expression('O is A*I+B'))) :-
    discover_affine_formula(Pairs, affine(A, B)).

discover_affine_formula(Examples, affine(A, B)) :-
    must_be(list, Examples),
    maplist(as_io_pair, Examples, Inputs, Outputs),
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
