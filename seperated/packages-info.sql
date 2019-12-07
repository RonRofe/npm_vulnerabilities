------------------------------------------------------------------------------------
-- QUERY: All Packages Names and package.json files ID
-- DESCRIPTION: Provide list of all NPM packages in GitHub and their package.json
--              file ID.
-- IDENTIFIER: [packages_info]
------------------------------------------------------------------------------------

SELECT id, package
FROM JS(
    (
        SELECT id, content
        FROM [bigquery-public-data:github_repos.sample_contents]
        WHERE id IN (
            SELECT id FROM [bigquery-public-data:github_repos.sample_files]
            WHERE LAST(SPLIT(files.path, '/')) = "package.json"
        )
    ),
    id, content,
    "[
        {name: 'id', type: 'string'},
        {name: 'package', type: 'string'}
    ]",
    "function(rowData, emit) {
        try {
            content = JSON.parse(rowData.content);
            if (content.name) {
                emit({
                    id: rowData.id,
                    package: content.name
                });
            }
        } catch(e) {}
    }"
)