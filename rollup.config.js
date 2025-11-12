import typescript from '@rollup/plugin-typescript';
import { string } from 'rollup-plugin-string';

const config = {
  input: 'feed-focus/src/intercept.ts',
  output: {
    file: 'extension/social_cleaner/content.js',
    format: 'iife',
    name: 'SocialCleaner'
  },
  plugins: [
    typescript({
      tsconfig: 'feed-focus/tsconfig.json',
      sourceMap: false
    }),
    string({
      include: '**/*.css'
    })
  ]
};

export default config;
