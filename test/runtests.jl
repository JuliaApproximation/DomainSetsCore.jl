using DomainSetsCore

using Test

struct InheritedDomain <: Domain{Int} end

struct InterfaceDomain end
DomainSetsCore.domaineltype(::InterfaceDomain) = Int
DomainSetsCore.DomainStyle(::Type{InterfaceDomain}) = IsDomain()

struct NonDomain end

d1 = InheritedDomain()
@test d1 isa Domain
@test eltype(d1) == Int
@test domaineltype(d1) == Int
@test domaineltype(AsDomain(d1)) == Int
@test DomainStyle(d1) == IsDomain()
@test checkdomain(d1) === d1
@test AsDomain(d1) === d1
@test domain(d1) === d1

d2 = InterfaceDomain()
@test !(d2 isa Domain)
@test domaineltype(d2) == Int
@test domaineltype(AsDomain(d2)) == Int
@test DomainStyle(d2) == IsDomain()
@test AsDomain(d2) isa DomainSetsCore.DomainRef
@test domaineltype(AsDomain(d2)) == domaineltype(d2)
@test domain(AsDomain(d2)) == d2
@test checkdomain(d2) === d2
@test checkdomain(AsDomain(d2)) === d2

d3 = NonDomain()
@test !(d3 isa Domain)
@test DomainStyle(d3) == NotDomain()
@test_throws ErrorException checkdomain(d3)

@test DomainStyle(2.0) == IsDomain()
@test DomainStyle([1,2]) == IsDomain()
@test DomainStyle(Set([1,2])) == IsDomain()

s = "string"
@test domaineltype(s) == eltype(s)
