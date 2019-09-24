# RedTeamDeploy
Deploy redteam infrastructure using Docker Compose. RTD focuses on allowing infrastructure to be rapidly setup and deployed.
RTD has multiple different [deployment options](#Deployment-Options). Each deployment is a different docker-compose file that presumably is to be run on a unique server.



## Deployment Options

### Cloud Deployment - `docker-compose.yml`
These servers are meant to be external upstream services and agregation points. They are deployed publically and with domain names. Each one is hosted on port 80 reverse proxied behind an NGINX container. See [Cloud Deployment](docs/cloud.md) for full deployment information.

- [Crowd Control](https://github.com/degenerat3/crowdcontrol) - Command and Control Server
- [Chainsaw](https://github.com/degenerat3/chainsaw) - Victim information collector and forwarder
- [The Library](https://github.com/RITRedteam/TheLibrary) - Redteam CDN and link generator
- [Pwnboard](https://github.com/micahjmartin/pwnboard) - Beacon and Access tracking
- [The Ark](https://github.com/RITRedteam/TheArk) - Internal IP adresses management
- [Sawmill](https://github.com/RITRedteam/Sawmill) _(OPTIONAL)_ - Redteam Logging server


### Interal Deployment - `docker-compose.internal.yml`
Deploys internal services that require private IP addresses. Most often deployed day-of on a local machine. See [Local Deployment](docs/cloud.md) for full deployment information.

- [Sangheili](https://github.com/ritredteam/sangheili) - Proxying service
- Multiple [Halos](https://github.com/ritredteam/TheArkHalo) - Reverse proxying services for each/C2 as needed
