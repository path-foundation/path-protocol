const getLogArguments = (logs, eventName) => {
    const log = logs.find(l => l.event === eventName);
    if (!log) {
        throw Error(`Log event"${eventName}" doesn't exist`);
    }

    return log.args;
};

const getLogArgument = (logs, eventName, argumentName) => {
    const args = getLogArguments(logs, eventName);
    return args ? args[argumentName] : null;
};

module.exports = { getLogArguments, getLogArgument };
