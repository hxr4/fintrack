# Backup step and Phase 4 manual test on the phone

This update installs over 0.3.0 and keeps your data. The database upgrades from version 2 to 3 on first open.

## 1. Upgrade
1. Open the app and unlock. Everything from before is still there: the ring, cards, supplies, fuel fills and balance check history.

## 2. Backup
1. Profile (avatar at the top of Home) > Settings > Backup and restore. You see the notice that uninstalling erases everything, and "No backup yet".
2. Create backup, then enter a passphrase twice (8 or more characters). It takes a few seconds, then "Saved to Download/fintrack-backup-....ftbackup" appears. Last backup shows today.
3. Open the Files app > Downloads. The file is there.
4. Tap Share and send it somewhere off the phone (Drive or a chat to yourself).

## 3. Restore (optional)
1. Log a small test spend, then restore the backup you just made from the same screen. Confirm. You see "Backup restored", and the test spend is gone.
2. Try a wrong passphrase. You see "The passphrase is wrong, or the file has been changed", and nothing changes.
3. A full clean-install test (uninstall, install, then "Restore from a backup" on the welcome page) is the real acceptance test. Do it only once you have the backup file safely off the phone.

## 4. Balance check fixes
1. Plan > Balance check shows the line about bank plus cash minus excluded money and logging a new deposit first.
2. On the day the next month's money arrives, a check before logging it shows "This looks like this month's money. Log it first?" with a Money arrived button.

## 5. Profile and gear
1. Tap the avatar on Home. Profile shows six gear cards with images. The bike shows your Striking Green photo.
2. Tap your avatar and pick a photo. Edit your name and "about you".
3. Open each gear item and fill in the purchase date, price paid, seller and warranty end. Cost per day and the warranty countdown appear.
4. Add a bill photo with the camera. Returning from the camera does not lock the app.
5. The bike card shows the odometer from your last fuel fill and the next service line. Open it: set insurance and PUC dates, and check they also show in Plan > Supplies and bike > Bike.
6. Add a new gear item, then remove it.
7. Create a new backup after adding photos.
