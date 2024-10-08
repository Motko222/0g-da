#!/bin/bash
                                                          
sudo journalctl -n 200 -u 0g-da-node.service -f --no-hostname -o cat
