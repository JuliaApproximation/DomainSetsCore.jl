# DomainSetsCore.jl
An interface package for working with domains as continuous sets of elements.

## The domain interface

A domain is a type that supports `in` and `eltype`. That is, for any given
object `x` the function call `in(x, domain)` returns whether or not `x` belongs
to the set. The `eltype` of a domain is an indication of the type of elements of
the set.

## Domains as mathematical sets

Domains are typically defined by a mathematical condition, rather than by type.
For example, the closed interval `[a,b]` is the set of all values `x` such that
`a <= x <= b`, irrespective of the type of `x`. Whenever possible, domains
behave as the mathematical continuous set. Thus, two closed intervals with equal
endpoints are considered equal, even if they have a different `eltype.`

## The Domain supertype and DomainStyle trait

This package defines the abstract type `Domain{T}` of continuous domains with
elements of type `T`. All types inheriting from it are treated as domains, i.e.,
as possibly continuous sets of elements. No concrete types are defined in this
package.

The package also defines the trait `DomainStyle`. Any type can declare to
implement the domain interface by defining
```julia
DomainSetsCore.DomainStyle(d::MyDomain) = IsDomain()
```

Numbers, abstract arrays and abstract sets are declared to be domains in this
package.

## More functionality with domains

Unions and intersections of domains are implemented generically in the
[DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.
Intervals inheriting from the `Domain` supertype are implemented in
[IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl).
