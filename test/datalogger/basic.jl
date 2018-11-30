module test_datalogger_basic

using DataLogger

output = DataLogger.read_stdout() do
    println("hello")
end

using Test
@test output == "hello\n"

end # module test_datalogger_basic
