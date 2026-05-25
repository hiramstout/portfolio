package main

import (
	"cloud.google.com/go/bigquery"
	storage "cloud.google.com/go/bigquery/storage/apiv1"
	"cloud.google.com/go/bigquery/storage/managedwriter/adapt"
	"cloud.google.com/go/logging"
	"context"
	"fmt"
	"git.jetbrains.space/wasatchmedical/development-resources/talkdesk"
	"github.com/go-co-op/gocron"
	"github.com/gobuffalo/packr/v2"
	"google.golang.org/api/iterator"
	"google.golang.org/genproto/googleapis/api/monitoredres"
	storagepb "google.golang.org/genproto/googleapis/cloud/bigquery/storage/v1"
	"google.golang.org/protobuf/proto"
	"io"
	"talkdesk-callbacks/pb"
	"time"
)

const (
	projectId     = "call-center-data-331917"
	clusterName   = "systems-dev-projects"
	serviceRegion = "us-central1"
	namespaceName = "talkdesk"
	k8sPodAppName = "talkdesk-callbacks"
)

type AvailabilityRow struct {
	EventTimestamp time.Time
	AgentEmail     string
	CurrentStatus  string
}
type CallsNeedingCallbackRow struct {
	InteractionID       string
	ContactPhoneNumber  string
	EventTimestamp      time.Time
	TalkdeskPhoneNumber string
}
type UserAvailabilityMapValueStruct struct {
	EventTimestamp time.Time
	UserStatus     string
}

const projectID = "call-center-data-331917"

var Lg *logging.Logger
var CallbacksClient talkdesk.CallbackRequestClient

//goland:noinspection GoUnusedExportedFunction
func main() {
	ctx := context.Background()
	logClient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log(logging.Error, err, "logging.NewClient(ctx, projectID)")
	}
	defer func(logClient *logging.Client) {
		if err := logClient.Close(); err != nil {
			log(logging.Error, err, "logging.NewClient(ctx, projectID)")
			return
		} else {
			return
		}
	}(logClient)
	Lg = logClient.Logger("cloudfunctions.googleapis.com%2Fcloud-functions")

	tz, err := time.LoadLocation("America/Creston")
	if err != nil {
		log(logging.Info, err, "time.LoadLocation(\"America/Creston\")")
	}
	scheduler := gocron.NewScheduler(tz)
	_, err = scheduler.Every(1).Minutes().Do(queueCallbacks)
	if err != nil {
		log(logging.Error, err, "scheduler.Every(2).Minutes().Do(CronJobFunction): %v")
		return
	}
	tClient := talkdesk.NewClient()
	CallbacksClient = tClient.NewCallbacksApiRequest()
	scheduler.StartBlocking()
}

func queueCallbacks() error {
	ctx := context.Background()
	ClinicTimezoneMap := make(map[string]string)
	ClinicTimezoneMap["+17706281111"] = "Eastern"
	ClinicTimezoneMap["+15129914000"] = "Central"
	ClinicTimezoneMap["+12082025000"] = "Mountain"
	ClinicTimezoneMap["+16173839999"] = "Eastern"
	ClinicTimezoneMap["+17046100261"] = "Central"
	ClinicTimezoneMap["+13124813333"] = "Central"
	ClinicTimezoneMap["+15134961122"] = "Eastern"
	ClinicTimezoneMap["+12167101111"] = "Eastern"
	ClinicTimezoneMap["+16146184000"] = "Eastern"
	ClinicTimezoneMap["+12149375000"] = "Central"
	ClinicTimezoneMap["+12029085555"] = "Eastern"
	ClinicTimezoneMap["+13034996000"] = "Mountain"
	ClinicTimezoneMap["+15153005555"] = "Central"
	ClinicTimezoneMap["+13134033333"] = "Eastern"
	ClinicTimezoneMap["+17138437000"] = "Central"
	ClinicTimezoneMap["+13175521111"] = "Eastern"
	ClinicTimezoneMap["+19132958000"] = "Central"
	ClinicTimezoneMap["+13103071111"] = "Pacific"
	ClinicTimezoneMap["+14148777999"] = "Central"
	ClinicTimezoneMap["+16122556461"] = "Central"
	ClinicTimezoneMap["+18019018000"] = "Mountain"
	ClinicTimezoneMap["+16155765000"] = "Central"
	ClinicTimezoneMap["+16467155555"] = "Eastern"
	ClinicTimezoneMap["+17573095555"] = "Eastern"
	ClinicTimezoneMap["+14058397000"] = "Eastern"
	ClinicTimezoneMap["+14026717777"] = "Central"
	ClinicTimezoneMap["+12157701839"] = "Eastern"
	ClinicTimezoneMap["+14123464666"] = "Central"
	ClinicTimezoneMap["+14014149999"] = "Eastern"
	ClinicTimezoneMap["+18049995699"] = "Central"
	ClinicTimezoneMap["+19166032000"] = "Pacific"
	ClinicTimezoneMap["+12109048000"] = "Central"
	ClinicTimezoneMap["+16196933333"] = "Pacific"
	ClinicTimezoneMap["+14805351000"] = "Pacific"
	ClinicTimezoneMap["+12066709000"] = "Pacific"
	ClinicTimezoneMap["+13145307777"] = "Central"
	ClinicTimezoneMap["+14359227000"] = "Mountain"
	ClinicTimezoneMap["+18135651000"] = "Eastern"
	ClinicTimezoneMap["+19196795000"] = "Eastern"
	ClinicTimezoneMap["+15024611110"] = "Eastern"
	ClinicTimezoneMap["+14103944000"] = "Eastern"

	ClinicTimezoneMap["+14104696507"] = "Eastern"
	ClinicTimezoneMap["+19198776455"] = "Eastern"
	ClinicTimezoneMap["+15024102000"] = "Eastern"
	ClinicTimezoneMap["+16125121111"] = "Eastern"
	ClinicTimezoneMap["+16616697776"] = "Pacific"
	ClinicTimezoneMap["+12153029999"] = "Pacific"
	ClinicTimezoneMap["+18044011111"] = "Eastern"
	ClinicTimezoneMap["+17047545555"] = "Eastern"
	ClinicTimezoneMap["+15137988000"] = "Eastern"
	ClinicTimezoneMap["+14142933333"] = "Central"
	ClinicTimezoneMap["+14126121111"] = "Eastern"

	var err error

	box := packr.New("SQL Commands", "./sql-commands")

	mountain, err := time.LoadLocation("America/Creston")
	if err != nil {
		log(logging.Error, err, "time.LoadLocation(\"America/Creston\")")
	}
	pacific, err := time.LoadLocation("America/Los_Angeles")
	if err != nil {
		log(logging.Error, err, "time.LoadLocation(\"America/Los_Angeles\")")
	}
	central, err := time.LoadLocation("America/Chicago")
	if err != nil {
		log(logging.Error, err, "time.LoadLocation(\"America/Chicago\")")
	}
	eastern, err := time.LoadLocation("America/New_York")
	if err != nil {
		log(logging.Error, err, "time.LoadLocation(\"America/New_York\")")
	}

	client, err := bigquery.NewClient(ctx, projectID)
	if err != nil {
		log(logging.Error, err, "bigquery.NewClient(ctx, projectID)")
	}
	client.Close()

	var availableUsers int16
	var UserAvailabilityMap = make(map[string]UserAvailabilityMapValueStruct)
	it, err := queryAvailability(ctx, client, box)
	if err != nil {
		log(logging.Error, err, "queryAvailability(ctx, client)")
	}
	for {
		var row AvailabilityRow
		if err := it.Next(&row); err == iterator.Done {
			break
		} else if err != nil {
			log(logging.Error, err, "it.Next(&row)")
			continue
		} else {
			UserAvailabilityMap[row.AgentEmail] = UserAvailabilityMapValueStruct{
				UserStatus:     row.CurrentStatus,
				EventTimestamp: row.EventTimestamp,
			}
			if row.CurrentStatus == "available" {
				availableUsers += 1
			}
		}
	}

	storageCallbackRequestedWriteClient, err := storage.NewBigQueryWriteClient(ctx)
	if err != nil {
		log(logging.Error, err, "storage.NewBigQueryWriteClient(ctx) - storageCallbackRequestedWriteClient")
	}
	defer client.Close()
	callbackRequestedStream, err := storageCallbackRequestedWriteClient.AppendRows(ctx)
	if err != nil {
		log(logging.Error, err, "storageCallbackRequestedWriteClient.AppendRows(ctx)")
	}
	var callbackRequestedOpts proto.MarshalOptions
	var callbackRequestedRowSchema pb.MissedCallQueuedRowAppend
	callbackRequestedDescriptor, err := adapt.NormalizeDescriptor(callbackRequestedRowSchema.ProtoReflect().Descriptor())
	if err != nil {
		log(logging.Error, err, "callbackRequestedDescriptor")
	}
	var CallbackRequestedData = make([][]byte, 0, 200)
	var missedCallsStillNeedingCallback int32 = 0
	var callbacksRequested int16

	it, err = queryMissedCallsNeedingCallbacks(ctx, client, box)
	if err != nil {
		log(logging.Error, err, "queryMissedCallsNeedingCallbacks(ctx, client, box)")
	}

	for {
		var callbackNeededRow CallsNeedingCallbackRow
		if err := it.Next(&callbackNeededRow); err == iterator.Done {
			break
		} else if err != nil {
			log(logging.Error, err, "it.Next(&callbackNeededRow)")
			continue
		} else {
			timezone, numberIsTimezoneMapped := ClinicTimezoneMap[callbackNeededRow.TalkdeskPhoneNumber]
			var isInBusinessHours bool
			if numberIsTimezoneMapped {
				var currentHourInLocalTime int
				switch timezone {
				case "Pacific":
					currentHourInLocalTime = time.Now().In(pacific).Hour()
				case "Mountain":
					currentHourInLocalTime = time.Now().In(mountain).Hour()
				case "Central":
					currentHourInLocalTime = time.Now().In(central).Hour()
				case "Eastern":
					currentHourInLocalTime = time.Now().In(eastern).Hour()
				}
				isInBusinessHours = currentHourInLocalTime > 9 && currentHourInLocalTime < 21
			} else {
				if callbackNeededRow.TalkdeskPhoneNumber != "+18777975666" {
					s := fmt.Sprintf("Unable to map timezone for phone number %v", callbackNeededRow.TalkdeskPhoneNumber)
					log(logging.Debug, nil, s)
				}
				restrictiveBusinessHourStart := time.Now().In(pacific).Hour()
				restrictiveBusinessHourEnd := time.Now().In(eastern).Hour()
				isInBusinessHours = restrictiveBusinessHourStart > 9 && restrictiveBusinessHourEnd < 21
			}
			isWithinThirtyMin := callbackNeededRow.EventTimestamp.Unix()+1800 > time.Now().Unix()
			if callbacksRequested < availableUsers && (isInBusinessHours || isWithinThirtyMin) {
				callbackRequest := talkdesk.RequestCallbackRequestData{
					ContactPhoneNumber:  callbackNeededRow.ContactPhoneNumber,
					TalkdeskPhoneNumber: callbackNeededRow.TalkdeskPhoneNumber,
				}
				if err := CallbacksClient.RequestCallback(callbackRequest); err != nil {
					log(logging.Error, err, "CallbacksClient.RequestCallback(callbackRequest)")
					continue
				}

				callbackRequestedRow := pb.MissedCallQueuedRowAppend{
					EventTimestamp:            time.Now().UnixNano() / 1000,
					InteractionId:             callbackNeededRow.InteractionID,
					AttemptNumber:             1,
					AvailableAgent:            int32(availableUsers),
					FailureStatus:             false,
					TotalStillNeedingCallback: missedCallsStillNeedingCallback,
				}
				buf, err := callbackRequestedOpts.Marshal(&callbackRequestedRow)
				if err != nil {
					log(logging.Error, err, "callbackRequestedOpts.Marshal(&callbackRequestedRow)")
					continue
				}
				CallbackRequestedData = append(CallbackRequestedData, buf)

				s := fmt.Sprintf("Successfully requested missed call for phone #%v", callbackNeededRow.ContactPhoneNumber)
				log(logging.Info, nil, s)

				availableUsers -= 1

				time.Sleep(time.Second / 2)
			} else {
				missedCallsStillNeedingCallback += 1
			}
		}
	}

	/*	it, err = querySecondAttempts(ctx, client, box)
		if err != nil {
			log(logging.Error, err, "queryMissedCallsNeedingCallbacks(ctx, client, box)")
		}

		for {
			var callbackNeededRow CallsNeedingCallbackRow
			if err := it.Next(&callbackNeededRow); err == iterator.Done {
				break
			} else if err != nil {
				log(logging.Error, err, "it.Next(&callbackNeededRow)")
				continue
			} else {
				timezone, numberIsTimezoneMapped := ClinicTimezoneMap[callbackNeededRow.TalkdeskPhoneNumber]
				var isInBusinessHours bool
				if numberIsTimezoneMapped {
					var currentHourInLocalTime int
					switch timezone {
					case "Pacific":
						currentHourInLocalTime = time.Now().In(pacific).Hour()
					case "Mountain":
						currentHourInLocalTime = time.Now().In(mountain).Hour()
					case "Central":
						currentHourInLocalTime = time.Now().In(central).Hour()
					case "Eastern":
						currentHourInLocalTime = time.Now().In(eastern).Hour()
					}
					isInBusinessHours = currentHourInLocalTime > 9 && currentHourInLocalTime < 21
				} else {
					if callbackNeededRow.TalkdeskPhoneNumber != "+18777975666" {
						s := fmt.Sprintf("Unable to map timezone for phone number %v", callbackNeededRow.TalkdeskPhoneNumber)
						log(logging.Debug, nil, s)
					}
					restrictiveBusinessHourStart := time.Now().In(pacific).Hour()
					restrictiveBusinessHourEnd := time.Now().In(eastern).Hour()
					isInBusinessHours = restrictiveBusinessHourStart > 9 && restrictiveBusinessHourEnd < 21
				}
				isWithinThirtyMin := callbackNeededRow.EventTimestamp.Unix()+1800 > time.Now().Unix()
				if callbacksRequested < availableUsers && (isInBusinessHours || isWithinThirtyMin) {
					callbackRequest := talkdesk.RequestCallbackRequestData{
						ContactPhoneNumber:  callbackNeededRow.ContactPhoneNumber,
						TalkdeskPhoneNumber: callbackNeededRow.TalkdeskPhoneNumber,
					}
					if err := CallbacksClient.RequestCallback(callbackRequest); err != nil {
						log(logging.Error, err, "CallbacksClient.RequestCallback(callbackRequest)")
						continue
					}

					callbackRequestedRow := pb.MissedCallQueuedRowAppend{
						EventTimestamp:            time.Now().UnixNano() / 1000,
						InteractionId:             callbackNeededRow.InteractionID,
						AttemptNumber:             1,
						AvailableAgent:            int32(availableUsers),
						FailureStatus:             false,
						TotalStillNeedingCallback: missedCallsStillNeedingCallback,
					}
					buf, err := callbackRequestedOpts.Marshal(&callbackRequestedRow)
					if err != nil {
						log(logging.Error, err, "callbackRequestedOpts.Marshal(&callbackRequestedRow)")
						continue
					}
					CallbackRequestedData = append(CallbackRequestedData, buf)

					s := fmt.Sprintf("Successfully requested second attempt for phone #%v", callbackNeededRow.ContactPhoneNumber)
					log(logging.Info, nil, s)

					availableUsers -= 1

					time.Sleep(time.Second / 2)
				} else {
					missedCallsStillNeedingCallback += 1
				}
			}
		}*/

	var callbackRequestStreamRequest = &storagepb.AppendRowsRequest{
		WriteStream: `projects/call-center-data-331917/datasets/Talkdesk/tables/callbacks-queued/streams/_default`,
		Rows: &storagepb.AppendRowsRequest_ProtoRows{
			ProtoRows: &storagepb.AppendRowsRequest_ProtoData{
				WriterSchema: &storagepb.ProtoSchema{
					ProtoDescriptor: callbackRequestedDescriptor,
				},
				Rows: &storagepb.ProtoRows{
					SerializedRows: CallbackRequestedData,
				},
			},
		},
	}
	if err := callbackRequestedStream.Send(callbackRequestStreamRequest); err != nil {
		log(logging.Error, err, "callbackRequestedStream.Send(callbackRequestStreamRequest)")
	}
	if err := callbackRequestedStream.CloseSend(); err != nil {
		log(logging.Error, err, "callbackRequestedStream.CloseSend()")
	}
	response, err := callbackRequestedStream.Recv()
	if err != nil {
		if err != io.EOF {
			log(logging.Error, err, "callbackRequestedStream.Recv()")
		}
	}
	s := fmt.Sprintf("Successfully streamed missed calls: %v", response)
	log(logging.Info, nil, s)

	s = fmt.Sprintf("Exexcuted Function. Available users: %v, Callback Still Needed: %v", availableUsers, missedCallsStillNeedingCallback)
	log(logging.Info, nil, s)
	return nil
}

func queryAvailability(ctx context.Context, client *bigquery.Client, box *packr.Box) (*bigquery.RowIterator, error) {
	s, err := box.FindString("query-availability.sql")
	if err != nil {
		return nil, err
	}

	query := client.Query(s)
	return query.Read(ctx)
}
func queryMissedCallsNeedingCallbacks(ctx context.Context, client *bigquery.Client, box *packr.Box) (*bigquery.RowIterator, error) {
	s, err := box.FindString("query-missed-calls.sql")
	if err != nil {
		return nil, err
	}
	query := client.Query(s)
	return query.Read(ctx)
}

/*func querySecondAttempts(ctx context.Context, client *bigquery.Client, box *packr.Box) (*bigquery.RowIterator, error) {
	s, err := box.FindString("second-attempts.sql")
	if err != nil {
		return nil, err
	}
	query := client.Query(s)
	return query.Read(ctx)
}*/

func log(severity logging.Severity, err error, payload string) {
	if err != nil {
		payload = fmt.Sprintf("%v: %v", payload, err)
		fmt.Println(payload)
	}
	if Lg != nil {
		Lg.Log(logging.Entry{
			Severity: severity,
			Payload:  payload,
			Resource: &monitoredres.MonitoredResource{
				Type: "k8s_container",
				Labels: map[string]string{
					"cluster_name":   clusterName,
					"namespace_name": namespaceName,
					"project_id":     projectId,
					"location":       serviceRegion,
				},
			},
			Labels: map[string]string{
				"k8s-pod/app": k8sPodAppName,
			},
		})
	}

	return
}
