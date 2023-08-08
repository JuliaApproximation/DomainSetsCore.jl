module DomainSetsCore

export Domain

"""
A domain is a set of elements that is possibly continuous.

Examples may be intervals and triangles. These are geometrical shapes, but more
generally a domain can be any type that supports `in`. Conceptually, a domain
is the set of all elements `x` for which `in(x, domain)` returns true.

A `Domain{T}` is a domain with elements of type `T`, in analogy with
`AbstractSet{T}` and `AbstractVector{T}`. The `eltype` of a `Domain{T}` is `T`.
However, unlike finite sets, the element type of a domain may be somewhat
ambiguous. For example, the closed interval `1..2` contains any element `x` for
which `1 <= x <= 2` is true, regardless of its type. Still, for the benefit of
computations involving continuous sets `T` is typically given in terms of an
`AbstractFloat` such as `Float64`.
"""
abstract type Domain{T} end
Base.eltype(::Type{<:Domain{T}}) where {T} = T

## Some aliases

"A `VectorDomain` is any domain whose eltype is `Vector{T}`."
const VectorDomain{T} = Domain{Vector{T}}

"An `AbstractVectorDomain` is any domain whose eltype is `<:AbstractVector{T}`."
const AbstractVectorDomain{T} = Domain{<:AbstractVector{T}}

abstract type DomainStyle end

"""
    IsDomain()

indicates it satisfies the domain interface, i.e. supports `in`.
"""
struct IsDomain <: DomainStyle end
struct NotDomain <: DomainStyle end

DomainStyle(::Type) = NotDomain()
DomainStyle(::Type{<:Domain}) = IsDomain()
DomainStyle(::Type{<:AbstractSet}) = IsDomain()
DomainStyle(::Type{<:AbstractArray}) = IsDomain()


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
