-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlResolveForFile

-- noinspection SqlNoDataSourceInspectionForFile

SELECT
    contact_phone AS ContactPhoneNumber,
    time_updated AS EventTimestamp,
    talkdesk_phone_number AS TalkdeskPhoneNumber,
    interaction_id AS InteractionID
FROM Talkdesk.`live-call-events` parent
WHERE EXTRACT(DATE FROM time_updated)>=DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND
    ( (interaction_type="missed") OR (interaction_type="abandoned") ) AND
    ( SELECT child.interaction_id FROM Talkdesk.`callbacks-queued` child WHERE
        child.interaction_id=parent.interaction_id
        AND EXTRACT(DATE FROM event_timestamp)>=DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY ) ) IS NULL AND
    ( SELECT MAX(child.time_updated) FROM Talkdesk.`live-call-events` child WHERE
        parent.time_updated<child.time_updated AND child.interaction_type != "missed"
        AND child.interaction_type != "abandoned" AND child.event_type="Inbound Interaction Call Enters Queue") IS NULL