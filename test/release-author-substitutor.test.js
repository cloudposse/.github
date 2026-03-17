'use strict';

const { describe, it, before } = require('node:test');
const assert = require('node:assert/strict');
const {
  DEFAULT_LLM_USERS,
  globToRegex,
  isLLMUser,
  extractPRReferences,
  substituteLLMAuthors,
} = require('../src/release-author-substitutor');

describe('DEFAULT_LLM_USERS', () => {
  it('is a non-empty array', () => {
    assert.ok(Array.isArray(DEFAULT_LLM_USERS));
    assert.ok(DEFAULT_LLM_USERS.length > 0);
  });

  it('includes github-copilot[bot]', () => {
    assert.ok(DEFAULT_LLM_USERS.includes('github-copilot[bot]'));
  });

  it('includes copilot', () => {
    assert.ok(DEFAULT_LLM_USERS.includes('copilot'));
  });

  it('includes devin-ai-integration[bot]', () => {
    assert.ok(DEFAULT_LLM_USERS.includes('devin-ai-integration[bot]'));
  });
});

describe('globToRegex', () => {
  it('matches exact string with no wildcards', () => {
    const re = globToRegex('copilot');
    assert.ok(re.test('copilot'));
    assert.ok(!re.test('xcopilotx'));
    assert.ok(!re.test('copilot-extra'));
  });

  it('matches strings with leading wildcard', () => {
    const re = globToRegex('*bot]');
    assert.ok(re.test('github-copilot[bot]'));
    assert.ok(re.test('[bot]'));
    assert.ok(!re.test('github-actions'));
  });

  it('matches strings with trailing wildcard', () => {
    const re = globToRegex('github-copilot*');
    assert.ok(re.test('github-copilot[bot]'));
    assert.ok(re.test('github-copilot'));
    assert.ok(!re.test('github-actions[bot]'));
  });

  it('matches strings with surrounding wildcards', () => {
    const re = globToRegex('*copilot*');
    assert.ok(re.test('github-copilot[bot]'));
    assert.ok(re.test('copilot'));
    assert.ok(re.test('my-copilot-assistant'));
    assert.ok(!re.test('githubbot'));
  });

  it('escapes special regex characters in the pattern', () => {
    const re = globToRegex('github-copilot[bot]');
    assert.ok(re.test('github-copilot[bot]'));
    // Should NOT match with arbitrary characters in place of [bot]
    assert.ok(!re.test('github-copilotXbotY'));
  });

  it('handles multiple wildcards', () => {
    const re = globToRegex('github*copilot*');
    assert.ok(re.test('github-copilot[bot]'));
    assert.ok(re.test('github_copilot'));
    assert.ok(!re.test('copilot-github'));
  });
});

describe('isLLMUser', () => {
  describe('with default LLM users list', () => {
    it('returns true for github-copilot[bot]', () => {
      assert.ok(isLLMUser('github-copilot[bot]'));
    });

    it('returns true for copilot', () => {
      assert.ok(isLLMUser('copilot'));
    });

    it('returns true for devin-ai-integration[bot]', () => {
      assert.ok(isLLMUser('devin-ai-integration[bot]'));
    });

    it('returns false for a regular human user', () => {
      assert.ok(!isLLMUser('octocat'));
      assert.ok(!isLLMUser('alice'));
      assert.ok(!isLLMUser('bob'));
    });

    it('returns false for dependabot (not in default LLM list)', () => {
      assert.ok(!isLLMUser('dependabot[bot]'));
    });

    it('is case-insensitive', () => {
      assert.ok(isLLMUser('GITHUB-COPILOT[BOT]'));
      assert.ok(isLLMUser('Copilot'));
      assert.ok(isLLMUser('GitHub-Copilot[Bot]'));
    });
  });

  describe('with custom LLM users list', () => {
    it('matches usernames in the custom list', () => {
      const customList = ['my-ai-bot', 'custom-llm'];
      assert.ok(isLLMUser('my-ai-bot', customList));
      assert.ok(isLLMUser('custom-llm', customList));
    });

    it('does not match usernames from the default list when custom list is provided', () => {
      const customList = ['my-ai-bot'];
      assert.ok(!isLLMUser('github-copilot[bot]', customList));
    });

    it('supports glob patterns in custom list', () => {
      const withGlob = ['*copilot*'];
      assert.ok(isLLMUser('github-copilot[bot]', withGlob));
      assert.ok(isLLMUser('copilot-assistant', withGlob));
      assert.ok(isLLMUser('my-copilot', withGlob));
      assert.ok(!isLLMUser('octocat', withGlob));
    });

    it('supports prefix glob patterns', () => {
      const withGlob = ['devin-*'];
      assert.ok(isLLMUser('devin-ai-integration[bot]', withGlob));
      assert.ok(!isLLMUser('github-copilot[bot]', withGlob));
    });

    it('is case-insensitive with glob patterns', () => {
      const withGlob = ['*COPILOT*'];
      assert.ok(isLLMUser('github-copilot[bot]', withGlob));
    });
  });
});

describe('extractPRReferences', () => {
  it('extracts a single PR reference', () => {
    const body = 'Some feature @github-copilot[bot] (#123)';
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 1);
    assert.strictEqual(refs[0].author, 'github-copilot[bot]');
    assert.strictEqual(refs[0].prNumber, 123);
    assert.strictEqual(refs[0].fullMatch, '@github-copilot[bot] (#123)');
  });

  it('extracts multiple PR references', () => {
    const body = [
      'Feature A @alice (#100)',
      'Feature B @github-copilot[bot] (#101)',
      'Feature C @bob (#102)',
    ].join('\n');
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 3);
    assert.strictEqual(refs[0].author, 'alice');
    assert.strictEqual(refs[0].prNumber, 100);
    assert.strictEqual(refs[1].author, 'github-copilot[bot]');
    assert.strictEqual(refs[1].prNumber, 101);
    assert.strictEqual(refs[2].author, 'bob');
    assert.strictEqual(refs[2].prNumber, 102);
  });

  it('returns an empty array when there are no PR references', () => {
    const body = 'No PR references here';
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 0);
  });

  it('handles the HTML change-template format from release-drafter', () => {
    const body = `<details>
  <summary>Add new feature @github-copilot[bot] (#42)</summary>
  Some body text
</details>`;
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 1);
    assert.strictEqual(refs[0].author, 'github-copilot[bot]');
    assert.strictEqual(refs[0].prNumber, 42);
  });

  it('handles a full realistic release notes body', () => {
    const body = `## 🚀 Enhancements

<details>
  <summary>Add feature X @github-copilot[bot] (#10)</summary>
  Feature description
</details>

<details>
  <summary>Refactor Y @alice (#11)</summary>
  Refactor description
</details>

## 🐛 Bug Fixes

<details>
  <summary>Fix bug Z @devin-ai-integration[bot] (#12)</summary>
  Bug fix description
</details>`;
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 3);
    assert.strictEqual(refs[0].author, 'github-copilot[bot]');
    assert.strictEqual(refs[1].author, 'alice');
    assert.strictEqual(refs[2].author, 'devin-ai-integration[bot]');
  });

  it('handles usernames with hyphens and dots', () => {
    const body = '@some-user.name (#99)';
    const refs = extractPRReferences(body);
    assert.strictEqual(refs.length, 1);
    assert.strictEqual(refs[0].author, 'some-user.name');
    assert.strictEqual(refs[0].prNumber, 99);
  });
});

describe('substituteLLMAuthors', () => {
  it('replaces a single LLM author with a human assignee', () => {
    const body = 'Add feature @github-copilot[bot] (#123)';
    const subs = [{ prNumber: 123, oldAuthor: 'github-copilot[bot]', newAuthor: 'alice' }];
    const result = substituteLLMAuthors(body, subs);
    assert.strictEqual(result, 'Add feature @alice (#123)');
  });

  it('replaces multiple LLM authors with different human assignees', () => {
    const body = [
      'Feature A @github-copilot[bot] (#100)',
      'Feature B @github-copilot[bot] (#101)',
    ].join('\n');
    const subs = [
      { prNumber: 100, oldAuthor: 'github-copilot[bot]', newAuthor: 'alice' },
      { prNumber: 101, oldAuthor: 'github-copilot[bot]', newAuthor: 'bob' },
    ];
    const result = substituteLLMAuthors(body, subs);
    assert.ok(result.includes('@alice (#100)'));
    assert.ok(result.includes('@bob (#101)'));
    assert.ok(!result.includes('@github-copilot[bot]'));
  });

  it('does not modify entries for non-LLM authors', () => {
    const body = [
      'Feature A @alice (#100)',
      'Feature B @github-copilot[bot] (#101)',
    ].join('\n');
    const subs = [{ prNumber: 101, oldAuthor: 'github-copilot[bot]', newAuthor: 'bob' }];
    const result = substituteLLMAuthors(body, subs);
    assert.ok(result.includes('@alice (#100)'));
    assert.ok(result.includes('@bob (#101)'));
    assert.ok(!result.includes('@github-copilot[bot]'));
  });

  it('returns the original body when no substitutions are provided', () => {
    const body = 'Feature @alice (#100)';
    const result = substituteLLMAuthors(body, []);
    assert.strictEqual(result, body);
  });

  it('handles the HTML change-template format from release-drafter', () => {
    const body = `<details>
  <summary>Add feature @github-copilot[bot] (#42)</summary>
  Body text
</details>`;
    const subs = [{ prNumber: 42, oldAuthor: 'github-copilot[bot]', newAuthor: 'reviewer' }];
    const result = substituteLLMAuthors(body, subs);
    assert.ok(result.includes('@reviewer (#42)'));
    assert.ok(!result.includes('@github-copilot[bot]'));
  });

  it('only replaces the matching PR number, not other occurrences', () => {
    // Same bot authored two PRs; only PR #100 should be substituted
    const body = [
      'Feature A @github-copilot[bot] (#100)',
      'Feature B @github-copilot[bot] (#101)',
    ].join('\n');
    const subs = [{ prNumber: 100, oldAuthor: 'github-copilot[bot]', newAuthor: 'alice' }];
    const result = substituteLLMAuthors(body, subs);
    assert.ok(result.includes('@alice (#100)'));
    assert.ok(result.includes('@github-copilot[bot] (#101)'));
  });

  it('handles a full realistic release notes body', () => {
    const body = `## 🚀 Enhancements

<details>
  <summary>Add feature X @github-copilot[bot] (#10)</summary>
  Feature description
</details>

<details>
  <summary>Refactor Y @alice (#11)</summary>
  Refactor description
</details>

## 🐛 Bug Fixes

<details>
  <summary>Fix bug Z @devin-ai-integration[bot] (#12)</summary>
  Bug fix description
</details>`;
    const subs = [
      { prNumber: 10, oldAuthor: 'github-copilot[bot]', newAuthor: 'carol' },
      { prNumber: 12, oldAuthor: 'devin-ai-integration[bot]', newAuthor: 'dave' },
    ];
    const result = substituteLLMAuthors(body, subs);
    assert.ok(result.includes('@carol (#10)'));
    assert.ok(result.includes('@alice (#11)'));
    assert.ok(result.includes('@dave (#12)'));
    assert.ok(!result.includes('@github-copilot[bot]'));
    assert.ok(!result.includes('@devin-ai-integration[bot]'));
  });
});
