const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');

module.exports = {
    ...jestConfig,
    modulePathIgnorePatterns: ['<rootDir>/.localdevserver'],
    moduleFileExtensions: ['js', 'html'],
    moduleNameMapper: {
        '^c/(.*)$': '<rootDir>/force-app/main/default/lwc/$1/$1',
        '^lightning/(.*)$': '<rootDir>/node_modules/@salesforce/sfdx-lwc-jest/src/lightning-stubs/$1/$1',
        '^lwc$': '<rootDir>/__mocks__/lwc.js',
    },
    testEnvironment: 'jsdom'
};
