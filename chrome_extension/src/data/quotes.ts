import { BuiltinQuote } from '../types';

const BUILTIN_QUOTES: BuiltinQuote[] = [
  {
    id: 'quote_1',
    text: 'The best way to take care of the future is to take care of the present moment.',
    author: 'Thich Nhat Hanh',
    category: 'mindfulness'
  },
  {
    id: 'quote_2',
    text: 'You are what you do, not what you say you\'ll do.',
    author: 'Carl Jung',
    category: 'action'
  },
  {
    id: 'quote_3',
    text: 'The cave you fear to enter holds the treasure you seek.',
    author: 'Joseph Campbell',
    category: 'courage'
  },
  {
    id: 'quote_4',
    text: 'What we plant in the soil of contemplation, we shall reap in the harvest of action.',
    author: 'Meister Eckhart',
    category: 'contemplation'
  },
  {
    id: 'quote_5',
    text: 'The present moment is the only time over which we have dominion.',
    author: 'Thich Nhat Hanh',
    category: 'mindfulness'
  },
  {
    id: 'quote_6',
    text: 'Concentrate all your thoughts upon the work at hand. The sun\'s rays do not burn until brought to a focus.',
    author: 'Alexander Graham Bell',
    category: 'focus'
  },
  {
    id: 'quote_7',
    text: 'The successful warrior is the average man with laser-like focus.',
    author: 'Bruce Lee',
    category: 'focus'
  },
  {
    id: 'quote_8',
    text: 'It is during our darkest moments that we must focus to see the light.',
    author: 'Aristotle',
    category: 'perseverance'
  },
  {
    id: 'quote_9',
    text: 'The art of being wise is knowing what to overlook.',
    author: 'William James',
    category: 'wisdom'
  },
  {
    id: 'quote_10',
    text: 'Wherever you are, be there totally.',
    author: 'Eckhart Tolle',
    category: 'presence'
  },
  {
    id: 'quote_11',
    text: 'The quieter you become, the more able you are to hear.',
    author: 'Rumi',
    category: 'mindfulness'
  },
  {
    id: 'quote_12',
    text: 'Focus on being productive instead of busy.',
    author: 'Tim Ferriss',
    category: 'productivity'
  },
  {
    id: 'quote_13',
    text: 'The key to success is to focus our conscious mind on things we desire not things we fear.',
    author: 'Brian Tracy',
    category: 'success'
  },
  {
    id: 'quote_14',
    text: 'Lack of direction, not lack of time, is the problem. We all have twenty-four hour days.',
    author: 'Zig Ziglar',
    category: 'direction'
  },
  {
    id: 'quote_15',
    text: 'The most important thing in life is to stop saying \'I wish\' and start saying \'I will\'. Consider nothing impossible, then treat possibilities as probabilities.',
    author: 'Charles Dickens',
    category: 'action'
  },
  {
    id: 'quote_16',
    text: 'Your work is going to fill a large part of your life, and the only way to be truly satisfied is to do what you believe is great work.',
    author: 'Steve Jobs',
    category: 'work'
  },
  {
    id: 'quote_17',
    text: 'The way to get started is to quit talking and begin doing.',
    author: 'Walt Disney',
    category: 'action'
  },
  {
    id: 'quote_18',
    text: 'Innovation distinguishes between a leader and a follower.',
    author: 'Steve Jobs',
    category: 'innovation'
  },
  {
    id: 'quote_19',
    text: 'Life is what happens to you while you\'re busy making other plans.',
    author: 'John Lennon',
    category: 'life'
  },
  {
    id: 'quote_20',
    text: 'The future belongs to those who believe in the beauty of their dreams.',
    author: 'Eleanor Roosevelt',
    category: 'dreams'
  }
];

export function getBuiltinQuotes(): BuiltinQuote[] {
  return BUILTIN_QUOTES;
}

export function getQuoteById(id: string): BuiltinQuote | undefined {
  return BUILTIN_QUOTES.find(quote => quote.id === id);
}

export function getQuotesByCategory(category: string): BuiltinQuote[] {
  return BUILTIN_QUOTES.filter(quote => quote.category === category);
}

export function getRandomBuiltinQuote(): BuiltinQuote {
  const randomIndex = Math.floor(Math.random() * BUILTIN_QUOTES.length);
  return BUILTIN_QUOTES[randomIndex];
}