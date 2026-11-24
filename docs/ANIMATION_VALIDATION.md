# Coordinated screen handoffs

## Mechanism

A ScreenHandoff value notifier carries paint progress from the outgoing clock to both mounted routes. HandoffScope identifies incoming and outgoing consumers. CustomTransitionPage is non-opaque, maintains route state, and returns the child unchanged: it performs no whole-page fade or slide.

Splash pushes the transparent destination at four seconds. Its existing five-second clock drives shared progress from zero to one over the final second. The original Splash widget, skyline painter and logo image remain mounted while buildings and pyramids fade/shrink at staggered intervals, followed by the Nile, sun and logo. Incoming background, illustration, title, description and controls consume that same progress. Only when exit progress reaches one does go_router remove Splash from the stack. Stable destination page keys preserve the incoming screen during this cleanup. A large skipped frame reaching the endpoint also commits correctly.

Onboarding persists completion, locks input and pushes the requested Login or Create Account route. After the first shared frame it runs a 1,000 ms local exit clock. Illustration, title, description, indicators and buttons fade/slide out through separate intervals. Auth uses that same clock for its background, navy header, logo, title and individual fields. Primary action, divider, Google action and language selector enter last. The existing AuthShell, header geometry and form-mode animation remain mounted on Login/Create Account changes. Popping Auth reverses the shared clock to restore the original Onboarding screen and unlock input; completion persistence is reused for a subsequent attempt.

There is no destination preview, copied screen or logo, timer delay, or whole-page opacity animation. The existing sun-position clipping reveal and vertical PageController gesture transforms are retained. Reduced motion settles the handoff immediately, including changes to that setting during an entrance.

## Why the previous mechanism failed

The previous route helper faded an entire destination Scaffold. Its opaque background covered outgoing content before element exits could be seen. Splash's painter retained constant opacity and had no per-element exit at all. Splash also navigated with go before the visual exit finished, leaving its lifetime to route removal. Separate initial content controllers were independent of outgoing motion. Timing changes alone could not make that implementation perform a coordinated handoff.

The replacement explicitly retains the source via push, shares progress, animates background separately from content, and commits Splash navigation only at the exit endpoint. Onboarding's inherited entrance scope also explicitly notifies descendants when shared progress changes; its settled local controller does not need to tick.

## Validation in this environment

- Dart formatting succeeds. All modified Dart production files remain below 400 lines.
- Added shared-progress widget coverage for source fade and destination stagger without advancing an independent entrance controller.
- Expanded production-router tests for source retention, destination element identity through Splash cleanup, intermediate content opacity, delayed Auth actions, duplicate taps, both Auth destinations, pop/re-entry, shell identity, localization and Forgot Password language-control absence.
- Existing sun clipping, reduced-motion and entrance rebuild tests remain; timing expectations were updated.
- Flutter analyze, Flutter test and debug APK build were attempted through the installed Flutter tool. Each stopped before execution because the SDK cache file bin/cache/libimobiledevice.stamp is outside the writable workspace. Dart formatting also reports the configured Pub lints cache as unreadable.
- The configured Android SDK/platform-tools path is inaccessible. No fresh APK, physical Android 11 playback, emulator playback, successful analysis, or passing test run is claimed. Visual acceptance still needs verification in an environment with SDK and device access.
