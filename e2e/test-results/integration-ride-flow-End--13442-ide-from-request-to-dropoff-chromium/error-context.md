# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: integration\ride-flow.spec.ts >> End-to-End Ride Flow >> should complete a ride from request to dropoff
- Location: tests\integration\ride-flow.spec.ts:5:7

# Error details

```
Error: expect(locator).toBeAttached() failed

Locator: locator('text=Accept').first()
Expected: attached
Timeout: 20000ms
Error: element(s) not found

Call log:
  - Expect "toBeAttached" with timeout 20000ms
  - waiting for locator('text=Accept').first()

```

# Page snapshot

```yaml
- generic [ref=e4]:
  - generic:
    - generic:
      - generic:
        - generic:
          - button [ref=e5]
          - generic:
            - group:
              - button [ref=e6]
              - button "Manila, Metro Manila, Philippines" [ref=e7]
              - generic:
                - generic: Ninoy Aquino International Airport, Pasay, Metro Manila, Philippines
              - button [ref=e8]
              - generic:
                - generic: Choose your ride
              - generic:
                - generic: Moto Fastest through traffic ₱65 None available
              - generic:
                - generic: Car Comfortable, up to 4 seats ₱120 None available
              - generic:
                - generic: Tricycle Budget-friendly local rides ₱50 None available
              - button "Requesting…" [active] [ref=e9]
```

# Test source

```ts
  49  |     await driverPage.getByRole("textbox").first().click();
  50  |     await driverPage.getByRole("textbox").first().fill("driver@example.com");
  51  |     await driverPage.getByRole("textbox").last().click();
  52  |     await driverPage.getByRole("textbox").last().fill("password123");
  53  |     await driverSignInButton.click({ force: true });
  54  | 
  55  |     const onlineToggle = driverPage.locator("text=Start shift").first();
  56  |     await expect(onlineToggle).toBeAttached({ timeout: 30000 });
  57  |     await onlineToggle.click({ force: true });
  58  | 
  59  |     // 3. Passenger logs in and requests a ride
  60  |     await passengerPage.goto("http://localhost:3000/?enable-semantics=true&sakai-e2e=true");
  61  |     await passengerPage.waitForSelector("flt-semantics", {
  62  |       state: "attached",
  63  |       timeout: 30000,
  64  |     });
  65  | 
  66  |     // Handle onboarding for passenger
  67  |     const passengerSkip = passengerPage.locator("text=Skip").first();
  68  |     const passengerSignIn = passengerPage.locator("text=Sign in").first();
  69  |     await Promise.race([
  70  |       passengerSkip
  71  |         .waitFor({ state: "visible", timeout: 20000 })
  72  |         .catch(() => {}),
  73  |       passengerSignIn
  74  |         .waitFor({ state: "visible", timeout: 20000 })
  75  |         .catch(() => {}),
  76  |     ]);
  77  |     if (await passengerSkip.isVisible()) {
  78  |       await passengerSkip.click({ force: true });
  79  |     }
  80  | 
  81  |     // Wait for login screen to be ready
  82  |     await expect(passengerPage.locator("text=Sign in").first()).toBeAttached({
  83  |       timeout: 20000,
  84  |     });
  85  | 
  86  |     await passengerPage.getByRole("textbox").first().click();
  87  |     await passengerPage
  88  |       .getByRole("textbox")
  89  |       .first()
  90  |       .fill("passenger@example.com");
  91  |     await passengerPage.getByRole("textbox").last().click();
  92  |     await passengerPage.getByRole("textbox").last().fill("password123");
  93  |     await passengerPage.locator("text=Sign in").first().click({ force: true });
  94  | 
  95  |     const saanKayoText = passengerPage.locator("text=Where to?").first();
  96  |     await expect(saanKayoText).toBeAttached({ timeout: 30000 });
  97  | 
  98  |     const passengerPickup = passengerPage.locator("text=Tap to set pickup").first();
  99  |     if (await passengerPickup.isVisible().catch(() => false)) {
  100 |       await passengerPickup.click({ force: true });
  101 |       const pickupInput = passengerPage.getByRole("textbox").last();
  102 |       await expect(pickupInput).toBeAttached({ timeout: 10000 });
  103 |       await pickupInput.fill("Manila");
  104 |       const pickupConfirm = passengerPage.locator('text=Confirm "Manila"').first();
  105 |       const pickupSuggestion = passengerPage
  106 |         .getByRole("button", { name: /Manila/i })
  107 |         .first();
  108 |       await Promise.race([
  109 |         pickupSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  110 |         pickupConfirm.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  111 |       ]);
  112 |       if (await pickupConfirm.isVisible().catch(() => false)) {
  113 |         await pickupConfirm.click({ force: true });
  114 |       } else {
  115 |         await pickupSuggestion.click({ force: true });
  116 |       }
  117 |       await expect(passengerPage.locator("text=Where to?").first()).toBeAttached({
  118 |         timeout: 10000,
  119 |       });
  120 |     }
  121 | 
  122 |     const whereToButtonRole = passengerPage.getByRole("button", { name: "Where to?" });
  123 |     await whereToButtonRole.click({ force: true });
  124 |     await passengerPage.waitForTimeout(1000);
  125 |     const whereToInput = passengerPage.getByRole("textbox").last();
  126 |     await expect(whereToInput).toBeAttached({ timeout: 15000 });
  127 |     await whereToInput.fill("Airport");
  128 |     const confirmButton = passengerPage.locator('text=Confirm "Airport"').first();
  129 |     const firstSuggestion = passengerPage
  130 |       .getByRole("button", { name: /Airport/i })
  131 |       .first();
  132 |     await Promise.race([
  133 |       firstSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  134 |       confirmButton.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  135 |     ]);
  136 |     if (await confirmButton.isVisible().catch(() => false)) {
  137 |       await confirmButton.click({ force: true });
  138 |     } else {
  139 |       await firstSuggestion.click({ force: true });
  140 |     }
  141 | 
  142 |     const requestRideButton = passengerPage.locator("text=Request").first();
  143 |     await expect(requestRideButton).toBeAttached({ timeout: 15000 });
  144 |     await requestRideButton.click({ force: true });
  145 | 
  146 |     // 4. Driver receives and accepts the ride
  147 |     // Wait for the incoming ride modal/notification on the driver app
  148 |     const acceptButton = driverPage.locator("text=Accept").first();
> 149 |     await expect(acceptButton).toBeAttached({ timeout: 20000 }); // give backend time to match
      |                                ^ Error: expect(locator).toBeAttached() failed
  150 |     await acceptButton.click({ force: true });
  151 | 
  152 |     // 5. Verify Passenger sees driver is en route
  153 |     await expect(
  154 |       passengerPage
  155 |         .locator("text=Driver is on the way")
  156 |         .or(passengerPage.locator("text=Arriving in"))
  157 |         .first(),
  158 |     ).toBeAttached({ timeout: 15000 });
  159 | 
  160 |     // 6. Complete the ride lifecycle
  161 |     // Driver taps 'Arrived'
  162 |     const arrivedButton = driverPage.locator("text=Arrived").first();
  163 |     await expect(arrivedButton).toBeAttached({ timeout: 10000 });
  164 |     await arrivedButton.click({ force: true });
  165 |     const forceArrive = driverPage.locator("text=Force Anyway").first();
  166 |     if (await forceArrive.isVisible({ timeout: 1000 }).catch(() => false)) {
  167 |       await forceArrive.click({ force: true });
  168 |     }
  169 | 
  170 |     // Driver taps 'Start Ride'
  171 |     const startRideButton = driverPage
  172 |       .locator("text=Start Ride")
  173 |       .or(driverPage.locator("text=Resume Active Ride"))
  174 |       .first();
  175 |     await expect(startRideButton).toBeAttached({ timeout: 10000 });
  176 |     await startRideButton.click({ force: true });
  177 | 
  178 |     // Driver taps 'Complete Ride' or 'Dropoff'
  179 |     const completeRideButton = driverPage
  180 |       .locator("text=Complete Ride")
  181 |       .or(driverPage.locator("text=Dropoff"))
  182 |       .first();
  183 |     await expect(completeRideButton).toBeAttached({ timeout: 10000 });
  184 |     await completeRideButton.click({ force: true });
  185 |     const forceComplete = driverPage.locator("text=Force Anyway").first();
  186 |     if (await forceComplete.isVisible({ timeout: 1000 }).catch(() => false)) {
  187 |       await forceComplete.click({ force: true });
  188 |     }
  189 | 
  190 |     // 7. Verify Passenger reaches completion/rating screen
  191 |     await expect(
  192 |       passengerPage
  193 |         .locator("text=Ride completed")
  194 |         .or(passengerPage.locator("text=Rate your driver"))
  195 |         .first(),
  196 |     ).toBeAttached({ timeout: 15000 });
  197 | 
  198 |     // Cleanup
  199 |     await passengerContext.close();
  200 |     await driverContext.close();
  201 |   });
  202 | });
  203 | 
```