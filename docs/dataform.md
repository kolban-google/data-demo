# Dataform

To demonstrate Dataform, do the following:

1. Go to BigQuery in the console

2. Open Dataform

3. Create a repository (+ CREATE REPOSITORY)

4. Supply a new Repository ID (eg. demo-<date>)

5. Supply a region (eg. us-central1)

6. Click Create

7. Click Go To Repositories

8. Drill into the new repository

9. Click CREATE DEVELOPMENT WORKSPACE

10. Supply a new Workspace ID (eg. dev1)

11. Click Create

12. Drill into the new Workspace

13. Click INITIALIZE WORKSPACE

14. Drill into definitions and delete:
    
    1. first_view.sqlx
    
    2. second_view.sqlx

15. Create sales.sqlx and include:
    
    ```
    config {
        type: "declaration",
        schema: "sales_ds"
    }
    ```
    
    

16. Create sales_day.sqlx and include:

```
config {
    type: "view",
    schema: "sales_ds"
}

SELECT
  date,
  COUNT(*) AS sales_count
FROM
  ${ref("sales")}
GROUP BY
  date
ORDER BY date DESC
```


