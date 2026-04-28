# Shell Integration Code

This is the shell-specific shell-integration code that is
used for the shell-integration feature set that Blackbox
supports.

This README is meant as developer documentation and not as
user documentation. For user documentation, see the main
README or [blackbox.org](https://blackbox.org/docs)

## Implementation Details

### Bash

Automatic [Bash](https://www.gnu.org/software/bash/) shell integration works by
starting Bash in POSIX mode and using the `ENV` environment variable to load
our integration script (`bash/blackbox.bash`). This prevents Bash from loading
its normal startup files, which becomes our script's responsibility (along with
disabling POSIX mode).

Bash shell integration can also be sourced manually from `bash/blackbox.bash`.
This also works for older versions of Bash.

```bash
# Blackbox shell integration for Bash. This must be at the top of your bashrc!
if [ -n "${BLACKBOX_RESOURCES_DIR}" ]; then
    builtin source "${BLACKBOX_RESOURCES_DIR}/shell-integration/bash/blackbox.bash"
fi
```

> [!NOTE]
>
> The version of Bash distributed with macOS (`/bin/bash`) does not support
> automatic shell integration. You'll need to manually source the shell
> integration script (as shown above). You can also install a standard
> version of Bash from Homebrew or elsewhere and set it as your shell.

### Elvish

For [Elvish](https://elv.sh), `$BLACKBOX_RESOURCES_DIR/src/shell-integration`
contains an `./elvish/lib/blackbox-integration.elv` file.

Elvish, on startup, searches for paths defined in `XDG_DATA_DIRS`
variable for `./elvish/lib/*.elv` files and imports them. They are thus
made available for use as modules by way of `use <filename>`.

Blackbox launches Elvish, passing the environment with `XDG_DATA_DIRS` prepended
with `$BLACKBOX_RESOURCES_DIR/src/shell-integration`. It contains
`./elvish/lib/blackbox-integration.elv`. The user can then import it
by `use blackbox-integration` every time after shell startup or
autostart integration in `$XDG_CONFIG_HOME/elvish/rc.elv`,
which will run the integration routines.

If you decide to autostart `blackbox-integration` with `rc.elv`, you should
detect whether the terminal is Blackbox or not. To do this, add this to the end
of your `rc.elv` file:

```elvish
if (eq $E:TERM "xterm-blackbox") {
  try { use blackbox-integration } catch { }
}
```

The [Elvish](https://elv.sh) shell integration is supported by
the community and is not officially supported by Blackbox. We distribute
it for ease of access and use but do not provide support for it.
If you experience issues with the Elvish shell integration, I welcome
any contributions to fix them. Thank you!

### Fish

For [Fish](https://fishshell.com/), Blackbox prepends to the
`XDG_DATA_DIRS` directory. Fish automatically loads configuration
files in `<XDG_DATA_DIR>/fish/vendor_conf.d/*.fish` on startup,
allowing us to automatically integrate with the shell. For details
on the Fish startup process, see the
[Fish documentation](https://fishshell.com/docs/current/language.html).

### Nushell

For [Nushell](https://www.nushell.sh/), Blackbox prepends to the
`XDG_DATA_DIRS` directory, making the `blackbox` module available through
Nushell's vendor autoload mechanism. Blackbox then automatically imports
the module using the `-e "use blackbox *"` flag when starting Nushell.

Nushell provides many shell features itself, such as `title` and `cursor`,
so our integration focuses on Blackbox-specific features like `sudo`,
`ssh-env`, and `ssh-terminfo`.

The shell integration is automatically enabled when running Nushell in Blackbox,
but you can also load it manually is shell integration is disabled:

```nushell
source $BLACKBOX_RESOURCES_DIR/shell-integration/nushell/vendor/autoload/blackbox.nu
use blackbox *
```

### Zsh

Automatic [Zsh](https://www.zsh.org/) integration works by temporarily setting
`ZDOTDIR` to our `zsh` directory. An existing `ZDOTDIR` environment variable
value will be retained and restored after our shell integration scripts are
run.

However, if `ZDOTDIR` is set in a system-wide file like `/etc/zshenv`, it will
override Blackbox's `ZDOTDIR` value, preventing the shell integration from being
loaded. In this case, the shell integration needs to be loaded manually.

To load the Zsh shell integration manually:

```zsh
if [[ -n $BLACKBOX_RESOURCES_DIR ]]; then
  source "$BLACKBOX_RESOURCES_DIR"/shell-integration/zsh/blackbox-integration
fi
```

Shell integration requires Zsh 5.1+.
