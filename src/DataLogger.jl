__precompile__(true)

module DataLogger

import Logging: ConsoleLogger

import Base.CoreLogging: AbstractLogger, LogLevel, Debug, Warn, min_enabled_level, _min_enabled_level, handle_message, current_logger_for_env, shouldlog, logging_error, log_record_id
import Base: global_logger


struct DataRecorder <: AbstractLogger
    stream::IO
    min_level::LogLevel
    message_limits::Dict{Any,Int}
end
function DataRecorder(; stream::IO=stdout, level=Debug, message_limits=Dict{Any,Int}())
    DataRecorder(stream, level, message_limits)
end

min_enabled_level(logger::DataRecorder) = logger.min_level
shouldlog(logger::DataRecorder, level, _module, group, id) = get(logger.message_limits, id, 1) > 0


# code from julia/base/logging.jl  handle_message
function handle_message(logger::DataRecorder, level, message, _module, group, id,
                        filepath, line; maxlog=nothing, kwargs...)
    if maxlog != nothing && maxlog isa Integer
        remaining = get!(logger.message_limits, id, maxlog)
        logger.message_limits[id] = remaining - 1
        remaining > 0 || return
    end
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    levelstr = level == Warn ? "Warning" : string(level)
    msglines = split(chomp(string(message)), '\n')
    printstyled(iob, "Record", color=:green)
    printstyled(iob, " ( ", color=:yellow)
    printstyled(iob, _module, " ", basename(filepath))
    printstyled(iob, "#", color=:light_black)
    printstyled(iob, line)
    printstyled(iob, " )", color=:yellow)
    printstyled(iob, ' ', msglines[1], color=:light_cyan)
    #for i in 2:length(msglines)
    #    println(iob, "│ ", msglines[i])
    #end
    if length(kwargs) != 0
        print(iob, ' ')
    end
    for (key, val) in kwargs
        print(iob, "  ", key, " = ", val)
    end
    printstyled(iob, '\n')
    write(logger.stream, take!(buf))
    nothing
end


# code from julia/base/logging.jl  logmsg_code
# Generate code for logging macros
function logmsg_code2(_module, file, line, level, message, exs...)
    id = nothing
    group = nothing
    kwargs = Any[]
    for ex in exs
        if ex isa Expr && ex.head === :(=) && ex.args[1] isa Symbol
            k,v = ex.args
            if !(k isa Symbol)
                throw(ArgumentError("Expected symbol for key in key value pair `$ex`"))
            end
            k = ex.args[1]
            # Recognize several special keyword arguments
            if k == :_id
                # id may be overridden if you really want several log
                # statements to share the same id (eg, several pertaining to
                # the same progress step).  In those cases it may be wise to
                # manually call log_record_id to get a unique id in the same
                # format.
                id = esc(v)
            elseif k == :_module
                _module = esc(v)
            elseif k == :_line
                line = esc(v)
            elseif k == :_file
                file = esc(v)
            elseif k == :_group
                group = esc(v)
            else
                # Copy across key value pairs for structured log records
                push!(kwargs, Expr(:kw, k, esc(v)))
            end
        elseif ex isa Expr && ex.head === :...
            # Keyword splatting
            push!(kwargs, esc(ex))
        else
            # Positional arguments - will be converted to key value pairs
            # automatically.
            push!(kwargs, Expr(:kw, Symbol(ex), esc(ex)))
        end
    end
    # Note that it may be necessary to set `id` and `group` manually during bootstrap
    id !== nothing || (id = Expr(:quote, log_record_id(_module, level, exs)))
    group !== nothing || (group = Expr(:quote, Symbol(splitext(basename(file))[1])))
    quote
        level = $level
        std_level = convert(LogLevel, level)
        if std_level >= getindex(_min_enabled_level)
            group = $group
            _module = $_module
            logger = current_logger_for_env(std_level, group, _module)
            if !(logger === nothing)
                id = $id
                # Second chance at an early bail-out (before computing the message),
                # based on arbitrary logger-specific logic.
                if shouldlog(logger, level, _module, group, id)
                    file = $file
                    line = $line
                    try
                        msg = $(esc(message))
                        handle_message(logger, level, msg, _module, group, id, file, line; $(kwargs...))
                    catch err
                        logging_error(logger, level, _module, group, id, file, line, err)
                    end
                end
            end
        end
        nothing
    end
end

const Record = LogLevel(1)
macro record(message, exs...)
    logmsg_code2((Base.CoreLogging.@_sourceinfo)..., :Record,  message, exs...)
end

function read_stdout(f)
    oldout = stdout
    rdout, wrout = redirect_stdout()

    logger = DataRecorder(; stream=wrout)
    global_logger(logger)

    out = @async read(rdout, String)
    f()
    redirect_stdout(oldout)
    close(wrout)

    global_logger(ConsoleLogger())
    fetch(out)
end

end # module
