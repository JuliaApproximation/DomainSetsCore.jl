module DomainSetsCore

export Domain

"""
A domain is a set of elements that is possibly continuous.

Examples may be intervals and triangles. These are geometrical shapes, but more
generally a domain can be any type that supports `in`. Conceptually, a domain
is the set of all elements `x` for which `in(x, domain)` returns true.
"""
abstract type Domain end


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

DomainRef(d) = AsDomain(d)

end # module DomainSetsCore
