package talkdesk

import (
	"encoding/json"
	"errors"
)

type DoNotCallListsRequestClient struct {
	client *Client
}

func (client *Client) NewDoNotCallListsRequest() DoNotCallListsRequestClient {
	contactsClient := DoNotCallListsRequestClient{client: client}
	return contactsClient
}

type CreateDoNotCallListsRequest struct {
	Name        string `json:"name"`
	CsvMetadata struct {
		Filename    string `json:"filename"`
		ByteSize    int    `json:"byte_size"`
		Checksum    string `json:"checksum"`
		ContentType string `json:"content_type"`
	} `json:"csv_metadata"`
}

type CreateDoNotCallListsResponse struct {
	Id        string `json:"id"`
	Name      string `json:"name"`
	Status    string `json:"status"`
	SignedUrl string `json:"signed_url"`
	Links     struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Upload struct {
			Href string `json:"href"`
		} `json:"upload"`
	} `json:"_links"`
}

func (DoNotCallListsRequest DoNotCallListsRequestClient) ExecuteFlows(request CreateDoNotCallListsRequest,
	response *CreateDoNotCallListsResponse) error {

	t := doNotCallListsCreateList
	client := DoNotCallListsRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - DoNotCallLists(...)"
		return errors.New(s)
	}
	p := &performHttpRequestParams{
		pathParamValues: nil,
		requestData:     request,
		client:          client,
	}

	data, err := client.performHttpRequest(t, p, nil)
	if err != nil {
		return err
	}

	if err = json.Unmarshal(data, response); err != nil {
		return err
	}

	return nil

}
