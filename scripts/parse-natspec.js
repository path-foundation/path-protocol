/* eslint no-restricted-syntax: off, no-plusplus: off */
/**
 * @license
 * MIT Licensed.
 * Copyright (c) 2018 OpenZeppelin.
 * https://github.com/OpenZeppelin/solidity-docgen/blob/master/src/util/parse-natspec.js
 */

/**
 * Parse the contents of a documentation comment to retrieve NatSpec
 * encoded tags. See the NatSpec specification for more details:
 * https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format
 */
module.exports = (docString, keepNewLine) => {
    if (docString === null || docString.length === 0) {
        return {};
    }
    const lines = docString.split('\n');
    const linesPerTag = {};
    let currentTag;
    let readingTag = false;
    const extraLines = [];
    for (let i = 0; i < lines.length; ++i) {
        const line = lines[i].trim();
        if (line.length > 0 && line[0] === '@') {
            const endOfTag = line.indexOf(' ');
            readingTag = true;
            currentTag = line.substr(1, endOfTag - 1);
            let content = line.substr(endOfTag + 1).trim();
            if (currentTag === 'param' && content.indexOf(' ') !== -1) {
                const paramName = content.substr(0, content.indexOf(' '));
                currentTag = `param:${paramName}`;
                content = content.substr(content.indexOf(' ') + 1).trim();
            } else if (currentTag === 'return' && content.indexOf(' ') !== -1) {
                const paramName = content.substr(0, content.indexOf(' '));
                currentTag = `return:${paramName}`;
                content = content.substr(content.indexOf(' ') + 1).trim();
            }
            linesPerTag[currentTag] = [content];
        } else if (readingTag) {
            linesPerTag[currentTag].push(line);
        } else {
            extraLines.push(line);
        }
    }
    const natspecTags = {};
    for (const [tag, linesOfTag] of Object.entries(linesPerTag)) {
        natspecTags[tag] = linesOfTag.join(keepNewLine ? '\n' : ' ');
    }
    if (extraLines.length > 0) {
        natspecTags.extra = extraLines.join(keepNewLine ? '\n' : ' ');
    }
    return natspecTags;
};
