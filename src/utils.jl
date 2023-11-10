# Fast isempty(intersect(u, v))
function intersects(u, v)
    for x in u
        if x in v
            return true
        end
    end
    false
end

initrng(rng::Union{Integer,AbstractRNG}) =
    (rng isa AbstractRNG) ? rng : Random.MersenneTwister(rng)