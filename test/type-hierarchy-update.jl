using Test
using SoleLogics

const SL = SoleLogics # SL.name to reference unexported names

# The following test set is intended to test the new type hierarchy update,
# considering both trivial and complex assertions regarding various aspects of SoleLogics.

# Declaration section

p = Atom("p")
q = Atom("q")
r = Atom("r")
m = Atom(1)
n = Atom(2)

pandq               = SyntaxBranch(CONJUNCTION, (p,q))
pandq_demorgan      = DISJUNCTION(p |> NEGATION, q |> NEGATION) |> NEGATION
qandp               = SyntaxBranch(CONJUNCTION, (q,p))
pandr               = SyntaxBranch(CONJUNCTION, (p,r))
porq                = SyntaxBranch(DISJUNCTION, (p,q))
norm                = SyntaxBranch(DISJUNCTION, (m,n))
trees_implication   = SyntaxBranch(IMPLICATION, (pandq, porq))

interp1             = TruthDict([p => TOP, q => TOP])
interp2             = TruthDict(1:4, BOT)

# Test section

@test Formula           <: Syntactical
@test AbstractSyntaxStructure   <: Formula
@test SyntaxLeaf              <: AbstractSyntaxStructure
@test Truth                     <: SyntaxLeaf

@test TOP               isa Truth
@test TOP               isa BooleanTruth
@test BOT            isa Truth
@test BOT            isa BooleanTruth

@test Connective        <: Syntactical
@test NamedConnective   <: Connective

@test Connective        <: Operator
@test Truth             <: Operator
@test Connective        <: SyntaxToken
@test SyntaxLeaf        <: SyntaxToken

@test SyntaxTree        <: AbstractSyntaxStructure
@test SyntaxBranch      <: SyntaxTree

@test NEGATION          isa NamedConnective
@test CONJUNCTION       isa NamedConnective
@test DISJUNCTION       isa NamedConnective
@test IMPLICATION       isa NamedConnective
@test typeof(¬)         <: NamedConnective
@test typeof(∧)         <: NamedConnective
@test typeof(∨)         <: NamedConnective
@test typeof(→)         <: NamedConnective

@test isnullary(p)      == true
@test syntaxstring(p)   == "p"

@test pandq             |> syntaxstring == CONJUNCTION(p, q)        |> syntaxstring
@test pandq             |> syntaxstring == (@synexpr p ∧ q)         |> syntaxstring
@test porq              |> syntaxstring == DISJUNCTION(p, q)        |> syntaxstring
@test porq              |> syntaxstring == (@synexpr p ∨ q)         |> syntaxstring
@test trees_implication |> syntaxstring == IMPLICATION(pandq, porq) |> syntaxstring
@test trees_implication |> syntaxstring == (@synexpr pandq → porq)  |> syntaxstring

@test pandq             |> syntaxstring ==
    SL.composeformulas(CONJUNCTION, (p, q)) |> syntaxstring
@test porq              |> syntaxstring ==
    SL.composeformulas(DISJUNCTION, (p, q)) |> syntaxstring
@test trees_implication |> syntaxstring ==
    SL.composeformulas(IMPLICATION, (pandq, porq)) |> syntaxstring

@test parseformula("p → q ∧ r") == (@synexpr p → q ∧ r)
@test parseformula("p → (q → r)") == (@synexpr p → (q → r))
@test parseformula("p → (q ∧ r)") == (@synexpr p → (q ∧ r))

@test syntaxstring((@synexpr □(□(□(p))) ∧ q)) == syntaxstring(parseformula("□□□p ∧ q"))
@test syntaxstring((@synexpr □(p) ∧ q)) == syntaxstring(parseformula("□p ∧ q"))

@test syntaxstring((@synexpr p ∧ □(□(□(q))))) == syntaxstring(parseformula("p ∧ □□□q"))
@test syntaxstring((@synexpr p ∧ □(q))) == syntaxstring(parseformula("p ∧ □q"))

@test syntaxstring((@synexpr □(□(□(p))) → q)) == syntaxstring(parseformula("□□□p → q"))
@test syntaxstring((@synexpr □(p) → q)) == syntaxstring(parseformula("□p → q"))

@test syntaxstring((@synexpr p → □(□(□(q))))) == syntaxstring(parseformula("p → □□□q"))
@test syntaxstring((@synexpr p → □(q))) == syntaxstring(parseformula("p → □q"))

@test natoms(pandq)                 == 2
@test natoms(trees_implication)     == natoms(pandq) + natoms(porq)
@test Set(atoms(pandq))             == Set(atoms(qandp))
@test Set(atoms(pandq))             == Set(atoms(porq))
@test Set(atoms(pandq))             != Set(atoms(pandr))
@test height(trees_implication)     == height(pandq) + height(qandp)

@test isequal(p, p)                     == true
@test isequal(p, q)                     == false
@test isequal(pandq, porq)              == false
@test isequal(porq, porq)               == true
@test isequal(pandq, pandq_demorgan)    == false # This is not semantics, but syntax only.

@test token(pandq)                      == CONJUNCTION
@test token(norm)                       == DISJUNCTION
@test token(pandq_demorgan)             == NEGATION
@test token(trees_implication)          == IMPLICATION

@test trees_implication |> children |> first == pandq
@test trees_implication |> children |> last  == porq

@test norm |> children |> first                     == SyntaxTree(m)
@test norm |> children |> first |> token            == m
@test norm |> children |> first |> token |> value   == value(m)

@test_nowarn interp1[p] = BOT
@test_nowarn interp1[p] = TOP

@test check(pandq, interp1) == true
