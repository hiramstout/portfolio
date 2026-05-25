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

WITH status_times AS (
		    SELECT MAX(event_timestamp) AS recent_timestamp, agent_email
    		FROM Talkdesk.`live-user-events`
    			WHERE current_status IS NOT NULL
		    	  AND EXTRACT(DATE FROM event_timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    		GROUP BY agent_email
		)
SELECT event_timestamp AS EventTimestamp,
    agent_email AS AgentEmail,
    current_status AS CurrentStatus
FROM Talkdesk.`live-user-events` parent
WHERE EXTRACT(DATE FROM event_timestamp)>=DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) AND
    event_timestamp=(SELECT recent_timestamp FROM status_times child WHERE child.agent_email=parent.agent_email) AND
    agent_email=(SELECT agent_email FROM status_times child WHERE child.recent_timestamp=parent.event_timestamp)
ORDER BY agent_email