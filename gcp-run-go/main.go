package main

import (
	"fmt"
	"net/http"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("HelloAuth", helloAuth)
}

func helloAuth(w http.ResponseWriter, r *http.Request) {
	// 1. Mandatory CORS headers for the Static Site
	w.Header().Set("Access-Control-Allow-Origin", "https://YOUR_BUCKET_NAME.storage.googleapis.com")
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	// 2. Handle Browser Preflight
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	// 3. Logic (Only reached if IAM allows the user)
	fmt.Fprint(w, "Hello World! You have successfully authenticated via IAM.")
}
