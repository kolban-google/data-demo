# BigQuery Snapshots and Clones
## Snapshots
In this demo we will illustrate BigQuery snapshots.

1. Go to the BigQuery console.
2. Go to the `sales_ds` dataset.
3. Select the `sales` table.
4. Click the **SNAPSHOT** button in the menu.
5. Click **SAVE**.


Now we will see that there is a new snapshot table called `sales-<DATE_TIME>`.

Look at the details of the snapshot table in the console and see that it has an icon that indicates that it is a snapshot.  In the Details panel, we will also see Base Table Info including:

* Base Table ID
* Snapshot time

Now let's update some data.

1. Query the snapshot table.
2. Insert a new row in the base table.

```
INSERT sales_ds.sales VALUES
  ('2023-10-28', 1, 'Green Widget', 9, 1.00, 9.00)
```
3. Query the base table and see that the new row **is** in the table.
3. Query the snapshot table and see that the new row is **not** in there.

What this shows is that we have taken a snapshot (copy) of the table.

Let's restore the table.

1. Show the details of the snapshot in the BigQuery console.
2. Select **RESTORE** to restore the table providing `sales` as the target table name.
3. Query the `sales` table and show that the previously inserted row is no longer present.

## Clones
Now we will look at clones.

1. Run the following DDL:

```
CREATE TABLE sales_ds.sales_clone CLONE sales_ds.sales;
```

2. See that a new table called `sales_clone` has been created.  You won't see any visual indication that this is a clone by way of a distinct icon.  However, if we look at the details of the table we will see that it contains Base Table information showing which table it was derived from.