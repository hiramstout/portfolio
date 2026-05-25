package talkdesk

import (
	"encoding/json"
	"errors"
)

type ContactsApiRequestClient struct {
	client *Client
}

func (client *Client) NewContactsApiRequest() ContactsApiRequestClient {
	contactsClient := ContactsApiRequestClient{client: client}
	return contactsClient
}

type ReadContactsRequest struct {
	Ids          []string `json:"ids"`
	Name         *string  `json:"name"`
	NameLoose    *string  `json:"name_loose"`
	Company      *string  `json:"company"`
	CompanyLoose *string  `json:"company_loose"`
	Integration  *string  `json:"integration"` // must follow integration_name:external_id regex format
	Page         *int     `json:"page"`
	PerPage      *int     `json:"per_page"`
	Phones       []string `json:"phones"` // must follow +11231231234 format
}

type ReadContactsResponse struct {
	Total    int `json:"total"`
	Embedded struct {
		Contacts []struct {
			Id      string `json:"id"`
			Name    string `json:"name"`
			Company string `json:"company"`
			Phones  []struct {
				Label  string `json:"label"`
				Number string `json:"number"`
			} `json:"phones"`
			Links struct {
				Self struct {
					Href string `json:"href"`
				} `json:"self"`
				Integrations struct {
					Href string `json:"href"`
				} `json:"integrations"`
			} `json:"_links"`
		} `json:"contacts"`
	} `json:"_embedded"`
	Page    int `json:"page"`
	PerPage int `json:"per_page"`
	Count   int `json:"count"`
	Links   struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Prev struct {
			Href string `json:"href"`
		} `json:"prev"`
		Next struct {
			Href string `json:"href"`
		} `json:"next"`
	} `json:"_links"`
}

func (contactRequest ContactsApiRequestClient) ListContacts(request ReadContactsRequest,
	response *ReadContactsResponse) error {
	var err error
	t := contactsGetList
	client := contactRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}

	q := &queryParamValues{}
	if len(request.Ids) > 0 {
		q.stringValues["ids"] = request.Ids
	}
	if len(request.Phones) > 0 {
		q.stringValues["phones"] = request.Phones
	}
	if request.Name != nil {
		q.stringValues["name"] = []string{*request.Name}
	}
	if request.NameLoose != nil {
		q.stringValues["name.loose"] = []string{*request.NameLoose}
	}
	if request.Company != nil {
		q.stringValues["company"] = []string{*request.Company}
	}
	if request.CompanyLoose != nil {
		q.stringValues["company.loose"] = []string{*request.CompanyLoose}
	}
	if request.Integration != nil {
		q.stringValues["integration"] = []string{*request.Integration}
	}
	if request.PerPage != nil {
		q.intValues["per_page"] = *request.PerPage
	}
	if request.Page != nil {
		q.intValues["page"] = *request.Page
	}

	p := &performHttpRequestParams{
		pathParamValues: nil,
		requestData:     nil,
		client:          client,
	}
	data, err := client.performHttpRequest(t, p, q)
	if err != nil {
		return err
	}
	if err = json.Unmarshal(data, response); err != nil {
		return err
	}
	return nil
}
