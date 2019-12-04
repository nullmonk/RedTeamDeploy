# RedTeamDeploy
Deploy redteam infrastructure using Docker Compose. RTD focuses on allowing infrastructure to be rapidly setup and deployed.
RTD has multiple different [deployment options](#Deployment-Options). Each deployment is a different docker-compose file that presumably is to be run on a unique server.


## Notes and Warnings
__Modification__  
Each of these services are meant to work together in a group. If you want to deploy a single service from the list, it will be best just to use the Dockerfile for the service as opposed to using only parts of these deployments.

__Security__  
These services are meant for Red/Blue security competitions, they will be running for, at most, a few days. They are hacked together, crash, and may contain security issues and not-best-practice deployments. __THEY ARE NOT MEANT FOR PRODUCTION OF ANY KIND__

__Scale__  
These services are, for the most part, very tiny. For the cloud deployment, all of the services can reasonably be deployed on a box with 4GB of RAM and a few GB of storage. You COULD run them on seperate hosts but for the most part that should not be an issue.

__Improvements__  
There are other unique tools which could help with our deployments. OInvestigate these further to determine usability:
- https://github.com/jwilder/nginx-proxy
- https://github.com/khast3x/Redcloud

## Deployment Options

### Cloud Deployment
These servers are meant to be external upstream services and agregation points. They are deployed publically and with domain names. Each one is hosted on port 80 reverse proxied behind an NGINX container. See [Cloud Deployment](docs/cloud.md) for full deployment information.

- [Crowd Control](https://github.com/degenerat3/crowdcontrol) - Command and Control Server
- [Chainsaw](https://github.com/degenerat3/chainsaw) - Victim information collector and forwarder
- [The Library](https://github.com/RITRedteam/TheLibrary) - Redteam CDN and link generator
- [Pwnboard](https://github.com/micahjmartin/pwnboard) - Beacon and Access tracking

- [Sawmill](https://github.com/RITRedteam/Sawmill) _(OPTIONAL)_ - Redteam Logging server


### Internal Deployment
Deploys internal services that require private IP addresses. Most often deployed day-of on a local machine. See [Internal Deployment](docs/internal.md) for full deployment information.

- [Sangheili](https://github.com/ritredteam/sangheili) - Proxying service
- [The Ark](https://github.com/RITRedteam/TheArk) - Internal IP adresses management
- Multiple [Halos](https://github.com/ritredteam/TheArkHalo) - Reverse proxying services for each C2 as needed


### Running and Setup
Running a deployment option should be as simple as starting that docker-compose file. But first, make sure you have completed the following steps to get your competition going:
- [ ] Update the [pwnboard topology](deployments/images/pwnboard/README.md)
- [ ] Set up the correct domains in [`images/proxy/nginx.conf`](deployments/images/proxy/nginx.conf). Each service needs a unique domain name.
- [ ] Forward all your domains to the correct IP address
- [ ] Change the passwords for each of the relevant services:
    - [Sawmill](deployments/images/proxy/README.md)
    - [The Library](.env)
    - [The Ark](.env)
- [ ] Update the Sawmill domain in the [env](.env) (Or leave it blank)

Once everything is completed, you may run the following commands to get it up and running:
```
docker-compose -f deployments/cloud.yml build
docker-compose -f deployments/cloud.yml up -d
```



### TODO
* Add Ark password and token values
* Test internal deployment
* Get Sangheili to point to the Ark properly
* Develop testing script for all the services as a healthcheck


