certbot renew \
    --standalone \
    --preferred-challenges http-01 \
    --http-01-port 8081 \
    --cert-name db.feminahip.or.tz \
    --deploy-hook 'cat /etc/letsencrypt/live/db.feminahip.or.tz/privkey.pem /etc/letsencrypt/live/db.feminahip.or.tz/fullchain.pem > /etc/haproxy/ssl.pem && systemctl restart haproxy'
