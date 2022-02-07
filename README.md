# Health Datasette

[Export new data](https://github.com/dogsheep/healthkit-to-sqlite#how-to-use)

`mv ~/Downloads/export.zip .`

`just build`

`just run`

[View graph](http://localhost:8001/healthkit?sql=with+trimmed+as+%28%0D%0A++select%0D%0A++++trim%28startDate%2C+%22+%2B0000%22%29+as+startDate%2C%0D%0A++++trim%28endDate%2C+%22+%2B0000%22%29+as+endDate%2C%0D%0A++++value%2C%0D%0A++++creationDate%0D%0A++from%0D%0A++++rDistanceWalkingRunning%0D%0A%29%2C%0D%0Afiltered+as+%28%0D%0A++select%0D%0A++++*%2C%0D%0A++++cast%28strftime%28%22%25w%22%2C+startDate%29+as+integer%29+as+week_day%2C%0D%0A++++cast%28strftime%28%22%25H%22%2C+startDate%29+as+integer%29+as+start_hour%2C%0D%0A++++cast%28strftime%28%22%25M%22%2C+startDate%29+as+integer%29+as+start_minute%2C%0D%0A++++cast%28strftime%28%22%25H%22%2C+endDate%29+as+integer%29+as+end_hour%2C%0D%0A++++strftime%28%22%25Y-%25m%22%2C+startDate%29+as+month%0D%0A++from%0D%0A++++trimmed%0D%0A++where%0D%0A++++startDate+%3E%3D+%222021-03-05%22%0D%0A--++++and+week_day+%3E%3D+1%0D%0A--++++and+week_day+%3C%3D+6%0D%0A--++++and+%28%0D%0A--++++++start_hour+%3E%3D+9%0D%0A--++++++or+end_hour+%3C+5%0D%0A--++++%29%0D%0A%29%0D%0Aselect%0D%0A++month%2C%0D%0A++round%28sum%28value%29%2C+2%29+as+km%0D%0Afrom%0D%0A++filtered%0D%0Awhere+month+is+not+null%0D%0Agroup+by%0D%0A++month#g.mark=bar&g.x_column=month&g.x_type=ordinal&g.y_column=km&g.y_type=quantitative)
