SELECT delivered_timestamp AS `DeliveredTimestamp`, severity AS `Severity`
FROM `call-center-data-331917`.`Showrate_Data`.`delivered-status-notifications`
ORDER BY delivered_timestamp DESC
LIMIT 1
