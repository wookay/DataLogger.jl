DataLogger
==========


- https://github.com/wookay/TestJulia07.jl/blob/master/test/broadcast/style.jl#L42

```julia
# ...snip...

using DataLogger
output = DataLogger.read_stdout() do

g  = G{Int,1}([5,6], "")
g2 = Float32.(g)
@info :g2 g2 isa G{Float32,1}

eval(quote

    @info :g3 $g2 .+ 1

    function Broadcast.broadcasted(::typeof(+), ::G{T,N}, ::Int) where {T,N}
        @info :broadcasted
    end

    @info :g5 $g2 .+ 1

end)

end
```

* output
```
Record ( Main style.jl#12 ) BroadcastStyle
Record ( Main style.jl#17 ) size
Record ( Main style.jl#22 ) similar   (T, N, ElType) = (Int64, 1, Float32)
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#33 ) setindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#33 ) setindex
Record ( Main style.jl#43 ) g2   g2 isa G{Float32, 1} = true
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#12 ) BroadcastStyle
Record ( Main style.jl#17 ) size
Record ( Main style.jl#22 ) similar   (T, N, ElType) = (Float32, 1, Float32)
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#33 ) setindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#33 ) setindex
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#17 ) size
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#28 ) getindex
Record ( Main style.jl#47 ) g3   Float32[5.0, 6.0] .+ 1 = Float32[6.0, 7.0]
Record ( Main style.jl#50 ) broadcasted
Record ( Main style.jl#53 ) g5   Float32[5.0, 6.0] .+ 1 = nothing
```
