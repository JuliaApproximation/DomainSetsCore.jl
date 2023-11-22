[![Build Status](https://github.com/JuliaApproximation/DomainSetsCore.jl/workflows/CI/badge.svg)](https://github.com/JuliaApproximation/DomainSetsCore.jl/actions)
[![Coverage](https://codecov.io/gh/JuliaApproximation/DomainSetsCore.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaApproximation/DomainSetsCore.jl)

# DomainSetsCore.jl
An interface package for working with domains as continuous sets of elements.

Examples of domains may be geometric sets such as intervals and triangles,
or the complex plane without the real line. However, domains are not limited to geometry. A domain could also be a collection of vectors or arrays, such as the
set of all orthogonal `3x3` matrices.

Existing types may add the interpretation of being a domain by implementing the
domain interface. They gain the ability to interact with other domains.

## The domain interface

### The `in` function

A domain is a set of elements that is possibly continuous. Continuous sets are
defined mathematically, not by an exhaustive list of their elements. In practice membership of the set is defined by the implementation of `in`. The function
call `in(x, domain)` evaluates to true if the domain contains an element `y`
such that `y == x`.

### The `domaineltype` function

The defining mathematical condition of a continuous set might be satisfied by
variables of different types. Still, the interface defines the `domaineltype`
of a domain. It is a valid type for elements of the set.

Functions that generate elements of the domain should generate elements
of that type. As a consequence, for finite sets such as `AbstractArray`s or `AbstractSet`s, the `domaineltype` agrees with the `eltype` of that set. For
intervals on the real line, the `domaineltype` might be `Float64`. When there is
no clear candidate the `domaineltype` might simply be `Any`.

### Minimal formal interface

The domain interface is formally summarised in the following table:

| Required methods | Brief description |
| ---------------- | ----------------- |
| `in(x, d)` | Returns `true` when `x` is an element of the domain, `false` otherwise |
| `DomainStyle(d)` | Returns `IsDomain()` if `d` implements this interface |

Optional methods include:

| Important optional methods | Default definition | Brief description
| --- | --- | --- |
| `domaineltype(d)` | `eltype(d)` | Returns a valid type for elements of the domain |

Several extensions of this minimal interface are defined in the [DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.


## Domains as mathematical sets

A domain behaves as much as possible like the mathematical set it represents, irrespective of its type. Thus, for example, two domains should be considered
equal if their membership functions agree.

It is not always possible to realize this intended behaviour in practice. Indeed
it may be difficult to discover automatically whether two domains are equal,
especially when their types are different. Still, the principle serves as a
design goal.


## The Domain supertype and DomainStyle trait

This package defines the abstract type `Domain{T}` of continuous sets with
`domaineltype` equal to `T`. No concrete domain types are defined in this
package.

The package also defines the trait `DomainStyle`. Any type can declare to
implement the domain interface by defining
```julia
DomainSetsCore.DomainStyle(d::MyDomain) = IsDomain()
```
`Number`'s, `AbstractArray`'s and `AbstractSet`'s are declared to be domains in
this package.

## Using the domain interface in practice with `AsDomain`

With the exception of subtypes of `Domain`, the set of types implementing the
domain interface is not based on a common abstract supertype. Functions that are
intended to manipulate domains may simply omit the type of the domain in the
function definition. However, functions defined in other packages can not be
extended to work for domains using dispatch only, as there is no common type to
dispatch on. For that reason this package defines the `AsDomain` reference.

In the absence of function ownership, the practice of domain references requires
active intent both by users and by developers. For a user, passing `AsDomain(d)`
to a function indicates that `d` is to be treated as a domain. For a developer,
the implementation `foo(d::AsDomain)` may be used to extend the functionality
of `foo` to domains.

Note that `AsDomain(d)` is not in itself a domain, it is merely a reference. The developer of `foo(d::AsDomain)` or of `foo(d::AnyDomain)` may use `domain(d)` to
access the domain object. Here, `AnyDomain` is the union of `AsDomain` and
`Domain`.

### Example usage

An example of this practice is the functionality of `union` in the
[DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.
The generic function `uniondomain(d1,d2)` returns a set which behaves as the
mathematical union of the sets `d1` and `d2`. Both variables are interpreted as
domains, regardless of their types.

A user wanting to use the standard `∪` syntax to form the union of domains has
to make this intention explicit by writing `AsDomain(d1) ∪ AsDomain(d2)`.

A developer may make the `∪` syntax more accessible to users as follows. As soon
as one of `d1` or `d2` is a `Domain` or a reference to a domain, the call to
`union` can safely be interpreted as the union of domains. Thus, a developer may
write:
```julia
union(d1::Anydomain, d2) = uniondomain(domain(d1), d2)
union(d1, d2::AnyDomain) = uniondomain(d1, domain(d2))
union(d1::AnyDomain, d2::AnyDomain) = uniondomain(domain(d1),domain(d2))
```
These definitions are safe in the sense that there is no ambiguity and no
possible clash with any other definition of `union(d1,d2)` in other packages.


## Incompatible element types

In principle, the function `in(x, domain)` should not throw an exception even
if the types seem mathematically nonsensical. In that case, the correct return
value is `false`. This mimicks the behaviour of `in` for finite sets in Julia:
```julia
julia> in(rand(3,3), 1:3)
false
```
Indeed, a `3x3` matrix is not equal to any of the numbers `1`, `2` or `3`. It
is simply not a member of the set, even if the comparison to members of the
set is not sensible.


## More functionality with domains

Unions and intersections of domains, as well as many other set operations, are implemented generically in the
[DomainSets.jl](https://github.com/JuliaApproximation/DomainSets.jl) package.

Intervals inheriting from the `Domain` supertype are implemented in
[IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl).
