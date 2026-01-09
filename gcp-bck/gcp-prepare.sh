#!/usr/bin/bash

SH_PROJECT=go-hello-auth
SH_PROJECT_ID=go-hello-auth-482914
SH_PROJECT_NUMBER=95844004012
SH_GITHUB_REPO=szabolcshajdara/go-hello-auth

gcloud config set project $SH_PROJECT_ID
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

gcloud iam workload-identity-pools create github-pool \
  --project=$SH_PROJECT_ID \
  --location="global" \
  --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers create-oidc github-provider \
  --project=$SH_PROJECT_ID \
  --location="global" \
  --workload-identity-pool=github-pool \
  --display-name="GitHub Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition="attribute.repository == '$SH_GITHUB_REPO'"

gcloud iam service-accounts create github-deployer \
  --project=$SH_PROJECT_ID \
  --display-name="GitHub Deployment SA"

gcloud iam service-accounts add-iam-policy-binding github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com \
  --project=$SH_PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$SH_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/OWNER/REPO"

gcloud iam service-accounts add-iam-policy-binding github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com \
  --project=$SH_PROJECT_ID \
  --role="roles/iam.serviceAccountTokenCreator" \
  --member="principalSet://iam.googleapis.com/projects/$SH_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/szabolcshajdara/$SH_PROJECT"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
--member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/iam.securityAdmin"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"
  
gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:$SH_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"
  
gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/apigateway.admin"

gcloud projects add-iam-policy-binding $SH_PROJECT_ID \
  --member="serviceAccount:github-deployer@$SH_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudfunctions.admin"