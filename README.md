# *SoleLogics.jl* – Computational logic in Julia

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://aclai-lab.github.io/SoleLogics.jl/stable)
[![Build Status](https://api.cirrus-ci.com/github/aclai-lab/SoleLogics.jl.svg)](https://cirrus-ci.com/github/aclai-lab/SoleLogics.jl)
[![Coverage](https://codecov.io/gh/aclai-lab/SoleLogics.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/aclai-lab/SoleLogics.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

## In a nutshell

*SoleLogics.jl* provides a fresh codebase for computational logic, featuring easy manipulation of:
- Propositional and (multi)modal logics (propositions, logical constants, alphabet, grammars, crisp/fuzzy algebras);
- Logical formulas (parsing, random generation, minimization);
- Logical interpretations (e.g., propositional valuations, Kripke structures);
- Algorithms for *finite [model checking](https://en.wikipedia.org/wiki/Model_checking)*, that is, checking that a formula is satisfied by an interpretation.

<!-- However, it can be used for other purposes by computational logicians. -->

## Usage

```julia
using Pkg; Pkg.add("SoleLogics")
using SoleLogics
```

### Parsing and manipulating Formulas

```julia
julia> φ1 = parseformulatree("¬p∧q∧(¬s∧¬z)");

julia> φ1 isa SyntaxTree
true

julia> syntaxstring(φ1)
"(¬(p)) ∧ (q ∧ ((¬(s)) ∧ (¬(z))))"

julia> φ2 = ⊥ ∨ Proposition("t") → φ1;

julia> φ2 isa SyntaxTree
true

julia> syntaxstring(φ2)
"(⊥ ∨ t) → ((¬(p)) ∧ (q ∧ ((¬(s)) ∧ (¬(z)))))"
```

<!-- 
### Generating random formulas

```julia-repl
julia> parseformulatree("")
```

### Generating random interpretations

```julia-repl
julia> parseformulatree("")
```

### Model checking

### Interpretation sets

-->

## About

The package is developed by the [ACLAI Lab](https://aclai.unife.it/en/) @ University of Ferrara.

*SoleLogics.jl* lays the logical foundations for [*Sole.jl*](https://github.com/aclai-lab/Sole.jl), an open-source framework for *symbolic machine learning*.
