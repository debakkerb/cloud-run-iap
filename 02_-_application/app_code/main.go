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
	compute "cloud.google.com/go/compute/apiv1"
	"cloud.google.com/go/compute/metadata"
	"google.golang.org/api/idtoken"
	computepb "google.golang.org/genproto/googleapis/cloud/compute/v1"
	"strconv"

	"context"
	"fmt"
	"log"
	"net/http"
	"os"
)

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

func handler(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	projectInformation, err := getProjectInformation(&ctx)
	if err != nil {
		log.Fatal(err)
	}

	serviceId, err := getServiceId(&ctx, projectInformation.ProjectID)
	if err != nil {
		log.Fatal(err)
	}

	payload, err := validateJWT(r, &ctx, serviceId, projectInformation)
	if err != nil {
		log.Fatal(err)
	}

	email := payload.Claims["email"]
	identity := payload.Claims["sub"]

	fmt.Fprintf(w, "Welcome %s!\n"+
		"Unique identifier: %s\n", email, identity)
}

func validateJWT(r *http.Request, ctx *context.Context, backendServiceId uint64, projectInformation *ProjectInformation) (*idtoken.Payload, error) {
	jwtAssertion := r.Header.Get("x-goog-iap-jwt-assertion")

	audience := fmt.Sprintf("/projects/%s/global/backendServices/%s", projectInformation.ProjectNumber, strconv.FormatUint(backendServiceId, 10))
	payload, err := idtoken.Validate(*ctx, jwtAssertion, audience)

	if err != nil {
		fmt.Printf("Error while validating payload: %v.\n", err)
		return nil, err
	}

	return payload, nil
}

func getServiceId(ctx *context.Context, projectId string) (uint64, error) {
	c, err := compute.NewBackendServicesRESTClient(*ctx)
	if err != nil {
		log.Printf("Error while retrieving the compute client: %v", err)
		return 0, err
	}
	defer c.Close()

	req := &computepb.GetBackendServiceRequest{
		Project:        projectId,
		BackendService: "lb-managed-backend",
	}

	resp, err := c.Get(*ctx, req)
	if err != nil {
		log.Printf("Error while executing the request to get the backend services: %v", err)
		return 0, err
	}

	return *resp.Id, nil
}

type ProjectInformation struct {
	ProjectID     string
	ProjectNumber string
}

func getProjectInformation(ctx *context.Context) (*ProjectInformation, error) {
	projectId, err := metadata.ProjectID()
	if err != nil {
		return nil, err
	}

	projectNumber, err := metadata.NumericProjectID()
	if err != nil {
		return nil, err
	}

	return &ProjectInformation{
		ProjectID:     projectId,
		ProjectNumber: projectNumber,
	}, nil
}
