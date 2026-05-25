package main

import (
	"cloud.google.com/go/logging"
	"context"
	"fmt"
	"google.golang.org/genproto/googleapis/api/monitoredres"
	"net/http"
	"os"
	"talkdesk_client_library_testing/talkdesk"
	"time"
)

const (
	projectID = "call-center-data-331917"
)

var lg *logging.Logger

func main() {
	ctx := context.Background()
	var err error

	http.HandleFunc("/", Function)

	logClient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log(logging.Error, "logging.NewClient(ctx, projectID)", err)
		return
	}
	defer func(logClient *logging.Client) {
		if err = logClient.Close(); err != nil {
			log(logging.Error, "logClient.Close()", err)
		}
		return
	}(logClient)
	lg = logClient.Logger("run.googleapis.com%2Frequests")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log(logging.Info, "Defaulting to port 8080", nil)
	}

	log(logging.Info, "Listening on port 8080", nil)
	if err = http.ListenAndServe(":"+port, nil); err != nil {
		log(logging.Critical, "http.ListenAndServe(\":\"+port, nil)", err)
		return
	}
}

var w http.ResponseWriter

type reports[T talkdesk.GetReportsResponse] struct {
	reportType      talkdesk.ReportType
	reportName      string
	responsePointer T
}

var reportClient *talkdesk.ReportingRequest

func Function(writer http.ResponseWriter, _ *http.Request) {
	w = writer
	var err error
	client := talkdesk.NewClient()
	reportClient = client.NewReportingApiRequest()

	var userStatusResponse = &talkdesk.UserStatusReportResponse{}

	userStatusTestRequest := reports[*talkdesk.UserStatusReportResponse]{
		reportType:      talkdesk.UserStatus,
		reportName:      "ringAttemptsTest",
		responsePointer: userStatusResponse,
	}
	if err = execute[*talkdesk.UserStatusReportResponse](userStatusTestRequest); err != nil {
		log(logging.Error, "execute[*talkdesk.RingAttemptsReportResponse](ringAttemptsTestRequest)", err)
		return
	} else {
		log(logging.Info, fmt.Sprintf("Ring attempts report successfully requested --- len: %v, ex: %v",
			len(userStatusResponse.Entries), userStatusResponse.Entries[0].StatusEndAt.String()), nil)
	}

	usersClient := client.NewUsersApiRequest()

	var listUsersResponse *talkdesk.ListUsersResponse
	active := true
	perPage := 199
	listUsersRequest := talkdesk.ListUsersRequest{
		OnlyCurrentAndBilledUsers: &active,
		EmailFilter:               nil,
		PageNumber:                nil,
		PerPage:                   &perPage,
	}
	if err := usersClient.ListUsers(listUsersRequest, listUsersResponse); err != nil {
		log(logging.Error, "usersClient.ListUsers(listUsersRequest, listUsersResponse)", err)
		return
	} else {
		log(logging.Info, fmt.Sprintf("users request performed successfully --- %v", listUsersResponse.Total), nil)
	}

	return
}

const (
	clusterName   = "systems-dev-projects"
	serviceRegion = "us-central1"
	namespaceName = "talkdesk"
	k8sPodAppName = "talkdesk-cl-testing"
)

func execute[T talkdesk.GetReportsResponse](reports reports[T]) error {

	tz, err := time.LoadLocation("America/Creston")
	if err != nil {
		return fmt.Errorf("time.LoadLocation(\"America/Creston\"): %v", err)
	}

	executeRequest := talkdesk.ExecuteReportRequest{
		ReportName: reports.reportName,
		ReportType: reports.reportType,
		FromTime:   time.Date(2022, time.June, 7, 0, 0, 0, 0, tz),
		ToTime:     time.Date(2022, time.June, 8, 0, 0, 0, 0, tz),
	}

	executeRequest.ReportType = reports.reportType
	executeRequest.ReportName = reports.reportName
	if err = talkdesk.ExecuteReport[T](reportClient, executeRequest, reports.responsePointer); err != nil {
		return fmt.Errorf("talkdesk.ExecuteReport[T](reportClient ,executeRequest, reports.responsePointer): %v", err)
	}

	return nil
}

func log(severity logging.Severity, payload string, err error) {
	if err != nil {
		payload = fmt.Sprintf("%v: %v", payload, err)
		fmt.Println(payload)
	}
	if lg != nil {
		lg.Log(logging.Entry{
			Severity: severity,
			Payload:  payload,
			Resource: &monitoredres.MonitoredResource{
				Type: "k8s_container",
				Labels: map[string]string{
					"cluster_name":   clusterName,
					"namespace_name": namespaceName,
					"project_id":     projectID,
					"location":       serviceRegion,
				},
			},
			Labels: map[string]string{
				"k8s-pod/app": k8sPodAppName,
			},
		})
	}

	if w != nil {
		if err != nil {
			w.Write([]byte(fmt.Sprintf("%v: %v", payload, err)))
		} else {
			w.Write([]byte(payload))
		}
	}

	return
}
