module DomainSetsCore

export AbstractDomain,
    Domain

"""
A domain is a set of elements that is possibly continuous.

Examples include intervals and triangles. These are geometrical shapes, but more
generally a domain can be any type that supports `in`. Conceptually, the domain
is the set of all elements `x` for which `in(x, domain)` returns true.
"""
abstract type AbstractDomain end

"""
A `Domain{T}` is a domain with elements of type `T`.

Unlike finite sets, the element type of a domain may be ambiguous. For
example, the closed interval `1..2` contains any element `x` for which
`1 <= x <= 2` is true, regardless of its type. A `Domain{T}` may be useful in
cases where there is an intended element type, for example `Float64` when
performing calculations.
"""
abstract type Domain{T} <: AbstractDomain end
Base.eltype(::Type{<:Domain{T}}) where {T} = T

## Some aliases

"A `VectorDomain` is any domain whose eltype is `Vector{T}`."
const VectorDomain{T} = Domain{Vector{T}}

"An `AbstractVectorDomain` is any domain whose eltype is `<:AbstractVector{T}`."
const AbstractVectorDomain{T} = Domain{<:AbstractVector{T}}

# We provide a default definition of `in` for domains, which:
# - returns false if `x` and `d` are deemed incompatible,
# - and invokes `indomain` with promoted arguments otherwise
in(x, d::AbstractDomain) =
    iscompatiblepair(x, d) && indomain(promote_pair(x, d)...)


"""
Is the given combination of point and domain compatible?

Compatibility of point and domain implies that they can be promoted to types
`T` and `Domain{T}` respectively. If a point and domain are incompatible, the
point cannot be an element of the domain.
"""
iscompatiblepair(x, d) = _iscompatiblepair(x, d, typeof(x), eltype(d))
# By default, x and d are compatible if the type of x and the eltype of d
# promote to a concrete type, or if the eltype of d is Any.
_iscompatiblepair(x, d, ::Type{S}, ::Type{T}) where {S,T} =
    _iscompatiblepair(x, d, S, T, promote_type(S,T))
_iscompatiblepair(x, d, ::Type{S}, ::Type{T}, ::Type{U}) where {S,T,U} = true
_iscompatiblepair(x, d, ::Type{S}, ::Type{T}, ::Type{Any}) where {S,T} = false
_iscompatiblepair(x, d, ::Type{S}, ::Type{Any}, ::Type{Any}) where {S} = true


"""
Promote point and domain to compatible types of the form `T` and `Domain{T}`.

If there are no compatible types, point and domain are returned without error.
"""
promote_pair(x, d) = _promote_pair(x, d, promote_type(typeof(x),eltype(d)))
_promote_pair(x, d, ::Type{T}) where {T} = convert(T, x), convert(Domain{T}, d)
_promote_pair(x, d, ::Type{Any}) = x, d
# Some exceptions:
# - tuples: there is no generic way to promote tuples
promote_pair(x::Tuple, d::Domain{<:Tuple}) = x, d
# - abstract vectors: promotion may be expensive
promote_pair(x::AbstractVector, d::AbstractVectorDomain) = x, d


"""
A reference to a domain.

In a function call, `DomainRef(x)` or `AsDomain(x)` can be used to indicate that
`x` should be treated as a domain in the function. This is similar to `Ref(x)`,
which is used in broadcast to indicate that `x` should not be iterated over.
"""
abstract type DomainRef end

struct AsDomain{D} <: DomainRef
    domain  ::  D
end
Base.eltype(::Type{<:AsDomain{D}}) where {D} = eltype(D)

DomainRef(d) = AsDomain(d)

end # module DomainSetsCore
