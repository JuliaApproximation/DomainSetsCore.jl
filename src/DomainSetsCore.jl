module DomainSetsCore

export Domain,
    domain,
    domaineltype,
    DomainStyle,
    IsDomain,
    NotDomain,
    AsDomain,
    AnyDomain,
    checkdomain


"""
    domaineltype(d)

The `domaineltype` of a continuous set is a valid type for elements of that set.
By default it is equal to the `eltype` of `d`, which in turn defaults to `Any`.
"""
domaineltype(d) = eltype(d)


"""
A `Domain{T}` is a supertype for domains with `domaineltype` equal to `T`.

In addition, the `eltype` of a `Domain{T}` is also equal to `T`.
"""
abstract type Domain{T} end

domaineltype(d::Domain{T}) where T = T
Base.eltype(::Type{<:Domain{T}}) where T = T


"""
    DomainStyle(d)

Trait to indicate whether or not `d` implements the domain interface.
"""
abstract type DomainStyle end

"""
    IsDomain()

indicates an object implements the domain interface.
"""
struct IsDomain <: DomainStyle end

"""
    NotDomain()

indicates an object does not implement the domain interface.
"""
struct NotDomain <: DomainStyle end


DomainStyle(d) = DomainStyle(typeof(d))
# - the default is no domain
DomainStyle(::Type) = NotDomain()
# - subtypes of Domain are domains
DomainStyle(::Type{<:Domain}) = IsDomain()
# - declare Number, AbstractSet and AbstractArray to be valid domain types
DomainStyle(::Type{<:Number}) = IsDomain()
DomainStyle(::Type{<:AbstractSet}) = IsDomain()
DomainStyle(::Type{<:AbstractArray}) = IsDomain()


"""
    domain(d)

Return a domain associated with the object `d`.
"""
domain(d::Domain) = d

"""
    AsDomain(d)

A reference to a domain.

In a function call, `AsDomain(x)` can be used to indicate that `x` should be
treated as a domain, e.g., `foo(x, AsDomain(d))`.
"""
abstract type AsDomain end

"A reference to a specific given domain."
struct DomainRef{D} <: AsDomain
    domain  ::  D
end

domain(d::DomainRef) = d.domain
domaineltype(d::AsDomain) = domaineltype(domain(d))

AsDomain(d) = DomainRef(d)
AsDomain(d::Domain) = d


"""
`AnyDomain` is the union of `Domain` and `AsDomain`.

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
