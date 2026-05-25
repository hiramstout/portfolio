package talkdesk

type scopeTokensMap map[scope]token
type tokenResponse struct {
	RequestTimestamp int    `json:"requestTimestamp"`
	AccessToken      string `json:"accessToken"`
	ExpiresIn        int    `json:"expiresIn"`
}

type Client struct {
	tokens    scopeTokensMap
	tokenBase string
	apiBase   string
}

func NewClient() Client {
	tokenMap := make(scopeTokensMap, 20)
	client := Client{tokens: tokenMap}

	client.tokenBase = tokenRequestUrl
	client.apiBase = base

	return client
}
