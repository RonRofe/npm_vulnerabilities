------------------------------------------------------------------------------------
-- QUERY: Most Popular NPM packages
-- DESCRIPTION: Return a list of the first 100 most popular NPM packages in GitHub.
--              Most popular package is defined as the package which has the largest
--              number of other packages that depend on it.
-- IDENTIFIER: [popular_packages]
------------------------------------------------------------------------------------

SELECT package, COUNT(*) as imports
FROM JS(
    (
        SELECT content
        FROM [bigquery-public-data:github_repos.sample_contents]
        WHERE id IN (
            SELECT id FROM [bigquery-public-data:github_repos.sample_files]
            WHERE LAST(SPLIT(files.path, '/')) = "package.json"
        )
    ),
    content,
    "[{ name: 'package', type: 'string'}]",
    "function(rowData, emit) {
        try {
            content = JSON.parse(rowData.content);
            if (content.dependencies) {
                Object.keys(content.dependencies).forEach((package) => {
                    emit({ package: package });
                });
            }
        } catch(e) {}     
    }"
)
GROUP BY package
ORDER BY imports DESC
LIMIT 100
