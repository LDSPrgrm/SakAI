# Instructions

- Following Playwright test failed.
- Explain why, be concise, respect Playwright best practices.
- Provide a snippet of code with the fix, if possible.

# Test info

- Name: passenger\core-flow.spec.ts >> Passenger Core Flow >> should allow a user to sign in and request a ride
- Location: tests\passenger\core-flow.spec.ts:49:7

# Error details

```
Error: expect(locator).toBeAttached() failed

Locator: locator('text=Finding your driver').first()
Expected: attached
Timeout: 15000ms
Error: element(s) not found

Call log:
  - Expect "toBeAttached" with timeout 15000ms
  - waiting for locator('text=Finding your driver').first()

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
  36  |     }
  37  | 
  38  |     // Wait for login screen to be visible
  39  |     await expect(page.locator("text=Sign in").first()).toBeAttached({
  40  |       timeout: 20000,
  41  |     });
  42  |   });
  43  | 
  44  |   test("should display login screen", async ({ page }) => {
  45  |     // Check if the sign in button is visible
  46  |     await expect(page.locator("text=Sign in").first()).toBeAttached();
  47  |   });
  48  | 
  49  |   test("should allow a user to sign in and request a ride", async ({
  50  |     page,
  51  |   }) => {
  52  |     // 1. Log In
  53  |     const emailInput = page.getByRole("textbox").first();
  54  |     const passwordInput = page.getByRole("textbox").last();
  55  |     const signInButton = page.locator("text=Sign in").first();
  56  | 
  57  |     // Fill in the login form
  58  |     await emailInput.click();
  59  |     await emailInput.fill("passenger@example.com");
  60  |     await passwordInput.click();
  61  |     await passwordInput.fill("password123");
  62  | 
  63  |     await signInButton.click({ force: true });
  64  | 
  65  |     // 2. Wait for home screen — the home/map tab has NO AppBar, so "SakAI · Home"
  66  |     //    is never in the DOM. Confirm we're on home by the "Where to?" button.
  67  |     const whereToButton = page.locator("text=Where to?").first();
  68  |     await expect(whereToButton).toBeAttached({ timeout: 15000 });
  69  | 
  70  |     const pickupButton = page.locator("text=Tap to set pickup").first();
  71  |     if (await pickupButton.isVisible().catch(() => false)) {
  72  |       await pickupButton.click({ force: true });
  73  |       const pickupTextbox = page.getByRole("textbox").last();
  74  |       await expect(pickupTextbox).toBeAttached({ timeout: 10000 });
  75  |       await pickupTextbox.fill("Manila");
  76  |       const pickupSuggestion = page
  77  |         .getByRole("button", { name: /Manila/i })
  78  |         .first();
  79  |       const pickupConfirm = page.locator('text=Confirm "Manila"').first();
  80  |       await Promise.race([
  81  |         pickupSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  82  |         pickupConfirm.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  83  |       ]);
  84  |       if (await pickupConfirm.isVisible().catch(() => false)) {
  85  |         await pickupConfirm.click({ force: true });
  86  |       } else {
  87  |         await pickupSuggestion.click({ force: true });
  88  |       }
  89  |       await expect(page.locator("text=Where to?").first()).toBeAttached({
  90  |         timeout: 10000,
  91  |       });
  92  |     }
  93  | 
  94  |     // 3. Open destination search by tapping "Where to?"
  95  |     const whereToButtonRole = page.getByRole("button", { name: "Where to?" });
  96  |     await whereToButtonRole.waitFor({ state: "visible", timeout: 10000 });
  97  |     await whereToButtonRole.click();
  98  |     await page.waitForTimeout(800);
  99  | 
  100 |     // The bottom sheet expands and a search textbox appears
  101 |     const searchTextbox = page.getByRole("textbox").last();
  102 |     await expect(searchTextbox).toBeAttached({ timeout: 15000 });
  103 |     await searchTextbox.fill("Airport");
  104 | 
  105 |     // 4. Handle destination selection — two possible paths:
  106 |     //    a) Geocoding returns suggestions → click the first suggestion button
  107 |     //    b) No results found → a "Confirm "Airport"" button appears
  108 |     const confirmButton = page.locator('text=Confirm "Airport"').first();
  109 |     const firstSuggestion = page
  110 |       .getByRole("button", { name: /Airport/i })
  111 |       .first();
  112 | 
  113 |     await Promise.race([
  114 |       firstSuggestion.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  115 |       confirmButton.waitFor({ state: "attached", timeout: 10000 }).catch(() => {}),
  116 |     ]);
  117 | 
  118 |     if (await confirmButton.isVisible().catch(() => false)) {
  119 |       await confirmButton.click({ force: true });
  120 |     } else {
  121 |       await firstSuggestion.click({ force: true });
  122 |     }
  123 | 
  124 |     // 5. Wait for the ride options panel.
  125 |     //    Button label is "Request Ride" or "Request {VehicleType}" — match via substring.
  126 |     const requestRideButton = page
  127 |       .getByRole("button", { name: /^Request/ })
  128 |       .first();
  129 |     await expect(requestRideButton).toBeAttached({ timeout: 15000 });
  130 |     await expect(requestRideButton).toBeEnabled({ timeout: 10000 });
  131 |     await requestRideButton.click({ force: true });
  132 | 
  133 |     // 6. Confirm navigation to the waiting / driver-finding screen
  134 |     await expect(
  135 |       page.locator("text=Finding your driver").first()
> 136 |     ).toBeAttached({ timeout: 15000 });
      |       ^ Error: expect(locator).toBeAttached() failed
  137 |   });
  138 | });
  139 | 
```