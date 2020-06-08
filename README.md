This starts a CP WebAPI gateway and keeps you logged in.

# Usage #
You need to set the following environment variables:
* USERNAME
* PASSWORD

You may use a command like
`docker run -d --rm --name=cldmtv-trade-gateway -p5000:5000 --env USERNAME=****** --env PASSWORD=************** cloudmative/cp-webapi-gateway`
