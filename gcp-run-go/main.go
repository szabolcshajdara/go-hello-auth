package goauth

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

// Define your allowed users here
var allowedUsers = map[string]bool{
	"szabolcs.hajdara@gmail.com": true,
	"sleet.eu@gmail.com":         true,
}

func init() {
	functions.HTTP("HelloAuth", helloAuth)
}

func helloAuth(w http.ResponseWriter, r *http.Request) {
	// 1. Set CORS headers
	w.Header().Set("Access-Control-Allow-Origin", "https://storage.googleapis.com") // Or "*"
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	// 2. Handle Preflight
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	// 3.1. Get the User Info header from API Gateway
	encodedUserInfo := r.Header.Get("X-Apigateway-Api-Userinfo")
	if encodedUserInfo == "" {
		http.Error(w, "Unauthorized: No user info found", http.StatusUnauthorized)
		return
	}

	// 3.2. Decode the Base64 header
	decodedBytes, err := base64.RawURLEncoding.DecodeString(encodedUserInfo)
	if err != nil {
		http.Error(w, "Internal Server Error: Failed to decode user info", http.StatusInternalServerError)
		return
	}

	// 3.3. Parse the JSON to get the email
	var userInfo struct {
		Email string `json:"email"`
	}
	if err := json.Unmarshal(decodedBytes, &userInfo); err != nil {
		http.Error(w, "Internal Server Error: Failed to parse user info", http.StatusInternalServerError)
		return
	}

	/* Use only if user identity is checked by the function itself
	// 3.4. Check the Allow List
	if !allowedUsers[userInfo.Email] {
		http.Error(w, fmt.Sprintf("Forbidden: User %s is not allowed", userInfo.Email), http.StatusForbidden)
		return
	}
	*/

	// 4. Logic
	fmt.Fprint(w, "Hello, World from "+userInfo.Email+"!")
}
