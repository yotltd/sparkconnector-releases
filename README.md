# sparkconnector-releases

Public distribution point for **SPARK Collector**, the on-premise network discovery agent used by [SPARK Dock](https://sparkdock.io). This repo holds only built binaries, container images, and the appliance disk image published by CI on each release -- there is no source code here. The collector's source stays in a private repository; this repo exists so a collector, installer, or appliance can pull updates anonymously, with no credentials stored on a client site.

## This is not a standalone tool

The collector does nothing by itself. It requires an active SPARK Dock account and a running SPARK Dock instance to enrol against -- without one, there is nothing to link it to and no dashboard to see the discovered network data in. If you found this repo without already using SPARK Dock, start at https://sparkdock.io.

## What's here

- `sparkcollector-linux-amd64` / `sparkcollector-linux-arm64` -- static Linux binaries.
- The Docker image, published to `ghcr.io/yotltd/sparkconnector` (`:stable`, `:latest`, and per-version tags).
- `spark-collector-appliance-<version>.img.gz` -- a bootable disk image that turns a spare mini-PC or NUC into a dedicated collector appliance: DHCP on boot, a setup web UI on `:8787`, no OS installer, no console login.
- `checksums.txt` / `appliance-checksums-<version>.txt` -- sha256 sums for everything above.
- `latest.json` -- the update manifest the self-update path reads.

## Getting started

Set up a SPARK Dock account first, then generate an enrolment code for a new collector from inside it. Which binary or image to use, and how to configure and link it, is covered by SPARK Dock's own collector setup flow, not by this repo.
