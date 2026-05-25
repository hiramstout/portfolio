WITH callbacks_still_unaddressed AS (WITH unaddressed AS (SELECT MAX(time_updated) AS max_time,
                                                                 contact_phone
                                                          FROM Talkdesk.`live-call-events` parent
                                                          WHERE (SELECT MAX(sub.time_updated)
                                                                 FROM Talkdesk.`live-call-events` sub
                                                                 WHERE parent.contact_phone = sub.contact_phone
                                                                   AND sub.contact_phone IS NOT NULL
                                                                   AND sub.event_type = "Inbound Interaction Call Enters Queue") = time_updated
                                                          GROUP BY contact_phone),
                                          callbacks AS (SELECT *
                                                        FROM Talkdesk.`live-call-events` parent
                                                        WHERE (SELECT DISTINCT interaction_id
                                                               FROM Talkdesk.`live-call-events` sub
                                                               WHERE event_category = "direct"
                                                                 AND sub.interaction_id = parent.interaction_id) IS NOT NULL)
                                     SELECT *
                                     FROM callbacks
                                              LEFT OUTER JOIN unaddressed
                                                              ON unaddressed.contact_phone = callbacks.contact_phone
                                     WHERE (unaddressed.contact_phone IS NULL
                                         OR unaddressed.max_time < callbacks.time_updated)
                                       AND (call_disposition = "Voicemail" OR call_disposition IS NULL))
SELECT calls.contact_phone_number AS `ContactPhoneNumber`,
       calls.talkdesk_phone_number AS `TalkdeskPhoneNumber`,
       calls.call_id AS `InteractionId`,
       calls.start_at AS `EventTimestamp`
FROM talkdesk_reporting.calls calls
         LEFT OUTER JOIN callbacks_still_unaddressed unaddressed
                         ON calls.call_id = unaddressed.interaction_id
WHERE unaddressed.interaction_id IS NOT NULL
  AND calls.talk_time <= 40
  AND (SELECT COUNT(*)
       FROM talkdesk_reporting.calls sub
       WHERE sub.contact_phone_number = calls.contact_phone_number) < 2
  AND TIMESTAMP_ADD(start_at, INTERVAL 1 HOUR ) < CURRENT_TIMESTAMP
ORDER BY calls.start_at DESC
