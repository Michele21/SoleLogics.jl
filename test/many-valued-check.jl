using SoleLogics
using SoleLogics.ManyValuedLogics
using SoleLogics.ManyValuedLogics: G3, α
@atoms p q
check(parseformula("p∧q→q"), TruthDict([p => α, q => ⊥]), G3)
