package talkdesk

import (
	"encoding/json"
	"errors"
	"time"
)

type UserApiRequest struct {
	client *Client
}

func (client *Client) NewUsersApiRequest() *UserApiRequest {
	c := &UserApiRequest{client: client}
	return c
}

type ListUsersRequest struct {
	OnlyCurrentAndBilledUsers *bool
	EmailFilter               *string
	PageNumber                *int
	PerPage                   *int
}

type ListUsersResponse struct {
	Embedded struct {
		Users []struct {
			Id             string     `json:"id"`
			Username       *string    `json:"username"`
			FullName       *string    `json:"full_name"`
			GivenName      *string    `json:"given_name"`
			MiddleName     *string    `json:"middle_name"`
			FamilyName     *string    `json:"family_name"`
			Active         *bool      `json:"active"`
			EmployeeNumber *string    `json:"employee_number"`
			CostCenter     *string    `json:"cost_center"`
			Timezone       *string    `json:"timezone"`
			PhoneNumbers   []string   `json:"phone_numbers"`
			ExternalId     *string    `json:"external_id"`
			ManagerId      *string    `json:"manager_id"`
			CreatedAt      *time.Time `json:"created_at"`
			ModifiedAt     *time.Time `json:"modified_at"`
			Links          struct {
				Self struct {
					Href string `json:"href"`
				} `json:"self"`
				Manager struct {
					Href string `json:"href"`
				} `json:"manager"`
			} `json:"_links"`
		} `json:"users"`
	} `json:"_embedded"`
	Count   int `json:"count"`
	Total   int `json:"total"`
	Page    int `json:"page"`
	PerPage int `json:"per_page"`
	Links   struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Next struct {
			Href string `json:"href"`
		} `json:"next"`
		First struct {
			Href string `json:"href"`
		} `json:"first"`
		Last struct {
			Href string `json:"href"`
		} `json:"last"`
	} `json:"_links"`
}

func (userRequest *UserApiRequest) ListUsers(request ListUsersRequest, response *ListUsersResponse) error {
	var err error
	t := usersList
	client := userRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}
	q := &queryParamValues{}
	q.intValues = map[string]int{}

	if request.EmailFilter != nil {
		q.stringValues = map[string][]string{"email": {*request.EmailFilter}}
	}
	if request.OnlyCurrentAndBilledUsers != nil {
		q.boolValues = map[string]bool{"active": *request.OnlyCurrentAndBilledUsers}
	}
	if request.PerPage != nil {
		q.intValues["per_page"] = *request.PerPage
	}
	if request.PageNumber != nil {
		q.intValues["page"] = *request.PageNumber
	}
	p := &performHttpRequestParams{
		client: client,
	}

	data, err := client.performHttpRequest(t, p, q)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(data, response); err != nil {
		return err
	}

	return nil
}

type GetUserDetailsRequest struct {
	UserId string
}

type GetUserDetailsResponse struct {
	Id             string    `json:"id"`
	UserName       string    `json:"user_name"`
	FullName       *string   `json:"full_name"`
	GivenName      *string   `json:"given_name"`
	MiddleName     *string   `json:"middle_name"`
	FamilyName     *string   `json:"family_name"`
	Active         *bool     `json:"active"`
	EmployeeNumber *string   `json:"employee_number"`
	CostCenter     *string   `json:"cost_center"`
	Timezone       *string   `json:"timezone"`
	PhoneNumbers   *[]string `json:"phone_numbers"`
	ExternalId     *string   `json:"external_id"`
	ManagerId      *string   `json:"manager_id"`
	ModifiedAt     *string   `json:"modified_at"`
	CreatedAt      *string   `json:"created_at"`
	Links          struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
		Manager struct {
			Href string `json:"href"`
		} `json:"manager"`
	} `json:"_links"`
}

func (userRequest *UserApiRequest) GetUserDetails(request GetUserDetailsRequest, response *GetUserDetailsResponse) error {
	var err error
	t := usersGetDetails
	client := userRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}

	if request.UserId == "" {
		err = errors.New("no user ID provided in GetUserDetails request")
		return err
	}
	p := &performHttpRequestParams{
		pathParamValues: []string{request.UserId},
		requestData:     nil,
		client:          userRequest.client,
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

type GetUserInfoResponse struct {
	Id    string `json:"id"`
	Sub   string `json:"sub"`
	Name  string `json:"name"`
	Email string `json:"email"`
	Links struct {
		Self struct {
			Href string `json:"href"`
		} `json:"self"`
	} `json:"_links"`
}

func (userRequest UserApiRequest) GetUserInfo(response *GetUserInfoResponse) error {
	var err error
	t := usersGetInfo
	client := userRequest.client
	if client == nil {
		s := "no client pointer found in repRequest %s - ListUsers(...)"
		return errors.New(s)
	}
	p := &performHttpRequestParams{
		pathParamValues: nil,
		requestData:     nil,
		client:          client,
	}

	data, err := client.performHttpRequest(t, p, nil)
	if err != nil {
		return err
	}
	if err := json.Unmarshal(data, response); err != nil {
		return err
	}

	return nil
}
