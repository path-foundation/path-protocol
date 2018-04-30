module.exports.getLogArgument = (logs, eventName, argumentName) => {
    const log = logs.find(l => l.event === eventName);
    if (!log || !(argumentName in log.args)) {
        throw Error(`Argument "${argumentName}" does not exist in the log "${eventName}"`);
    }

    return log ? log.args[argumentName] : null;
};
