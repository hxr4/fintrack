# Phase 2 manual test on the phone

Use real values. Each step says what you should see.

## 1. Lock
1. Open Fintrack for the first time. You should see onboarding, not the lock.
2. After onboarding, swipe the app away from recents and open it again. The fingerprint or PIN prompt appears; cancel it. "Not unlocked. Try again." shows, and nothing behind it is visible.
3. Unlock. Home appears.
4. Open recents. The Fintrack preview is blank, and a screenshot is blocked.
5. Press Home, wait 10 seconds, and come back. There is no prompt.
6. Press Home, wait 40 seconds, and come back. The prompt appears.
7. Tap the lock icon at the top of Home. The app locks at once.

## 2. Full onboarding
1. Start. Enter this month's amount and the date it arrived, and keep anchor day 5.
2. Floors: 150, 1200, 750. Next.
3. Split: try changing a value so the total is not 100. Next should do nothing and the total line turns amber. Put it back to 100.
4. Money right now: enter your real bank balance and cash in hand, and 0 excluded.
5. Recurring costs: skip. Supplies: add one item (for example soap, 90, 45 days). Payments: leave card off.
6. Finish. Home shows "Day N of M, K left", the ring, and nine cards, including Goals with no plus button. There are no Bike fund or Recurring fund cards.

## 3. Logging
1. Tap "+40 Food". Within a moment the ring number drops by 40, the Food card drops by 40, and "Logged ₹40 in Food" shows with Undo.
2. Tap Undo. Both numbers go back.
3. Long-press "+100 Food". The add sheet opens with ₹100 and Food selected. Save.
4. Tap + on the Petrol card, type 250, keep UPI, and save. The Petrol card updates.
5. Open the add sheet again. Only Cash and UPI are shown. Turn on Settings > Card payments, go back, and open the add sheet again. Card now appears.
6. Type "60 tea" in the type-to-log bar and press done. A chip shows "₹60 · Food". Tap the chip, pick Outings, and save. Then type "60 tea" again: it now suggests Outings.
7. Swipe an entry away in Report > All entries. It disappears, with Undo.

## 4. Food at zero
Do this only if you are fine with the test entries staying in this month's data, or delete them afterwards from Report > All entries.
1. Tap + on Food and enter more than the Food card shows (for example 7000). Save.
2. A card at the top says "Moved ₹X into Food" and "Holding ₹Y for the coming weeks". The Food card shows about one week of floor, and the Outings and Try new cards show "held" amounts.
3. If it is before day 10 of the cycle, the card also says "Food ran out early this cycle" with Balance check and Family summary buttons (these say "arrives in a later update").
4. Tap Undo. The card disappears and Food goes back to negative.
5. Repeat step 1 and tap Got it. The card goes away and does not come back after reopening the app.
6. Delete the test entry from Report > All entries.

## 5. Restart
1. Note the ring amount and two card amounts.
2. Swipe Fintrack away from recents, open it, and unlock. The same numbers show.
3. Reboot the phone, open it, and unlock. The same numbers show.

## 6. Late night (optional, after midnight)
Between 00:00 and 04:00 the home screen is dimmed, a Night food stock card with a gentle line appears at the top, and the quick-add chips say "Night food".
