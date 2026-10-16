# Amphetamine Enhancer (maintained fork)

This fork keeps Amphetamine Enhancer working on Apple silicon and current macOS. The original repo has not been updated since 2020. All credit for Amphetamine and the Enhancer goes to William Gustafson ([x74353](https://github.com/x74353)).

## What changed in this fork

- New enhancement: Closed-Display Mode Watchdog. On Apple silicon laptops, Amphetamine's closed-display mode can turn off while a session is still running, and then the Mac sleeps as soon as the lid closes. This happens after plugging in or unplugging power, or after starting a new session without ending the old one ([#46](https://github.com/x74353/Amphetamine-Enhancer/issues/46)). The watchdog checks every 10 seconds. If the current session had closed-display mode on and it turns off, the watchdog turns it back on. Sessions that allow sleep with the lid closed are left alone.
- The watchdog also replaces the old Closed-Display Mode Fail-Safe. If Amphetamine quits or crashes with closed-display mode on, it turns sleep back on. The old fail-safe read Amphetamine's settings directly, and macOS no longer allows that.
- Apple silicon laptops now get the closed-display enhancements. The old check looked for "Book" in the model name, and Apple silicon laptops report names like `Mac17,3`.
- Universal build (Apple silicon and Intel). The Intel-only Sparkle and LetsMove frameworks are removed, so there are no in-app updates from the original feed.

## Requirements

- Amphetamine 5.x from the Mac App Store
- [Amphetamine Power Protect](https://x74353.github.io/Amphetamine-Power-Protect/), which the watchdog uses to run `pmset -a disablesleep` without a password

## Build

Open `Xcode Project/Amphetamine Enhancer.xcodeproj` and build the Release scheme, or run:

```
cd "Xcode Project"
xcodebuild -project "Amphetamine Enhancer.xcodeproj" -scheme "Amphetamine Enhancer" -configuration Release ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO build
```

Move the app to /Applications, open it, select Closed-Display Mode Watchdog and click Install. The watchdog logs each action to `~/Library/Logs/amphetamine-enhancer-cdmWatchdog.log`.

## Known limitation

The watchdog cannot read Amphetamine's settings, so it learns whether a session uses closed-display mode by watching for it to turn on. If you tick "Allow system sleep when display is closed" in the middle of a session, end that session and start a new one so the watchdog does not turn closed-display mode back on.

---

# Welcome to Amphetamine Enhancer

<B>NOTE: Amphetamine Enhancer requires Amphetamine 5.0. Visit the Mac App Store to upgrade.</B>

Want to skip the introduction and just download Amphetamine Enhancer? [Click here.](https://github.com/x74353/Amphetamine-Enhancer/raw/master/Releases/Current/Amphetamine%20Enhancer.dmg)

<B> What is Amphetamine Enhancer? </B> <BR>
Amphetamine Enhancer is a helper application that enhances a couple of Amphetamine's features. In its 1.0 release, Amphetamine Enhancer adds the following abilities to Amphetamine:
 
• Adds a fail-safe for the closed-display mode feature found in Amphetamine 5.0+ <BR>
• Gives Amphetamine 5.0+ the ability to use all running processes with Triggers and app-based sessions 
 
More enhancements may be added in the future.
 
<B> Why is a Separate App Needed? </B> <BR>
Amphetamine itself is a sandboxed app. All apps distributed through the Mac App Store are sandboxed (it's a requirement). Sandboxing severely limits what an app can do on your Mac. This is usually a good thing as it helps prevent malware and viruses from taking over your Mac or stealing your information. 

Unfortunately, sandboxing also means that certain actions/tasks can't be completed by the sandboxed app. Getting a list of every app and process running on your Mac is something a sandboxed app can't do. That's where Amphetamine Enhancer comes in. Since Amphetamine Enhancer is not distributed through the App Store, it's not sandboxed and isn't limited in the same ways Amphetamine is.

<B> Why Not Un-Sandbox Amphetamine and Distribute it Outside the App Store? </B> <BR>
Amphetamine is a popular app and is downloaded hundreds to thousands of times every day. For better or worse, the App Store is an easy way to distribute apps. As an independent developer, with little to no income from my apps, I don't have a desire or the financial resources to pay out-of-pocket for the bandwidth and web hosting fees that would be incurred by distributing Amphetamine outside of the App Store. I also don't have an advertising budget either. Amphetamine has become popular via word-of-mouth and it is consistently ranked high in the Mac App Store  (which gives it visibility to those browsing the App Store charts). This popularity caused Apple to feature Amphetamine in an App Store Story. It's unlikely all of this would have happened without the App Store as a distribution channel.

Beyond that, the majority of people who use Amphetamine have no need for the advanced features that Amphetamine Enhancer provides. There's also a ton of people who would never visit Github and download a DMG or installer for Amphetamine. Losing the ease-of-distribution and App Store ranking visibility would only hurt Amphetamine's user-base growth.

<B> Can I Trust Amphetamine Enhancer Not to Steal My Info and Hack My Mac? </B> <BR>
Amphetamine Enhancer is open-source. I've done this so you can feel comfortable that it is not stealing your information, infecting your Mac, or doing anything else naughty. Apple has also notarized the downloadable release(s) of Amphetamine Enhancer. This means Apple has scanned Amphetamine Enhancer for known malware and other vunerablities.

<B> What License Applies to Amphetamine Enhancer? </B> <BR>
This project is licensed under the terms of the MIT license.
 
<B> Where Do I Download Amphetamine Enhancer? </B> <BR>
[Right here](https://github.com/x74353/Amphetamine-Enhancer/raw/master/Releases/Current/Amphetamine%20Enhancer.dmg) on Github.
