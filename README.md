# go-hello-auth
Go Hello World with authentication

User should be authenticated with Google Authentication.

The solution can be deployed manually with the following steps.

- Start codespace
- Connect the codespace with VSCode
- Execute the following commands:
  - gcloud functions deploy go-hello-auth \  
    --gen2 \  
    --runtime go125 \  
    --region europe-west1 \  
    --project go-hello-auth-482914 \  
    --entry-point HelloAuth \  
    --trigger-http \  
    --source gcp-run-go \  
    --no-allow-unauthenticated
  - gcloud api-gateway apis create go-hello-auth-api \  
    --project=go-hello-auth-482914
  - gcloud iam service-accounts create api-gw-backend-sa \  
    --display-name="API Gateway Backend Service Account"
  - gcloud functions add-iam-policy-binding go-hello-auth \  
    --region europe-west1 \  
    --member "serviceAccount:api-gw-backend-sa@go-hello-auth-482914.iam.gserviceaccount.com" \  
    --role "roles/cloudfunctions.invoker"
  - gcloud functions add-iam-policy-binding go-hello-auth \  
   --region europe-west1 \  
   --member "serviceAccount:api-gw-backend-sa@go-hello-auth-482914.iam.gserviceaccount.com" \  
   --role "roles/run.invoker"
  - gcloud api-gateway api-configs create go-hello-auth-api-config \  
    --api=go-hello-auth-api \  
    --openapi-spec=gcp-apigw/openapi.yaml \  
    --backend-auth-service-account=api-gw-backend-sa@go-hello-auth-482914.iam.gserviceaccount.com \  
    --project=go-hello-auth-482914
  - gcloud api-gateway gateways create go-hello-auth-gateway \  
    --api=go-hello-auth-api \  
    --api-config=go-hello-auth-api-config \  
    --location=europe-west1 \  
    --project=go-hello-auth-482914
  - gcloud storage buckets create gs://go-hello-auth-web \  
    --location=europe-west1 \  
    --uniform-bucket-level-access
  - gcloud storage cp gcp-bck/index.html gs://go-hello-auth-web/
  - gcloud storage buckets add-iam-policy-binding gs://go-hello-auth-web \  
    --member="allUsers" \  
    --role="roles/storage.objectViewer"
  - gcloud storage buckets update gs://go-hello-auth-web --web-main-page-suffix=index.html
 
  ## Optional: user check via Google IAM

  - Go code should not contain the user check (step 3 with all the substeps).
  - The Gateway API should not be deployed with service account usage, but pass through the original identity:
    - Modify the openapi.yaml and add the disable_auth flag:
      ```yaml
      /hello:
        get:
          operationId: hello
          x-google-backend:
            address: https://europe-west1-go-hello-auth-482914.cloudfunctions.net/go-hello-auth
            disable_auth: true # This tells the gateway to pass the user's identity through
          security:
            - google_id_token: []
          ...
    - Deploy it without service account usage:  
      gcloud api-gateway api-configs create go-hello-auth-api-config \  
      --api=go-hello-auth-api \  
      --openapi-spec=gcp-apigw/openapi.yaml \  
      --project=go-hello-auth-482914
    - Remove service account rights:  
      - gcloud functions remove-iam-policy-binding go-hello-auth \  
        --region europe-west1 \  
        --member "serviceAccount:api-gw-backend-sa@go-hello-auth-482914.iam.gserviceaccount.com" \  
        --role "roles/cloudfunctions.invoker"
      - gcloud functions remove-iam-policy-binding go-hello-auth \  
        --region europe-west1 \  
        --member "serviceAccount:api-gw-backend-sa@go-hello-auth-482914.iam.gserviceaccount.com" \  
        --role "roles/run.invoker"
    - Add rights to dedicated users to call the function:
      - gcloud functions add-iam-policy-binding go-hello-auth \  
        --region europe-west1 \  
        --member "user1@gmail.com" \  
        --role "roles/cloudfunctions.invoker"
      - gcloud functions add-iam-policy-binding go-hello-auth \  
        --region europe-west1 \  
        --member "user1@gmail.com" \  
        --role "roles/run.invoker"
            
  
