# IDEAS

Proposals that are outside the brief. None of these will be built without a yes.

## I01. Capture UPI debits from bank SMS or UPI app notifications
UPI hiding spending is the main known problem. A notification listener (or SMS read permission) could detect "debited Rs 40" messages and offer a one-tap confirm card with the amount prefilled. Everything stays on the device. The cost is a sensitive permission and per-bank message parsing. This would use the existing `notification` transaction source.
