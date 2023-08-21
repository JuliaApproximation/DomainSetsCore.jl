module DomainSetsCore

export Domain,
    domain,
    DomainStyle,
    IsDomain,
    NotDomain,
    AsDomain,
    AnyDomain,
    checkdomain

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


abstract type DomainStyle end

"""
    IsDomain()

indicates it satisfies the domain interface.
"""
struct IsDomain <: DomainStyle end
struct NotDomain <: DomainStyle end

DomainStyle(x) = DomainStyle(typeof(x))
DomainStyle(::Type) = NotDomain()
DomainStyle(::Type{<:Domain}) = IsDomain()
DomainStyle(::Type{<:AbstractSet}) = IsDomain()
DomainStyle(::Type{<:AbstractArray}) = IsDomain()


"""
A reference to a domain.

In a function call, `AsDomain(x)` can be used to indicate that `x` should be
treated as a domain in the function, e.g., `foo(x, AsDomain(d))`.
"""
abstract type AsDomain end

"A reference to a specific given domain."
struct DomainRef{D} <: AsDomain
    domain  ::  D
end
Base.eltype(::Type{<:DomainRef{D}}) where {D} = eltype(D)

domain(d::DomainRef) = d.domain
domain(d::Domain) = d

AsDomain(d) = DomainRef(d)
AsDomain(d::Domain) = d

"""
`AnyDomain` can be a concrete domain or a reference to a domain.

In both cases `domain(d::AnyDomain)` returns the domain itself.
"""
const AnyDomain = Union{Domain,AsDomain}

"""
   checkdomain(d)

Checks that `d` is a domain or refers to a domain and if so returns that domain,
throws an error otherwise.
"""
checkdomain(d::Domain) = d
# we trust the explicit intention of a user providing a domain reference
checkdomain(d::AsDomain) = domain(d)
# for other objects we check DomainStyle
checkdomain(d) = _checkdomain(d, DomainStyle(d))
_checkdomain(d, ::IsDomain) = d
_checkdomain(d, ::NotDomain) =
    error("Domain does not implement domain interface as indicated by DomainStyle.")


end # module DomainSetsCore
