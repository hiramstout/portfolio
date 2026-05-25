-- returns most recent ping, and the most recent starting from 5 minutes ago
SELECT time_stamp AS `TimeStamp`, refresh_alive AS `RefreshAlive`,
       previous_showrates_alive AS `PreviousShowratesAlive`, showrates_alive AS `ShowratesAlive`
FROM Showrate_Data.`script-status-pings`
WHERE
    (time_stamp = (SELECT MAX(time_stamp)
                   FROM Showrate_Data.`script-status-pings` sub
                   WHERE (TIMESTAMP_SUB(CURRENT_TIMESTAMP, INTERVAL 5 MINUTE)
                       > sub.time_stamp))) OR
    (time_stamp = (SELECT MAX(time_stamp)
                   FROM Showrate_Data.`script-status-pings`))
ORDER BY time_stamp DESC
