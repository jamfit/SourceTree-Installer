# SourceTree Installer

## What were we trying to solve?

At JAMF Software, our development teams use Stash for code repositories. The default GUI app we provide thought Self Service for checking out and working with those repos is Atalassian's SourceTree. As with other apps available in Self Service, SourceTree is small enough that we decided to script the install process to always pull the latest version and, at the same time, apply our org's license to register the app.

## What does it do?

The page you can download SourceTree from provides a direct link to the latest DMG. The script reads this page and pulls out the direct download link. Once downloaded, the DMG is mounted, the app is copied to the Applications directory, the license file is written into the currently logged in user's Library, and is opened for them to begin using.
With the on-demand app download and keeping the license plist contents in the script, the policy never needs to be updated unless there is a change with the download URL location or with our license.

## How to deploy this script in a policy

Upload the script to your JSS and create a policy. In the section that contains the text for the license plist, replace the values for the 'Name', 'Email', and 'Signature' keys with the ones for your org. This script has been tested against 10.9 and 10.10 clients.

## License

```
Copyright (c) 2015, JAMF Software, LLC. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this
      list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this
      list of conditions and the following disclaimer in the documentation and/or
      other materials provided with the distribution.
    * Neither the name of the JAMF Software, LLC nor the names of its contributors
      may be used to endorse or promote products derived from this software without
      specific prior written permission.
      
THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE,
LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```