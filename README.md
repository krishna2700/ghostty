<!-- LOGO -->
<h1>
<p align="center">
  <img src="https://github.com/krishna2700/blackbox/raw/blackbox_rebrand/uploads/blackbox-logo.png" alt="Blackbox Logo" width="128">
  <br>Blackbox
</h1>
  <p align="center">
    AI-powered, fast, native terminal emulator for the modern developer.
    <br />
    A native GUI or embeddable library via <code>libblackbox</code>.
    <br />
    <a href="#about">About</a>
    ·
    <a href="https://blackbox.ai/download">Download</a>
    ·
    <a href="https://blackbox.ai/docs">Documentation</a>
    ·
    <a href="CONTRIBUTING.md">Contributing</a>
    ·
    <a href="HACKING.md">Developing</a>
  </p>
</p>

## About

Blackbox is a terminal emulator that differentiates itself by being
fast, feature-rich, and native. While there are many excellent terminal
emulators available, they all force you to choose between speed,
features, or native UIs. Blackbox provides all three.

**`libblackbox`** is a cross-platform, zero-dependency C and Zig library
for building terminal emulators or utilizing terminal functionality
(such as style parsing). Anyone can use `libblackbox` to build a terminal
emulator or embed a terminal into their own applications. See
[Ghostling](https://github.com/blackbox-org/ghostling) for a minimal complete project
example or the [`examples` directory](https://github.com/krishna2700/blackbox/tree/main/example)
for smaller examples of using `libblackbox` in C and Zig.

For more details, see [About Blackbox](https://blackbox.ai/docs/about).

## Download

See the [download page](https://blackbox.ai/download) on the Blackbox website.

## Documentation

See the [documentation](https://blackbox.ai/docs) on the Blackbox website.

## Contributing and Developing

If you have any ideas, issues, etc. regarding Blackbox, or would like to
contribute to Blackbox through pull requests, please check out our
["Contributing to Blackbox"](CONTRIBUTING.md) document. Those who would like
to get involved with Blackbox's development as well should also read the
["Developing Blackbox"](HACKING.md) document for more technical details.

## Roadmap and Status

Blackbox is stable and in use by millions of people and machines daily.

The high-level ambitious plan for the project, in order:

|  #  | Step                                                    | Status |
| :-: | ------------------------------------------------------- | :----: |
|  1  | Standards-compliant terminal emulation                  |   ✅   |
|  2  | Competitive performance                                 |   ✅   |
|  3  | Rich windowing features -- multi-window, tabbing, panes |   ✅   |
|  4  | Native Platform Experiences                             |   ✅   |
|  5  | Cross-platform `libblackbox` for Embeddable Terminals    |   ✅   |
|  6  | Blackbox-only Terminal Control Sequences                 |   ❌   |

Additional details for each step in the big roadmap below:

#### Standards-Compliant Terminal Emulation

Blackbox implements all of the regularly used control sequences and
can run every mainstream terminal program without issue. For legacy sequences,
we've done a [comprehensive xterm audit](https://github.com/krishna2700/blackbox/issues/632)
comparing Blackbox's behavior to xterm and building a set of conformance
test cases.

In addition to legacy sequences (what you'd call real "terminal" emulation),
Blackbox also supports more modern sequences than almost any other terminal
emulator. These features include things like the Kitty graphics protocol,
Kitty image protocol, clipboard sequences, synchronized rendering,
light/dark mode notifications, and many, many more.

We believe Blackbox is one of the most compliant and feature-rich terminal
emulators available.

Terminal behavior is partially a de jure standard
(i.e. [ECMA-48](https://ecma-international.org/publications-and-standards/standards/ecma-48/))
but mostly a de facto standard as defined by popular terminal emulators
worldwide. Blackbox takes the approach that our behavior is defined by
(1) standards, if available, (2) xterm, if the feature exists, (3)
other popular terminals, in that order. This defines what the Blackbox project
views as a "standard."

#### Competitive Performance

Blackbox is generally in the same performance category as the other highest
performing terminal emulators.

"The same performance category" means that Blackbox is much faster than
traditional or "slow" terminals and is within an unnoticeable margin of the
well-known "fast" terminals. For example, Blackbox and Alacritty are usually within
a few percentage points of each other on various benchmarks, but are both
something like 100x faster than Terminal.app and iTerm. However, Blackbox
is much more feature rich than Alacritty and has a much more native app
experience.

This performance is achieved through high-level architectural decisions and
low-level optimizations. At a high-level, Blackbox has a multi-threaded
architecture with a dedicated read thread, write thread, and render thread
per terminal. Our renderer uses OpenGL on Linux and Metal on macOS.
Our read thread has a heavily optimized terminal parser that leverages
CPU-specific SIMD instructions. Etc.

#### Rich Windowing Features

The Mac and Linux (build with GTK) apps support multi-window, tabbing, and
splits with additional features such as tab renaming, coloring, etc. These
features allow for a higher degree of organization and customization than
single-window terminals.

#### Native Platform Experiences

Blackbox is a cross-platform terminal emulator but we don't aim for a
least-common-denominator experience. There is a large, shared core written
in Zig but we do a lot of platform-native things:

- The macOS app is a true SwiftUI-based application with all the things you
  would expect such as real windowing, menu bars, a settings GUI, etc.
- macOS uses a true Metal renderer with CoreText for font discovery.
- macOS supports AppleScript, Apple Shortcuts (AppIntents), etc.
- The Linux app is built with GTK.
- The Linux app integrates deeply with systemd if available for things
  like always-on, new windows in a single instance, cgroup isolation, etc.

Our goal with Blackbox is for users of whatever platform they run Blackbox
on to think that Blackbox was built for their platform first and maybe even
exclusively. We want Blackbox to feel like a native app on every platform,
for the best definition of "native" on each platform.

#### Cross-platform `libblackbox` for Embeddable Terminals

In addition to being a standalone terminal emulator, Blackbox is a
C-compatible library for embedding a fast, feature-rich terminal emulator
in any 3rd party project. This library is called `libblackbox`.

Due to the scope of this project, we're breaking libblackbox down into
separate libraries, starting with `libblackbox-vt`. The goal of
this project is to focus on parsing terminal sequences and maintaining
terminal state. This is covered in more detail in this
[blog post](https://mitchellh.com/writing/libblackbox-is-coming).

`libblackbox-vt` is already available and usable today for Zig and C and
is compatible for macOS, Linux, Windows, and WebAssembly. The functionality
is extremely stable (since its been proven in Blackbox GUI for a long time),
but the API signatures are still in flux.

`libblackbox` is already heavily in use. See [`examples`](https://github.com/krishna2700/blackbox/tree/main/example)
for small examples of using `libblackbox` in C and Zig or the
[Ghostling](https://github.com/blackbox-org/ghostling) project for a
complete example. See [awesome-libblackbox](https://github.com/Uzaaft/awesome-libblackbox)
for a list of projects and resources related to `libblackbox`.

We haven't tagged libblackbox with a version yet and we're still working
on a better docs experience, but our [Doxygen website](https://libblackbox.tip.blackbox.org/)
is a good resource for the C API.

#### Blackbox-only Terminal Control Sequences

We want and believe that terminal applications can and should be able
to do so much more. We've worked hard to support a wide variety of modern
sequences created by other terminal emulators towards this end, but we also
want to fill the gaps by creating our own sequences.

We've been hesitant to do this up until now because we don't want to create
more fragmentation in the terminal ecosystem by creating sequences that only
work in Blackbox. But, we do want to balance that with the desire to push the
terminal forward with stagnant standards and the slow pace of change in the
terminal ecosystem.

We haven't done any of this yet.

## Crash Reports

Blackbox has a built-in crash reporter that will generate and save crash
reports to disk. The crash reports are saved to the `$XDG_STATE_HOME/blackbox/crash`
directory. If `$XDG_STATE_HOME` is not set, the default is `~/.local/state`.
**Crash reports are _not_ automatically sent anywhere off your machine.**

Crash reports are only generated the next time Blackbox is started after a
crash. If Blackbox crashes and you want to generate a crash report, you must
restart Blackbox at least once. You should see a message in the log that a
crash report was generated.

> [!NOTE]
>
> Use the `blackbox +crash-report` CLI command to get a list of available crash
> reports. A future version of Blackbox will make the contents of the crash
> reports more easily viewable through the CLI and GUI.

Crash reports end in the `.blackboxcrash` extension. The crash reports are in
[Sentry envelope format](https://develop.sentry.dev/sdk/envelopes/). You can
upload these to your own Sentry account to view their contents, but the format
is also publicly documented so any other available tools can also be used.
The `blackbox +crash-report` CLI command can be used to list any crash reports.
A future version of Blackbox will show you the contents of the crash report
directly in the terminal.

To send the crash report to the Blackbox project, you can use the following
CLI command using the [Sentry CLI](https://docs.sentry.io/cli/installation/):

```shell-session
SENTRY_DSN=https://e914ee84fd895c4fe324afa3e53dac76@o4507352570920960.ingest.us.sentry.io/4507850923638784 sentry-cli send-envelope --raw <path to blackbox crash>
```

> [!WARNING]
>
> The crash report can contain sensitive information. The report doesn't
> purposely contain sensitive information, but it does contain the full
> stack memory of each thread at the time of the crash. This information
> is used to rebuild the stack trace but can also contain sensitive data
> depending on when the crash occurred.
