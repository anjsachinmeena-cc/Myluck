# Myluck — starter project

This is an early Flutter UI prototype for a short-video app. It includes a demo feed, likes, and a Discover page with links that open other platforms. It is **not** a finished social network: account login, video uploading/hosting, comments, moderation, recommendations, and backend services are not implemented.

## Build an Android APK using GitHub Actions (phone-friendly)

1. Create a repository on https://github.com/new. Name it `myluck`, choose **Public** or **Private**, and create it.
2. On the repository page, tap **Add file → Upload files**.
3. Extract this ZIP on your phone first. Upload the *contents* of the extracted folder (including `lib`, `pubspec.yaml`, `README.md`, and the hidden `.github` folder). If your phone's file picker hides `.github`, use the GitHub website's **Add file → Create new file** and create `.github/workflows/build-android.yml`, then paste the workflow content from this ZIP.
4. Commit the uploaded files to the `main` branch.
5. Open the repository's **Actions** tab. Select **Build Myluck Android APK**. If it hasn't started automatically, tap **Run workflow → Run workflow**.
6. Open the completed workflow run and find **Artifacts** near the bottom. Download `myluck-release-apk`, then extract the downloaded artifact ZIP to get `app-release.apk`.
7. Install the APK on your Android phone only after the build succeeds. Android may ask you to allow installs from the browser/files app; only allow it for this APK if you trust the source repository you uploaded.

GitHub's mobile layout can vary. Do not upload your GitHub password, SMS codes, or other secrets into repository files.
