package talkdesk

import (
	"encoding/json"
	"fmt"
	"time"
)

type RecordListRequestClient struct {
	client *Client
}

func (client *Client) NewRecordsListRequest() *RecordListRequestClient {
	return &RecordListRequestClient{client: client}
}

type GetAllRecordListsRequest struct {
	Name    *string
	Status  *bool
	Page    *int
	PerPage *int
}

type GetAllRecordListsResponse struct {
	Total      int `json:"total"`
	Page       int `json:"page"`
	TotalPages int `json:"total_pages"`
	PerPage    int `json:"per_page"`
	Count      int `json:"count"`
	Links      struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Next struct {
			Href string `json:"href"`
		} `json:"next"`
		Prev struct {
			Href string `json:"href"`
		} `json:"prev"`
		First struct {
			Href string `json:"href"`
		} `json:"first"`
		Last struct {
			Href string `json:"href"`
		} `json:"last"`
	} `json:"_links"`
	Embedded struct {
		RecordLists []struct {
			Id           string    `json:"id"`
			Name         string    `json:"name"`
			CreatedAt    time.Time `json:"created_at"`
			RecordsCount int       `json:"records_count"`
			Status       string    `json:"status"`
			AccountId    string    `json:"account_id"`
			Links        struct {
				Self struct {
					Href string `json:"href"`
				} `json:"self"`
			} `json:"_links"`
		} `json:"record_lists"`
	} `json:"_embedded"`
}

func (c RecordListRequestClient) GetAllRecordLists(request GetAllRecordListsRequest,
	response *GetAllRecordListsResponse) error {
	var err error
	t := recordListsGetAll
	p := &performHttpRequestParams{
		pathParamValues: nil,
		requestData:     true,
		client:          c.client,
	}
	q := &queryParamValues{}
	if request.Name != nil {
		q.stringValues["name"] = []string{*request.Name}
	}
	if request.Status != nil {
		q.boolValues["status"] = *request.Status
	}
	if request.Page != nil {
		q.intValues["page"] = *request.Page
	}
	if request.PerPage != nil {
		q.intValues["per_page"] = *request.PerPage
	}

	data, err := c.client.performHttpRequest(t, p, q)
	if err != nil {
		return fmt.Errorf("c.client.performHttpRequest(t, p, q):\\nt: %v\\np: %v\\nq: %v\\nerror: %v", t, p, q, err)
	}
	if err = json.Unmarshal(data, response); err != nil {
		return fmt.Errorf("json.Unmarshal(data, response):\\ndata: %v\\nerror: %v", data, err)
	}

	return nil
}
