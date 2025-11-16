const typescript = require('@rollup/plugin-typescript');
const { nodeResolve } = require('@rollup/plugin-node-resolve');
const commonjs = require('@rollup/plugin-commonjs');
const replace = require('@rollup/plugin-replace');
const copy = require('rollup-plugin-copy');

const isProduction = process.env.NODE_ENV === 'production';

const getPlugins = (includeCopy = false) => {
  const plugins = [
    replace({
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development'),
      preventAssignment: true
    }),
    nodeResolve({
      browser: true,
      preferBuiltins: false
    }),
    commonjs(),
    typescript({
      sourceMap: !isProduction,
      inlineSources: !isProduction
    })
  ];
  
  if (includeCopy) {
    plugins.push(
      copy({
        targets: [
          { src: 'src/manifest.json', dest: 'dist' },
          { src: 'src/icons/*', dest: 'dist/icons' },
          { src: 'src/styles/*', dest: 'dist/styles' },
          { src: '../web/chrome_extension/**/*', dest: 'dist' }
        ],
        copyOnce: true
      })
    );
  }
  
  return plugins;
};

const baseConfig = {
  external: ['chrome']
};

module.exports = [

  
  // Content Scripts - Facebook
  {
    ...baseConfig,
    input: 'src/content/sites/facebook.ts',
    output: {
      file: 'dist/content/facebook.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - Twitter
  {
    ...baseConfig,
    input: 'src/content/sites/twitter.ts',
    output: {
      file: 'dist/content/twitter.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - Instagram
  {
    ...baseConfig,
    input: 'src/content/sites/instagram.ts',
    output: {
      file: 'dist/content/instagram.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - LinkedIn
  {
    ...baseConfig,
    input: 'src/content/sites/linkedin.ts',
    output: {
      file: 'dist/content/linkedin.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - Reddit
  {
    ...baseConfig,
    input: 'src/content/sites/reddit.ts',
    output: {
      file: 'dist/content/reddit.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - YouTube
  {
    ...baseConfig,
    input: 'src/content/sites/youtube.ts',
    output: {
      file: 'dist/content/youtube.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - GitHub
  {
    ...baseConfig,
    input: 'src/content/sites/github.ts',
    output: {
      file: 'dist/content/github.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Content Scripts - Hacker News
  {
    ...baseConfig,
    input: 'src/content/sites/hackernews.ts',
    output: {
      file: 'dist/content/hackernews.js',
      format: 'es',
      sourcemap: !isProduction
    },
    plugins: getPlugins()
  },
  
  // Background Service Worker
  {
    ...baseConfig,
    input: 'src/background/service-worker.ts',
    output: {
      file: 'dist/background/service-worker.js',
      format: 'iife',
      sourcemap: !isProduction
    },
    plugins: getPlugins(true)
  }
];