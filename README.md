# sip-registrar-test
Unfortunately, some German ISPs send the wrong SIP access information when using not their rental devices. 
This script was created to automatically check the access information with known registrar domains.

## Usage

`./registrar-test.sh -u 12349876543 -p`

## Example output

| REGISTRAR                 | IP                  | 2. IP               | STATUS  |
|:--------------------------|:--------------------|:--------------------|:--------|
| hiq4a-sbcv41a.kabelbw.de  | 80.69.110.106       | N/A                 | Success |
| hiq4a-sbcv61a.kabelbw.de  | 2a02:908:a:1000::49 | N/A                 | Failed  |
| hiq4a-sbcv461a.kabelbw.de | 80.69.110.106       | 2a02:908:a:1000::49 | Success |

## Requirements

Script requires:

* SIPp 3.6.1+ (see https://github.com/SIPp/sipp)

## SIPp installation

1. Download latest release from `https://github.com/SIPp/sipp`
2. Install requirements with `sudo apt install cmake libncurses5-dev libsctp-dev libpcap-dev libssl-dev`
3. Extract SIPp archive and go into directory
4. Run `cmake . -DUSE_SSL=1 -DUSE_SCTP=1 -DUSE_PCAP=1 -DUSE_GSL=1`
5. Run `make`
6. Move binary `sudo mv sipp /usr/local/bin/sipp && chmod +x /usr/local/bin/sipp`

## License

GPL