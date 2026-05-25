package talkdesk

import (
	"fmt"
	"net/http"
	"regexp"
	"time"
)

const (
	base            = "https://api.talkdeskapp.com/"
	tokenRequestUrl = "http://talkdesk-token-gen.talkdesk:8080"
)

type scope int
type token struct {
	expirationTime time.Time
	key            string
}

//goland:noinspection goCommentStart
const (
	unknownScope scope = iota

	attributesRead                 // TODO - METADATA DONE
	attributesWrite                // TODO - METADATA DONE
	callbackWrite                  // TODO - FINAL TEST NEEDED
	contactsRead                   // TODO - METADATA DONE
	doNotCallListsManage           // TODO - METADATA DONE
	flowInteractionsStart          // TODO - FINAL TEST NEEDED
	identityPhoneValidationRead    // TODO - METADATA DONE
	liveQueriesRead                // TODO
	liveSubscriptionsRead          // TODO
	liveSubscriptionsWrite         // TODO
	messagesWrite                  // TODO - METADATA DONE
	recordListsManage              // TODO - METADATA DONE
	reportsRead                    // TODO - FINAL TEST NEEDED
	reportsWrite                   // TODO - FINAL TEST NEEDED
	ringGroupsRead                 // TODO - METADATA DONE
	usersRead                      // TODO - FIRST DRAFT DONE
	userRingGroupsRead             // TODO - METADATA DONE
	voiceBiometricsEnrollmentWrite // TODO - METADATA DONE
	voiceBiometricsEnrollmentRead  // TODO - METADATA DONE
	// guardian-users:read
	// guardian-sessions:read
	// guardian-cases:read
	// messagesRead
	// TODO: REGEX RESTRICTIONS FOR STRUCT REQUEST BODIES
)

func (s scope) String() string {
	switch s {
	case attributesRead:
		return "attributes:read"
	case attributesWrite:
		return "attributes:write"
	case callbackWrite:
		return "callback:write"
	case contactsRead:
		return "contacts:read"
	case doNotCallListsManage:
		return "do-not-call-lists:manage"
	case flowInteractionsStart:
		return "flow-interactions:start"
	case identityPhoneValidationRead:
		return "identity-phone-validation:read"
	case liveQueriesRead:
		return "live-queries:read"
	case liveSubscriptionsRead:
		return "live-queries:write"
	case liveSubscriptionsWrite:
		return "live-subscriptions:write"
	case messagesWrite:
		return "messages:write"
	case recordListsManage:
		return "record-lists:manage"
	case reportsRead:
		return "data-reports:read"
	case reportsWrite:
		return "data-reports:write"
	case ringGroupsRead:
		return "ring-groups:read"
	case usersRead:
		return "users:read"
	case userRingGroupsRead:
		return "user-ring-groups:read"
	case voiceBiometricsEnrollmentWrite:
		return "voicebiometrics-enroll:write"
	case voiceBiometricsEnrollmentRead:
		return "voicebiometrics-consent:read"

	default:
		return "unknown scope"
	}
}

type requestType int

const (

	// Reports API request types
	reportsCheckStatus requestType = iota
	reportsDelete
	reportsExecute
	reportsListFromType
	reportsGet

	// Callbacks API request types
	callbacksRequest

	// Flows API request types
	flowsExecute

	// Contacts API request types
	contactsGetList
	contactsGetById
	contactsRemoveById
	contactsListIntegrations

	// Users API request types
	usersList
	usersGetDetails
	usersGetInfo

	// Record Lists API Request Types
	recordListsCreateList
	recordListsCreateMultipleRecords
	recordListsCreateRecord
	recordListsCreateSignedUrlForCsvUpload
	recordListsDeleteList
	recordListsDeleteRecord
	recordListsGetAll
	recordListsGetListDetails
	recordListsGetRecord
	recordListsUpdateMultipleRecords
	recordListsUpdateRecord
	recordListsUploadObject

	// Do Not Call Lists API request types
	doNotCallListsCreateEntry
	doNotCallListsCreateList
	doNotCallListsDeleteEntry
	doNotCallListsDetails
	doNotCallListsGetEntry
	doNotCallListsListLists
	doNotCallListsUpdateEntries
	doNotCallListsUpdateSingleEntry

	// Attributes API request types
	attributesAddUserAssociation
	attributesCreateAttribute
	attributesCreateCategory
	attributesDeleteCategory
	attributesDeleteUserAssociation
	attributesGetAttributeDetails
	attributesGetCategoryList
	attributesGetList
	attributesGetUserAttributeList
	attributesListUsers
	attributesUpdateAttribute
	attributesUpdateCategory

	// Ring Groups API request types
	ringGroupsList
	ringGroupsGetAssignedUsers

	// Messages API request types
	messagesSendMessage

	// Phone Validation API request types
	phoneValidationGetInsights

	// Voice Biometrics API request types
	voiceBiometricsEnrollWithPhraseId
	voiceBiometricsRemoveEnrollmentInformation
	voiceBiometricsGetConsentStatus
	voiceBiometricsSetConsentStatus
)

func (t requestType) getRequestPath() string {
	switch t {
	// Reports API paths
	case reportsExecute:
		return "data/reports/{type}/jobs"
	case reportsGet:
		return "data/reports/{type}/files/{id}"
	case reportsCheckStatus:
		return "data/reports/{type}/jobs/{id}"
	case reportsDelete:
		return "data/reports/{type}/files/{id}"
	case reportsListFromType:
		return "data/reports/{type}/jobs"

	// Users API paths
	case usersList:
		return "users"
	case usersGetDetails:
		return "users/{id}"
	case usersGetInfo:
		return "users/me"

	// Flows API paths
	case flowsExecute:
		return "flows/{flow_id}/interactions"

	// Contacts API paths
	case contactsGetList:
		return "contacts"
	case contactsGetById:
		return "contacts/{contact_id}"
	case contactsRemoveById:
		return "contacts/{contact_id}"
	case contactsListIntegrations:
		return "contacts/{contact_id}/integrations"

	// Callbacks API paths
	case callbacksRequest:
		return "calls/callback"

	// Do Not Call Lists API paths
	case doNotCallListsCreateList:
		return "do-not-call-lists"
	case doNotCallListsCreateEntry:
		return "do-not-call-lists/{id}/entries"
	case doNotCallListsDeleteEntry:
		return "do-not-call-lists/{id}/entries/{id_entry}"
	case doNotCallListsDetails:
		return "do-not-call-lists/{id}"
	case doNotCallListsGetEntry:
		return "do-not-call-lists/{id}/entries"
	case doNotCallListsListLists:
		return "do-not-call-lists"
	case doNotCallListsUpdateEntries:
		return "do-not-call-lists/{id}/entries"
	case doNotCallListsUpdateSingleEntry:
		return "do-not-call-lists/{id}/entries/{id_entry}"

	// Record Lists API paths
	case recordListsCreateList:
		return "record-lists"
	case recordListsCreateMultipleRecords:
		return "record-lists/{id}/records/bulks"
	case recordListsCreateRecord:
		return "record-lists/{id}/records"
	case recordListsCreateSignedUrlForCsvUpload:
		return "record-lists/{id}/upload-requests"
	case recordListsDeleteList:
		return "record-lists/{id}/records"
	case recordListsDeleteRecord:
		return "/record-lists/{id}/records/{id_record}"
	case recordListsGetAll:
		return "record/lists"
	case recordListsGetListDetails:
		return "record-lists/{id}"
	case recordListsGetRecord:
		return "record-lists/{id}/records/{id_record}"
	case recordListsUpdateMultipleRecords:
		return "record-lists/{id}/records/bulks"
	case recordListsUpdateRecord:
		return "record-lists/{id}/records/{id_record}"
	case recordListsUploadObject:
		return "record-lists/{id}/upload-requests/{id_upload_request}"

	// Attributes API paths
	case attributesAddUserAssociation:
		return "attributes/{attribute_id}/users"
	case attributesCreateAttribute:
		return "attributes"
	case attributesCreateCategory:
		return "attributes-categories"
	case attributesDeleteCategory:
		return "attributes-categories/{category_id}"
	case attributesDeleteUserAssociation:
		return "attributes/{attribute_id}/users"
	case attributesGetAttributeDetails:
		return "attributes/{attribute_id}"
	case attributesGetCategoryList:
		return "attributes-categories"
	case attributesGetList:
		return "attributes"
	case attributesGetUserAttributeList:
		return "users/{user_id}/attributes"
	case attributesListUsers:
		return "attributes/{attribute_id}/users"
	case attributesUpdateAttribute:
		return "attributes/{attribute_id}"
	case attributesUpdateCategory:
		return "attributes-categories/{category_id}"

	// Ring Groups API paths
	case ringGroupsList:
		return "ring-groups"
	case ringGroupsGetAssignedUsers:
		return "ring-groups/{id}/users"

	// Messages API paths
	case messagesSendMessage:
		return "messages"

	// Phone Validation API paths
	case phoneValidationGetInsights:
		return "identity/phonevalidations/{phone_number}"

	// Voice Biometrics API paths
	case voiceBiometricsEnrollWithPhraseId:
		return "voicebiometrics/contacts/{contact_id}/enrollment"
	case voiceBiometricsRemoveEnrollmentInformation:
		return "voicebiometrics/contacts/{contact_id}/enrollment"
	case voiceBiometricsGetConsentStatus:
		return "voicebiometrics/contacts/{contact_id}/consent"
	case voiceBiometricsSetConsentStatus:
		return "voicebiometrics/contacts/{contact_id}/consent"

	// Unknown
	default:
		return ""
	}
}

// Order is important
func (t requestType) getPathParamNames() []string {
	switch t {
	// Reports API path parameters
	case reportsGet:
		return []string{"type", "id"}
	case reportsDelete:
		return []string{"type", "id"}
	case reportsListFromType:
		return []string{"type"}
	case reportsCheckStatus:
		return []string{"type", "id"}
	case reportsExecute:
		return []string{"type"}

	// Flows API path parameters
	case flowsExecute:
		return []string{"flow_id", "id"}

	// Contacts API path parameters
	case contactsGetById:
		return []string{"contact_id"}
	case contactsRemoveById:
		return []string{"contact_id"}
	case contactsListIntegrations:
		return []string{"contact_id"}

	// Do Not Call Lists path parameters
	case doNotCallListsCreateEntry:
		return []string{"id"}
	case doNotCallListsDeleteEntry:
		return []string{"id", "id_entry"}
	case doNotCallListsDetails:
		return []string{"id"}
	case doNotCallListsGetEntry:
		return []string{"id"}
	case doNotCallListsUpdateEntries:
		return []string{"id"}
	case doNotCallListsUpdateSingleEntry:
		return []string{"id", "id_entry"}

	// Record Lists API path parameters
	case recordListsCreateMultipleRecords:
		return []string{"id"}
	case recordListsCreateRecord:
		return []string{"id"}
	case recordListsCreateSignedUrlForCsvUpload:
		return []string{"id"}
	case recordListsDeleteList:
		return []string{"id"}
	case recordListsDeleteRecord:
		return []string{"id", "id_record"}
	case recordListsGetListDetails:
		return []string{"id"}
	case recordListsGetRecord:
		return []string{"id", "id_record"}
	case recordListsUpdateMultipleRecords:
		return []string{"id"}
	case recordListsUpdateRecord:
		return []string{"id", "id_record"}
	case recordListsUploadObject:
		return []string{"id", "id_upload_request"}

	// Attributes API path parameters
	case attributesAddUserAssociation:
		return []string{"attribute_id"}
	case attributesDeleteCategory:
		return []string{"category_id"}
	case attributesDeleteUserAssociation:
		return []string{"attribute_id"}
	case attributesGetAttributeDetails:
		return []string{"attribute_id"}
	case attributesGetUserAttributeList:
		return []string{"user_id"}
	case attributesListUsers:
		return []string{"attribute_id"}
	case attributesUpdateAttribute:
		return []string{"attribute_id"}
	case attributesUpdateCategory:
		return []string{"category_id"}

	// Ring Groups API path parameters
	case ringGroupsGetAssignedUsers:
		return []string{"id"}

	// Phone Validation API path parameters
	case phoneValidationGetInsights:
		return []string{"phone_number"}

	case voiceBiometricsEnrollWithPhraseId:
		return []string{"contact_id"}
	case voiceBiometricsRemoveEnrollmentInformation:
		return []string{"contact_id"}
	case voiceBiometricsGetConsentStatus:
		return []string{"contact_id"}
	case voiceBiometricsSetConsentStatus:
		return []string{"contact_id"}

	default:
		return nil
	}
}

// Map of single parameter data types for query parameters. Key is the name of the field, value
// is a bool determining whether the parameter is required.
type qpString struct {
	name            string
	isMandatory     bool
	isMultiValue    bool
	regexConstraint *regexp.Regexp
}
type qpEnum struct {
	name        string
	isMandatory bool
	enumType    func(enumInterface qpEnumInterface) (string, error)
}
type qpBool struct {
	name        string
	isMandatory bool
}
type qpInt struct {
	name           string
	isMandatory    bool
	lowConstraint  *int
	highConstraint *int
}
type qpDefinitionList struct {
	stringFields []qpString
	boolFields   []qpBool
	intFields    []qpInt
	enumFields   []qpEnum
}
type querySortType int

const (
	Ascending querySortType = iota
	Descending
)

func (q querySortType) String() string {
	switch q {
	case Ascending:
		return "ascending"
	case Descending:
		return "descending"
	default:
		return ""
	}
}

type qpEnumInterface interface {
	querySortType | any
	String() string
}

func (t requestType) getQueryParamNames() *qpDefinitionList {
	pageAndPerPageLow := 1
	page := qpInt{
		name:          "page",
		lowConstraint: &pageAndPerPageLow,
	}
	perPageHigh := 200
	perPage := qpInt{
		name:           "per_page",
		lowConstraint:  &pageAndPerPageLow,
		highConstraint: &perPageHigh,
	}

	switch t {

	// Reports API query parameters
	case reportsListFromType:
		return &qpDefinitionList{intFields: []qpInt{page, perPage}}

	// Users API query parameters
	case usersList:
		return &qpDefinitionList{
			stringFields: []qpString{{name: "email"}},
			boolFields:   []qpBool{{name: "active"}},
			intFields:    []qpInt{page, perPage},
		}

	// Contacts API query parameters
	case contactsGetList:
		return &qpDefinitionList{
			stringFields: []qpString{
				{name: "ids", // List of contact UIDs
					isMultiValue: true},
				{name: "name"},          // Human-readable contact name, strict matching
				{name: "name.loose"},    // Human-readable contact name, loose matching
				{name: "company"},       // Human-readable company name, strict matching
				{name: "company.loose"}, // Human-readable company name, loose matching
				// Integration that the contact is sourced from, must follow integration_name:external_id regex format
				{name: "integration",
					regexConstraint: regexp.MustCompile(`[^:]+:[^:]+`)},
				{name: "phones",
					isMultiValue:    true,
					regexConstraint: regexp.MustCompile(`\+1[0-9]{10}`)},
			},
			intFields: []qpInt{page, perPage},
		}

	// Do Not Call Lists API query parameters
	case doNotCallListsGetEntry:
		return &qpDefinitionList{
			stringFields: []qpString{
				{name: "phone_number",
					regexConstraint: regexp.MustCompile(`\+1[0-9]{10}`)},
			},
			intFields: []qpInt{page, perPage},
		}
		// []string{"phone_number", "page", "per_page"}
	case doNotCallListsListLists:
		return &qpDefinitionList{
			stringFields: []qpString{{name: "name"}, {name: "status"}},
			intFields:    []qpInt{page, perPage},
		}

	// Record Lists API query parameters
	case recordListsGetAll:
		return &qpDefinitionList{
			stringFields: []qpString{{name: "name"}, {name: "status"}},
			intFields:    []qpInt{page, perPage},
		}
	case recordListsDeleteList:
		return &qpDefinitionList{
			stringFields: []qpString{
				{name: "phone",
					regexConstraint: regexp.MustCompile(`\+1[0-9]{10}`)},
			},
		}

	// Attributes API query parameters
	case attributesGetCategoryList:
		// sort is either "ascending" or "descending", "ascending is default"
		return &qpDefinitionList{
			intFields: []qpInt{page, perPage},
			enumFields: []qpEnum{
				{name: "sort",
					enumType: func(enumType qpEnumInterface) (string, error) {
						switch (enumType).(type) {
						case querySortType:
							return enumType.String(), nil
						default:
							return "", fmt.Errorf("incorrect enum type passed - must be sort type")
						}
					}},
			},
		}
	case attributesGetList:
		// "categories" query parameter can take multiple values, i.e. ?categories=1&categories=2
		return &qpDefinitionList{
			intFields: []qpInt{page, perPage},
			stringFields: []qpString{
				{name: "name"},
				{name: "categories", isMultiValue: true},
				{name: "proficiency"},
			},
			boolFields: []qpBool{{name: "active"}},
			enumFields: []qpEnum{
				{name: "sort",
					enumType: func(enumInterface qpEnumInterface) (string, error) {
						switch (enumInterface).(type) {
						case querySortType:
							return enumInterface.String(), nil
						default:
							return "", fmt.Errorf("incorrect enum type passed - must be sort type")
						}
					}},
			},
		}
	case attributesGetUserAttributeList:
		return &qpDefinitionList{
			intFields: []qpInt{page, perPage},
		}
	case attributesListUsers:
		return &qpDefinitionList{
			intFields:    []qpInt{page, perPage},
			stringFields: []qpString{{name: "name"}},
		}

	// Ring Groups API query parameters
	case ringGroupsList:
		return &qpDefinitionList{
			stringFields: []qpString{{name: "name"}},
			intFields:    []qpInt{page, perPage},
		}
	case ringGroupsGetAssignedUsers:
		return &qpDefinitionList{
			boolFields: []qpBool{{name: "active"}},
			intFields:  []qpInt{page, perPage},
		}

	default:
		return nil
	}
}

type header int

const (
	noHeader header = iota
	accept
	contentType
)

func (h header) getHeaderKey() string {
	switch h {
	case accept:
		return "Accept"
	case contentType:
		return "Content-Type"
	case noHeader:
		return ""
	default:
		return ""
	}
}

func (h header) getHeaderValue() []string {
	switch h {
	case accept:
		return []string{"application/json"}
	case contentType:
		return []string{"application/json"}
	default:
		return nil
	}
}

func (t requestType) getRequestHeaders() []header {

	switch t {
	// Reports API request headers
	case reportsExecute:
		return []header{accept, contentType}
	case reportsGet:
		return []header{accept}
	case reportsCheckStatus:
		return []header{accept}
	case reportsDelete:
		return []header{accept}
	case reportsListFromType:
		return []header{accept}

	// Users API request headers
	case usersList:
		return []header{accept}
	case usersGetDetails:
		return []header{accept}
	case usersGetInfo:
		return []header{accept}

	// Flows API request headers
	case flowsExecute:
		return []header{accept, contentType}

	// Contacts API request headers
	case contactsGetList:
		return []header{accept}
	case contactsGetById:
		return []header{accept}
	case contactsRemoveById:
		return []header{accept, contentType}
	case contactsListIntegrations:
		return []header{accept}

	// Callbacks API request headers
	case callbacksRequest:
		return []header{contentType}

	// Do Not Call Lists API request headers
	case doNotCallListsCreateEntry:
		return []header{accept, contentType}
	case doNotCallListsCreateList:
		return []header{accept, contentType}
	case doNotCallListsDeleteEntry:
		return []header{contentType}
	case doNotCallListsDetails:
		return []header{contentType}
	case doNotCallListsGetEntry:
		return []header{contentType}
	case doNotCallListsListLists:
		return []header{contentType}
	case doNotCallListsUpdateEntries:
		return []header{accept, contentType}
	case doNotCallListsUpdateSingleEntry:
		return []header{accept, contentType}

	// Record Lists API request headers
	case recordListsCreateList:
		return []header{accept, contentType}
	case recordListsCreateMultipleRecords:
		return []header{accept, contentType}
	case recordListsCreateRecord:
		return []header{accept, contentType}
	case recordListsCreateSignedUrlForCsvUpload:
		return []header{accept, contentType}
	case recordListsDeleteList:
		return []header{accept}
	case recordListsDeleteRecord:
		return []header{accept}
	case recordListsGetAll:
		return []header{accept}
	case recordListsGetListDetails:
		return []header{accept}
	case recordListsGetRecord:
		return []header{accept}
	case recordListsUpdateMultipleRecords:
		return []header{accept, contentType}
	case recordListsUpdateRecord:
		return []header{accept, contentType}
	case recordListsUploadObject:
		return []header{accept, contentType}

	// Attributes API headers
	case attributesAddUserAssociation:
		return []header{accept, contentType}
	case attributesCreateAttribute:
		return []header{accept, contentType}
	case attributesCreateCategory:
		return []header{accept, contentType}
	case attributesDeleteCategory:
		return []header{accept}
	case attributesDeleteUserAssociation:
		return []header{accept}
	case attributesGetAttributeDetails:
		return []header{accept}
	case attributesGetCategoryList:
		return []header{accept}
	case attributesGetList:
		return []header{accept}
	case attributesGetUserAttributeList:
		return []header{accept}
	case attributesListUsers:
		return []header{accept}
	case attributesUpdateAttribute:
		return []header{accept, contentType}
	case attributesUpdateCategory:
		return []header{accept, contentType}

	// Ring Groups API headers
	case ringGroupsList:
		return []header{accept}
	case ringGroupsGetAssignedUsers:
		return []header{accept}

	// Messages API headers
	case messagesSendMessage:
		return []header{accept, contentType}

	// Phone Validation API headers:
	case phoneValidationGetInsights:
		return []header{accept}

	// Voice Biometrics API headers:
	case voiceBiometricsEnrollWithPhraseId:
		return []header{accept, contentType}
	case voiceBiometricsRemoveEnrollmentInformation:
		return []header{accept}
	case voiceBiometricsGetConsentStatus:
		return []header{accept}
	case voiceBiometricsSetConsentStatus:
		return []header{accept, contentType}

	// Unknown
	default:
		return nil
	}
}

func (t requestType) getRequestMethod() string {

	switch t {

	// Reports API methods
	case reportsExecute:
		return http.MethodPost
	case reportsGet:
		return http.MethodGet
	case reportsCheckStatus:
		return http.MethodGet
	case reportsDelete:
		return http.MethodDelete
	case reportsListFromType:
		return http.MethodGet

	// Users API methods
	case usersList:
		return http.MethodGet
	case usersGetDetails:
		return http.MethodGet
	case usersGetInfo:
		return http.MethodGet

	// Flows API methods
	case flowsExecute:
		return http.MethodPost

	// Contacts API methods
	case contactsGetList:
		return http.MethodGet
	case contactsGetById:
		return http.MethodGet
	case contactsRemoveById:
		return http.MethodDelete
	case contactsListIntegrations:
		return http.MethodGet

	// Callbacks API methods
	case callbacksRequest:
		return http.MethodPost

	// Do Not Call Lists API methods
	case doNotCallListsCreateEntry:
		return http.MethodPost
	case doNotCallListsCreateList:
		return http.MethodPost
	case doNotCallListsDeleteEntry:
		return http.MethodDelete
	case doNotCallListsDetails:
		return http.MethodGet
	case doNotCallListsGetEntry:
		return http.MethodGet
	case doNotCallListsListLists:
		return http.MethodGet
	case doNotCallListsUpdateEntries:
		return http.MethodPatch
	case doNotCallListsUpdateSingleEntry:
		return http.MethodPatch

	// Record lists API methods
	case recordListsCreateList:
		return http.MethodPost
	case recordListsCreateMultipleRecords:
		return http.MethodPost
	case recordListsCreateRecord:
		return http.MethodPost
	case recordListsCreateSignedUrlForCsvUpload:
		return http.MethodPost
	case recordListsDeleteList:
		return http.MethodDelete
	case recordListsDeleteRecord:
		return http.MethodDelete
	case recordListsGetAll:
		return http.MethodGet
	case recordListsGetListDetails:
		return http.MethodGet
	case recordListsGetRecord:
		return http.MethodGet
	case recordListsUpdateMultipleRecords:
		return http.MethodPatch
	case recordListsUpdateRecord:
		return http.MethodPatch
	case recordListsUploadObject:
		return http.MethodPatch

	// Attributes API methods
	case attributesAddUserAssociation:
		return http.MethodPost
	case attributesCreateAttribute:
		return http.MethodPost
	case attributesCreateCategory:
		return http.MethodPost
	case attributesDeleteCategory:
		return http.MethodDelete
	case attributesDeleteUserAssociation:
		return http.MethodDelete
	case attributesGetAttributeDetails:
		return http.MethodGet
	case attributesGetCategoryList:
		return http.MethodGet
	case attributesGetList:
		return http.MethodGet
	case attributesGetUserAttributeList:
		return http.MethodGet
	case attributesListUsers:
		return http.MethodPost
	case attributesUpdateAttribute:
		return http.MethodPut
	case attributesUpdateCategory:
		return http.MethodPatch

	// Ring Groups API methods
	case ringGroupsList:
		return http.MethodGet
	case ringGroupsGetAssignedUsers:
		return http.MethodGet

	// Messages API methods
	case messagesSendMessage:
		return http.MethodPost

	// Phone Validation API methods
	case phoneValidationGetInsights:
		return http.MethodGet

	// Voice Biometrics API methods
	case voiceBiometricsEnrollWithPhraseId:
		return http.MethodPut
	case voiceBiometricsRemoveEnrollmentInformation:
		return http.MethodDelete
	case voiceBiometricsGetConsentStatus:
		return http.MethodGet
	case voiceBiometricsSetConsentStatus:
		return http.MethodPut

	// Unknown
	default:
		return ""
	}
}

func (t requestType) getRequestScope() scope {

	switch t {
	// Reports API paths
	case reportsExecute:
		return reportsWrite
	case reportsGet:
		return reportsRead
	case reportsCheckStatus:
		return reportsRead
	case reportsDelete:
		return reportsWrite
	case reportsListFromType:
		return reportsRead

	// Users API paths
	case usersList:
		return usersRead
	case usersGetDetails:
		return usersRead
	case usersGetInfo:
		return usersRead

	// Flows API paths
	case flowsExecute:
		return flowInteractionsStart

	// Contacts API paths
	case contactsGetList:
		return contactsRead
	case contactsGetById:
		return contactsRead
	case contactsRemoveById:
		return contactsRead
	case contactsListIntegrations:
		return contactsRead

	// Callbacks API paths
	case callbacksRequest:
		return callbackWrite

	// Do Not Call Lists API paths
	case doNotCallListsCreateEntry:
		return doNotCallListsManage
	case doNotCallListsCreateList:
		return doNotCallListsManage
	case doNotCallListsDeleteEntry:
		return doNotCallListsManage
	case doNotCallListsDetails:
		return doNotCallListsManage
	case doNotCallListsGetEntry:
		return doNotCallListsManage
	case doNotCallListsListLists:
		return doNotCallListsManage
	case doNotCallListsUpdateEntries:
		return doNotCallListsManage
	case doNotCallListsUpdateSingleEntry:
		return doNotCallListsManage

	// Record Lists API paths
	case recordListsCreateList:
		return recordListsManage
	case recordListsCreateMultipleRecords:
		return recordListsManage
	case recordListsCreateRecord:
		return recordListsManage
	case recordListsCreateSignedUrlForCsvUpload:
		return recordListsManage
	case recordListsDeleteList:
		return recordListsManage
	case recordListsDeleteRecord:
		return recordListsManage
	case recordListsGetAll:
		return recordListsManage
	case recordListsGetListDetails:
		return recordListsManage
	case recordListsGetRecord:
		return recordListsManage
	case recordListsUpdateMultipleRecords:
		return recordListsManage
	case recordListsUpdateRecord:
		return recordListsManage
	case recordListsUploadObject:
		return recordListsManage

	// Attributes API scopes
	case attributesAddUserAssociation:
		return attributesWrite
	case attributesCreateAttribute:
		return attributesWrite
	case attributesCreateCategory:
		return attributesWrite
	case attributesDeleteCategory:
		return attributesWrite
	case attributesDeleteUserAssociation:
		return attributesWrite
	case attributesGetAttributeDetails:
		return attributesRead
	case attributesGetCategoryList:
		return attributesRead
	case attributesGetList:
		return attributesRead
	case attributesGetUserAttributeList:
		return attributesRead
	case attributesListUsers:
		return attributesRead
	case attributesUpdateAttribute:
		return attributesWrite
	case attributesUpdateCategory:
		return attributesWrite

	// Ring Groups API scopes
	case ringGroupsList:
		return ringGroupsRead
	case ringGroupsGetAssignedUsers:
		return userRingGroupsRead

	// Messages API scopes
	case messagesSendMessage:
		return messagesWrite

	// Phone Validation API scopes
	case phoneValidationGetInsights:
		return identityPhoneValidationRead

	// Voice Biometrics API scopes
	case voiceBiometricsEnrollWithPhraseId:
		return voiceBiometricsEnrollmentWrite
	case voiceBiometricsRemoveEnrollmentInformation:
		return voiceBiometricsEnrollmentWrite
	case voiceBiometricsGetConsentStatus:
		return voiceBiometricsEnrollmentRead
	case voiceBiometricsSetConsentStatus:
		return voiceBiometricsEnrollmentWrite

	// Unknown
	default:
		return unknownScope
	}
}
