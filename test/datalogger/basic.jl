module test_datalogger_basic

using DataLogger

logger = Base.global_logger()

output = DataLogger.read_stdout() do
    println("hello")
end

using Test
@test output == "hello\n"

using Logging
@test logger isa Logging.ConsoleLogger

end # module test_datalogger_basic
