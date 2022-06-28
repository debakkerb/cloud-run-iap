package main

/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import (
	"context"
	"fmt"
	"google.golang.org/api/idtoken"
	"log"
	"net/http"
	"os"
)

var clientId = os.Getenv("CLIENT_ID")
var secretId = os.Getenv("CLIENT_SECRET")
var projectId = os.Getenv("PROJECT_ID")
var projectNumber = os.Getenv("PROJECT_NUMBER")

func main() {
	log.Print("Starting server ...")
	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s.", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}

}

func validateJWT(iapJWT string) error {
	ctx := context.Background()
	audience := fmt.Sprintf("/projects/%s/global/backendServices/%s", projectNumber, projectId)

	fmt.Println("===============================================")
	fmt.Println(iapJWT)
	fmt.Println("===============================================")

	payload, err := idtoken.Validate(ctx, iapJWT, audience)
	if err != nil {
		return err
	}

	fmt.Println(payload)

	return nil
}

func handler(w http.ResponseWriter, r *http.Request) {
	jwtAssertion := r.Header.Get("x-goog-iap-jwt-assertion")
	validateJWT(jwtAssertion)

	name := os.Getenv("NAME")
	if name == "" {
		name = "World"
	}

	fmt.Fprintf(w, "Hello %s!\n", name)
}
