package talkdesk

import (
	"encoding/json"
	"errors"
	"fmt"
	"time"
)

// Returns a copy of the client object. The purpose in having a method with no reason
// other than to return a copy of the client is to limit method autofill suggestions to
// a single API. This makes it easier to remember what you are looking for.
type ReportingRequest struct {
	client *Client
}

func (client *Client) NewReportingApiRequest() *ReportingRequest {
	reportClient := &ReportingRequest{client: client}
	return reportClient
}

// The enumerated report types available in the data-reports api library. Report types
// that have been commented out did not return any entries at the time of writing the
// client library
type ReportType int

const (
	Calls ReportType = iota
	AcwTimeData
	ContactOnlineTime
	Contacts
	HoldTimeData
	InboundContactVolume
	QualityManagementEvaluationAnalysis
	RingAttempts
	StudioFlowExecution
	TalkTimeData
	UserStatus
	UNKNOWN
	// CsatScore
	// Feedback
	// OutboundDialerCalls
)

func (report ReportType) String() string {
	switch report {
	case Calls:
		return "calls"
	case AcwTimeData:
		return "acw_time_data"
	case ContactOnlineTime:
		return "contact_online_time"
	case Contacts:
		return "contacts"
	case HoldTimeData:
		return "hold_time_data"
	case InboundContactVolume:
		return "inbound_contact_volume"
	case QualityManagementEvaluationAnalysis:
		return "qm_evaluation_analysis"
	case RingAttempts:
		return "ring_attempts"
	case StudioFlowExecution:
		return "studio_flow_execution"
	case TalkTimeData:
		return "talk_time_data"
	case UserStatus:
		return "user_status"
	case UNKNOWN:
		return "unknown report type"
	// case CsatScore:
	//     return "csat_score"
	// case Feedback:
	//     return "feedback"
	// case OutboundDialerCalls:
	//     return "outbound_dialer_calls"
	default:
		return "unknown report type"
	}
}

// ReportName, FromTime, and, ToTime are used in the JSON request body. ReportType is a
// path parameter.
type ExecuteReportRequest struct {
	ReportType ReportType
	ReportName string
	FromTime   time.Time
	ToTime     time.Time
}

// Local struct declaration used to marshall parameters into the request body
type timespanMarshaller struct {
	From string `json:"from"`
	To   string `json:"to"`
}
type executeReportMarshaller struct {
	Name     string             `json:"name"`
	Format   string             `json:"format"`
	Timespan timespanMarshaller `json:"timespan"`
}

// Used to un-marshall the response from the execute report api call as well as
// the get report status function
type executeReportResponse struct {
	Job struct {
		Id     string `json:"id"`
		Status string `json:"status"`
	}
}

// ExecuteReport:
func ExecuteReport[T GetReportsResponse](reportingClient *ReportingRequest, request ExecuteReportRequest,
	responsePointer T) error {

	var err error
	marshaller := executeReportMarshaller{
		Name:   request.ReportName,
		Format: `json`,
		Timespan: timespanMarshaller{
			From: request.FromTime.Format(time.RFC3339),
			To:   request.ToTime.Format(time.RFC3339),
		},
	}
	client := reportingClient.client
	t := reportsExecute
	p := &performHttpRequestParams{
		pathParamValues: []string{request.ReportType.String()},
		requestData:     marshaller,
		client:          client,
	}

	var matchingReportType ReportType
	switch any(responsePointer).(type) {
	case *AcwTimeReportResponse:
		matchingReportType = AcwTimeData
	case *CallsReportResponse:
		matchingReportType = Calls
	case *ContactOnlineTimeReportResponse:
		matchingReportType = ContactOnlineTime
	case *ContactsReportResponse:
		matchingReportType = Contacts
	case *HoldTimeReportResponse:
		matchingReportType = HoldTimeData
	case *InboundContactVolumeReportResponse:
		matchingReportType = InboundContactVolume
	case *RingAttemptsReportResponse:
		matchingReportType = RingAttempts
	case *StudioFlowExecutionReportResponse:
		matchingReportType = StudioFlowExecution
	case *TalkTimeDataReportResponse:
		matchingReportType = TalkTimeData
	case *UserStatusReportResponse:
		matchingReportType = UserStatus
	case *QaEvaluationAnalysisReportResponse:
		matchingReportType = QualityManagementEvaluationAnalysis
	default:
		matchingReportType = UNKNOWN
	}
	if request.ReportType != matchingReportType {
		return fmt.Errorf("response struct of report type %v provided for a %v report "+
			"- incorrect type provided", string(matchingReportType), string(request.ReportType))
	}

	data, err := client.performHttpRequest(t, p, nil)
	if err != nil {
		return fmt.Errorf("client.performHttpRequest(t, p, nil) %v\ntokenBase: %v",
			err, tokenRequestUrl)
	}
	if len(data) < 1 {
		return errors.New("client.performHttpRequest(t, p, nil): no data returned")
	}
	var response executeReportResponse
	if err = json.Unmarshal(data, &response); err != nil {
		return fmt.Errorf("json.Unmarshal(data, &responseUnmarhaller):\ndata: %v\nerror: %v",
			string(data), err)
	}
	if response.Job.Id == "" {
		return fmt.Errorf("no ID")
	}

	for {
		finished, data, _ := getReportStatus(client, response.Job.Id, request.ReportType)
		if err != nil {
			return fmt.Errorf("status, data, _ := response.CheckReportStatus() --- %v", err)
		} else if !finished {
			time.Sleep(time.Second * 2)
		} else {
			if err = unMarshallReportData[T](data, request.ReportType, responsePointer); err != nil {
				return err
			} else {
				break
			}
		}
	}

	if err := client.DeleteReport(response.Job.Id, request.ReportType); err != nil {
		return err
	}

	return nil
}

// The get report status api method will return a copy of the execute report response until
// it is finished, then will return the report itself. This function will unmarshall the
// response into the execute report response struct, and if it is empty will return the
// data back to the execute report function to be passed to the unMarshallReportData
// function for parsing.
func getReportStatus(client *Client, id string, report ReportType) (bool, []byte, error) {
	t := reportsCheckStatus
	p := &performHttpRequestParams{
		pathParamValues: []string{report.String(), id},
		requestData:     nil,
		client:          client,
	}

	response := executeReportResponse{}
	data, err := client.performHttpRequest(t, p, nil)
	if err != nil {
		return false, nil, err
	}
	if err = json.Unmarshal(data, &response); err != nil {
		return false, nil, err
	}

	if response.Job.Status == "" {
		return true, data, nil
	} else {
		return false, data, nil
	}
}

// Unmarshalls the data into the response struct. Also takes fields that are not automatically
// parsed by the encoding/json library (bool, times, and enums), outputs the field into a local
// struct type, and sets the values in the global structs
func unMarshallReportData[T GetReportsResponse](data []byte, reqType ReportType, response T) error {
	var err error

	// Different fields included in the talkdesk data reports api that can be interpreted as a
	// boolean.
	dataToBoolMap := map[string]bool{
		"Yes":   true,
		"No":    false,
		"IN":    true,
		"OUT":   false,
		"Warm":  true,
		"Blind": false,
	}

	// Parses data (returned from the getReportStatus function) into the user provided response
	// struct.
	if err = json.Unmarshal(data, response); err != nil {
		return fmt.Errorf("json.Unmarshal(data, response):\\nerror: %v", err)
	}

	// Unmarshals any fields that can be parsed into a more representative data type in go. Does
	// so with booleans, times, and enums. The response structs used for this can be found below
	// all the functions in this file.
	switch any(response).(type) {

	case *AcwTimeReportResponse:
		manualFields := acwTimeManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*AcwTimeReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*AcwTimeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StartedAt = parsedTime
			}
		}

	case *CallsReportResponse:
		manualFields := callsReportManualParser{}
		if err := json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*CallsReportResponse/" +
				"json.Unmarshal(*data, &manualFields)")
		}
		responseStruct := *any(response).(*CallsReportResponse)
		for i, manual := range manualFields.Entries {

			// Returns a CallType constant (enumerated field)
			responseStruct.Entries[i].Type = genCallReportCallType(manual.Type)
		}

	case *ContactOnlineTimeReportResponse:
		manualFields := contactOnlineTimeManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*ContactOnlineTimeReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*ContactOnlineTimeReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*ContactOnlineTimeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StartedAt = parsedTime
			}
		}

	case *ContactsReportResponse:
		manualFields := contactsManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*ContactsReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*ContactsReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.FinishedAt); err != nil {
				return fmt.Errorf("*(response).(*ContactsReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.FinishedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].FinishedAt = parsedTime
			}
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*ContactsReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].FinishedAt = parsedTime
			}
			if manual.ConnectedAt != nil {
				if parsedTime, err := time.Parse("2006-01-02 15:04:05", *manual.ConnectedAt); err != nil {
					return fmt.Errorf("*(response).(*ContactsReportResponse)/"+
						"time.Parse(\"2006-01-02 15:04:05\", manual.ConnectedAt) --- err=%v", err)
				} else {
					responseStruct.Entries[i].FinishedAt = parsedTime
				}
			}
			if manual.AnsweredAt != nil {
				if parsedTime, err := time.Parse("2006-01-02 15:04:05", *manual.AnsweredAt); err != nil {
					return fmt.Errorf("*(response).(*ContactsReportResponse)/"+
						"time.Parse(\"2006-01-02 15:04:05\", manual.AnsweredAt) --- err=%v", err)
				} else {
					responseStruct.Entries[i].FinishedAt = parsedTime
				}
			}

			// Bool parsing
			if parsedBool, ok := dataToBoolMap[manual.Callback]; ok {
				responseStruct.Entries[i].Callback = parsedBool
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.Callback]"+
					" returned not ok response: %v", manual.Callback)
			}
			if parsedBool, ok := dataToBoolMap[manual.Direction]; ok {
				responseStruct.Entries[i].IsInbound = parsedBool
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.Direction]"+
					" returned not ok response: %v", manual.Direction)
			}
			if manual.DisconnectedByAgent != nil {
				if parsedBool, ok := dataToBoolMap[*manual.DisconnectedByAgent]; ok {
					responseStruct.Entries[i].DisconnectedByAgent = &parsedBool
				} else {
					return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.DisconnectedByAgent] "+
						"returned not ok response: %v", *manual.DisconnectedByAgent)
				}
			}
			if parsedBool, ok := dataToBoolMap[manual.InsideBusinessHours]; ok {
				responseStruct.Entries[i].InsideBusinessHours = parsedBool
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.InsideBusinessHours]"+
					" returned not ok response: %v", manual.InsideBusinessHours)
			}
			if parsedBool, ok := dataToBoolMap[manual.InsideServiceLevel]; ok {
				responseStruct.Entries[i].InsideServiceLevel = parsedBool
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.InsideServiceLevel]"+
					" returned not ok response: %v", manual.InsideServiceLevel)
			}
			if manual.LastContact != nil {
				if parsedBool, ok := dataToBoolMap[*manual.LastContact]; ok {
					responseStruct.Entries[i].LastContact = &parsedBool
				} else {
					return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.LastContact]"+
						" returned not ok response: %v", *manual.LastContact)
				}
			}

			// Manual parser consolidates transfer_in_type and transfer_out_type into the IsWarmTransfer field,
			// since the fields are mutually exclusive. If one is nil, the other is not. Sets the field in the
			// global struct to a boolean.
			if parsedBool, ok := dataToBoolMap[manual.TransferIn]; ok {
				responseStruct.Entries[i].TransferIn = parsedBool
				if manual.TransferInType != nil {
					if parsedBool, ok := dataToBoolMap[*manual.TransferInType]; ok {
						responseStruct.Entries[i].IsWarmTransfer = &parsedBool
					} else {
						return fmt.Errorf("parsedBool, ok := dataToBoolMap[*manual.TransferInType]"+
							" returned not ok response: %v", *manual.TransferInType)
					}
				}
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.TransferIn]"+
					" returned not ok response: %v", manual.TransferIn)
			}
			if parsedBool, ok := dataToBoolMap[manual.TransferOut]; ok {
				responseStruct.Entries[i].TransferOut = parsedBool
				if manual.TransferOutType != nil {
					if parsedBool, ok := dataToBoolMap[*manual.TransferOutType]; ok {
						responseStruct.Entries[i].IsWarmTransfer = &parsedBool
					} else {
						return fmt.Errorf("parsedBool, ok := dataToBoolMap[*manual.TransferOutType]"+
							" returned not ok response: %v", *manual.TransferOutType)
					}
				}
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.TransferOut]"+
					" returned not ok response: %v", manual.TransferOut)
			}
			if parsedBool, ok := dataToBoolMap[manual.WithinServiceLevelThreshold]; ok {
				responseStruct.Entries[i].WithinServiceLevelThreshold = parsedBool
			} else {
				return fmt.Errorf("parsedBool, ok := dataToBoolMap[manual.WithinServiceLevelThreshold]"+
					" returned not ok response: %v", manual.WithinServiceLevelThreshold)
			}

			// Returns a ContactType constant (enumerated field)
			responseStruct.Entries[i].ContactType = genContactType(manual.ContactType)
		}

	case *HoldTimeReportResponse:
		manualFields := holdTimeManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*HoldTimeReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*HoldTimeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StartedAt = parsedTime
			}
		}

	case *InboundContactVolumeReportResponse:
		manualFields := inboundContactVolumeManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*InboundContactVolumeReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*InboundContactVolumeReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*InboundContactVolumeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StartedAt = parsedTime
			}
		}

	case *RingAttemptsReportResponse:
		manualFields := ringAttemptsManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*RingAttemptsReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*RingAttemptsReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if manual.RingFinishedAtTime != "" {

				if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.RingFinishedAtTime); err != nil {
					return fmt.Errorf("*(response).(*RingAttemptsReportResponse)/"+
						"time.Parse(\"2006-01-02 15:04:05\", manual.RingFinishedAtTime) --- err=%v", err)
				} else {
					responseStruct.Entries[i].RingFinishedAtTime = &parsedTime
				}
			}
			if manual.RingStartedAtTime != "" {
				if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.RingStartedAtTime); err != nil {
					return fmt.Errorf("*(response).(*RingAttemptsReportResponse)/"+
						"time.Parse(\"2006-01-02 15:04:05\", manual.RingStartedAtTime) --- err=%v", err)
				} else {
					responseStruct.Entries[i].RingStartedAtTime = &parsedTime
				}
			}
		}

	case *StudioFlowExecutionReportResponse:
		manualFields := studioFlowExecutionManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*StudioFlowExecutionReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*StudioFlowExecutionReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if manual.StudioFlowExecutionsAggregatedFlowExecutionFinishedTime != "" {
				if parsedTime, err := time.Parse("2006-01-02 15:04:05",
					manual.StudioFlowExecutionsAggregatedFlowExecutionFinishedTime); err != nil {

					return fmt.Errorf("*(response).(*StudioFlowExecutionReportResponse)/"+
						"time.Parse(\"2006-01-02 15:04:05\", "+
						"manual.StudioFlowExecutionsAggregatedFlowExecutionFinishedTime) --- err=%v", err)
				} else {
					responseStruct.Entries[i].StudioFlowExecutionsAggregatedFlowExecutionFinishedTime = &parsedTime
				}
			}
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.Timestamp); err != nil {
				return fmt.Errorf("*(response).(*StudioFlowExecutionReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.Timestamp) --- err=%v", err)
			} else {
				responseStruct.Entries[i].Timestamp = parsedTime
			}
		}

	case *TalkTimeDataReportResponse:
		manualFields := talkTimeDataManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*TalkTimeDataReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*TalkTimeDataReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StartedAt); err != nil {
				return fmt.Errorf("*(response).(*TalkTimeDataReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StartedAt = parsedTime
			}
		}

	case *UserStatusReportResponse:
		manualFields := userStatusManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*UserStatusReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*UserStatusReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StatusStartAt); err != nil {
				return fmt.Errorf("*(response).(*ContactOnlineTimeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StatusStartAt = parsedTime
			}
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.StatusEndAt); err != nil {
				return fmt.Errorf("*(response).(*ContactOnlineTimeReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.StartedAt) --- err=%v", err)
			} else {
				responseStruct.Entries[i].StatusEndAt = parsedTime
			}
		}

	case *QaEvaluationAnalysisReportResponse:
		manualFields := qaEvaluationAnalysisManualParser{}
		if err = json.Unmarshal(data, &manualFields); err != nil {
			return fmt.Errorf("*QaEvaluationAnalysisReportResponse/"+
				"json.Unmarshal(*data, &manualFields) --- Err=%v", err)
		}
		responseStruct := *any(response).(*QaEvaluationAnalysisReportResponse)
		for i, manual := range manualFields.Entries {

			// Time parsing
			if parsedTime, err := time.Parse("2006-01-02 15:04:05", manual.EvaluationTime); err != nil {
				return fmt.Errorf("*(response).(*QaEvaluationAnalysisReportResponse)/"+
					"time.Parse(\"2006-01-02 15:04:05\", manual.EvaluationTime) --- err=%v", err)
			} else {
				responseStruct.Entries[i].EvaluationTime = parsedTime
			}

			// Returns a ContactType constant (enumerated field)
			responseStruct.Entries[i].QuestionType = genQaEvaluationAnalysisQuestionType(manual.QuestionType)
		}

	}

	return nil
}

// Struct declaration and function definition for the List Reports of Type data-reports api method
type ListReportsOfTypeRequest struct {
	ReportType ReportType
	PageNumber *int
	PerPage    *int
}
type ListReportsOfTypeResponse struct {
	Total    int `json:"total"`
	Count    int `json:"count"`
	Embedded struct {
		Jobs []struct {
			Id       string `json:"id"`
			Name     string `json:"name"`
			Status   string `json:"status"`
			Format   string `json:"format"`
			Timespan struct {
				From time.Time `json:"from"`
				To   time.Time `json:"to"`
			} `json:"timespan"`
			Links struct {
				Self struct {
					Href string `json:"href"`
				} `json:"self"`
				Files struct {
					Href string `json:"href"`
				} `json:"files"`
			} `json:"_links"`
		} `json:"jobs"`
	} `json:"_embedded"`
	Links struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Next struct {
			Href string `json:"href"`
		} `json:"next"`
	} `json:"_links"`
}

func (repRequest ReportingRequest) ListAllReportsOfType(request ListReportsOfTypeRequest,
	response *ListReportsOfTypeResponse) error {
	var err error
	var queryParamValueMap map[string]string
	t := reportsListFromType
	client := repRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListAllReportsOfType(...)"
		return errors.New(s)
	}

	if request.ReportType.String() == UNKNOWN.String() {
		err = errors.New("unknown report type provided")
		return err
	}
	q := &queryParamValues{}
	if request.PageNumber != nil {
		q.intValues["page"] = *request.PageNumber
	}
	if request.PerPage != nil {
		q.intValues["per_page"] = *request.PerPage
	}
	p := &performHttpRequestParams{
		pathParamValues: []string{request.ReportType.String()},
		requestData:     nil,
		client:          client,
	}

	data, err := client.performHttpRequest(t, p, q)
	if err != nil {
		return fmt.Errorf("client.performHttpRequest(t, p, queryParamValueMap):"+
			"\nt: %v\np: %vqueryParamValueMap: %v\nerror: %v", t, p, queryParamValueMap, err)
	}
	if err = json.Unmarshal(data, response); err != nil {
		return fmt.Errorf("json.Unmarshal(data, response):\ndata: %v\nerror: %v", data, err)
	}

	return nil
}

// Deletes report by the report type and report id, called automatically by ExecuteReport after
// completion as well.
func (client *Client) DeleteReport(id string, report ReportType) error {
	var err error
	t := reportsDelete
	p := &performHttpRequestParams{
		pathParamValues: []string{report.String(), id},
		requestData:     nil,
		client:          client,
	}

	if _, err = client.performHttpRequest(t, p, nil); err != nil {
		return fmt.Errorf("client.performHttpRequest(t, p, nil):"+
			"\nt: %v\np: %v\nerror: %v", t, p, err)
	}

	return nil
}

// Struct type definitions for the report responses, and any local structs used to manually un-marshal response
// fields into other data types. Fields that did not return data in any entries are commented out at the
// bottom of the declaration
type GetReportsResponse interface {
	*AcwTimeReportResponse |
		*CallsReportResponse |
		*ContactOnlineTimeReportResponse |
		*ContactsReportResponse |
		*HoldTimeReportResponse |
		*InboundContactVolumeReportResponse |
		*RingAttemptsReportResponse |
		*StudioFlowExecutionReportResponse |
		*TalkTimeDataReportResponse |
		*UserStatusReportResponse |
		*QaEvaluationAnalysisReportResponse
}

// ACW Time report structs
type acwTimeManualParser struct {
	Entries []struct {
		StartedAt string `json:"started_at"`
	} `json:"entries"`
}
type AcwTimeReportResponse struct {
	Entries []struct {
		AgentId             string    `json:"agent_id"`               // EXAMPLE: 6216ad50e3eed13d4d561502
		RingGroupsName      string    `json:"ring_groups_name"`       // EXAMPLE: seattle csr
		TeamId              *string   `json:"team_id"`                // EXAMPLE: a1a2c8e573d54b01a1a7c52792ce065d
		StartedAt           time.Time `json:"-"`                      // MANUALLY PARSED
		AcwTimeSecondsTotal int       `json:"acw_time_seconds_total"` // EXAMPLE: 9
	} `json:"entries"`
	Total int `json:"total"`
}

// Calls report structs and enum declaration
type CallsReportCallTypes int

const (
	CallsTypeNewField CallsReportCallTypes = iota
	CallsTypeAbandoned
	CallsTypeInbound
	CallsTypeMissed
	CallsTypeOutbound
	CallsTypeOutboundMissed
	CallsTypeShortAbandoned
	CallsTypeVoicemail
)

func (t CallsReportCallTypes) String() string {
	switch t {
	case CallsTypeNewField:
		return "New Enumerated Field - Please check field value manually"
	case CallsTypeAbandoned:
		return "abandoned"
	case CallsTypeInbound:
		return "inbound"
	case CallsTypeMissed:
		return "missed"
	case CallsTypeOutbound:
		return "outbound"
	case CallsTypeOutboundMissed:
		return "outbound_missed"
	case CallsTypeShortAbandoned:
		return "short_abandoned"
	case CallsTypeVoicemail:
		return "voicemail"
	default:
		return ""
	}
}
func genCallReportCallType(s string) CallsReportCallTypes {
	switch s {
	case "abandoned":
		return CallsTypeAbandoned
	case "inbound":
		return CallsTypeInbound
	case "missed":
		return CallsTypeMissed
	case "outbound":
		return CallsTypeOutbound
	case "outbound_missed":
		return CallsTypeOutboundMissed
	case "short_abandoned":
		return CallsTypeShortAbandoned
	case "voicemail":
		return CallsTypeVoicemail
	default:
		return CallsTypeNewField
	}
}

type callsReportManualParser struct {
	Entries []struct {
		Type string `json:"type"`
	} `json:"entries"`
}
type CallsReportResponse struct {
	Total   int    `json:"total"`
	Type    string `json:"type"`
	Version string `json:"version"`
	Entries []struct {
		CallId                   string               `json:"call_id"`                     // EXAMPLE: 66da31bdbfed4a9299f0e04ed4525c42
		Callsid                  string               `json:"callsid"`                     // EXAMPLE: CAeb9fdf035d4779c740bac0202af06d0d
		ContactPhoneNumber       string               `json:"contact_phone_number"`        // EXAMPLE: +13605880640
		RingGroups               string               `json:"ring_groups"`                 // EXAMPLE: seattle csr
		TalkdeskPhoneNumber      string               `json:"talkdesk_phone_number"`       // EXAMPLE: +12066709000
		HandlingUserEmail        *string              `json:"handling_user_email"`         // EXAMPLE: karla@edmedicalclinic.com
		HandlingUserId           *string              `json:"handling_user_id"`            // EXAMPLE: 628272e7136cda5e7af8a5ba
		HandlingUserName         *string              `json:"handling_user_name"`          // EXAMPLE: Karla Prieto
		RecordingUrl             *string              `json:"recording_url"`               // EXAMPLE: https://api.talkdeskapp.com/calls/66da31bdbfed4a9299f0e04ed4525c42/recordings
		TalkdeskPhoneDisplayName *string              `json:"talkdesk_phone_display_name"` // EXAMPLE: Seattle [Bay Side (PT)]
		TeamId                   *string              `json:"team_id"`                     // EXAMPLE: a1a2c8e573d54b01a1a7c52792ce065d
		TeamName                 *string              `json:"team_name"`                   // EXAMPLE: Team GT
		UserEmail                *string              `json:"user_email"`                  // EXAMPLE: benelson.murray@edmedicalclinic.com
		UserId                   *string              `json:"user_id"`                     // EXAMPLE: 61fd420e9f93cd05ed86b6fe
		UserName                 *string              `json:"user_name"`                   // EXAMPLE: Benjamin Nelson
		Type                     CallsReportCallTypes `json:"-"`                           // ENUM: inbound, abandoned, short_abandoned, outbound, voicemail, missed
		StartAt                  time.Time            `json:"start_at"`
		EndAt                    time.Time            `json:"end_at"`
		AbandonTime              int                  `json:"abandon_time"`       // EXAMPLE: 19
		HoldTime                 int                  `json:"hold_time"`          // EXAMPLE: 35
		TalkTime                 int                  `json:"talk_time"`          // EXAMPLE: 10
		TotalRingingTime         int                  `json:"total_ringing_time"` // EXAMPLE: 13
		TotalTime                int                  `json:"total_time"`         // EXAMPLE: 30
		UserVoiceRating          int                  `json:"user_voice_rating"`  // EXAMPLE: 0
		WaitTime                 int                  `json:"wait_time"`          // EXAMPLE: 15
		IsCallForwarding         bool                 `json:"is_call_forwarding"`
		IsCallbackFromQueue      bool                 `json:"is_callback_from_queue"`
		IsExternalTransfer       bool                 `json:"is_external_transfer"`
		IsIfNoAnswer             bool                 `json:"is_if_no_answer"`
		IsInBusinessHours        bool                 `json:"is_in_business_hours"`
		IsTransfer               bool                 `json:"is_transfer"`
		// CsatScore                *int      `json:"csat_score"`
		// CsatSurveyTime           string    `json:"csat_survey_time"`
		// DispositionCode          *string   `json:"disposition_code"`
		// IsMoodPrompted           *bool     `json:"is_mood_prompted"`
		// IvrOptions               string    `json:"ivr_options"`
		// Notes                    *string   `json:"notes"`
		// Mood                     string    `json:"mood"`
	} `json:"entries"`
}

// Contact Online Time report structs
type contactOnlineTimeManualParser struct {
	Entries []struct {
		StartedAt string `json:"started_at"`
	} `json:"entries"`
}
type ContactOnlineTimeReportResponse struct {
	Entries []struct {
		AgentId               string    `json:"agent_id"`                // EXAMPLE: 61fd44ed9f93cd05ed86b70a
		TeamId                *string   `json:"team_id"`                 // EXAMPLE: 5cf884c4325a4486bd977865ece145ee
		StartedAt             time.Time `json:"-"`                       // MANUALLY PARSED
		StatusDurationSeconds int       `json:"status_duration_seconds"` // EXAMPLE: 1
	} `json:"entries"`
	Total int `json:"total"`
}

// Contact report structs and enum declaration
type ContactType int

const (
	ContactTypeUnknown ContactType = iota
	ContactTypeAbandoned
	ContactTypeAnswered
	ContactTypeConnected
	ContactTypeMissed
	ContactTypeNotConnected
	ContactTypeShortAbandoned
)

func (t ContactType) String() string {
	switch t {
	case ContactTypeUnknown:
		return "New Enumerated Field - Please check field value manually"
	case ContactTypeAbandoned:
		return "Abandoned"
	case ContactTypeAnswered:
		return "Answered"
	case ContactTypeConnected:
		return "Connected"
	case ContactTypeMissed:
		return "Missed"
	case ContactTypeNotConnected:
		return "Not ContactTypeConnected"
	case ContactTypeShortAbandoned:
		return "Short ContactTypeAbandoned"
	default:
		return ""
	}
}
func genContactType(response string) ContactType {
	switch response {
	case "Abandoned":
		return ContactTypeAbandoned
	case "Answered":
		return ContactTypeAnswered
	case "Connected":
		return ContactTypeConnected
	case "Missed":
		return ContactTypeMissed
	case "Not ContactTypeConnected":
		return ContactTypeNotConnected
	case "Short ContactTypeAbandoned":
		return ContactTypeShortAbandoned
	default:
		return ContactTypeUnknown
	}
}

type contactsManualParser struct {
	Entries []struct {
		Callback                    string  `json:"callback"`
		ContactType                 string  `json:"contact_type"`
		Direction                   string  `json:"direction"`
		FinishedAt                  string  `json:"finished_at"`
		InsideBusinessHours         string  `json:"inside_business_hours"`
		InsideServiceLevel          string  `json:"inside_service_level"`
		StartedAt                   string  `json:"started_at"`
		TransferIn                  string  `json:"transfer_in"`
		TransferOut                 string  `json:"transfer_out"`
		WithinServiceLevelThreshold string  `json:"within_service_level_threshold"`
		AnsweredAt                  *string `json:"answered_at"`
		ConnectedAt                 *string `json:"connected_at"`
		DisconnectedByAgent         *string `json:"disconnected_by_agent"`
		LastContact                 *string `json:"last_contact"`
		TransferInType              *string `json:"transfer_in_type"`
		TransferOutType             *string `json:"transfer_out_type"`
	} `json:"entries"`
}
type ContactsReportResponse struct {
	Entries []struct {
		CompanyNumber               string      `json:"company_number"`         // EXAMPLE: +12066709000
		ContactId                   string      `json:"contact_id"`             // EXAMPLE: b2172d5238f24ed9ad63e615e9dc2e38
		ContactPersonNumber         string      `json:"contact_person_number"`  // EXAMPLE: +13605880640
		InteractionId               string      `json:"interaction_id"`         // EXAMPLE: 66da31bdbfed4a9299f0e04ed4525c42
		RingGroups                  string      `json:"ring_groups"`            // EXAMPLE: seattle csr
		DirectAssignmentIds         *string     `json:"direct_assignment_ids"`  // EXAMPLE: 50303539303542536e000004
		DirectAssignmentUser        *string     `json:"direct_assignment_user"` // EXAMPLE: External Phone Number
		ExternalPhoneNumber         *string     `json:"external_phone_number"`  // EXAMPLE: +18135330273
		HandlingRingGroups          *string     `json:"handling_ring_groups"`   // EXAMPLE: csr
		PhoneDisplayName            *string     `json:"phone_display_name"`     // EXAMPLE: Seattle [Bay Side (PT)]
		TeamId                      *string     `json:"team_id"`                // EXAMPLE: a1a2c8e573d54b01a1a7c52792ce065d
		TeamName                    *string     `json:"team_name"`              // EXAMPLE: Team GT
		UserId                      *string     `json:"user_id"`                // EXAMPLE: 6216ad50e3eed13d4d561502
		UserName                    *string     `json:"user_name"`              // EXAMPLE: Benjamin Nelson
		ContactType                 ContactType `json:"-"`                      // ENUM: Abandoned/Answered/Connected/Missed/Not Connected/Short Abandoned
		FinishedAt                  time.Time   `json:"-"`                      // MANUALLY PARSED
		StartedAt                   time.Time   `json:"-"`                      // MANUALLY PARSED
		AnsweredAt                  *time.Time  `json:"-"`                      // MANUALLY PARSED
		ConnectedAt                 *time.Time  `json:"-"`                      // MANUALLY PARSED
		Duration                    int         `json:"duration"`               // EXAMPLE: 33
		AbandonTime                 *int        `json:"abandon_time"`           // EXAMPLE: 10
		AfterCallWorkTime           *int        `json:"after_call_work_time"`   // EXAMPLE: 9
		ConnectTime                 *int        `json:"connect_time"`           // EXAMPLE: 16
		HandleTime                  *int        `json:"handle_time"`            // EXAMPLE: 18
		HardHoldTime                *int        `json:"hard_hold_time"`         // EXAMPLE: 34
		HoldTime                    *int        `json:"hold_time"`              // EXAMPLE: 34
		RingTime                    *int        `json:"ring_time"`              // EXAMPLE: 13
		ShortAbandonTime            *int        `json:"short_abandon_time"`     // EXAMPLE: 1
		SoftHoldTime                *int        `json:"soft_hold_time"`         // EXAMPLE: 144
		TalkTime                    *int        `json:"talk_time"`              // EXAMPLE: 9
		TimeToMissed                *int        `json:"time_to_missed"`         // EXAMPLE: 20
		WaitTime                    *int        `json:"wait_time"`              // EXAMPLE: 14
		Callback                    bool        `json:"-"`                      // MANUALLY PARSED
		IsInbound                   bool        `json:"-"`                      // MANUALLY PARSED (in/out)
		InsideBusinessHours         bool        `json:"-"`                      // MANUALLY PARSED (yes/no)
		InsideServiceLevel          bool        `json:"-"`                      // MANUALLY PARSED (yes/no)
		TransferIn                  bool        `json:"-"`                      // MANUALLY PARSED (yes/no)
		TransferOut                 bool        `json:"-"`                      // MANUALLY PARSED (yes/no)
		WithinServiceLevelThreshold bool        `json:"-"`                      // MANUALLY PARSED (yes/no)
		DisconnectedByAgent         *bool       `json:"-"`                      // MANUALLY PARSED (yes/no)
		IsWarmTransfer              *bool       `json:"-"`                      // MANUALLY PARSED (blind/warm)
		LastContact                 *bool       `json:"-"`                      // MANUALLY PARSED (yes/no)
		// TimeToVoicemail             *int    `json:"time_to_voicemail"` - Never returns a value
	} `json:"entries"`
	Total int `json:"total"`
}

// Hold Time report structs
type holdTimeManualParser struct {
	Entries []struct {
		StartedAt string `json:"started_at"`
	}
}
type HoldTimeReportResponse struct {
	Entries []struct {
		AgentId              string    `json:"agent_id"`                // EXAMPLE: 61f9775a50da00603c003f49
		RingGroupsName       string    `json:"ring_groups_name"`        // EXAMPLE: kansas city sales
		TeamId               *string   `json:"team_id"`                 // EXAMPLE: 5cf884c4325a4486bd977865ece145ee
		StartedAt            time.Time `json:"-"`                       // MANUALLY PARSED
		HoldTimeSecondsTotal int       `json:"hold_time_seconds_total"` // EXAMPLE: 85
	} `json:"entries"`
	Total int `json:"total"`
}

// Inbound Contact Volume report structs
type inboundContactVolumeManualParser struct {
	Entries []struct {
		StartedAt string `json:"started_at"`
	} `json:"entries"`
}
type InboundContactVolumeReportResponse struct {
	Entries []struct {
		AgentId         string    `json:"agent_id"`          // EXAMPLE: 61fd3ece9661825d012860b9
		RingGroupsName  string    `json:"ring_groups_name"`  // EXAMPLE: tampa sales
		TeamId          *string   `json:"team_id"`           // EXAMPLE: 1ca2571560b54d24812cd543e2a48241
		StartedAt       time.Time `json:"-"`                 // MANUALLY PARSED
		InContactVolume int       `json:"in_contact_volume"` // EXAMPLE: 1
	} `json:"entries"`
	Total int `json:"total"`
}

// Ring Attempts report structs
type ringAttemptsManualParser struct {
	Entries []struct {
		RingFinishedAtTime string `json:"started_at"`
		RingStartedAtTime  string `json:"ring_started_at_time"`
	} `json:"entries"`
}
type RingAttemptsReportResponse struct {
	Entries []struct {
		AttemptType         string     `json:"attempt_type"`          // Enum: Answered/Canceled/Device Unavailable/Ignored/Rejected
		BatchRingId         string     `json:"batch_ring_id"`         // EXAMPLE: d4cb2923858843eb988a59099a33bc05
		ContactId           string     `json:"contact_id"`            // EXAMPLE: b2172d5238f24ed9ad63e615e9dc2e38
		InteractionId       string     `json:"interaction_id"`        // EXAMPLE: 66da31bdbfed4a9299f0e04ed4525c42
		RingAttemptId       string     `json:"ring_attempt_id"`       // EXAMPLE: d78826724fbc617c75ca7f3d9cc818f749b67793
		UserName            string     `json:"user_name"`             // EXAMPLE: Benjamin Nelson
		TeamName            *string    `json:"team_name"`             // EXAMPLE: Team GT
		UserEmail           *string    `json:"user_email"`            // EXAMPLE: benelson.murray@edmedicalclinic.com
		RingFinishedAtTime  *time.Time `json:"-"`                     // MANUALLY PARSED
		RingStartedAtTime   *time.Time `json:"-"`                     // MANUALLY PARSED
		RingAttemptDuration int        `json:"ring_attempt_duration"` // EXAMPLE: 13
	} `json:"entries"`
	Total int `json:"total"`
}

// Studio Flow Execution report structs
type studioFlowExecutionManualParser struct {
	Entries []struct {
		StudioFlowExecutionsAggregatedFlowExecutionFinishedTime string `json:"studio_flow_executions_aggregated_flow_execution_finished_time"`
		Timestamp                                               string `json:"timestamp"`
	} `json:"entries"`
}
type StudioFlowExecutionReportResponse struct {
	Entries []struct {
		CallSid                                                 string     `json:"call_sid"`             // EXAMPLE: CAeb9fdf035d4779c740bac0202af06d0d
		InteractionId                                           string     `json:"interaction_id"`       // EXAMPLE: 66da31bdbfed4a9299f0e04ed4525c42
		ComponentTitle                                          *string    `json:"component_title"`      // EXAMPLE: End Flow
		DestinationNumber                                       *string    `json:"destination_number"`   // EXAMPLE: +12066709000
		Exit                                                    *string    `json:"exit"`                 // EXAMPLE: ok
		FlowId                                                  *string    `json:"flow_id"`              // EXAMPLE: a6fe38444c1646d2947820d63fa94a56
		FlowName                                                *string    `json:"flow_name"`            // EXAMPLE: Seattle Patient IVR - imported
		OriginNumber                                            *string    `json:"origin_number"`        // EXAMPLE:+13605880640
		StepName                                                *string    `json:"step_name"`            // EXAMPLE: END
		Timestamp                                               time.Time  `json:"-"`                    // MANUALLY PARSED
		StudioFlowExecutionsAggregatedFlowExecutionFinishedTime *time.Time `json:"-"`                    // MANUALLY PARSED
		StepExecutionOrder                                      int        `json:"step_execution_order"` // EXAMPLE: 7
		TimeInStep                                              float64    `json:"time_in_step"`         // EXAMPLE: 2.6157406e-06
	} `json:"entries"`
	Total int `json:"total"`
}

// Talk Time Data report structs
type talkTimeDataManualParser struct {
	Entries []struct {
		StartedAt string `json:"started_at"`
	} `json:"entries"`
}
type TalkTimeDataReportResponse struct {
	Entries []struct {
		AgentId              string    `json:"agent_id"`                // EXAMPLE: 62486423d40af160e5a30fba
		RingGroupsName       string    `json:"ring_groups_name"`        // EXAMPLE: dc sales
		TeamId               *string   `json:"team_id"`                 // EXAMPLE: a1a2c8e573d54b01a1a7c52792ce065d
		StartedAt            time.Time `json:"-"`                       // MANUALLY PARSED
		TalkTimeSecondsTotal int       `json:"talk_time_seconds_total"` // EXAMPLE: 1
	} `json:"entries"`
	Total int `json:"total"`
}

// User Status report structs
type userStatusManualParser struct {
	Entries []struct {
		StatusEndAt   string `json:"status_end_at"`
		StatusStartAt string `json:"status_start_at"`
	} `json:"entries"`
}
type UserStatusReportResponse struct {
	Type    string `json:"type"`
	Version string `json:"version"`
	Entries []struct {
		RingGroups    string    `json:"ring_groups"`  // EXAMPLE: agents+csr+sales+email+med csr+med sales
		StatusLabel   string    `json:"status_label"` // EXAMPLE: offline
		TeamId        string    `json:"team_id"`      // EXAMPLE: 1ca2571560b54d24812cd543e2a48241
		UserEmail     string    `json:"user_email"`   // EXAMPLE: bentley@edmedicalclinic.com
		UserId        string    `json:"user_id"`      // EXAMPLE: 629e83be24976642c60a216d
		UserName      string    `json:"user_name"`    // EXAMPLE: Hiram Stout
		TeamName      *string   `json:"team_name"`    // EXAMPLE: Team Ashley
		StatusEndAt   time.Time `json:"-"`            // MANUALLY PARSED
		StatusStartAt time.Time `json:"-"`            // MANUALLY PARSED
		StatusTime    int       `json:"status_time"`  // EXAMPLE: 86400
		IsUserActive  bool      `json:"is_user_active"`
	} `json:"entries"`
	Total int `json:"total"`
}

// Qa Evaluation Analysis report structs and enum declaration
type QaEvaluationAnalysisQuestionType int

const (
	QaQuestionTypeNewField QaEvaluationAnalysisQuestionType = iota
	QaQuestionTypeMultipleChoice
	QaQuestionTypeText
)

func (t QaEvaluationAnalysisQuestionType) String() string {
	switch t {
	case QaQuestionTypeMultipleChoice:
		return "MultipleChoiceQuestion"
	case QaQuestionTypeText:
		return "TextQuestion"
	case QaQuestionTypeNewField:
		return "New Enumerated Field - Please check field value manually"
	default:
		return ""
	}
}
func genQaEvaluationAnalysisQuestionType(s string) QaEvaluationAnalysisQuestionType {
	switch s {
	case "MultipleChoiceQuestion":
		return QaQuestionTypeMultipleChoice
	case "TextQuestion":
		return QaQuestionTypeText
	default:
		return QaQuestionTypeNewField
	}
}

type qaEvaluationAnalysisManualParser struct {
	Entries []struct {
		EvaluationTime string `json:"evaluation_time"`
		QuestionType   string `json:"question_type"`
	} `json:"entries"`
}
type QaEvaluationAnalysisReportResponse struct {
	Entries []struct {
		Agent                   string                           `json:"agent"`                     // EXAMPLE: Oskar Hernandez-Meneses (oskar@edmedicalclinic.com) [621659c7dc923b6ea8d53ade]
		AgentEmail              string                           `json:"agent_email"`               // EXAMPLE: oskar@edmedicalclinic.com
		AgentId                 string                           `json:"agent_id"`                  // EXAMPLE: 621659c7dc923b6ea8d53ade
		AgentName               string                           `json:"agent_name"`                // EXAMPLE: Oskar Hernandez-Meneses
		EvaluationId            string                           `json:"evaluation_id"`             // EXAMPLE: ae93129a-94e0-4947-85cf-bbc63d14e163
		EvaluatorId             string                           `json:"evaluator_id"`              // EXAMPLE: 61fd41969f93cd05ed86b6fd
		EvaluatorName           string                           `json:"evaluator_name"`            // EXAMPLE: Kobi Barrett
		FormId                  string                           `json:"form_id"`                   // EXAMPLE: 8af2bca6806f971a018085e5d2c756f0
		FormName                string                           `json:"form_name"`                 // EXAMPLE: Existing Patient Evaluation v1
		InteractionId           string                           `json:"interaction_id"`            // EXAMPLE: 82181fe8d19a473cb28e1f92d49f2075
		QuestionAnswer          string                           `json:"question_answer"`           // EXAMPLE: Above and Beyond
		QuestionId              string                           `json:"question_id"`               // EXAMPLE: 8af2bca6806f971a018085e5d2c85711
		QuestionText            string                           `json:"question_text"`             // EXAMPLE: Compliance Failures (Type none if none)
		RingGroupNames          string                           `json:"ring_group_names"`          // EXAMPLE: nashville csr
		SectionId               string                           `json:"section_id"`                // EXAMPLE: 8af2bca6806f971a018085e5d2c8570c
		SectionName             string                           `json:"section_name"`              // EXAMPLE: HIPAA Compliance
		TeamName                *string                          `json:"team_name"`                 // EXAMPLE: Team Spencer
		QuestionType            QaEvaluationAnalysisQuestionType `json:"-"`                         // ENUM:    MultipleChoiceQuestion, TextQuestion
		EvaluationTime          time.Time                        `json:"-"`                         // MANUALLY PARSED
		EvaluationMaxScore      int                              `json:"evaluation_max_score"`      // EXAMPLE: 19
		EvaluationObtainedScore int                              `json:"evaluation_obtained_score"` // EXAMPLE: 0
		EvaluationVersion       int                              `json:"evaluation_version"`        // EXAMPLE: 0
		SectionObtainedScore    int                              `json:"section_obtained_score"`    // EXAMPLE: 5
		SectionMaxScore         int                              `json:"section_max_score"`         // EXAMPLE: 5
		QuestionMaxScore        *int                             `json:"question_max_score"`        // EXAMPLE: 1
		QuestionObtainedScore   *int                             `json:"question_obtained_score"`   // EXAMPLE: 1
		// BranchTo                *string `json:"branch_to"`
		// FirstEvaluatedOn        *string `json:"first_evaluated_on"`
		// HeaderId                *string `json:"header_id"`
		// HeaderText              *string `json:"header_text"`
		// InteractionReference    *string `json:"interaction_reference"`
	} `json:"entries"`
	Total int `json:"total"`
}
