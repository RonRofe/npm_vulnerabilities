SELECT repo_name, commit, subject, message
FROM [bigquery-public-data:github_repos.sample_commits]
WHERE commits.repo_name IN (
    SELECT files.repo_name AS repo_name
    FROM (
        SELECT id, package
        FROM JS(
            (
                SELECT id, content
                FROM [bigquery-public-data:github_repos.sample_contents]
                WHERE id IN (
                    SELECT id FROM [bigquery-public-data:github_repos.sample_files]
                    WHERE RIGHT(path, 12) = "package.json"
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
    ) AS packages_info
    JOIN [bigquery-public-data:github_repos.sample_files] AS files
    ON packages_info.id = files.id
    WHERE packages_info.package IN (
        SELECT package
        FROM (
            SELECT package, COUNT(*) as imports
            FROM JS(
                (
                    SELECT content
                    FROM [bigquery-public-data:github_repos.sample_contents]
                    WHERE id IN (
                        SELECT id FROM [bigquery-public-data:github_repos.sample_files]
                        WHERE RIGHT(path, 12) = "package.json"
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
        )
    )
)
AND (
    REGEXP_EXTRACT(subject, r"(vuln | XSS | remote scripts | injection | escape | http | https | HTTP response splitting | Cross site scripting | FTP bounce attack | validation | password | token)") IS NOT NULL
    OR REGEXP_EXTRACT(message, r"(vuln | XSS | remote scripts | injection | escape | http | https | HTTP response splitting | Cross site scripting | FTP bounce attack | password | token)") IS NOT NULL
)
