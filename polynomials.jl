struct Polynomial{T <: Number} <: Number
    coefs::Vector{T}
    degree::Int
    sym::Symbol

    function Polynomial(coefs::Union{Vector{T}, Tuple{Vararg{T}}}; sym::Symbol  = :𝕩) where T <: Number 
        ##trimming the polynomial
        while length(coefs) > 0 && coefs[end] == zero(T)
            coefs = coefs[begin:end-1]
        end

        new{T}(coefs, length(coefs) - 1, sym)
    end
end

import Base: getindex, convert, promote_rule, firstindex, lastindex, zero, one

getindex(p::Polynomial{T}, i::Int) where T <: Number = (0 ≤ i ≤ p.degree) ? p.coefs[i+1] : zero(T)

convert(::Type{Polynomial{T}}, x::Number) where {T} = Polynomial([convert(T, x)])
convert(::Type{Polynomial{T}}, p::Polynomial{S}) where {T, S <: Number} = Polynomial(convert.(T, p.coefs))

promote_rule(::Type{Polynomial{T}}, ::Type{S}) where {T, S <: Number} = Polynomial{promote_type(T, S)}

firstindex(p::Polynomial) = 0
lastindex(p::Polynomial) = p.degree

zero(::Type{Polynomial{T}}) where {T} = Polynomial([zero(T)])
zero(::Type{Polynomial})::Polynomial = Polynomial([0])

one(::Type{Polynomial{T}}) where {T} = Polynomial([one(T)])
one(::Type{Polynomial})::Polynomial = Polynomial([1])

Base.show(io::IO, p::Polynomial{T}) where T <: Number = print(io, join(reverse(["$(p[i])$(p.sym)^$i" for i ∈ 0:p.degree if p[i] != zero(T)]), " + "))

(p::Polynomial)(x) = evalpoly(x, p.coefs) 

x = Polynomial([zero(Int), one(Int)])
y = Polynomial([zero(Float64), one(Float64)]; sym = :𝕪)
z = Polynomial([zero(Complex), one(Complex)]; sym = :𝕫)
𝕩(::Type{T}) where {T} = Polynomial([zero(T), one(T)])

import Base: +, -, *, ÷, %, mod

+(p::Polynomial, q::Polynomial)::Polynomial = Polynomial([p[i] + q[i] for i ∈ 0:max(p.degree, q.degree)+1])
-(p::Polynomial, q::Polynomial)::Polynomial = Polynomial([p[i] - q[i] for i ∈ 0:max(p.degree, q.degree)+1])
*(p::Polynomial, q::Polynomial)::Polynomial = Polynomial([sum([p[j] * q[i - j] for j ∈ 0:i]) for i ∈ 0:(p.degree + q.degree)]) 
÷(p::Polynomial, q::Polynomial{T}) where T = let (δ, r, 𝚡) = (p.degree - q.degree, p[end]/q[end], 𝕩(T))
    try r = convert(T, r); catch; end
    δ < 0 ? zero(Polynomial) : r*𝚡^δ + ÷(p - q*r*𝚡^δ, q)
end
%(p::Polynomial, q::Polynomial)::Polynomial = p - q*(p ÷ q)
mod(p::Polynomial, q::Polynomial)::Polynomial = p % q

import Base: <, >, ==

<(p::Polynomial, q::Polynomial)::Bool = p.degree < q.degree
>(p::Polynomial, q::Polynomial)::Bool = p.degree > q.degree
==(p::Polynomial, q::Polynomial)::Bool = (p.degree == q.degree) && (p.coefs == q.coefs)

ν(p::Polynomial) = iszero(p) ? Inf : (findfirst(!iszero, p.coefs) - 1)
