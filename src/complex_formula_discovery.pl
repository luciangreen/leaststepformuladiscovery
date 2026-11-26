:- module(complex_formula_discovery,
    [ discover_formula/3,
      discover_formula/6,
      discover_formula/5,
      discover_rule/4,
      discover_index_formula/2,
      discover_recursive_formula/3,
      least_cost_program/5,
      discover_formula_result/3,
      formula_alternatives/3
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

%% discover_formula_result(+Examples, +Dictionary, -Result)
% Result is found(Formula, Cost) or no_formula(Reason), where Reason is
% no_examples, too_few_examples(Count, needed(2)), non_numeric_examples,
% conflicting_examples(Input) or no_candidate_fits.
discover_formula_result(Examples, Dictionary, Result) :-
    (   discover_formula(target/2, Examples, Dictionary, Formula, _Proof, Cost)
    ->  Result = found(Formula, Cost)
    ;   failure_reason(Examples, Reason),
        Result = no_formula(Reason)
    ).

failure_reason([], no_examples) :- !.
failure_reason(Examples, conflicting_examples(X)) :-
    member(io(X, Y1), Examples),
    member(io(X2, Y2), Examples),
    X == X2, Y1 \== Y2, !.
failure_reason(Examples, non_numeric_examples) :-
    member(io(X, Y), Examples),
    \+ (number(X), number(Y)), !.
failure_reason(Examples, too_few_examples(N, needed(2))) :-
    length(Examples, N), N < 2, !.
failure_reason(_, no_candidate_fits).

%% formula_alternatives(+Examples, +Dictionary, -Alternatives)
% Every candidate found, cheapest first, as alternative(Formula, Cost, Kind),
% so a user can see what the chosen formula was preferred to.
formula_alternatives(Examples, Dictionary, Alternatives) :-
    findall(cand(F,C,P,K),
      program_synthesis:synthesise(Examples, Dictionary, F, C, P, K),
      Candidates),
    keysort_candidates(Candidates, Sorted),
    findall(alternative(F, C, K), member(cand(F,C,_,K), Sorted), Alternatives).

candidate_goal(quadratic(A,B,C), goal_quadratic(A,B,C)) :- !.
candidate_goal(affine(A,B), Goal) :-
    Goal = goal_affine(A,B).
candidate_goal(Program, Goal) :-
    is_list(Program),
    Goal = goal_program(Program).

goal_affine(A,B, Input, Output) :-
    number(Input),
    Output is A*Input + B.

goal_quadratic(A,B,C, Input, Output) :-
    number(Input),
    Output is A*Input*Input + B*Input + C.

goal_program([], Value, Value).
goal_program([call(Name/2)|Rest], Input, Output) :-
    Goal =.. [Name, Input, Mid],
    call(Goal),
    goal_program(Rest, Mid, Output).
