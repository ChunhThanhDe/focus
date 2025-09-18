module.exports = {
  root: true,
  env: {
    browser: true,
    es2020: true,
    webextensions: true,
    node: true
  },
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    '@typescript-eslint/recommended-requiring-type-checking'
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    project: './tsconfig.json'
  },
  plugins: [
    '@typescript-eslint'
  ],
  rules: {
    // TypeScript specific rules
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'warn',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/prefer-const': 'error',
    '@typescript-eslint/no-non-null-assertion': 'warn',
    
    // General rules
    'no-console': 'off', // Allow console for extension debugging
    'prefer-const': 'error',
    'no-var': 'error',
    'object-shorthand': 'error',
    'prefer-template': 'error',
    
    // Chrome extension specific
    'no-undef': 'off' // TypeScript handles this
  },
  ignorePatterns: [
    'dist/**/*',
    'node_modules/**/*',
    '*.js' // Ignore JS files in root (like this config)
  ],
  globals: {
    chrome: 'readonly'
  }
};