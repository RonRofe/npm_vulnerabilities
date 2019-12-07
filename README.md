# NPM Packages Vulnerabilities Finder

A Google BigQuery project which takes all GitHub's most popular NPM packages and extract all their vulnerabilities (in commits).  
The queries are running on the sample tables for avoiding high costs, which means most of the data in each table used is not linked to the others. Therefore, the result of the queries will be empty tables.  
In order to test it on the origin tables and get results, change the tables names.