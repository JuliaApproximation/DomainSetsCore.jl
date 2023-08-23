[![Build Status](https://github.com/JuliaApproximation/DomainSetsCore.jl/workflows/CI/badge.svg)](https://github.com/JuliaApproximation/DomainSetsCore.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaApproximation/DomainSetsCore.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaApproximation/DomainSetsCore.jl)

# DomainSetsCore.jl
An interface package for working with domains as continuous sets of elements.

## The domain interface

A domain is a set that supports `in`. That is, for any given object `x` the
function call `in(x, domain)` returns whether or not `x` belongs
to the domain. Hence, the set may be continuous. The `domaineltype` of a domain
is the `eltype` of any discrete approximation of the continuous set (or just the
`eltype` of the set if it is discrete).

Examples of domains may be intervals and triangles, vectors and arrays, or
the set of all orthogonal `3x3` matrices with `Float64` elements. The typical
`domaineltype` of an interval is `Float64`, which is the standard discrete approximation of continuous numbers in Julia.

The interface is formally summarised in the following table:

| Required methods | Brief description |
| ---------------- | ----------------- |
| `in(x, d)` | Returns `true` when `x` is an element of the domain, `false` otherwise |
| `DomainStyle(d)` | Returns `IsDomain()` if `d` implements this interface |

Optional methods include:

| Important optional methods | Default definition | Brief description
| --- | --- | --- |
| `domaineltype(d)` | `eltype(typeof(d))` | Returns the type of discrete samples of the domain |

Several extensions of this minimal interface are defined in the [DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package

## Domains as mathematical sets

Domains are typically defined by a mathematical condition, rather than by type.
For example, the closed interval `[a,b]` is the set of all values `x` such that
`a <= x <= b`, irrespective of the type of `x`. Whenever possible, domains
behave as the mathematical continuous set. Thus, two closed intervals with equal
endpoints are considered equal, even if they have different types and a different `domaineltype`.

## The Domain supertype and DomainStyle trait

This package defines the abstract type `Domain{T}` of continuous domains with
elements of type `T`. All types inheriting from it are treated as domains, i.e.,
as possibly continuous sets of elements. No concrete domain types are defined
in this package.

The package also defines the trait `DomainStyle`. Any type can declare to
implement the domain interface by defining
```julia
DomainSetsCore.DomainStyle(d::MyDomain) = IsDomain()
```

`Number`s, `AbstractArray`s and `AbstractSet`s are declared to be domains in
this package.

## Using the domain interface in practice with `AsDomain`

The set of types implementing the domain interface is not based on a common
abstract supertype, but on the `DomainStyle` trait. It is therefore not
possible to dispatch on the property of being a domain, except for subtypes of `Domain`.

For this reason the package defines the `AsDomain` reference. A user who invokes
a generic function `foo` and intends for the object `d` to be treated as a
domain in that function can indicate so by passing `d` "as a domain":
```julia
foo(x, AsDomain(d))
```

Conversely, a developer writing a function that acts on domains can accept
variables of type `AnyDomain`, the union of `Domain` and `AsDomain`. The domain
itself is available as `domain(d)`:
```julia
foo(x, d::AnyDomain) = ...  # domain(d) is the domain object of d
```

In the example above the function `foo` is a generic function, which may have
multiple methods for variables of different types. If a function is meant to
operate exclusively on domains, then there is no need for the user to indicate
the intention with `AsDomain`. This may instead be reflected in the name of the function, such as `foo_domain`.

An example of this practice is the functionality of `union` in the
[DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.
The generic function `uniondomain(d1,d2)` returns a set which behaves as the
mathematical union of `d1` and `d2`. Both variables are interpreted as domains,
regardless of their types. The same result can be achieved using the general
syntax of the `∪` operator, which results in the call `union(d1, d2)`, but in
this case the intention has to be made explicit:
```julia
AsDomain(d1) ∪ AsDomain(d2) == uniondomain(d1, d2)
```

## More functionality with domains

Unions and intersections of domains, as well as many other set operations, are implemented generically in the
[DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.

Intervals inheriting from the `Domain` supertype are implemented in
[IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl).
