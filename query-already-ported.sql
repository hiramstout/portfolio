SELECT date_updated AS `DateUpdated`,
       count(1) AS `ScheduledAppointments`
FROM `call-center-data-331917`.Marketing_Acuity.acuity_webhooks
WHERE date_updated<="2022-04-04" AND event_type="scheduled"
GROUP BY date_updated
ORDER BY date_updated
