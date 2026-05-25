package talkdesk

import (
	"encoding/json"
	"errors"
)

type FlowsApiRequestClient struct {
	client *Client
}

func (client *Client) NewFlowsApiRequest() FlowsApiRequestClient {
	flowsClient := FlowsApiRequestClient{client: client}
	return flowsClient
}

type ExecuteFlowsRequest struct {
	OrderID string
	FlowID  string
}

type ExecuteFlowsResponse struct {
	InteractionID string `json:"interaction_id"`
	FlowVersionID string `json:"flow_version_id"`
}

type executeFlowsMarshaller struct {
	OrderID string `json:"orderID"`
}

func (flowsRequest FlowsApiRequestClient) ExecuteFlows(request ExecuteFlowsRequest,
	response *ExecuteFlowsResponse) error {
	marshaller := executeFlowsMarshaller{
		OrderID: request.OrderID,
	}
	t := flowsExecute
	client := flowsRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}
	p := &performHttpRequestParams{
		pathParamValues: []string{request.FlowID},
		requestData:     marshaller,
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
