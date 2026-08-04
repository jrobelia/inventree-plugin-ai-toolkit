import { describe, it, expect } from 'vitest';

/**
 * Example frontend unit test using Vitest.
 *
 * Replace this with tests for your plugin's utility functions and hooks.
 */

function add(a: number, b: number): number {
  return a + b;
}

describe('example utility', () => {
  it('adds two numbers', () => {
    expect(add(1, 2)).toBe(3);
  });
});
