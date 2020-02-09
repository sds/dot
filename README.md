# Dot

Dot is a framework for managing your user configuration files and environment
(usually referred to as "dotfiles").

Dot supports a powerful plugin system allowing authors to write plugins that
work with multiple different shells and operating systems.

## Installation

You'll need a POSIX-compliant shell (e.g. `sh`) to perform the initial
installation, but otherwise any of the following shells are supported:

* Bash
* Zsh
* Fish

The easiest way to get started is to clone
[my personal dot files](https://github.com/sds/.files) and clear out the
`plugins` directory so you start with a clean slate.

```bash
git clone --recurse-submodules https://github.com/sds/.files ~/.files
cd ~/.files
rm -rf plugins/*
bin/install
```

Dot's architecture allows it to support any kind of shell. If you don't see a
shell you use here, feel free to add support for it in a pull request!

Installing Dot will create a `.files` directory in your current user's home
directory. Inside that directory will be a `plugins` directory which you
can fill with as many subdirectories for each plugin you write. These
directories can be other Git repositories, for example.

Also in the `.files` directory is a `framework` directory which is this repository
(stored as a Git submodule). This allows you to easily update to newer versions
of the framework but keep it otherwise separated from your personal plugins.

Depending on the shell you use, your various shell startup files
(`~/.bashrc`, `~/.zshrc`, etc.) will be symlinked into a corresponding file
in the `framework` directory. This allows Dot to link into your shells
startup sequence to load the relevant code from your plugins.

* [Bash Startup Files](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html)
* [Zsh Startup Files](http://zsh.sourceforge.net/Intro/intro_3.html)
* [Fish Startup Files](http://fishshell.com/docs/current/tutorial.html#tut_startup)

## Plugin structure

A plugin is simply a directory in your `$DOT_HOME/plugins` directory containing
appropriate scripts and configuration. Plugins can contain configuration for
multiple shells and operating systems.

The following directories within the plugin directory have special meaning to Dot:

Directory                 | Purpose
--------------------------|-----------------------------------------------------
`bin`                     | Executables to add to `PATH` after installing plugin
`env`                     | Environment variables to set when loading plugin (regardless of shell context)
`env/login`               | Environment variables to set when initializing a login shell
`env/interactive`         | Environment variables to set when initializing an interactive shell
`env/setup`               | Environment variables to set during both install/uninstall
`env/setup/install`       | Environment variables to set during install
`env/setup/uninstall`     | Environment variables to set during uninstall
`lib`                     | Scripts to source when loading plugin (regardless of shell context)
`lib/login`               | Scripts to source when initializing a login shell
`lib/logout`              | Scripts to source when exiting a login shell
`lib/interactive`         | Scripts to source when initializing an interactive shell
`libexec`                 | Support executables to always add to `PATH` when loading plugin
`libexec/setup`           | Support executables to add to `PATH` during both install/uninstall
`libexec/setup/install`   | Support executables to add to `PATH` during install
`libexec/setup/uninstall` | Support executables to add to `PATH` during uninstall
`setup`                   | Executables to execute during install/uninstall
`setup/install`           | Executables to execute during install
`setup/uninstall`         | Executables to execute during uninstall

The following files within the plugin directory have special meaning to Dot:

File                 | Purpose
---------------------|-----------------------------------------------------------------
`dependencies`       | List of plugins that must be loaded _before_ this plugin is loaded.
`platforms`          | List of operating systems this plugin supports.

The `dependencies` file is especially useful if you want to have plugins
expose helper functions or environment variables that are used by other
plugins. Ensuring that those plugins are loaded (and their
functions/environment variables set) before other plugins are run allow
you to support better separation of responsibility.

The `platforms` file is useful if a plugin is operating system-specific.
For example, if a plugin only works on macOS, you should add a `platforms`
file to the plugin containing the line `mac`.

### Aliases, functions, and executables

Most shells have the concept of aliases and functions, so it can be a bit
confusing when you should use one over the other. This section aims to
provide clear guidelines about use cases for each type and how they compare
to standard executables.

#### Aliases

Aliases should be thought of as simple shortcuts, e.g. setting `g` = `git`
for making it easier to execute common commands in your shell.

You should use an alias when you want the auto-completions for the aliased
command to continue work.

#### Functions

Functions are shell helpers that can modify environment variables in your
shell or perform other useful things specific to your shell.

#### Executables

If the command you're thinking of isn't a shortcut (i.e. alias) or setting
environment variables in your actual shell, you should use an executable.
This doesn't need to be a compiled binary, but can be a script with
executable permissions and a [shebang line][Shebang] at the top, e.g.

```bash
cat > my-executable <<EOF
#!/usr/bin/env sh
echo "My very own executable!"
EOF
chmod +x my-executable
```

The advantage of using executables is that they are isolated and aren't
loaded until you attempt to execute them, reducing the time it takes
for your shell to start up.

## Shell contexts

Important to the use of Dot is understanding the different contexts in which
a shell can run. Some quick definitions:

* **Login shell**:
  A shell which is typically spawned when you first login to a system via
  the `login` command (e.g. when you connect to a host via `ssh` or open
  a terminal on your machine for the first time).

* **Interactive shell**:
  A shell whose standard input stream is connected to a console/TTY, and thus
  is able to receive input from a user.

These definitions are not mutually exclusive--a shell can be both a login
shell _and_ an interactive shell, one of the two, or neither!

Here are same examples for the `bash` shell (your shell's behavior may be different):

Command                       | Login         | Interactive
------------------------------|:-------------:|:----------:
`-bash` †                     |  ✅            | ✅
`bash -l`                     |  ✅            | ✅
`bash -i`                     |               | ✅
`bash -li`                    |  ✅            | ✅
`bash -c "some-command"`      |               |
`bash -lc "some-command"`     |  ✅            |
`bash -ic "some-command"`     |               | ✅
`bash -lic "some-command"`    |  ✅            | ✅

† *Starting a shell with a leading `-` is done via the
[`login`](https://linux.die.net/man/1/login) command*


## Writing a Plugin

Writing your own plugin with Dot is designed to be easy. To start, you need
to identify what you want your plugin to do.

  * Does it install files in your home directory?
  * Does it set any environment variables?
  * Does it declare any aliases or functions for use in your shell?

If you're installing any sort of files or repository, you'll need to add a
script to your plugin's `setup` directory and then use Dot's various helpers
(e.g. `dot::symlink`) to install the files.

## Motivations

Dot was motivated by the desire to:

* Save setup time on new systems

* Provide a flexible framework for organizing a large number of configuration
  files

* Allow easy switching between shells when pair programming (for example
  if one pair prefers a different shell) without breaking all of your
  configuration

* Learn more about the idiosyncrasies of various shells

## Frequently Asked Questions

* **How is Dot different from other config management systems? (Ansible/Chef/etc.)**
  Dot tries to carve out a niche specifically for configuring a
  personal/development machine for a single user. However, at its core it's
  accomplishing similar goals to full-blown config management systems.

  If you need the additional bells and whistles provided by those tools, you
  should use them. However, state of the art for these tools constantly changes
  and is hard to keep up with. Shell languages on the other hand, are
  relatively static, so code you write for Dot will likely serve you longer.

* **Why is my favorite shell not supported?**
  Support for additional shells is a pull request away. If your shell is
  POSIX-compatible it might be easier than you think, as many of the
  routines used by Dot are written in POSIX-compatible shell script.

  Check out the `shells` directory in `lib`/`libexec` to see the code required
  to support each shell.

## Etymology

Dot comes from the fact that it was originally designed to manage user 'dot'
files, and is a tribute to [Dot Matrix][DotMatrix] of [ReBoot][ReBoot] fame.

## License

Dot is released under the terms of the [Apache 2.0 license](LICENSE).

[DotMatrix]: http://reboot.wikia.com/wiki/Dot_Matrix
[ReBoot]: http://en.wikipedia.org/wiki/ReBoot
[Shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)
