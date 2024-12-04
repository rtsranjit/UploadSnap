
**Approach and Methodology for "UploadSnap" iOS App**

**Overview**

**"UploadSnap"** is an iOS app that lets users capture, store, and upload images with real-time progress tracking. It’s built using **SwiftUI**, **Realm** for local storage, and **UserNotifications** for alerts when uploads are done.

**Architecture**

**Model:** The CapturedImage stores image details and is saved in Realm for easy retrieval.

**ViewModel:** Handles image uploads and updates the UI with progress and statuses.

**View:** Displays images and upload statuses using SwiftUI views.
Tools Used

SwiftUI for building a modern, responsive UI.
Realm to save and manage images locally.
UserNotifications to notify users when uploads finish.
Challenges and Solutions

**Tracking Upload Progress:** Displayed smoothly using SwiftUI's circle progress bar.

**Image Upload Resumption:** Planned feature for future updates using URLSession.

**Background Uploads:** Uploads continue even when the app is in the background, with progress and status saved and notifications sent.
Key Decisions

**MVVM Architecture** keeps the code organized and scalable.

**Realm** simplifies managing image data.
Notifications keep users informed, even in the background.

**Conclusion**

"UploadSnap" combines simple, effective design with powerful tools to deliver a seamless image capture and upload experience.
