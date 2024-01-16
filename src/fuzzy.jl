using Graphs

# Author: alberto-paparella

############################################################################################
#### HeytingTruth ##########################################################################
############################################################################################

"""
    struct HeytingTruth <: Truth
        label::String
        index::Int
    end

A truth value of a Heyting algebra.
Heyting truth values are represented by a label, and an index corresponding to its
position in the domain vector of the associated algebra.
Values `⊤` and `⊥` always exist with index 1 and 2, respectively.
New values can be easily constructed via the [`@heytingtruths`](@ref) macro.

See also [`@heytingtruths`](@ref), [`HeytingAlgebra`](@ref), [`Truth`](@ref)
"""
struct HeytingTruth <: Truth
    label::String
    index::Int  # the index of the node in the domain vector: no order is implied!

    function HeytingTruth(label::String, index::Int)
        return new(label, index)
    end

    function HeytingTruth(booleantruth::BooleanTruth)
        istop(booleantruth) ? HeytingTruth("⊤", 1) : HeytingTruth("⊥", 2)
    end
end

"""
Return the label of a [`HeytingTruth`](@ref).
"""
label(t::HeytingTruth)::String = t.label

"""
Return the index of a [`HeytingTruth`](@ref).
"""
index(t::HeytingTruth)::Int = t.index

istop(t::HeytingTruth) = index(t) == 1
isbot(t::HeytingTruth) = index(t) == 2

"""
Return the label associated with the t.
"""
syntaxstring(t::HeytingTruth; kwargs...) = label(t)

convert(::Type{HeytingTruth}, t::HeytingTruth) = t

function convert(::Type{HeytingTruth}, booleantruth::BooleanTruth)
    return istop(booleantruth) ? HeytingTruth("⊤", 1) : HeytingTruth("⊥", 2)
end

"""
Convert an object of type HeytingTruth to an object of type BooleanTruth (if possible).
"""
function convert(::Type{BooleanTruth}, t::HeytingTruth)
    if istop(t)
        return TOP
    elseif isbot(t)
        return BOT
    else
        error("Cannot convert HeytingTruth \"" * syntaxstring(t) * "\" to BooleanTruth. " *
              "Only ⊤ and ⊥ can be converted to BooleanTruth.")
    end
end

############################################################################################
#### HeytingAlgebra ########################################################################
############################################################################################

"""
    struct HeytingAlgebra
        domain::Vector{HeytingTruth}
        graph::Graphs.SimpleGraphs.SimpleDiGraph
    end

A structure for representing an Heyting algebra, characterized by the domain of its truths
and a graph representing the partial ordering between them.
⊤ and ⊥ are always the first and the second element of each algebra, respectively.

See also [`@heytingalgebra`](@ref), [`HeytingTruth`](@ref)
"""
struct HeytingAlgebra
    domain::Vector{HeytingTruth}
    graph::Graphs.SimpleGraphs.SimpleDiGraph # directed graph where (α, β) represents α ≺ β

    function HeytingAlgebra(domain::Vector{HeytingTruth},
                            graph::Graphs.SimpleGraphs.SimpleDiGraph)
        return new(domain, graph)
    end

    function HeytingAlgebra(domain::Vector{HeytingTruth}, relations::Vector{Edge{Int64}})
        return HeytingAlgebra(domain, SimpleDiGraph(relations))
    end
end

domain(h::HeytingAlgebra) = h.domain
top(h::HeytingAlgebra) = h.domain[1]
bot(h::HeytingAlgebra) = h.domain[2]
graph(h::HeytingAlgebra) = h.graph

cardinality(h::HeytingAlgebra) = length(domain(h))
isboolean(h::HeytingAlgebra) = (cardinality(h) == 2)

"""
    @heytingtruths(labels...)

Instantiate a collection of [`HeytingTruth`](@ref)s and return them as a vector.
⊤ and ⊥ already exist as const of type BooleanTruth and they are treated as HeytingTruth
with index 1 and 2 respectively.

!!! info
    HeytingTruths instantiated with this macro are defined in the global scope as constants.

# Examples
```julia-repl
julia> SoleLogics.@heytingtruths α β
2-element Vector{HeytingTruth}:
 HeytingTruth: α
 HeytingTruth: β

julia> α
HeytingTruth: α

See also [`HeytingTruth`](@ref), [`@heytingalgebra`](@ref)
"""
macro heytingtruths(labels...)
    quote
        $(map(t -> :(const $(t[2]) = $(HeytingTruth(string(t[2]), t[1]+2))), enumerate(labels))...)
        [$(labels...)]
    end |> esc
end

"""
    @heytingalgebra(name, values, relations...)

Instantiate a [`HeytingAlgebra`](@ref) as a constant in the global scope with name `name`,
with domain containing `values` and graph represented by the tuples `relations...` with each
tuple (α, β) representing a direct edge in the graph asserting α ≺ β.

!!! info
    Please not how the values of type [`HeytingTruth`](@ref) must be created beforehand
    (e.g., [`@heytingvalues`](@ref)) and not include ⊤ and ⊥.

# Examples
```julia-repl
julia> SoleLogics.@heytingtruths α β
2-element Vector{HeytingTruth}:
 HeytingTruth: α
 HeytingTruth: β

julia> SoleLogics.@heytingalgebra heytingalgebra4 (α, β) (⊥, α) (⊥, β) (α, ⊤) (β, ⊤)
HeytingTruth[HeytingTruth: ⊤, HeytingTruth: ⊥, HeytingTruth: α, HeytingTruth: β]
Vector{HeytingTruth}
HeytingAlgebra(HeytingTruth[HeytingTruth: ⊤, HeytingTruth: ⊥, HeytingTruth: α, HeytingTruth: β], SimpleDiGraph{Int64}(4, [Int64[], [3, 4], [1], [1]], [[3, 4], Int64[], [2], [2]]))

See also [`HeytingTruth`](@ref), [`@heytingalgebra`](@ref)
"""
macro heytingalgebra(name, values, relations...)
    quote
        domain = [convert(HeytingTruth, ⊤), convert(HeytingTruth, ⊥), $values...]
        println(domain)
        println(typeof(domain))
        edges = Vector{Edge{Int64}}()
        map(e -> push!(edges, Edge(eval(e))), $relations)
        const $name = (HeytingAlgebra(domain, edges))
    end |> esc
end

Graphs.Edge(t::Tuple{HeytingTruth, HeytingTruth}) = Edge(index(t[1]), index(t[2]))
Graphs.Edge(t::Tuple{HeytingTruth, BooleanTruth}) = Edge((t[1], convert(HeytingTruth, t[2])))
Graphs.Edge(t::Tuple{BooleanTruth, HeytingTruth}) = Edge((convert(HeytingTruth, t[1]), t[2]))
Graphs.Edge(t::Tuple{BooleanTruth, BooleanTruth}) = Edge((convert(HeytingTruth, t[1]), convert(HeytingTruth, t[2])))

function Graphs.inneighbors(heytingalgebra::HeytingAlgebra, t::HeytingTruth)::Vector{HeytingTruth}
    return domain(heytingalgebra)[inneighbors(graph(heytingalgebra), index(t))]
end

function Graphs.outneighbors(heytingalgebra::HeytingAlgebra, t::HeytingTruth)::Vector{HeytingTruth}
    return domain(heytingalgebra)[outneighbors(graph(heytingalgebra), index(t))]
end

# α ≺ β
function precedes(h::HeytingAlgebra, α::HeytingTruth, β::HeytingTruth)
    if α ∈ inneighbors(h, β)
        return true
    else
        for γ ∈ outneighbors(h, α)
            if precedes(h, γ, β)
                return true
            end
        end
        return false
    end
end
precedes(h::HeytingAlgebra, α::HeytingTruth, β::BooleanTruth) = precedes(h, α, convert(HeytingTruth, β))
precedes(h::HeytingAlgebra, α::BooleanTruth, β::HeytingTruth) = precedes(h, convert(HeytingTruth, α), β)
precedes(h::HeytingAlgebra, α::BooleanTruth, β::BooleanTruth) = precedes(h, convert(HeytingTruth, α), convert(HeytingTruth, β))

# β ≺ α
succeedes(h::HeytingAlgebra, α::HeytingTruth, β::HeytingTruth) = precedes(h, β, α)
succeedes(h::HeytingAlgebra, α::HeytingTruth, β::BooleanTruth) = succeedes(h, α, convert(HeytingTruth, β))
succeedes(h::HeytingAlgebra, α::BooleanTruth, β::HeytingTruth) = succeedes(h, convert(HeytingTruth, α), β)
succeedes(h::HeytingAlgebra, α::BooleanTruth, β::BooleanTruth) = succeedes(h, convert(HeytingTruth, α), convert(HeytingTruth, β))

# α ⪯ β
precedeq(h::HeytingAlgebra, α::HeytingTruth, β::HeytingTruth) = α == β ||  precedes(h, α, β)
precedeq(h::HeytingAlgebra, α::HeytingTruth, β::BooleanTruth) = precedeq(h, α, convert(HeytingTruth, β))
precedeq(h::HeytingAlgebra, α::BooleanTruth, β::HeytingTruth) = precedeq(h, convert(HeytingTruth, α), β)
precedeq(h::HeytingAlgebra, α::BooleanTruth, β::BooleanTruth) = precedeq(h, convert(HeytingTruth, α), convert(HeytingTruth, β))

# β ⪯ α
succeedeq(h::HeytingAlgebra, α::HeytingTruth, β::HeytingTruth) = α == β ||  succeedes(h, α, β)
succeedeq(h::HeytingAlgebra, α::HeytingTruth, β::BooleanTruth) = succeedeq(h, α, convert(HeytingTruth, β))
succeedeq(h::HeytingAlgebra, α::BooleanTruth, β::HeytingTruth) = succeedeq(h, convert(HeytingTruth, α), β)
succeedeq(h::HeytingAlgebra, α::BooleanTruth, β::BooleanTruth) = succeedeq(h, convert(HeytingTruth, α), convert(HeytingTruth, β))

# Meet (greatest lower bound) between values α and β
function collatetruth(::typeof(∧), (α, β)::NTuple{N, T where T<:HeytingTruth}, h::HeytingAlgebra) where {N}
    if precedeq(h, α, β)
        return α
    elseif succeedes(h, α, β)
        return β
    else
        for γ ∈ inneighbors(h, α)
            if γ ∈ inneighbors(h, β)
                return γ
            else
                collatetruth(∧, (α, β), h)
            end
        end
    end
end

# Join (least upper bound) between values α and β
function collatetruth(::typeof(∨), (α, β)::NTuple{N, T where T<:HeytingTruth}, h::HeytingAlgebra) where {N}
    if succeedeq(h, α, β)
        return α
    elseif precedes(h, α, β)
        return β
    else
        for γ ∈ outneighbors(h, α)
            if γ ∈ outneighbors(h, β)
                return γ
            else
                return collatetruth(∨, (α, β), h)
            end
        end
    end
end

# Implication/pseudo-complement α → β = join(γ | meet(α, γ) = β)
function collatetruth(::typeof(→), (α, β)::NTuple{N, T where T<:HeytingTruth}, h::HeytingAlgebra) where {N}
    η = bot(h)
    for γ ∈ domain(h)
        if precedeq(h, collatetruth(∧, (α, γ), h), β)
            η = collatetruth(∨, (η, γ), h)
        else
            continue
        end
    end
    return η
end

collatetruth(c::Connective, (α, β)::Tuple{HeytingTruth, BooleanTruth}, h::HeytingAlgebra) = collatetruth(c, (α, convert(HeytingTruth, β)), h)
collatetruth(c::Connective, (α, β)::Tuple{BooleanTruth, HeytingTruth}, h::HeytingAlgebra) = collatetruth(c, (convert(HeytingTruth, α), β), h)
collatetruth(c::Connective, (α, β)::Tuple{BooleanTruth, BooleanTruth}, h::HeytingAlgebra) = collatetruth(c, (convert(HeytingTruth, α), convert(HeytingTruth, β)), h)

simplify(c::Connective, (α, β)::Tuple{HeytingTruth,HeytingTruth}, h::HeytingAlgebra) = collatetruth(c, (α, β), h)
simplify(c::Connective, (α, β)::Tuple{HeytingTruth,BooleanTruth}, h::HeytingAlgebra) = collatetruth(c, (α, convert(HeytingTruth, β)), h)
simplify(c::Connective, (α, β)::Tuple{BooleanTruth,HeytingTruth}, h::HeytingAlgebra) = collatetruth(c, (convert(HeytingTruth, α), β), h)
simplify(c::Connective, (α, β)::Tuple{BooleanTruth,BooleanTruth}, h::HeytingAlgebra) = collatetruth(c, (convert(HeytingTruth, α), convert(HeytingTruth, β)), h)

# Note: output type can both be BooleanTruth or HeytingTruth, i.e., the following check can be used effectively
# convert(HeytingTruth, interpret(φ, td8)) == convert(HeytingTruth,interpret(φ, td8, booleanalgebra)))
function interpret(φ::SyntaxBranch, i::AbstractAssignment, h::HeytingAlgebra, args...; kwargs...)::Formula
    return simplify(token(φ), Tuple(
        [interpret(ch, i, h, args...; kwargs...) for ch in children(φ)]
    ), h)
end

function collatetruth(::typeof(¬), (α,)::Tuple{HeytingTruth}, h::HeytingAlgebra)
    if isboolean(h)
        if istop(α)
            return ⊥
        else
            return ⊤
        end
    else
        return error("¬ operation isn't defined outside of BooleanAlgebra")
    end
end
collatetruth(c::Connective, (α,)::Tuple{BooleanTruth}, h::HeytingAlgebra) = collatetruth(c, convert(HeytingTruth, α), h)

simplify(c::Connective, (α,)::Tuple{HeytingTruth}, h::HeytingAlgebra) = collatetruth(c, (α,), h)
simplify(c::Connective, (α,)::Tuple{BooleanTruth}, h::HeytingAlgebra) = simplify(c, (convert(HeytingTruth, α),), h)