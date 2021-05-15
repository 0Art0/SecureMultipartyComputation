getval(::Type{Val{x}}) where {x} = x

struct Quot{T, Q} <: T where {T <: Number, Q <: Val}
    a::T
    
    Quot(a::T, q::T) where {T <: Number} = iszero(q) ? error("Division by zero") : new{T, Val{q}}(mod(a, q))
end

modulus(q::Quot{T, Q}) where{T <: Number, Q <: Val} = getval(Q)

import Base:zero, one, inv, +, -, *, /, \, %, mod

zero(::Type{Quot{T, Q}}) where {T <: Number, Q <: Val} = Quot(zero(T), getval(Q))
one(::Type{Quot{T, Q}}) where {T <: Number, Q <: Val} = Quot(one(T), getval(Q))

for op ∈ (:+, :-, :*)
    @eval $op(x::Quot{T, Q}, y::Quot{T, Q}) where {T <: Number, Q <: Val} = Quot($op(x.a, y.a), getval(Q))
end

inv(x::Quot{T,Q}) where {T <: Number, Q <: Val} = let (gcd, b) = GCD(x.a, getval(Q); bezout = true); @assert gcd == 1; Quot(b[end], getval(Q)); end

/(x::Quot{T, Q}, y::Quot{T, Q}) where {T <: Number, Q <: Val} = x * inv(y)

\(x::Quot{T, Q}, y::Quot{T, Q}) where {T <: Number, Q <: Val} = inv(x) * y

%(x::Quot{T, Q}, y::Quot{T, Q}) where {T <: Number, Q <: Val} = x.a % y.a

mod(x::Quot{T, Q}, y::Quot{T, Q}) where {T <: Number, Q <: Val} = x % y 

import Base: convert, promote_rule

convert(::Type{Quot{T, Q}}, x::Number) where {T, Q <: Val} = Quot(convert(T, x), getval(Q))
convert(::Type{Quot{T, Q}}, y::Quot{S, Q}) where {Q <: Val, T, S <: Number} = Quot(convert(T, y.a), getval(Q))

promote_rule(::Type{Quot{T, Q}}, ::Type{S}) where {Q <: Val, T, S <: Number} = Quot{promote_type(T, S), Q}

Base.show(io::IO, x::Quot{T, Q}) where {T <: Number, Q <: Val} = print(io, "$(x.a)  mod  $(getval(Q))")

Base.rand(::Type{Quot{T, Q}}) where {T <: Number, Q <: Val} = Quot(rand(1:getval(Q)), getval(Q))
Base.rand(::Type{Quot{T, Q}}, n::Int) where {T <: Number, Q <: Val} = [rand(Quot{T, Q}) for _ ∈ 1:n]

function GCD(p::T, q::T; bezout = true) where {T <: Number}
    a, b = ( p >= q ? (p, q) : (q, p) ) .|> copy
    bez, out = [1, 0], [0, 1]

    while !iszero(b) 
        q, r = divrem(a, b)
        
        bez, out = out, bez - q.*out 
	a, b = b, r
    end

    bezout ? (a, bez) : a
end
