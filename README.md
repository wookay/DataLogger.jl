DataLogger
==========

|  **Build Status**                                               |
|:---------------------------------------------------------------:|
|  [![][travis-img]][travis-url]  [![][codecov-img]][codecov-url] |


```julia
using DataLogger
output = DataLogger.read_stdout() do
    println("hello")
end

output == "hello\n"
```


[travis-img]: https://api.travis-ci.org/wookay/DataLogger.jl.svg?branch=master
[travis-url]: https://travis-ci.org/wookay/DataLogger.jl

[codecov-img]: https://codecov.io/gh/wookay/DataLogger.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/wookay/DataLogger.jl/branch/master
