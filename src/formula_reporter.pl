:- module(formula_reporter,
    [ build_formula_report/7
    ]).

build_formula_report(Target, Examples, Dictionary, Program, Cost, Verification, report([
    target(Target),
    examples_count(ExampleCount),
    dictionary_entries(DictionaryCount),
    selected_program(Program),
    cost(Cost),
    verification(Verification)
])) :-
    length(Examples, ExampleCount),
    length(Dictionary, DictionaryCount).
