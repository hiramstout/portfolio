package talkdesk

import "errors"

type CallbackRequestClient struct {
	client *Client
}

func (client *Client) NewCallbacksApiRequest() CallbackRequestClient {
	callbackClient := CallbackRequestClient{client: client}
	return callbackClient
}

type RequestCallbackRequestData struct {
	TalkdeskPhoneNumber string `json:"talkdesk_phone_number"`
	ContactPhoneNumber  string `json:"contact_phone_number"`
}

func (callbackApiRequest *CallbackRequestClient) RequestCallback(data *RequestCallbackRequestData) error {
	t := callbacksRequest
	client := callbackApiRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}
	p := &performHttpRequestParams{
		pathParamValues: nil,
		requestData:     data,
		client:          client,
	}

	if _, err := client.performHttpRequest(t, p, nil); err != nil {
		return err
	}

	return nil
}
