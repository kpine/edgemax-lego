# edgemax-lego

Deploy Let's Encrypt SSL certificates on EdgeRouters with the [Lego](https://github.com/go-acme/lego) Let's Encrypt Client.

This uses the ACME DNS-01 challenge to confirm that you own the domain name, thus a DNS provider that is supported by the Lego client is required. See the list of [supported DNS providers](https://go-acme.github.io/lego/dns/) and their configuration settings.

This project supports and has only been tested on an ERLite-3 running EdgeOSv2.0.9-hotfix.2.

## Installation

### Download Lego Client

The Lego client is a single binary written in Go. It has support for numerious platforms. For the ERLite-3, I use the `linux_mips64_hardfloat` version. Other versions may work as well.

All related files are  stored in `/config/scripts/lego`. This example uses v4.4.0 which was the current version. See the [Lego Releases](https://github.com/go-acme/lego/releases) page for the latest release and download URLs.

```
$ mkdir -p /config/scripts/lego
$ cd /config/scripts/lego
$ curl -L -o - https://github.com/go-acme/lego/releases/download/v4.4.0/lego_v4.4.0_linux_mips_hardfloat.tar.gz | tar -xzf - lego
```

You can test the lego client with `./lego -h` and it should print help text if working properly.

### Download Scripts

Either clone this project into `/config/scripts/lego`, or download the [`renew.sh`](renew.sh) and [`deploy.sh`](deploy.sh) scripts individually to the same directory.

## Configuration

The renewal script loads an optional [`lego.cfg`](lego.cfg) file with some required configuration settings, plus the DNS provider settings. The file should be saved as `/config/scripts/lego/lego.cfg`. 

The settings can be exported as environment variables instead of using a configuration file. See the example file for required variables. The DNS provider settings must also be exported.

The file is the easiest way to use these scripts since the task scheduler does not support environment variables.

## Certificate Requests

The act of registering and creating  certificates is a distinct step from renewal, so we need to request the certificates the first time before setting up automatic renewals.

Before running any commands, considering testing the process first using the Let's Encrypt staging environment. The production server is rate limited and too many requests will use up the limits. To enable the staging server, set the `USE_STAGING` environment variable.

```
$ export USE_STAGING=1
```

Unset the variable when everything is confirmed working, and repeat the process to generate real certificates.

The commands must be run as root. Either login as root (`sudo su`), or use sudo. If using sudo, don't forget to preserve the environment variables (`sudo -E`) if any are set.

The renewal scripts takes an optional `run` argument that creates the certificates for the first time. This argument instructs the Lego client to create the certificates instead of renewing. This must be done one time for a domain prior to configuring renewals.

```
$ /config/scripts/lego/renew.sh run
```

Only when a certificate is newly created or renewed will Lego run the deploy script. The deploy script copies the certificate to the target installation directory and restarts the EdgeRouter UI so that the new certificate is loaded.

The certificate is saved as `/config/ssl/server.pem`.


## Router Certificate Configuration

Tell the EdgeRouter to use the certificate saved at `/config/ssl/server.pem`.

```
$ configure
# set service gui cert-file /config/ssl/server.pem
# commit
# save
```

The router should now be accessible at https://www.example.com (your domain) with a valid SSL certificate. Ensure that your DNS server resolves that domain to the router's IP address.

## Certificate Renewals

The Lego client will automatically renew certificates 30 days before they expire. Otherwise it does nothing. With this in mind, we can create a scheduled task to attempt a renewal every day to ensure the certificate is always valid.

```
$ configure
# set system task-scheduler task renew.acme executable path /config/scripts/lego/renew.sh
# set system task-scheduler task renew.acme interval 1d
# commit
# save
```

## Motivation

I was previously using an acme.sh-based deployment script that I can no longer find the source of. I was looking at [hungnguyenm/edgemax-acme](https://github.com/hungnguyenm/edgemax-acme), which has provided some inspiration, but I wanted to use Lego instead.