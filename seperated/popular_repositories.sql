-- מוציא את כל השמות של הפאקגים והמאגרים שלהם
-- 

------------------------------------------------------------------------------------
-- QUERY: Most popular NPM repositories
-- DESCRIPTION: Proivde a list of the most popular packages' repositories names.
-- IDENTIFIER: [popular_repositories]
------------------------------------------------------------------------------------

SELECT files.repo_name AS repo_name
FROM (
    [packages_info]
) AS packages_info
JOIN [bigquery-public-data:github_repos.sample_files] AS files
ON packages_info.id = files.id
WHERE packages_info.package IN (
    SELECT package
    FROM (
        [popular-packages]
    )
)