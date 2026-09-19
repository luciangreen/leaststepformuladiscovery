:- module(complex_formula_discovery,
    [ discover_formula/3,
      discover_formula/6,
      discover_formula/5,
      discover_rule/4,
      discover_index_formula/2,
      discover_recursive_formula/3,
      least_cost_program/5
    ]).

:- use_module(cost_model).
:- use_module(program_synthesis).
:- use_module(index_formula, []).
:- use_module(rule_discovery, []).
:- use_module(recursive_discovery, []).
:- use_module(formula_reporter).
:- use_module(candidate_verify).

discover_formula(Examples, Dictionary, Formula) :-
    discover_formula(target/2, Examples, Dictionary, Formula, _Proof, _Cost).

discover_formula(Target, TrainingExamples, ValidationExamples, Dictionary, Formula) :-
    discover_formula(Target, TrainingExamples, Dictionary, Candidate, _Proof, _Cost),
    candidate_goal(Candidate, Goal),
    candidate_verify:verify_program(Goal, ValidationExamples, _),
    Formula = Candidate.

discover_formula(Target, Examples, Dictionary, Formula, Proof, Cost) :-
    choose_best_candidate(Examples, Dictionary, Formula, Cost, CandidateProof, Kind),
    formula_reporter:build_formula_report(Target, Examples, Dictionary, Formula, Cost, CandidateProof, Report),
    Proof = [kind(Kind), CandidateProof, Report].

discover_rule(Target, Examples, Dictionary, Rule) :-
    rule_discovery:discover_rule(Target, Examples, Dictionary, Rule).

discover_index_formula(IndexPairs, Formula) :-
    index_formula:discover_index_formula(IndexPairs, Formula).

discover_recursive_formula(Examples, Dictionary, Program) :-
    recursive_discovery:discover_recursive_formula(Examples, Dictionary, Program).

least_cost_program(Inputs, Outputs, Dictionary, Program, Cost) :-
    program_synthesis:least_cost_program(Inputs, Outputs, Dictionary, Program, Cost, _).

choose_best_candidate(Examples, Dictionary, Formula, Cost, Proof, Kind) :-
    findall(cand(F,C,P,K),
      program_synthesis:synthesise(Examples, Dictionary, F, C, P, K),
      Candidates),
    Candidates \= [],
    keysort_candidates(Candidates, [cand(Formula, Cost, Proof, Kind)|_]).

keysort_candidates(Candidates, Sorted) :-
    findall(C-cand(F,C,P,K), member(cand(F,C,P,K), Candidates), Pairs),
    keysort(Pairs, SortedPairs),
    findall(Candidate, member(_-Candidate, SortedPairs), Sorted).

candidate_goal(affine(A,B), Goal) :-
    Goal = goal_affine(A,B).
candidate_goal(Program, Goal) :-
    is_list(Program),
    Goal = goal_program(Program).

goal_affine(A,B, Input, Output) :-
    number(Input),
    Output is A*Input + B.

goal_program([], Value, Value).
goal_program([call(Name/2)|Rest], Input, Output) :-
    Goal =.. [Name, Input, Mid],
    call(Goal),
    goal_program(Rest, Mid, Output).
