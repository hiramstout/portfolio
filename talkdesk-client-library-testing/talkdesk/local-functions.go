package talkdesk

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"regexp"
	"strconv"
	"time"
)

// TODO max per page is 200 for query parameters

func (client *Client) compileRequestUrl(t requestType, pathParamValues []string) (*url.URL, error) {
	var err error

	if t.getRequestPath() == "" {
		return nil, fmt.Errorf("fmt.Sprintf(\"t.getRequestPath(): no path returned for request type\")")
	}

	if t.getPathParamNames() != nil {
		if pathParamValues != nil {
			if len(pathParamValues) < len(t.getPathParamNames()) {
				s := fmt.Sprintf("not enough paramters provided for %v request. "+
					"# provided: %v, # required: %v, provided values: %v, needed parameter names: %v",
					t, len(pathParamValues), len(t.getPathParamNames()), pathParamValues,
					t.getPathParamNames())
				err := errors.New(s)
				return nil, err
			}
		} else {
			s := fmt.Sprintf("parameters provided for %v request when they were not needed. "+
				"# provided: %v, # required: %v, provided values: %v, needed parameter names: %v",
				t, 0, len(t.getPathParamNames()), pathParamValues,
				t.getPathParamNames())
			err = errors.New(s)
			return nil, err
		}
	}

	s := client.apiBase + t.getRequestPath()

	for i, name := range t.getPathParamNames() {
		r, err := regexp.Compile(fmt.Sprintf("{%v}", name))
		if err != nil {
			return nil, fmt.Errorf("regexp.Compile(fmt.Sprintf(\"{%v}\", name)):\\nname: %v\\nerror: %v", name, err)
		}
		s = r.ReplaceAllString(s, pathParamValues[i])
	}

	u, err := url.ParseRequestURI(s)
	if err != nil {
		return nil, fmt.Errorf("url.ParseRequestURI(s):\\ns: %v\\nerr: %v", s, err)
	}

	return u, nil
}

func (client *Client) generateTalkdeskToken(t requestType) error {
	dereffedClient := *client
	var err error

	if dereffedClient.tokens == nil {
		return fmt.Errorf("dereffedClient.tokens: no token map in client")
	}
	if t.getRequestScope().String() == "" {
		return fmt.Errorf("fmt.Sprintf(\"t.getRequestScope().String() == \\\"\\\": no request scope returned\")")
	}

	type requestScopes struct {
		Scopes []string `json:"scopes"`
	}

	requestScopesStruct := &requestScopes{Scopes: []string{t.getRequestScope().String()}}

	sendBody, err := json.Marshal(requestScopesStruct)
	if err != nil {
		return fmt.Errorf("json.Marshal(requestScopesStruct): %v", err)
	}

	response, err := http.Post(client.tokenBase, "application/json", bytes.NewReader(sendBody))
	if err != nil {
		return fmt.Errorf("http.Post(...): %v", err)
	}
	body, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return fmt.Errorf("ioutil.ReadAll(response.Body): %v", err)
	}
	defer func(response *http.Response) {
		err = response.Body.Close()
	}(response)
	if err = checkResponseStatusCode(response, t); err != nil {
		err = errors.New(fmt.Sprintf("%s - Response: %s - Request: %s", err, string(body), string(sendBody)))
		return fmt.Errorf("checkResponseStatusCode(response, t): %v", err)
	}
	var tokenR tokenResponse
	if err = json.Unmarshal(body, &tokenR); err != nil {
		return fmt.Errorf("json.Unmarshal(body, &tokenR): %v", err)
	}

	if t := tokenR.AccessToken; len(t) == 0 {
		return errors.New(fmt.Sprintf("token length is zero - %v", string(body)))
	}
	expiresIn, err := time.ParseDuration(strconv.Itoa(tokenR.ExpiresIn) + "s")
	if err != nil {
		return fmt.Errorf("time.ParseDuration(strconv.Itoa(tokenR.ExpiresIn) + \"s\"): %v", err)
	}

	token := token{
		expirationTime: time.Now().Add(expiresIn),
		key:            tokenR.AccessToken,
	}
	dereffedClient.tokens[t.getRequestScope()] = token

	return err
}

func checkResponseStatusCode(response *http.Response, requestType requestType) error {
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return fmt.Errorf("request %v returned a non-200 status code: %v", requestType, response.StatusCode)
	}

	return nil
}

// FIXME causing token request loop
type queryParamValues struct {
	stringValues map[string][]string
	intValues    map[string]int
	boolValues   map[string]bool
	enumValues   map[string]any
}

func (t requestType) compileQueryParams(url string, queryValues *queryParamValues) (string, error) {
	// url.QueryEscape()
	escapedParameters := make([]string, 0, 20)

	if t.getQueryParamNames() != nil {
		paramStruct := *t.getQueryParamNames()
		for _, paramDef := range paramStruct.stringFields {
			if value, ok := queryValues.stringValues[paramDef.name]; paramDef.isMandatory && (!ok || len(value) == 0) {
				return "", fmt.Errorf("no value provided for mandatory query parameter %v", paramDef.name)
			} else if ok {
				maxIteratorCount := 1
				if paramDef.isMultiValue {
					maxIteratorCount = len(value)
				}
				for i := 1; i <= maxIteratorCount; i += 1 {
					if paramDef.regexConstraint != nil && !paramDef.regexConstraint.MatchString(value[i]) {
						return "", fmt.Errorf("value %v provided for query parameter %v. value must conform to "+
							"regex formula %v", value[i], paramDef.name, paramDef.regexConstraint.String())
					} else {
						s := paramDef.name + "=" + value[i]
						escapedParameters = append(escapedParameters, s)
					}
				}
			}
		}
		for _, paramDef := range paramStruct.intFields {
			if value, ok := queryValues.intValues[paramDef.name]; paramDef.isMandatory && !ok {
				return "", fmt.Errorf("no value provided for mandatory query parameter %v", paramDef.name)
			} else if ok {
				if paramDef.highConstraint != nil && value > *paramDef.highConstraint {

					return "", fmt.Errorf("value > *paramDef.highConstraint --- Value: %v, Max: %v ",
						value, paramDef.highConstraint)
				} else if paramDef.lowConstraint != nil && value < *paramDef.lowConstraint {

					return "", fmt.Errorf("value < *paramDef.lowConstraint --- Value: %v, Min: %v ",
						value, *paramDef.lowConstraint)
				} else {
					s := paramDef.name + "=" + strconv.Itoa(value)
					escapedParameters = append(escapedParameters, s)
				}
			}
		}
		for _, paramDef := range paramStruct.boolFields {
			if value, ok := queryValues.boolValues[paramDef.name]; paramDef.isMandatory && !ok {
				return "", fmt.Errorf("no value provided for mandatory query parameter %v", paramDef.name)
			} else {
				var stringValue string
				if value == true {
					stringValue = "true"
				} else {
					stringValue = "false"
				}
				s := paramDef.name + "=" + stringValue
				escapedParameters = append(escapedParameters, s)
			}
		}
		for _, paramDef := range paramStruct.enumFields {
			if enum, ok := queryValues.enumValues[paramDef.name]; paramDef.isMandatory && !ok {
				return "", fmt.Errorf("no value provided for mandatory query parameter %v", paramDef.name)
			} else if assertedType, ok := (enum).(qpEnumInterface); !ok {
				return "", fmt.Errorf("assertedType, ok := (enum).(qpEnumInterface) not ok --- " +
					"must be query parameter enum with String() method")
			} else if value, err := paramDef.enumType(assertedType); err != nil {
				return "", fmt.Errorf("if value, err := paramDef.enumType(assertedType) --- err: %v", err)
			} else {
				s := paramDef.name + "=" + value
				escapedParameters = append(escapedParameters, s)
			}
		}
	}
	if len(escapedParameters) > 0 {
		url = url + "?"
		for i := 0; i <= len(escapedParameters)-1; i += 1 {
			if i < len(escapedParameters)-1 {
				url = url + escapedParameters[i] + "&"
			} else {
				url = url + escapedParameters[i]
			}
		}
	}

	return url, nil
}

type performHttpRequestParams struct {
	pathParamValues []string
	requestData     interface{}
	client          *Client
}

// FIXME Multiple page href link options

func (client *Client) performHttpRequest(t requestType, params *performHttpRequestParams,
	queryParams *queryParamValues) ([]byte, error) {
	var err error
	dereffedClient := *client
	dereffedParams := *params

	requestUrl, err := client.compileRequestUrl(t, dereffedParams.pathParamValues)
	if err != nil {
		return nil, fmt.Errorf("client.compileRequestUrl(t, dereffedParams.pathParamValues):\\nt: %v\\ndereffedParams.pathParamValues: %v\\nerror: %v",
			t, dereffedParams.pathParamValues, err)
	}
	urlString := requestUrl.String()
	queryCompiledUri, err := t.compileQueryParams(urlString, queryParams)
	if err != nil {
		return nil, fmt.Errorf("t.compileQueryParams(urlString, queryParams) --- err: %v", err)
	}

	var body []byte
	if dereffedParams.requestData != nil {
		body, err = json.Marshal(dereffedParams.requestData)
		if err != nil {
			return nil, fmt.Errorf("json.Marshal(dereffedParams.requestData):\\ndereffedParams.requestData: %v\\nerror: %v",
				dereffedParams.requestData, err)
		}
	}

	headerSlice := t.getRequestHeaders()
	headers := make(map[string][]string)
	for _, h := range headerSlice {
		mapKey := h.getHeaderKey()
		mapValue := h.getHeaderValue()
		headers[mapKey] = mapValue
	}
	if headers == nil {
		return nil, fmt.Errorf("client.getHeaders(t):\\nt: %v, error: %v", t, err)
	}
	tokens := dereffedClient.tokens

	token, ok := tokens[t.getRequestScope()]
	if ok == false {
		if err = client.generateTalkdeskToken(t); err != nil {
			return nil, fmt.Errorf("client.generateTalkdeskToken(t): %v", err)
		}
		token = dereffedParams.client.tokens[t.getRequestScope()]
	} else if token.expirationTime.Unix() < time.Now().Unix() {
		if err = client.generateTalkdeskToken(t); err != nil {
			return nil, fmt.Errorf("client.generateTalkdeskToken(t): %v", err)
		}
		token = dereffedParams.client.tokens[t.getRequestScope()]
	}

	headers["authorization"] = []string{fmt.Sprintf("bearer %v", token.key)}
	method := t.getRequestMethod()
	if method == "" {
		return nil, fmt.Errorf("client.getMethod(t):\\nt: %v\\nerror: %v", t, err)
	}

	httpClient := &http.Client{}
	var request *http.Request
	if body != nil {
		request, err = http.NewRequest(method, queryCompiledUri, bytes.NewReader(body))
		if err != nil {
			return nil, fmt.Errorf("http.NewRequest(method, queryCompiledUri, bytes.NewReader(body)): %v\\n"+
				"method: %v, queryCompiledUri: %v, body: %v", err, method, queryCompiledUri, string(body))
		}
	} else {
		request, err = http.NewRequest(method, queryCompiledUri, nil)
		if err != nil {
			return nil, fmt.Errorf("http.NewRequest(method, queryCompiledUri, nil): %v\\n"+
				"method: %v, queryCompiledUri: %v", err, method, queryCompiledUri)
		}
	}
	request.Header = headers

	response, err := httpClient.Do(request)
	if err != nil {
		return nil, fmt.Errorf("httpClient.Do(request): %v\\nrequest: %v\\nuri:%v\\nurl:%v", err, request, queryCompiledUri,
			requestUrl.String())
	}
	if err = checkResponseStatusCode(response, t); err != nil {
		body, err = ioutil.ReadAll(response.Body)
		if err != nil {
			return nil, fmt.Errorf("checkResponseStatusCode(response, t):\\nresponse: %v\\nt: %v\\nerror: %v", response, t, err)
		}

		s := string(body)
		err = fmt.Errorf("checkResponseStatusCode(response, t) - %v:\\nresponse: %v\\nt: %v\\nbody: %v\\nerror: %v",
			response, t, response.StatusCode, s, err)
		return nil, err
	}

	var responseBody []byte
	defer response.Body.Close()

	responseBody, err = ioutil.ReadAll(response.Body)
	if err != nil {
		return nil, fmt.Errorf("ioutil.ReadAll(response.Body): %v\\nresponse.Body: %v", err, response.Body)
	}

	return responseBody, err
}
