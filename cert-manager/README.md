step certificate create --profile intermediate-ca --kty=RSA "k3d Intermediate CA" k3d.crt k3d.key

openssl rsa -in k3d.key -out k3d-nopass.key

cat k3d-nopass.key | base64 -b 0
cat k3d.crt | base64 -b 0

