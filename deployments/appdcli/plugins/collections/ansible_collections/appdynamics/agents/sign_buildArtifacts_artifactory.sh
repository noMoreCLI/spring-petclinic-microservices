#!/usr/bin/env bash

CURRENT_DIR=${PWD}
echo "current working DIR is $CURRENT_DIR"

# Define the path to the folder containing the files
dist_folder_path="$CURRENT_DIR/dist"

# For downloading the certificate for digital signing
ARTIFACT_REPO_URL="https://artifactory.bare.appdynamics.com/artifactory"
PFX_FILE_NAME="agent-signing-certificate.pfx"
PFX_ARTIFACT_LOCATION="third-party-product-dependencies/com/digicert/signing-certificate-windows/1.0.0/signing-certificate-windows-1.0.0.pfx"

# Download the PFX file for signing
curl -u $ARTIFACT_REPO_USERNAME:$ARTIFACT_REPO_PASSWORD -o $PFX_FILE_NAME  $ARTIFACT_REPO_URL"/"$PFX_ARTIFACT_LOCATION

# DEBUG
echo "Downloaded PFX file:" $(ls -atrl $PFX_FILE_NAME)

# Convert .pfx file to key
openssl pkcs12 -in $PFX_FILE_NAME -nocerts -out appdynamics.pem -nodes -passin env:PFX_PASSWORD -passout pass:
echo "Converting .pfx file to pem file:" $(ls -atrl appdynamics.pem)

# Loop through all the files in the folder
for file in $dist_folder_path/*; do
  # Digitally sign before publishing
  /usr/bin/openssl dgst -sha256 -sign appdynamics.pem -out $file".sig"  $file
  echo "signature file created:" $(ls -atrl $file".sig")
done