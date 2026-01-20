#!/bin/sh
# Define variables
APPLDUALSINK=DualAppleDisplay
APPLDUAL_L=alsa_output.usb-Apple_Inc._Display_Audio_27711502-00.analog-stereo
APPLDUAL_R=alsa_output.usb-Apple_Inc._Display_Audio_27711702-00.analog-stereo

# Function to create virtual sink
create_virtual_sink() {
    pw-cli create-node adapter '{ factory.name=support.null-audio-sink node.name=DualAppleDisplay object.linger=true audio.channels=2 audio.format=FL+FR media.class=Audio/Sink }'
}

# Function to link virtual sink to physical sinks
link_sinks() {
    /usr/bin/pw-link $APPLDUALSINK:monitor_FL $APPLDUAL_L:playback_FL
    /usr/bin/pw-link $APPLDUALSINK:monitor_FL $APPLDUAL_L:playback_FR
    /usr/bin/pw-link $APPLDUALSINK:monitor_FR $APPLDUAL_R:playback_FL
    /usr/bin/pw-link $APPLDUALSINK:monitor_FR $APPLDUAL_R:playback_FR
}

# Wait for PipeWire to initialize
sleep 5

# Create virtual sink and link it
create_virtual_sink
sleep 1  # Small delay to ensure sink is created
link_sinks
