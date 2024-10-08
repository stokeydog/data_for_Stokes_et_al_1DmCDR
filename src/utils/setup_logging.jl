using Logging

function setup_logging()
    global_logger(ConsoleLogger(stderr, Logging.Info))
    return
end