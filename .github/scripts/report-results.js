const fs = require('fs');
const fsPromises = fs.promises;

const readSarif = async (path) => {
  try {
    await fsPromises.access(path, fsPromises.constants.F_OK);
    const sarif = await fsPromises.readFile(path, 'utf8');
    return JSON.parse(sarif);
  } catch {
    return null;
  }
}

const absoluteModulePath = (filepath, moduleDir) => {
  const segments = filepath.replace(/\\/g, '/').split('/').slice(0, -1);
  if (!segments.length) {
    return null;
  }

  return moduleDir === '.'
    ? segments[0]
    : segments[0] === moduleDir
      ? segments.join('/')
      : `${moduleDir}/${segments.join('/')}`;
};

const baseModulePath = (filepath, moduleDir) => {
  const normalized = filepath.replace(/\\/g, '/');
  return normalized.startsWith(moduleDir) ? normalized.slice(moduleDir.length + 1) : normalized;
};

const processSarif = (sarif, moduleDir) => {
  const results = sarif?.runs?.[0]?.results || [];
  return results.reduce((acc, { locations = [] }) => {
    const uri = locations[0]?.physicalLocation?.artifactLocation?.uri;
    const modulePath = uri && absoluteModulePath(uri, moduleDir);
    if (modulePath) {
      acc[modulePath] = (acc[modulePath] || 0) + 1;
    }
    return acc;
  }, {});
};

const addToolResults = (module, toolName, toolCounts) => {
  const issueCount = toolCounts?.[module.module] || 0;
  module[toolName] = toolCounts ? (issueCount === 0 ? 'passed' : 'failed') : 'skipped';
  module[`${toolName}_issues`] = issueCount;
};

const TRIVY_TOOL = 'trivy';
const SNYK_TOOL = 'snyk';

const STATUS_ICONS = { passed: '✅', failed: '❌', skipped: '⏭️' };

module.exports = async ({ github, context, core }) => {
  const moduleDir = process.env.MODULE_DIR;
  if (!moduleDir) {
    core.setFailed('MODULE_DIR environment variable is required');
    return;
  }

  // Read tftest results and initialize base results structure. The tftest
  // results are in JSONL format with each line containing a JSON object for a
  // module and its results. We pivot the results array into flat fields for
  // merging with SARIF results.
  const tftestResults = fs.readFileSync('tftest-results.json', 'utf8')
    .trim()
    .split('\n');

  const baseResults = tftestResults.map(line => {
    const { module, results = [] } = JSON.parse(line);
    return results.reduce((acc, { check, status }) =>
      ({ ...acc, [check]: status }),
      { module, linting: 'skipped' }
    );
  });

  // Read and process SARIF results for Trivy and Snyk. The module path is
  // extracted from the file paths in the SARIF results and the number of issues
  // per module is counted. This allows us to determine the status for each tool
  // based on whether any issues were found for that module. If the SARIF file
  // is missing, we mark the tool as 'skipped' for all modules.
  const trivySarif = await readSarif('trivy-results.sarif');
  const trivyResult = trivySarif && processSarif(trivySarif, moduleDir);

  const snykSarif = await readSarif('snyk-results.sarif');
  const snykResult = snykSarif && processSarif(snykSarif, moduleDir);

  baseResults.forEach(module => {
    addToolResults(module, TRIVY_TOOL, trivyResult);
    addToolResults(module, SNYK_TOOL, snykResult);
  });

  // Build the markdown table for the comment. Each row represents a module and
  // its results across the different checks. For the Trivy and Snyk columns, if
  // there are any issues found (status 'failed'), we include a link to the
  // Security tab with a query to filter results for that specific module and
  // tool. We also include a summary below the table with the total number of
  // modules, how many passed, and how many failed. If there are any security
  // findings, we add a section with instructions to view the details in the
  // Security tab.

  const repoOwner = context.repo.owner;
  const repoName = context.repo.repo;
  const issueNumber = context.issue.number;

  const getStatusCell = (module, status, issueCount, category) => {
    const icon = STATUS_ICONS[status] || '❓';
    const path = encodeURIComponent(baseModulePath(module, moduleDir));
    return status === 'failed' && issueCount > 0
      ? `${icon} [(${issueCount})](https://github.com/${repoOwner}/${repoName}/security/code-scanning?query=is%3Aopen+pr%3A${issueNumber}+tool%3A${category}+path%3A${path})`
      : icon;
  };

  const buildTableRow = ({ module, structure, formatting, validation, linting, trivy, trivy_issues, snyk, snyk_issues }) => {
    const columns = [
      getStatusCell(module, structure, 0, 'structure'),
      getStatusCell(module, formatting, 0, 'formatting'),
      getStatusCell(module, validation, 0, 'validation'),
      getStatusCell(module, linting, 0, 'linting'),
      getStatusCell(module, trivy, trivy_issues, TRIVY_TOOL),
      getStatusCell(module, snyk, snyk_issues, SNYK_TOOL),
    ];
    return `| \`${module}\` | ${columns.join(' | ')} |`;
  }

  const byName = (a, b) => a.module.localeCompare(b.module);

  const passedModules = baseResults.filter(r =>
    r.structure === 'passed' &&
    r.formatting === 'passed' &&
    r.validation === 'passed' &&
    r.trivy === 'passed' &&
    (r.snyk === 'passed' || r.snyk === 'skipped')
  ).length;

  const hasSecurityFindings = baseResults.some(r =>
    (r.trivy === 'failed' && r.trivy_issues > 0) ||
    (r.snyk === 'failed' && r.snyk_issues > 0)
  );

  const securitySection = hasSecurityFindings
    ? `\n\n### 🔍 Security Findings\n\nSecurity issues have been detected. Click the linked numbers in the trivy/Snyk columns above to view detailed findings in the [Security tab](https://github.com/${repoOwner}/${repoName}/security/code-scanning?query=is%3Aopen+pr%3A${issueNumber}).`
    : '';

  const output = `## Terraform Module Validation Results

| Module | Structure | Formatting | Validation | Linting | Trivy | Snyk |
|--------|-----------|------------|------------|---------|-------|------|
${baseResults.sort(byName).map(buildTableRow).join('\n')}

**Summary:** modules: ${baseResults.length}, passed: ${passedModules}, failed: ${baseResults.length - passedModules}${securitySection}

<!-- terraform-validation-summary -->`;

  // Check for existing comment by this bot to update, otherwise create new
  // comment with results. This ensures we don't spam the PR with multiple
  // comments on each run.
  const { data: comments } = await github.rest.issues.listComments({
    owner: repoOwner,
    repo: repoName,
    issue_number: issueNumber,
  });

  const existingComment = comments.find(c =>
    c.user.type === 'Bot' && c.body.includes('<!-- terraform-validation-summary -->')
  );

  const commentParams = {
    owner: repoOwner,
    repo: repoName,
    body: output,
  };

  existingComment
    ? await github.rest.issues.updateComment({ ...commentParams, comment_id: existingComment.id })
    : await github.rest.issues.createComment({ ...commentParams, issue_number: issueNumber });

  // Return the status overall status - if any module has a failure in core
  // categories, mark the check as failed.
  const hasFailed = baseResults.some(r =>
    r.structure === 'failed' ||
    r.formatting === 'failed' ||
    r.validation === 'failed'
  );

  if (hasFailed) {
    core.setFailed('One or more modules failed validation checks');
  }
};
