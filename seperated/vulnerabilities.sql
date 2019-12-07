------------------------------------------------------------------------------------
-- QUERY: Vulnerabilities
-- DESCRIPTION: Return commits which have a vulnerabilities.
-- IDENTIFIER: [popular_repositories]
------------------------------------------------------------------------------------

SELECT repo_name, commit, subject, message
FROM [bigquery-public-data:github_repos.sample_commits]
WHERE commits.repo_name IN (
    [popular_repositories]
)
AND (
    REGEXP_EXTRACT(subject, r"(vuln | XSS | remote scripts | injection | escape | http | https | HTTP response splitting | Cross site scripting | FTP bounce attack | validation | password | token)") IS NOT NULL
    OR REGEXP_EXTRACT(message, r"(vuln | XSS | remote scripts | injection | escape | http | https | HTTP response splitting | Cross site scripting | FTP bounce attack | password | token)") IS NOT NULL
)