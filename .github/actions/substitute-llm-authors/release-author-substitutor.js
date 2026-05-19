'use strict';

/**
 * Default list of LLM/AI assistant usernames to detect in release notes.
 * These will be replaced with the PR's human assignee when generating release notes.
 * Supports exact match (case-insensitive) and glob patterns using '*'.
 */
const DEFAULT_LLM_USERS = [
  'github-copilot[bot]',
  'copilot',
  'devin-ai-integration[bot]',
  'amazon-q[bot]',
  'codeium[bot]',
];

/**
 * Converts a glob pattern (with * wildcards) to a RegExp that matches the full string.
 * @param {string} pattern - Glob pattern (case-insensitive, already lowercased)
 * @returns {RegExp}
 */
function globToRegex(pattern) {
  const regexStr = pattern
    .split('*')
    .map(s => s.replace(/[.+?^${}()|[\]\\]/g, '\\$&'))
    .join('.*');
  return new RegExp(`^${regexStr}$`);
}

/**
 * Checks whether a GitHub username matches an LLM/AI user pattern.
 * Matching is case-insensitive. Supports exact matches and glob patterns using '*'.
 *
 * @param {string} username - GitHub username to check
 * @param {string[]} [llmUsers] - List of LLM usernames or glob patterns.
 *   Defaults to DEFAULT_LLM_USERS when not provided.
 * @returns {boolean} True if the username matches any entry in the LLM users list
 */
function isLLMUser(username, llmUsers) {
  const users = llmUsers || DEFAULT_LLM_USERS;
  const norm = username.toLowerCase();
  return users.some(llmUser => {
    const nu = llmUser.toLowerCase();
    if (nu.includes('*')) {
      return globToRegex(nu).test(norm);
    }
    return norm === nu;
  });
}

/**
 * Extracts PR author and number references from a release notes body.
 * Matches patterns produced by the release-drafter change-template, e.g.:
 *   "@username (#123)"
 *
 * @param {string} body - Release notes body text
 * @returns {Array<{author: string, prNumber: number, fullMatch: string}>}
 */
function extractPRReferences(body) {
  const prPattern = /@([a-zA-Z0-9_.\-[\]]+)\s+\(#(\d+)\)/g;
  const matches = [];
  let match;
  while ((match = prPattern.exec(body)) !== null) {
    matches.push({
      fullMatch: match[0],
      author: match[1],
      prNumber: parseInt(match[2], 10),
    });
  }
  return matches;
}

/**
 * Substitutes LLM bot authors with human assignees in release notes.
 * Each substitution is targeted per-PR number so that multiple PRs from the
 * same bot can be attributed to different human assignees.
 *
 * @param {string} body - Release notes body text
 * @param {Array<{prNumber: number, oldAuthor: string, newAuthor: string}>} prSubstitutions
 * @returns {string} Updated release notes body
 */
function substituteLLMAuthors(body, prSubstitutions) {
  let updatedBody = body;
  for (const { prNumber, oldAuthor, newAuthor } of prSubstitutions) {
    const escapedAuthor = oldAuthor.replace(/[.+?^${}()|[\]\\]/g, '\\$&');
    const pattern = new RegExp(`@${escapedAuthor}(\\s+\\(#${prNumber}\\))`, 'g');
    updatedBody = updatedBody.replace(pattern, `@${newAuthor}$1`);
  }
  return updatedBody;
}

module.exports = {
  DEFAULT_LLM_USERS,
  globToRegex,
  isLLMUser,
  extractPRReferences,
  substituteLLMAuthors,
};
