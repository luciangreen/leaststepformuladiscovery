:- module(cegis,
    [ cegis/4
    ]).

:- use_module(program_synthesis).

cegis(_Target, SeedExamples, Dictionary, Formula) :-
    program_synthesis:synthesise(SeedExamples, Dictionary, Formula, _Cost, _Proof, _Kind).
