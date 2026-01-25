acme.sh --set-default-ca --server letsencrypt
export CF_API_TOKEN="GGZj61PUFdSY80JWLQNxeQLcuuK4Sd63X0C2lb24"
export CF_Token="GGZj61PUFdSY80JWLQNxeQLcuuK4Sd63X0C2lb24"
export CF_Account_ID="9ea8520a8f80e26d7cf7addbaaf49b64"
acme.sh --issue --dns dns_cf -d missbb.us -d '*.missbb.us'