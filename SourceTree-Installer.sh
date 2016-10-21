#!/bin/bash

policy="SourceTree"
loggertag="system-log-tag" # JAMF IT uses the tag "jamfsw-it-logs"
tempDir="/Library/Application Support/JAMF/tmp"

# This logging function writes messages to both the STDOUT
# for the JSS log as well as into the local system.log
log() {
echo "$1"
/usr/bin/logger -t "$loggertag: $policy" "$1"
}

# Scrape the current download URL from the landing page for SourceTree downloads
downloadURL=`/usr/bin/curl -s https://www.sourcetreeapp.com/ | /usr/bin/awk -F'"' '{print $120}'`
log "SourceTree download URL: $downloadURL"

# Check for the expected size of the downloaded Zipped File
webfilesize=$(/usr/bin/curl $downloadURL -ILs | /usr/bin/tr -d '\r' | /usr/bin/awk '/Content-Length:/ {print $2}')
log "The expected size of the downloaded file is $webfilesize"

#Downloading the file to the temp directory
/usr/bin/curl $downloadURL -o "$tempDir/outfile.zip"
if [ $? -ne 0 ]; then
    log "curl error code $?: The SoureTree Zip did not successfully download"
    exit 1
fi

# Check the size of the downloaded Zip
dlfilesize=$(/usr/bin/cksum "$tempDir/outfile.zip" | /usr/bin/awk '{print $2}')
log "The size of the downloaded file is $dlfilesize"

# Compare the expected size against the downloaded size
if [[ $webfilesize -ne $dlfilesize ]]; then
    log "The file did not download properly"
    exit 1
fi

#If SourceTree is already installed, uninstall it
if [ -e /Applications/SourceTree.app ]; then
    /bin/rm -rf /Applications/SourceTree.app
    log "Deleted an existing copy of SourceTree.app"
fi

#Unzipping SourceTree
unzip "$tempDir/outfile.zip" -d "$tempDir"

#Copying SourceTree.app to Applications
log "Copying SourceTree.app to Applications"
/bin/cp -a "$tempDir/SourceTree.app" /Applications/
if [ $? -ne 0 ]; then
    log "cp error code $?: SourceTree.app did not successfully copy"
    exit 1
fi

# The SourceTree license
# Replace the values for the 'Name', 'Email' and 'Signature' keys with your own!
read -d '' license <<"EOF"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Name</key>
    <string>Your Org</string>
    <key>Email</key>
    <string>adminaccount@yourorg.com</string>
    <key>Product</key>
    <string>SourceTree</string>
    <key>Signature</key>
    <data>--Your base64 encoded license string goes here--</data>
</dict>
</plist>
EOF

# Get the logged in user's username
userName=$(/bin/ls -l /dev/console | /usr/bin/awk '{print $3}')
log "The logged in user is: $userName"

# Get the logged in user's home directory
userHome=$(/usr/bin/dscl . read "/Users/$userName" | /usr/bin/awk '/NFSHomeDirectory:/ {print $2}')
log "The user home directory is: $userHome"

log "Writing the SourceTree license file"
# Create the SourceTree Application Support directory
/bin/mkdir -m 755 "$userHome/Library/Application Support/SourceTree"

# Write the SourceTree license file
echo "$license" > "$userHome/Library/Application Support/SourceTree/sourcetree.license"
/bin/chmod 644 "$userHome/Library/Application Support/SourceTree/sourcetree.license"
/usr/sbin/chown -R $userName "$userHome/Library/Application Support/SourceTree"

log "Opening SourceTree.app"
/usr/bin/su "$userName" -c "/usr/bin/open /Applications/SourceTree.app"

# Run a recon to update the JSS inventory
log "Running Recon."
/usr/local/bin/jamf recon || log "jamf error code $?: There was an error running Recon"

exit 0
